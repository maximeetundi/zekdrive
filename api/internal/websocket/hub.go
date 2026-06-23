package websocket

import (
	"context"
	"encoding/json"
	"log"
	"sync"

	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/database"
)

type Hub struct {
	clients    map[uuid.UUID]*Client
	Register   chan *Client
	Unregister chan *Client
	mu         sync.RWMutex
	redis      *database.RedisClient
}

func NewHub(redis *database.RedisClient) *Hub {
	return &Hub{
		clients:    make(map[uuid.UUID]*Client),
		Register:   make(chan *Client),
		Unregister: make(chan *Client),
		redis:      redis,
	}
}

func (h *Hub) Run() {
	// Start Redis subscriber listener in the background
	go h.listenToRedis()

	for {
		select {
		case client := <-h.Register:
			h.mu.Lock()
			h.clients[client.UserID] = client
			h.mu.Unlock()
			log.Printf("WebSocket client registered: User %s", client.UserID)

		case client := <-h.Unregister:
			h.mu.Lock()
			if _, ok := h.clients[client.UserID]; ok {
				delete(h.clients, client.UserID)
				close(client.send)
				log.Printf("WebSocket client unregistered: User %s", client.UserID)
			}
			h.mu.Unlock()
		}
	}
}

func (h *Hub) SendToUser(userID uuid.UUID, message []byte) {
	h.mu.RLock()
	defer h.mu.RUnlock()
	if client, ok := h.clients[userID]; ok {
		client.send <- message
	}
}

func (h *Hub) listenToRedis() {
	ctx := context.Background()
	// Subscribe to a pattern for notifications as well or handle them in the channel loop
	// For notifications, we can subscribe to "notifications:*" pattern
	patternPubSub := h.redis.PSubscribe(ctx, "notifications:*", "driver:location:*")
	defer patternPubSub.Close()

	ch := patternPubSub.Channel()

	log.Println("WebSocket Hub successfully subscribed to Redis Pub/Sub channels")

	for msg := range ch {
		// Distribute messages based on topic
		h.handleRedisMessage(msg.Channel, msg.Payload)
	}
}

func (h *Hub) handleRedisMessage(channel string, payload string) {
	var data map[string]interface{}
	if err := json.Unmarshal([]byte(payload), &data); err != nil {
		log.Printf("Error unmarshaling Redis pub/sub payload: %v", err)
		return
	}

	// 1. If it's a user notification
	// Channel format: notifications:<user_id>
	if len(channel) > 14 && channel[:14] == "notifications:" {
		userIDStr := channel[14:]
		userID, err := uuid.Parse(userIDStr)
		if err == nil {
			// Deliver to the connected WebSocket client
			h.SendToUser(userID, []byte(payload))
		}
	}

	// 2. If it's a driver location update
	// Channel format: driver:location:<driver_id>
	if len(channel) > 16 && channel[:16] == "driver:location:" {
		// Broadcast location to any rider observing this driver
		h.mu.RLock()
		defer h.mu.RUnlock()
		for _, client := range h.clients {
			// If client has subscribed to this driver's location updates
			client.subsMu.RLock()
			subscribed := client.subscribedDrivers[channel[16:]]
			client.subsMu.RUnlock()

			if subscribed {
				client.send <- []byte(payload)
			}
		}
	}
}
