package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type VehicleType string

const (
	VehicleTypeEconomy  VehicleType = "economy"
	VehicleTypePremium  VehicleType = "premium"
	VehicleTypeDelivery VehicleType = "delivery"
)

type Vehicle struct {
	ID          uuid.UUID   `json:"id" db:"id"`
	DriverID    uuid.UUID   `json:"driver_id" db:"driver_id"`
	Make        string      `json:"make" db:"make"`
	Model       string      `json:"model" db:"model"`
	Year        int         `json:"year" db:"year"`
	PlateNumber string      `json:"plate_number" db:"plate_number"`
	Color       string      `json:"color" db:"color"`
	Type        VehicleType `json:"type" db:"type"`
	CreatedAt   time.Time   `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time   `json:"updated_at" db:"updated_at"`
}

type CreateVehicleRequest struct {
	DriverID    string      `json:"driver_id" validate:"required,uuid"`
	Make        string      `json:"make" validate:"required"`
	Model       string      `json:"model" validate:"required"`
	Year        int         `json:"year" validate:"required,gt=1900"`
	PlateNumber string      `json:"plate_number" validate:"required"`
	Color       string      `json:"color" validate:"required"`
	Type        VehicleType `json:"type" validate:"required,oneof=economy premium delivery"`
}

type VehicleRepository interface {
	Create(ctx context.Context, vehicle *Vehicle) error
	GetByID(ctx context.Context, id uuid.UUID) (*Vehicle, error)
	GetByDriverID(ctx context.Context, driverID uuid.UUID) (*Vehicle, error)
	Update(ctx context.Context, vehicle *Vehicle) error
	Delete(ctx context.Context, id uuid.UUID) error
}
