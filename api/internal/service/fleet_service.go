package service

import (
	"context"
	"errors"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/domain"
)

type fleetService struct {
	fleetRepo  domain.FleetRepository
	userRepo   domain.UserRepository
	driverRepo domain.DriverRepository
	storeRepo  domain.StoreRepository
}

func NewFleetService(
	fleetRepo domain.FleetRepository,
	userRepo domain.UserRepository,
	driverRepo domain.DriverRepository,
	storeRepo domain.StoreRepository,
) domain.FleetService {
	return &fleetService{
		fleetRepo:  fleetRepo,
		userRepo:   userRepo,
		driverRepo: driverRepo,
		storeRepo:  storeRepo,
	}
}

// ── Pro Profile Management ───────────────────────────────────────────────────

// ActivateProProfile adds a sub-profile type to the user's pro_profiles list.
// This allows a user to become simultaneously a driver AND fleet_owner AND merchant.
func (s *fleetService) ActivateProProfile(ctx context.Context, userID uuid.UUID, profile domain.ProProfileType) error {
	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil || user == nil {
		return errors.New("user not found")
	}

	// Parse existing profiles
	existing := strings.Split(user.ProProfiles, ",")
	for _, p := range existing {
		if strings.TrimSpace(p) == string(profile) {
			return nil // Already activated
		}
	}

	// Add new profile
	if user.ProProfiles == "" {
		user.ProProfiles = string(profile)
	} else {
		user.ProProfiles = user.ProProfiles + "," + string(profile)
	}

	// Upgrade role to "pro" if not already an admin
	if user.Role != domain.RoleAdmin {
		user.Role = domain.RolePro
	}

	return s.userRepo.Update(ctx, user)
}

// GetProProfileSummary returns the full summary of a Pro user's active profiles
func (s *fleetService) GetProProfileSummary(ctx context.Context, userID uuid.UUID) (*domain.ProProfileSummary, error) {
	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil || user == nil {
		return nil, errors.New("user not found")
	}

	summary := &domain.ProProfileSummary{
		UserID:      user.ID,
		Name:        user.Name,
		Email:       user.Email,
		Phone:       user.Phone,
		ProProfiles: parseProfiles(user.ProProfiles),
	}

	// Enrich with driver profile if active
	if hasProfile(user.ProProfiles, domain.ProProfileDriver) ||
		user.Role == domain.RoleDriver {
		driver, _ := s.driverRepo.GetByUserID(ctx, userID)
		summary.Driver = driver
	}

	// Enrich with fleet data if fleet_owner
	if hasProfile(user.ProProfiles, domain.ProProfileFleetOwner) {
		fleets, _ := s.fleetRepo.ListFleetsByOwner(ctx, userID)
		for i := range fleets {
			vehicles, _ := s.fleetRepo.ListVehiclesByFleet(ctx, fleets[i].ID)
			fleets[i].Vehicles = vehicles
		}
		summary.Fleets = fleets
	}

	// Enrich with store if merchant
	if hasProfile(user.ProProfiles, domain.ProProfileMerchant) ||
		user.Role == domain.RoleStore {
		store, _ := s.storeRepo.GetStoreByUserID(ctx, userID)
		summary.Store = store
	}

	return summary, nil
}

// ── Fleet CRUD ───────────────────────────────────────────────────────────────

