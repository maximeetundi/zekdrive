package handler

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"log"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/websocket/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/domain"
	"github.com/zekdrive/api/internal/service"
	ws "github.com/zekdrive/api/internal/websocket"
)

type WSHandler struct {
	hub         *ws.Hub
	authService service.AuthService
	driverRepo  domain.DriverRepository
}

func NewWSHandler(hub *ws.Hub, authService service.AuthService, driverRepo domain.DriverRepository) *WSHandler {
	return &WSHandler{
		hub:         hub,
		authService: authService,
		driverRepo:  driverRepo,
	}
}

func (h *WSHandler) Upgrade() fiber.Handler {
	return func(c *fiber.Ctx) error {
		if websocket.IsWebSocketUpgrade(c) {
			tokenStr := c.Query("token")
			if tokenStr == "" {
				return fiber.ErrUnauthorized
			}

			// Validate token
			token, err := h.authService.ValidateToken(tokenStr, false)
			if err != nil || !token.Valid {
				log.Printf("WS connection rejected: invalid token: %v", err)
				return fiber.ErrUnauthorized
			}

			claims, ok := token.Claims.(jwt.MapClaims)
			if !ok {
				return fiber.ErrUnauthorized
			}

			userIDStr, err := claims.GetSubject()
			if err != nil || userIDStr == "" {
				return fiber.ErrUnauthorized
			}

			userID, err := uuid.Parse(userIDStr)
			if err != nil {
				return fiber.ErrUnauthorized
			}

			c.Locals("userID", userID)
			return c.Next()
		}

		return fiber.ErrUpgradeRequired
	}
}

func (h *WSHandler) Handler() fiber.Handler {
	return websocket.New(func(c *websocket.Conn) {
		userIDLoc := c.Locals("userID")
		userID, ok := userIDLoc.(uuid.UUID)
		if !ok {
			c.Close()
			return
		}

		client := ws.NewClient(h.hub, userID, c, h.driverRepo)
		h.hub.Register <- client

		// Spin up write pump in separate goroutine, read pump blocks the current thread
		go client.WritePump()
		client.ReadPump()
	})
}

func (h *WSHandler) PusherAuth(c *fiber.Ctx) error {
	tokenStr := c.Get("Authorization")
	if tokenStr == "" {
		tokenStr = c.Query("token")
	}
	if len(tokenStr) > 7 && tokenStr[:7] == "Bearer " {
		tokenStr = tokenStr[7:]
	}

	if tokenStr == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	// Validate token
	token, err := h.authService.ValidateToken(tokenStr, false)
	if err != nil || !token.Valid {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "invalid token"})
	}

	// Read socket_id and channel_name from body
	socketID := c.FormValue("socket_id")
	channelName := c.FormValue("channel_name")

	if socketID == "" || channelName == "" {
		// Try parsing from JSON body
		type AuthRequest struct {
			SocketID    string `json:"socket_id"`
			ChannelName string `json:"channel_name"`
		}
		var req AuthRequest
		if err := c.BodyParser(&req); err == nil {
			if socketID == "" {
				socketID = req.SocketID
			}
			if channelName == "" {
				channelName = req.ChannelName
			}
		}
	}

	if socketID == "" || channelName == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "socket_id and channel_name are required"})
	}

	// Generate Pusher compatible signature
	// key is "drivemond", secret is "drivemond"
	secret := "drivemond"
	sig := generatePusherSignature(socketID, channelName, secret)

	return c.JSON(fiber.Map{
		"auth": "drivemond:" + sig,
	})
}

func (h *WSHandler) PusherHandler() fiber.Handler {
	return websocket.New(func(c *websocket.Conn) {
		key := c.Params("key")
		if key != "drivemond" {
			log.Printf("Pusher WS connection rejected: invalid key: %s", key)
			c.Close()
			return
		}

		socketID := uuid.New().String()
		client := ws.NewPusherClient(h.hub, socketID, c)
		h.hub.PusherRegister <- client

		// Immediately send connection established event
		connEstablished := map[string]interface{}{
			"event": "pusher:connection_established",
			"data":  "{\"socket_id\":\"" + socketID + "\",\"activity_timeout\":120}",
		}
		connEstablishedBytes, _ := json.Marshal(connEstablished)
		_ = c.WriteMessage(websocket.TextMessage, connEstablishedBytes)

		// Spin up pumps
		go client.WritePump()
		client.ReadPump()
	})
}

func generatePusherSignature(socketID, channelName, secret string) string {
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write([]byte(socketID + ":" + channelName))
	return hex.EncodeToString(mac.Sum(nil))
}
