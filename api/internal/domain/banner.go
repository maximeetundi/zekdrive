package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type Banner struct {
	ID              uuid.UUID `json:"id" db:"id"`
	Name            string    `json:"name" db:"name"`
	Description     string    `json:"description" db:"description"`
	TimePeriod      string    `json:"time_period" db:"time_period"`
	DisplayPosition string    `json:"display_position" db:"display_position"`
	RedirectLink    string    `json:"redirect_link" db:"redirect_link"`
	BannerGroup     string    `json:"banner_group" db:"banner_group"`
	StartDate       string    `json:"start_date" db:"start_date"`
	EndDate         string    `json:"end_date" db:"end_date"`
	Image           string    `json:"image" db:"image"`
	CreatedAt       time.Time `json:"created_at" db:"created_at"`
	UpdatedAt       time.Time `json:"updated_at" db:"updated_at"`
}

type BannerRepository interface {
	List(ctx context.Context) ([]Banner, error)
	Create(ctx context.Context, banner *Banner) error
	Update(ctx context.Context, banner *Banner) error
	Delete(ctx context.Context, id uuid.UUID) error
	GetByID(ctx context.Context, id uuid.UUID) (*Banner, error)
}
