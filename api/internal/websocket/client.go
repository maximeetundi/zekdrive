package websocket

import (
	"context"
	"encoding/json"
	"log"
	"sync"
	"time"

	"github.com/gofiber/websocket/v2"
	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/domain"
)

const (
	writeWait      = 10 * time.Second
	pongWait       = 60 * time.Second
	pingPeriod     = (pongWait * 9) / 10
	maxMessageSize = 512
)

type WSMessage struct {
	Type    string                 `json:"type"`
	Payload map[string]interface{} `json:"payload"`
}

type Client struct {
	Hub           *Hub
	UserID        uuid.UUID
	Conn          *websocket.Conn
	send          chan []byte
	driverService domain.DriverRepository // To directly save driver location if sent over WebSocket

	subscribedDrivers map[string]bool
	subsMu            sync.RWMutex
}

func NewClient(hub *Hub, userID uuid.UUID, conn *websocket.Conn, ds domain.DriverRepository) *Client {
	return &Client{
		Hub:               hub,
		UserID:            userID,
		Conn:              conn,
		send:              make(chan []byte, 256),
		driverService:     ds,
		subscribedDrivers: make(map[string]bool),
	}
}

func (c *Client) ReadPump() {
	defer func() {
		c.Hub.Unregister <- c
		c.Conn.Close()
	}()

	c.Conn.SetReadLimit(maxMessageSize)
	c.Conn.SetReadDeadline(time.Now().Add(pongWait))
	c.Conn.SetPongHandler(func(string) error {
		c.Conn.SetReadDeadline(time.Now().Add(pongWait))
		return nil
	})

	for {
		_, message, err := c.Conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("WebSocket error: %v", err)
			}
			break
		}

		var wsMsg WSMessage
		if err := json.Unmarshal(message, &wsMsg); err != nil {
			log.Printf("Invalid WebSocket JSON message: %v", err)
			continue
		}

		c.handleWSMessage(wsMsg)
	}
}

func (c *Client) WritePump() {
	ticker := time.NewTicker(pingPeriod)
	defer func() {
		ticker.Stop()
		c.Conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.send:
			c.Conn.SetWriteDeadline(time.Now().Add(writeWait))
			if !ok {
				c.Conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			w, err := c.Conn.NextWriter(websocket.TextMessage)
			if err != nil {
				return
			}
			w.Write(message)

			// Add queued chat messages to the current websocket message.
			n := len(c.send)
			for i := 0; i < n; i++ {
				w.Write([]byte{'\n'})
				w.Write(<-c.send)
			}

			if err := w.Close(); err != nil {
				return
			}

		case <-ticker.C:
			c.Conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.Conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}

func (c *Client) handleWSMessage(msg WSMessage) {
	switch msg.Type {
	case "subscribe_driver":
		driverIDStr, ok := msg.Payload["driver_id"].(string)
		if ok {
			c.subsMu.Lock()
			c.subscribedDrivers[driverIDStr] = true
			c.subsMu.Unlock()
			log.Printf("User %s subscribed to driver location: %s", c.UserID, driverIDStr)
		}

	case "unsubscribe_driver":
		driverIDStr, ok := msg.Payload["driver_id"].(string)
		if ok {
			c.subsMu.Lock()
			delete(c.subscribedDrivers, driverIDStr)
			c.subsMu.Unlock()
			log.Printf("User %s unsubscribed from driver location: %s", c.UserID, driverIDStr)
		}

	case "update_location":
		latVal, okLat := msg.Payload["latitude"].(float64)
		lngVal, okLng := msg.Payload["longitude"].(float64)
		driverIDStr, okDriver := msg.Payload["driver_id"].(string)

		if okLat && okLng && okDriver {
			driverID, err := uuid.Parse(driverIDStr)
			if err == nil {
				// Update location in database
				// Using background context
				c.driverService.UpdateLocation(context.Background(), driverID, latVal, lngVal)
			}
		}
	}
}
