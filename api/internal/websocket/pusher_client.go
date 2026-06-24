package websocket

import (
	"encoding/json"
	"log"
	"sync"
	"time"

	"github.com/gofiber/websocket/v2"
)

type PusherClient struct {
	Hub      *Hub
	SocketID string
	Conn     *websocket.Conn
	send     chan []byte
	channels map[string]bool
	mu       sync.RWMutex
}

func NewPusherClient(hub *Hub, socketID string, conn *websocket.Conn) *PusherClient {
	return &PusherClient{
		Hub:      hub,
		SocketID: socketID,
		Conn:     conn,
		send:     make(chan []byte, 256),
		channels: make(map[string]bool),
	}
}

type PusherWSMessage struct {
	Event   string      `json:"event"`
	Channel string      `json:"channel,omitempty"`
	Data    interface{} `json:"data"`
}

func (c *PusherClient) ReadPump() {
	defer func() {
		c.Hub.PusherUnregister <- c
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
			break
		}

		var msg PusherWSMessage
		if err := json.Unmarshal(message, &msg); err != nil {
			log.Printf("Pusher client invalid JSON message: %v", err)
			continue
		}

		c.handleMessage(msg)
	}
}

func (c *PusherClient) WritePump() {
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
			if err := c.Conn.WriteMessage(websocket.TextMessage, message); err != nil {
				return
			}
		case <-ticker.C:
			c.Conn.SetWriteDeadline(time.Now().Add(writeWait))
			// Pusher expects a ping event from client, but we can also ping it
			pingMsg := []byte(`{"event":"pusher:ping","data":{}}`)
			if err := c.Conn.WriteMessage(websocket.TextMessage, pingMsg); err != nil {
				return
			}
		}
	}
}

func (c *PusherClient) handleMessage(msg PusherWSMessage) {
	switch msg.Event {
	case "pusher:ping":
		// Respond with pong
		pongMsg := []byte(`{"event":"pusher:pong","data":{}}`)
		c.send <- pongMsg

	case "pusher:subscribe":
		// Subscribe to channel
		var dataMap map[string]interface{}
		switch d := msg.Data.(type) {
		case map[string]interface{}:
			dataMap = d
		}

		if dataMap != nil {
			channelName, _ := dataMap["channel"].(string)
			if channelName != "" {
				c.mu.Lock()
				c.channels[channelName] = true
				c.mu.Unlock()

				// Add to Hub map
				c.Hub.PusherSubscribe(channelName, c)

				// Respond subscription succeeded
				subSucceeded := map[string]interface{}{
					"event":   "pusher_internal:subscription_succeeded",
					"channel": channelName,
					"data":    "{}",
				}
				subBytes, _ := json.Marshal(subSucceeded)
				c.send <- subBytes
				log.Printf("Pusher client %s subscribed to channel %s", c.SocketID, channelName)
			}
		}

	case "pusher:unsubscribe":
		// Unsubscribe from channel
		var dataMap map[string]interface{}
		switch d := msg.Data.(type) {
		case map[string]interface{}:
			dataMap = d
		}

		if dataMap != nil {
			channelName, _ := dataMap["channel"].(string)
			if channelName != "" {
				c.mu.Lock()
				delete(c.channels, channelName)
				c.mu.Unlock()

				c.Hub.PusherUnsubscribe(channelName, c)
				log.Printf("Pusher client %s unsubscribed from channel %s", c.SocketID, channelName)
			}
		}
	}
}
