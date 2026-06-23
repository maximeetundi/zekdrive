package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type DriverStatus string

const (
	DriverStatusOffline DriverStatus = "offline"
	DriverStatusOnline  DriverStatus = "online"
	DriverStatusBusy    DriverStatus = "busy"
)

type Driver struct {
	ID            uuid.UUID    `json:"id" db:"id"`
	UserID        uuid.UUID    `json:"user_id" db:"user_id"`
	LicenseNumber string       `json:"license_number" db:"license_number"`
	Status        DriverStatus `json:"status" db:"status"`
	Rating        float64      `json:"rating" db:"rating"`
	Latitude      *float64     `json:"latitude" db:"latitude"`
	Longitude     *float64     `json:"longitude" db:"longitude"`
	CreatedAt     time.Time    `json:"created_at" db:"created_at"`
	UpdatedAt     time.Time    `json:"updated_at" db:"updated_at"`

	// Joined fields
	User    *User    `json:"user,omitempty"`
	Vehicle *Vehicle `json:"vehicle,omitempty"`
}

type UpdateLocationRequest struct {
	Latitude  float64 `json:"latitude" validate:"required,latitude"`
	Longitude float64 `json:"longitude" validate:"required,longitude"`
}

type UpdateStatusRequest struct {
	Status DriverStatus `json:"status" validate:"required,oneof=offline online busy"`
}

type DriverRepository interface {
	Create(ctx context.Context, driver *Driver) error
	GetByID(ctx context.Context, id uuid.UUID) (*Driver, error)
	GetByUserID(ctx context.Context, userID uuid.UUID) (*Driver, error)
	Update(ctx context.Context, driver *Driver) error
	UpdateLocation(ctx context.Context, driverID uuid.UUID, lat, lng float64) error
	UpdateStatus(ctx context.Context, driverID uuid.UUID, status DriverStatus) error
	FindNearby(ctx context.Context, lat, lng float64, radiusMeters float64, limit int) ([]Driver, error)
	List(ctx context.Context, status DriverStatus, limit, offset int) ([]Driver, error)
}
