package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

// ProProfileType represents a Pro user's activated sub-profile
type ProProfileType string

const (
	ProProfileDriver     ProProfileType = "driver"      // Chauffeur (conduit un véhicule)
	ProProfileFleetOwner ProProfileType = "fleet_owner" // Propriétaire de parc automobile
	ProProfileMerchant   ProProfileType = "merchant"    // Gérant restaurant / boutique
)

// Fleet represents a named set of vehicles owned by a fleet owner
type Fleet struct {
	ID          uuid.UUID `json:"id" db:"id"`
	OwnerID     uuid.UUID `json:"owner_id" db:"owner_id"`
	Name        string    `json:"name" db:"name"`
	Description string    `json:"description" db:"description"`
	IsActive    bool      `json:"is_active" db:"is_active"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`

	// Relations
	Owner    *User     `json:"owner,omitempty"`
	Vehicles []Vehicle `json:"vehicles,omitempty"`
}

// FleetAssignment records a driver being assigned to a vehicle within a fleet
type FleetAssignment struct {
	ID           uuid.UUID  `json:"id" db:"id"`
	FleetID      uuid.UUID  `json:"fleet_id" db:"fleet_id"`
	VehicleID    uuid.UUID  `json:"vehicle_id" db:"vehicle_id"`
	DriverID     uuid.UUID  `json:"driver_id" db:"driver_id"`
	AssignedAt   time.Time  `json:"assigned_at" db:"assigned_at"`
	UnassignedAt *time.Time `json:"unassigned_at,omitempty" db:"unassigned_at"`
	IsActive     bool       `json:"is_active" db:"is_active"`

	// Relations
	DriverName  string `json:"driver_name,omitempty"`
	DriverPhone string `json:"driver_phone,omitempty"`
	VehicleMake string `json:"vehicle_make,omitempty"`
	VehicleModel string `json:"vehicle_model,omitempty"`
	PlateNumber string `json:"plate_number,omitempty"`
}

// ProProfileSummary gives a full overview of a Pro user's activated profiles
type ProProfileSummary struct {
	UserID      uuid.UUID      `json:"user_id"`
	Name        string         `json:"name"`
	Email       string         `json:"email"`
	Phone       string         `json:"phone"`
	ProProfiles []string       `json:"pro_profiles"` // ["driver", "fleet_owner", "merchant"]

	// Driver profile (if active)
	Driver *Driver `json:"driver,omitempty"`

	// Fleet owner profile (if active)
	Fleets []Fleet `json:"fleets,omitempty"`

	// Merchant profile (if active)
	Store *Store `json:"store,omitempty"`
}

// Requests

type CreateFleetRequest struct {
	Name        string `json:"name" validate:"required,min=2,max=100"`
	Description string `json:"description"`
}

type AssignDriverToVehicleRequest struct {
	VehicleID string `json:"vehicle_id" validate:"required,uuid"`
	DriverID  string `json:"driver_id" validate:"required,uuid"`
}

type AddVehicleToFleetRequest struct {
	FleetID     string      `json:"fleet_id" validate:"required,uuid"`
	Make        string      `json:"make" validate:"required"`
	Model       string      `json:"model" validate:"required"`
	Year        int         `json:"year" validate:"required,gt=1900"`
	PlateNumber string      `json:"plate_number" validate:"required"`
	Color       string      `json:"color" validate:"required"`
	Type        VehicleType `json:"type" validate:"required,oneof=economy premium delivery"`
}

type ActivateProProfileRequest struct {
	Profile ProProfileType `json:"profile" validate:"required,oneof=driver fleet_owner merchant"`
}

// Interfaces

type FleetRepository interface {
	CreateFleet(ctx context.Context, fleet *Fleet) error
	GetFleetByID(ctx context.Context, id uuid.UUID) (*Fleet, error)
	ListFleetsByOwner(ctx context.Context, ownerID uuid.UUID) ([]Fleet, error)
	UpdateFleet(ctx context.Context, fleet *Fleet) error
	DeleteFleet(ctx context.Context, id uuid.UUID) error

	// Vehicles in fleet
	AddVehicleToFleet(ctx context.Context, fleetID, vehicleID uuid.UUID) error
	ListVehiclesByFleet(ctx context.Context, fleetID uuid.UUID) ([]Vehicle, error)
	ListVehiclesByOwner(ctx context.Context, ownerID uuid.UUID) ([]Vehicle, error)

	// Driver assignments
	AssignDriver(ctx context.Context, assignment *FleetAssignment) error
	UnassignDriver(ctx context.Context, vehicleID uuid.UUID) error
	ListAssignmentsByFleet(ctx context.Context, fleetID uuid.UUID) ([]FleetAssignment, error)
	GetActiveAssignmentByVehicle(ctx context.Context, vehicleID uuid.UUID) (*FleetAssignment, error)
}

type FleetService interface {
	// Fleet CRUD
	CreateFleet(ctx context.Context, ownerID uuid.UUID, req *CreateFleetRequest) (*Fleet, error)
	GetFleet(ctx context.Context, fleetID uuid.UUID) (*Fleet, error)
	ListOwnerFleets(ctx context.Context, ownerID uuid.UUID) ([]Fleet, error)
	UpdateFleet(ctx context.Context, ownerID uuid.UUID, fleetID uuid.UUID, req *CreateFleetRequest) (*Fleet, error)
	DeleteFleet(ctx context.Context, ownerID uuid.UUID, fleetID uuid.UUID) error

	// Vehicle management
	AddVehicleToFleet(ctx context.Context, ownerID uuid.UUID, req *AddVehicleToFleetRequest) (*Vehicle, error)
	ListFleetVehicles(ctx context.Context, ownerID uuid.UUID, fleetID uuid.UUID) ([]Vehicle, error)
	ListAllOwnerVehicles(ctx context.Context, ownerID uuid.UUID) ([]Vehicle, error)

	// Driver assignment
	AssignDriverToVehicle(ctx context.Context, ownerID uuid.UUID, req *AssignDriverToVehicleRequest) (*FleetAssignment, error)
	UnassignDriverFromVehicle(ctx context.Context, ownerID uuid.UUID, vehicleID uuid.UUID) error
	ListFleetAssignments(ctx context.Context, ownerID uuid.UUID, fleetID uuid.UUID) ([]FleetAssignment, error)

	// Pro profile management
	ActivateProProfile(ctx context.Context, userID uuid.UUID, profile ProProfileType) error
	GetProProfileSummary(ctx context.Context, userID uuid.UUID) (*ProProfileSummary, error)
}
