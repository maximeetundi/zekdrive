package handler

import (
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
