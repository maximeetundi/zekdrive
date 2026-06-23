package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type Zone struct {
	ID              uuid.UUID `json:"id" db:"id"`
	Name            string    `json:"name" db:"name"`
	Boundary        string    `json:"boundary" db:"boundary"` // WKT string: POLYGON((lng lat, ...))
	BaseFare        float64   `json:"base_fare" db:"base_fare"`
	FarePerKm       float64   `json:"fare_per_km" db:"fare_per_km"`
	FarePerMinute   float64   `json:"fare_per_minute" db:"fare_per_minute"`
	SurgeMultiplier float64   `json:"surge_multiplier" db:"surge_multiplier"`
	CreatedAt       time.Time `json:"created_at" db:"created_at"`
	UpdatedAt       time.Time `json:"updated_at" db:"updated_at"`
}

type CreateZoneRequest struct {
	Name            string  `json:"name" validate:"required"`
	Boundary        string  `json:"boundary" validate:"required"` // Expect WKT POLYGON((lng lat, ...))
	BaseFare        float64 `json:"base_fare" validate:"required,gt=0"`
	FarePerKm       float64 `json:"fare_per_km" validate:"required,gt=0"`
	FarePerMinute   float64 `json:"fare_per_minute" validate:"required,gt=0"`
	SurgeMultiplier float64 `json:"surge_multiplier" validate:"required,gt=0"`
}

type UpdateSurgeRequest struct {
	SurgeMultiplier float64 `json:"surge_multiplier" validate:"required,gt=0"`
}

type ZoneRepository interface {
	Create(ctx context.Context, zone *Zone) error
	GetByID(ctx context.Context, id uuid.UUID) (*Zone, error)
	FindContainingPoint(ctx context.Context, lat, lng float64) (*Zone, error)
	Update(ctx context.Context, zone *Zone) error
	UpdateSurge(ctx context.Context, zoneID uuid.UUID, surge float64) error
	List(ctx context.Context) ([]Zone, error)
	Delete(ctx context.Context, id uuid.UUID) error
}
