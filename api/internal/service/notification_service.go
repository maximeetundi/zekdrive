package service

import (
	"context"
	"encoding/json"
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/database"
)

type NotificationPayload struct {
	UserID    uuid.UUID              `json:"user_id"`
	Title     string                 `json:"title"`
	Body      string                 `json:"body"`
	Data      map[string]interface{} `json:"data,omitempty"`
	Timestamp int64                  `json:"timestamp"`
}

type NotificationService interface {
	SendNotification(ctx context.Context, userID uuid.UUID, title, body string, data map[string]interface{}) error
}

type notificationService struct {
	redis *database.RedisClient
}

func NewNotificationService(redis *database.RedisClient) NotificationService {
	return &notificationService{redis: redis}
}

func (s *notificationService) SendNotification(ctx context.Context, userID uuid.UUID, title, body string, data map[string]interface{}) error {
	payload := NotificationPayload{
		UserID:    userID,
		Title:     title,
		Body:      body,
		Data:      data,
		Timestamp: time.Now().Unix(),
	}

	bytes, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	// Log notification locally
	log.Printf("[Notification] User: %s | Title: %s | Body: %s", userID, title, body)

	// Publish notifications to Redis pub/sub
	return s.redis.Publish(ctx, "notifications:"+userID.String(), bytes).Err()
}
