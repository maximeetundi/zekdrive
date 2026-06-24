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
	clients           map[uuid.UUID]*Client
	Register          chan *Client
	Unregister        chan *Client
	pusherClients     map[string]*PusherClient
	pusherSubscribers map[string]map[string]*PusherClient
	PusherRegister    chan *PusherClient
	PusherUnregister  chan *PusherClient
	mu                sync.RWMutex
	redis             *database.RedisClient
}

func NewHub(redis *database.RedisClient) *Hub {
	return &Hub{
		clients:           make(map[uuid.UUID]*Client),
		Register:          make(chan *Client),
		Unregister:        make(chan *Client),
		pusherClients:     make(map[string]*PusherClient),
		pusherSubscribers: make(map[string]map[string]*PusherClient),
		PusherRegister:    make(chan *PusherClient),
		PusherUnregister:  make(chan *PusherClient),
		redis:             redis,
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

		case client := <-h.PusherRegister:
			h.mu.Lock()
			h.pusherClients[client.SocketID] = client
			h.mu.Unlock()
			log.Printf("Pusher client registered: SocketID %s", client.SocketID)

		case client := <-h.PusherUnregister:
			h.mu.Lock()
			if _, ok := h.pusherClients[client.SocketID]; ok {
				delete(h.pusherClients, client.SocketID)
				close(client.send)
				// Remove client from all subscribers
				for chanName, subs := range h.pusherSubscribers {
					delete(subs, client.SocketID)
					if len(subs) == 0 {
						delete(h.pusherSubscribers, chanName)
					}
				}
				log.Printf("Pusher client unregistered: SocketID %s", client.SocketID)
			}
			h.mu.Unlock()
		}
	}
}

func (h *Hub) SendToUser(userID uuid.UUID, message []byte) {
	h.mu.RLock()
	cells := h.clients[userID]
	h.mu.RUnlock()
	if cells != nil {
		cells.send <- message
	}
}

func (h *Hub) listenToRedis() {
	ctx := context.Background()
	// Subscribe to notifications, driver locations, and pusher channels
	patternPubSub := h.redis.PSubscribe(ctx, "notifications:*", "driver:location:*", "pusher:channel:*")
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

	// 3. If it's a pusher broadcast
	// Channel format: pusher:channel:<pusher_channel_name>
	if len(channel) > 15 && channel[:15] == "pusher:channel:" {
		pusherChan := channel[15:]
		h.BroadcastToPusherChannel(pusherChan, []byte(payload))
	}
}

func (h *Hub) PusherSubscribe(channel string, client *PusherClient) {
	h.mu.Lock()
	defer h.mu.Unlock()
	if h.pusherSubscribers[channel] == nil {
		h.pusherSubscribers[channel] = make(map[string]*PusherClient)
	}
	h.pusherSubscribers[channel][client.SocketID] = client
}

func (h *Hub) PusherUnsubscribe(channel string, client *PusherClient) {
	h.mu.Lock()
	defer h.mu.Unlock()
	if h.pusherSubscribers[channel] != nil {
		delete(h.pusherSubscribers[channel], client.SocketID)
		if len(h.pusherSubscribers[channel]) == 0 {
			delete(h.pusherSubscribers, channel)
		}
	}
}

func (h *Hub) BroadcastToPusherChannel(channel string, payload []byte) {
	h.mu.RLock()
	defer h.mu.RUnlock()
	subs, exists := h.pusherSubscribers[channel]
	if !exists {
		return
	}

	for _, client := range subs {
		select {
		case client.send <- payload:
		default:
			// client send channel full, skip
		}
	}
}
