package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type DeliveryStatus string

const (
	DeliveryStatusRequested DeliveryStatus = "requested"
	DeliveryStatusAssigned  DeliveryStatus = "assigned"
	DeliveryStatusPickedUp  DeliveryStatus = "picked_up"
	DeliveryStatusDelivered DeliveryStatus = "delivered"
	DeliveryStatusCancelled DeliveryStatus = "cancelled"
)

type Delivery struct {
	ID             uuid.UUID      `json:"id" db:"id"`
	SenderID       uuid.UUID      `json:"sender_id" db:"sender_id"`
	DriverID       *uuid.UUID     `json:"driver_id" db:"driver_id"`
	TripID         *uuid.UUID     `json:"trip_id" db:"trip_id"`
	PickupLat      float64        `json:"pickup_lat" db:"pickup_lat"`
	PickupLng      float64        `json:"pickup_lng" db:"pickup_lng"`
	DropoffLat     float64        `json:"dropoff_lat" db:"dropoff_lat"`
	DropoffLng     float64        `json:"dropoff_lng" db:"dropoff_lng"`
	RecipientName  string         `json:"recipient_name" db:"recipient_name"`
	RecipientPhone string         `json:"recipient_phone" db:"recipient_phone"`
	PackageDetails string         `json:"package_details" db:"package_details"`
	Status         DeliveryStatus `json:"status" db:"status"`
	Fare           float64        `json:"fare" db:"fare"`
	CreatedAt      time.Time      `json:"created_at" db:"created_at"`
	UpdatedAt      time.Time      `json:"updated_at" db:"updated_at"`

	// Joined details
	Sender *User   `json:"sender,omitempty"`
	Driver *Driver `json:"driver,omitempty"`
}

type CreateDeliveryRequest struct {
	PickupLat      float64 `json:"pickup_lat" validate:"required,latitude"`
	PickupLng      float64 `json:"pickup_lng" validate:"required,longitude"`
	DropoffLat     float64 `json:"dropoff_lat" validate:"required,latitude"`
	DropoffLng     float64 `json:"dropoff_lng" validate:"required,longitude"`
	RecipientName  string  `json:"recipient_name" validate:"required"`
	RecipientPhone string  `json:"recipient_phone" validate:"required"`
	PackageDetails string  `json:"package_details" validate:"required"`
}

type UpdateDeliveryStatusRequest struct {
	Status DeliveryStatus `json:"status" validate:"required,oneof=assigned picked_up delivered cancelled"`
}

type DeliveryRepository interface {
	Create(ctx context.Context, delivery *Delivery) error
	GetByID(ctx context.Context, id uuid.UUID) (*Delivery, error)
	Update(ctx context.Context, delivery *Delivery) error
	UpdateStatus(ctx context.Context, id uuid.UUID, status DeliveryStatus) error
	UpdateDriver(ctx context.Context, id uuid.UUID, driverID uuid.UUID) error
	ListBySenderID(ctx context.Context, senderID uuid.UUID, limit, offset int) ([]Delivery, error)
	ListByDriverID(ctx context.Context, driverID uuid.UUID, limit, offset int) ([]Delivery, error)
}
