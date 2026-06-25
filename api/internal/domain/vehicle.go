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
	ID               uuid.UUID   `json:"id" db:"id"`
	DriverID         uuid.UUID   `json:"driver_id" db:"driver_id"`      // Legacy: originally 1-to-1 with driver
	OwnerID          *uuid.UUID  `json:"owner_id" db:"owner_id"`        // User who OWNS the vehicle (fleet owner or self-owning driver)
	AssignedDriverID *uuid.UUID  `json:"assigned_driver_id" db:"assigned_driver_id"` // Driver currently assigned to drive it
	FleetID          *uuid.UUID  `json:"fleet_id" db:"fleet_id"`        // Fleet this vehicle belongs to (optional)
	Make             string      `json:"make" db:"make"`
	Model            string      `json:"model" db:"model"`
	Year             int         `json:"year" db:"year"`
	PlateNumber      string      `json:"plate_number" db:"plate_number"`
	Color            string      `json:"color" db:"color"`
	Type             VehicleType `json:"type" db:"type"`
	KycStatus        string      `json:"kyc_status" db:"kyc_status"`
	KycDocument      string      `json:"kyc_document" db:"kyc_document"`
	CreatedAt        time.Time   `json:"created_at" db:"created_at"`
	UpdatedAt        time.Time   `json:"updated_at" db:"updated_at"`
}

type CreateVehicleRequest struct {
	DriverID    string      `json:"driver_id" validate:"omitempty,uuid"` // optional for fleet vehicles
	OwnerID     string      `json:"owner_id" validate:"omitempty,uuid"`  // fleet owner user ID
	FleetID     string      `json:"fleet_id" validate:"omitempty,uuid"`  // assign to fleet
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
	ListByOwnerID(ctx context.Context, ownerID uuid.UUID) ([]Vehicle, error)
	Update(ctx context.Context, vehicle *Vehicle) error
	Delete(ctx context.Context, id uuid.UUID) error
}
