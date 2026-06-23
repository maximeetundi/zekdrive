package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type TripStatus string

const (
	TripStatusRequested  TripStatus = "requested"
	TripStatusAccepted   TripStatus = "accepted"
	TripStatusArriving   TripStatus = "arriving"
	TripStatusInProgress TripStatus = "in_progress"
	TripStatusCompleted  TripStatus = "completed"
	TripStatusCancelled  TripStatus = "cancelled"
)

type PaymentStatus string

const (
	PaymentPending PaymentStatus = "pending"
	PaymentPaid    PaymentStatus = "paid"
	PaymentFailed  PaymentStatus = "failed"
)

type Trip struct {
	ID             uuid.UUID     `json:"id" db:"id"`
	RiderID        uuid.UUID     `json:"rider_id" db:"rider_id"`
	DriverID       *uuid.UUID    `json:"driver_id" db:"driver_id"`
	PickupLat      float64       `json:"pickup_lat" db:"pickup_lat"`
	PickupLng      float64       `json:"pickup_lng" db:"pickup_lng"`
	DropoffLat     float64       `json:"dropoff_lat" db:"dropoff_lat"`
	DropoffLng     float64       `json:"dropoff_lng" db:"dropoff_lng"`
	PickupAddress  string        `json:"pickup_address" db:"pickup_address"`
	DropoffAddress string        `json:"dropoff_address" db:"dropoff_address"`
	Status         TripStatus    `json:"status" db:"status"`
	Fare           float64       `json:"fare" db:"fare"`
	PaymentStatus  PaymentStatus `json:"payment_status" db:"payment_status"`
	RouteCoords    *string       `json:"route_coords" db:"route_coords"` // JSON string representation of [ [lng, lat], ... ]
	CreatedAt      time.Time     `json:"created_at" db:"created_at"`
	UpdatedAt      time.Time     `json:"updated_at" db:"updated_at"`

	// Joined details
	Rider  *User   `json:"rider,omitempty"`
	Driver *Driver `json:"driver,omitempty"`
}

type CreateTripRequest struct {
	PickupLat      float64     `json:"pickup_lat" validate:"required,latitude"`
	PickupLng      float64     `json:"pickup_lng" validate:"required,longitude"`
	DropoffLat     float64     `json:"dropoff_lat" validate:"required,latitude"`
	DropoffLng     float64     `json:"dropoff_lng" validate:"required,longitude"`
	PickupAddress  string      `json:"pickup_address" validate:"required"`
	DropoffAddress string      `json:"dropoff_address" validate:"required"`
	VehicleType    VehicleType `json:"vehicle_type" validate:"required,oneof=economy premium delivery"`
}

type UpdateTripStatusRequest struct {
	Status TripStatus `json:"status" validate:"required,oneof=accepted arriving in_progress completed cancelled"`
}

type TripRepository interface {
	Create(ctx context.Context, trip *Trip) error
	GetByID(ctx context.Context, id uuid.UUID) (*Trip, error)
	Update(ctx context.Context, trip *Trip) error
	UpdateStatus(ctx context.Context, id uuid.UUID, status TripStatus) error
	UpdateDriver(ctx context.Context, id uuid.UUID, driverID uuid.UUID) error
	UpdatePaymentStatus(ctx context.Context, id uuid.UUID, status PaymentStatus) error
	GetActiveTripByRiderID(ctx context.Context, riderID uuid.UUID) (*Trip, error)
	GetActiveTripByDriverID(ctx context.Context, driverID uuid.UUID) (*Trip, error)
	ListByRiderID(ctx context.Context, riderID uuid.UUID, limit, offset int) ([]Trip, error)
	ListByDriverID(ctx context.Context, driverID uuid.UUID, limit, offset int) ([]Trip, error)
}
