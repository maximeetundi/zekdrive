package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type Setting struct {
	ID             uuid.UUID   `json:"id" db:"id"`
	KeyName        string      `json:"key_name" db:"key_name"`
	LiveValues     interface{} `json:"live_values" db:"live_values"`
	TestValues     interface{} `json:"test_values" db:"test_values"`
	SettingsType   string      `json:"settings_type" db:"settings_type"`
	Mode           string      `json:"mode" db:"mode"`
	IsActive       bool        `json:"is_active" db:"is_active"`
	AdditionalData interface{} `json:"additional_data" db:"additional_data"`
	CreatedAt      time.Time   `json:"created_at" db:"created_at"`
	UpdatedAt      time.Time   `json:"updated_at" db:"updated_at"`
}

type SettingRepository interface {
	Upsert(ctx context.Context, s *Setting) error
	GetByKey(ctx context.Context, keyName string) (*Setting, error)
	ListByType(ctx context.Context, settingsType string) ([]Setting, error)
}

type SettingService interface {
	GetSettings(ctx context.Context) (map[string]interface{}, error)
	SaveSettings(ctx context.Context, data map[string]interface{}) error
}