func (s *fleetService) CreateFleet(ctx context.Context, ownerID uuid.UUID, req *domain.CreateFleetRequest) (*domain.Fleet, error) {
	fleet := &domain.Fleet{
		ID:          uuid.New(),
		OwnerID:     ownerID,
		Name:        req.Name,
		Description: req.Description,
		IsActive:    true,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
	if err := s.fleetRepo.CreateFleet(ctx, fleet); err != nil {
		return nil, err
	}
	return fleet, nil
}

func (s *fleetService) GetFleet(ctx context.Context, fleetID uuid.UUID) (*domain.Fleet, error) {
	fleet, err := s.fleetRepo.GetFleetByID(ctx, fleetID)
	if err != nil {
		return nil, err
	}
	if fleet == nil {
		return nil, errors.New("fleet not found")
	}
	// Load vehicles
	vehicles, _ := s.fleetRepo.ListVehiclesByFleet(ctx, fleetID)
	fleet.Vehicles = vehicles
	return fleet, nil
}

func (s *fleetService) ListOwnerFleets(ctx context.Context, ownerID uuid.UUID) ([]domain.Fleet, error) {
	fleets, err := s.fleetRepo.ListFleetsByOwner(ctx, ownerID)
	if err != nil {
		return nil, err
	}
	for i := range fleets {
		vehicles, _ := s.fleetRepo.ListVehiclesByFleet(ctx, fleets[i].ID)
		fleets[i].Vehicles = vehicles
	}
	return fleets, nil
}

func (s *fleetService) UpdateFleet(ctx context.Context, ownerID uuid.UUID, fleetID uuid.UUID, req *domain.CreateFleetRequest) (*domain.Fleet, error) {
	fleet, err := s.fleetRepo.GetFleetByID(ctx, fleetID)
	if err != nil || fleet == nil {
		return nil, errors.New("fleet not found")
	}
	if fleet.OwnerID != ownerID {
		return nil, errors.New("unauthorized: you do not own this fleet")
	}
	fleet.Name = req.Name
	fleet.Description = req.Description
	fleet.UpdatedAt = time.Now()
	if err := s.fleetRepo.UpdateFleet(ctx, fleet); err != nil {
		return nil, err
	}
	return fleet, nil
}

func (s *fleetService) DeleteFleet(ctx context.Context, ownerID uuid.UUID, fleetID uuid.UUID) error {
	fleet, err := s.fleetRepo.GetFleetByID(ctx, fleetID)
	if err != nil || fleet == nil {
		return errors.New("fleet not found")
	}
	if fleet.OwnerID != ownerID {
		return errors.New("unauthorized: you do not own this fleet")
	}
	return s.fleetRepo.DeleteFleet(ctx, fleetID)
}

// ── Vehicle management ───────────────────────────────────────────────────────

func (s *fleetService) AddVehicleToFleet(ctx context.Context, ownerID uuid.UUID, req *domain.AddVehicleToFleetRequest) (*domain.Vehicle, error) {
	fleetID, err := uuid.Parse(req.FleetID)
	if err != nil {
		return nil, errors.New("invalid fleet_id")
	}

	fleet, err := s.fleetRepo.GetFleetByID(ctx, fleetID)
	if err != nil || fleet == nil {
		return nil, errors.New("fleet not found")
	}
	if fleet.OwnerID != ownerID {
		return nil, errors.New("unauthorized: you do not own this fleet")
	}

	// A fleet vehicle's "driver_id" field is set to the fleet owner's driver profile (if any),
	// or stays as a zero UUID. The real driver assignment is via fleet_assignments.
	driverProfile, _ := s.driverRepo.GetByUserID(ctx, ownerID)
	driverID := uuid.Nil
	if driverProfile != nil {
		driverID = driverProfile.ID
	}

	now := time.Now()
	vehicle := &domain.Vehicle{
		ID:          uuid.New(),
		DriverID:    driverID,
		OwnerID:     &ownerID,
		FleetID:     &fleetID,
		Make:        req.Make,
		Model:       req.Model,
		Year:        req.Year,
		PlateNumber: req.PlateNumber,
		Color:       req.Color,
		Type:        req.Type,
		KycStatus:   "unsubmitted",
		CreatedAt:   now,
		UpdatedAt:   now,
	}

	// We store via the vehicle repository; for now use a direct DB insert
	// The vehicle_repo Create must be updated to handle nullable owner_id / fleet_id
	return vehicle, nil // TODO: persist via vehicleRepo.Create after updating it
}

func (s *fleetService) ListFleetVehicles(ctx context.Context, ownerID uuid.UUID, fleetID uuid.UUID) ([]domain.Vehicle, error) {
	fleet, err := s.fleetRepo.GetFleetByID(ctx, fleetID)
	if err != nil || fleet == nil {
		return nil, errors.New("fleet not found")
	}
	if fleet.OwnerID != ownerID {
		return nil, errors.New("unauthorized")
	}
	return s.fleetRepo.ListVehiclesByFleet(ctx, fleetID)
}

func (s *fleetService) ListAllOwnerVehicles(ctx context.Context, ownerID uuid.UUID) ([]domain.Vehicle, error) {
	return s.fleetRepo.ListVehiclesByOwner(ctx, ownerID)
}

// ── Driver assignment ────────────────────────────────────────────────────────

func (s *fleetService) AssignDriverToVehicle(ctx context.Context, ownerID uuid.UUID, req *domain.AssignDriverToVehicleRequest) (*domain.FleetAssignment, error) {
	vehicleID, err := uuid.Parse(req.VehicleID)
	if err != nil {
		return nil, errors.New("invalid vehicle_id")
	}
	driverID, err := uuid.Parse(req.DriverID)
	if err != nil {
		return nil, errors.New("invalid driver_id")
	}

	// Get the fleet for this vehicle
	vehicles, err := s.fleetRepo.ListVehiclesByOwner(ctx, ownerID)
	if err != nil {
		return nil, err
	}
	var targetVehicle *domain.Vehicle
	for i := range vehicles {
		if vehicles[i].ID == vehicleID {
			targetVehicle = &vehicles[i]
			break
		}
	}
	if targetVehicle == nil {
		return nil, errors.New("vehicle not found or not owned by you")
	}

	fleetID := uuid.Nil
	if targetVehicle.FleetID != nil {
		fleetID = *targetVehicle.FleetID
	}

	assignment := &domain.FleetAssignment{
		ID:         uuid.New(),
		FleetID:    fleetID,
		VehicleID:  vehicleID,
		DriverID:   driverID,
		AssignedAt: time.Now(),
		IsActive:   true,
	}

	if err := s.fleetRepo.AssignDriver(ctx, assignment); err != nil {
		return nil, err
	}
	return assignment, nil
}

func (s *fleetService) UnassignDriverFromVehicle(ctx context.Context, ownerID uuid.UUID, vehicleID uuid.UUID) error {
	return s.fleetRepo.UnassignDriver(ctx, vehicleID)
}

func (s *fleetService) ListFleetAssignments(ctx context.Context, ownerID uuid.UUID, fleetID uuid.UUID) ([]domain.FleetAssignment, error) {
	return s.fleetRepo.ListAssignmentsByFleet(ctx, fleetID)
}

// ── Helpers ──────────────────────────────────────────────────────────────────

func parseProfiles(raw string) []string {
	if raw == "" {
		return []string{}
	}
	parts := strings.Split(raw, ",")
	result := make([]string, 0, len(parts))
	for _, p := range parts {
		trimmed := strings.TrimSpace(p)
		if trimmed != "" {
			result = append(result, trimmed)
		}
	}
	return result
}

func hasProfile(raw string, profile domain.ProProfileType) bool {
	for _, p := range parseProfiles(raw) {
		if p == string(profile) {
			return true
		}
	}
	return false
}
