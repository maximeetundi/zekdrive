package repository

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/database"
	"github.com/zekdrive/api/internal/domain"
)

type fleetRepo struct {
	db *database.PostgresDB
}

func NewFleetRepository(db *database.PostgresDB) domain.FleetRepository {
	return &fleetRepo{db: db}
}

// ── Fleet CRUD ───────────────────────────────────────────────────────────────

func (r *fleetRepo) CreateFleet(ctx context.Context, f *domain.Fleet) error {
	query := `
		INSERT INTO fleets (id, owner_id, name, description, is_active, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`
	_, err := r.db.ExecContext(ctx, query,
		f.ID, f.OwnerID, f.Name, f.Description, f.IsActive, f.CreatedAt, f.UpdatedAt,
	)
	return err
}

func (r *fleetRepo) GetFleetByID(ctx context.Context, id uuid.UUID) (*domain.Fleet, error) {
	query := `
		SELECT id, owner_id, name, description, is_active, created_at, updated_at
		FROM fleets
		WHERE id = $1
	`
	f := &domain.Fleet{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&f.ID, &f.OwnerID, &f.Name, &f.Description, &f.IsActive, &f.CreatedAt, &f.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return f, nil
}

func (r *fleetRepo) ListFleetsByOwner(ctx context.Context, ownerID uuid.UUID) ([]domain.Fleet, error) {
	query := `
		SELECT id, owner_id, name, description, is_active, created_at, updated_at
		FROM fleets
		WHERE owner_id = $1
		ORDER BY created_at DESC
	`
	rows, err := r.db.QueryContext(ctx, query, ownerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var fleets []domain.Fleet
	for rows.Next() {
		f := domain.Fleet{}
		if err := rows.Scan(&f.ID, &f.OwnerID, &f.Name, &f.Description, &f.IsActive, &f.CreatedAt, &f.UpdatedAt); err != nil {
			return nil, err
		}
		fleets = append(fleets, f)
	}
	return fleets, nil
}

func (r *fleetRepo) UpdateFleet(ctx context.Context, f *domain.Fleet) error {
	query := `
		UPDATE fleets
		SET name = $1, description = $2, is_active = $3, updated_at = $4
		WHERE id = $5 AND owner_id = $6
	`
	_, err := r.db.ExecContext(ctx, query, f.Name, f.Description, f.IsActive, f.UpdatedAt, f.ID, f.OwnerID)
	return err
}

func (r *fleetRepo) DeleteFleet(ctx context.Context, id uuid.UUID) error {
	_, err := r.db.ExecContext(ctx, `DELETE FROM fleets WHERE id = $1`, id)
	return err
}

// ── Vehicle management ───────────────────────────────────────────────────────

func (r *fleetRepo) AddVehicleToFleet(ctx context.Context, fleetID, vehicleID uuid.UUID) error {
	query := `UPDATE vehicles SET fleet_id = $1, updated_at = $2 WHERE id = $3`
	_, err := r.db.ExecContext(ctx, query, fleetID, time.Now(), vehicleID)
	return err
}

func (r *fleetRepo) ListVehiclesByFleet(ctx context.Context, fleetID uuid.UUID) ([]domain.Vehicle, error) {
	query := `
		SELECT id, driver_id, make, model, year, plate_number, color, type,
		       kyc_status, kyc_document, owner_id, assigned_driver_id, fleet_id, created_at, updated_at
		FROM vehicles
		WHERE fleet_id = $1
		ORDER BY created_at DESC
	`
	return r.scanVehicles(ctx, query, fleetID)
}

func (r *fleetRepo) ListVehiclesByOwner(ctx context.Context, ownerID uuid.UUID) ([]domain.Vehicle, error) {
	query := `
		SELECT id, driver_id, make, model, year, plate_number, color, type,
		       kyc_status, kyc_document, owner_id, assigned_driver_id, fleet_id, created_at, updated_at
		FROM vehicles
		WHERE owner_id = $1
		ORDER BY created_at DESC
	`
	return r.scanVehicles(ctx, query, ownerID)
}

func (r *fleetRepo) scanVehicles(ctx context.Context, query string, arg interface{}) ([]domain.Vehicle, error) {
	rows, err := r.db.QueryContext(ctx, query, arg)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var vehicles []domain.Vehicle
	for rows.Next() {
		v := domain.Vehicle{}
		err := rows.Scan(
			&v.ID, &v.DriverID, &v.Make, &v.Model, &v.Year, &v.PlateNumber, &v.Color, &v.Type,
			&v.KycStatus, &v.KycDocument, &v.OwnerID, &v.AssignedDriverID, &v.FleetID,
			&v.CreatedAt, &v.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		vehicles = append(vehicles, v)
	}
	return vehicles, nil
}

// ── Driver assignments ───────────────────────────────────────────────────────

func (r *fleetRepo) AssignDriver(ctx context.Context, a *domain.FleetAssignment) error {
	// Deactivate any existing active assignment for this vehicle
	_, err := r.db.ExecContext(ctx,
		`UPDATE fleet_assignments SET is_active = false, unassigned_at = $1 WHERE vehicle_id = $2 AND is_active = true`,
		time.Now(), a.VehicleID,
	)
	if err != nil {
		return err
	}

	// Create new assignment
	query := `
		INSERT INTO fleet_assignments (id, fleet_id, vehicle_id, driver_id, assigned_at, is_active)
		VALUES ($1, $2, $3, $4, $5, true)
	`
	_, err = r.db.ExecContext(ctx, query, a.ID, a.FleetID, a.VehicleID, a.DriverID, a.AssignedAt)
	if err != nil {
		return err
	}

	// Update vehicle's assigned_driver_id
	_, err = r.db.ExecContext(ctx,
		`UPDATE vehicles SET assigned_driver_id = $1, updated_at = $2 WHERE id = $3`,
		a.DriverID, time.Now(), a.VehicleID,
	)
	return err
}

func (r *fleetRepo) UnassignDriver(ctx context.Context, vehicleID uuid.UUID) error {
	now := time.Now()
	_, err := r.db.ExecContext(ctx,
		`UPDATE fleet_assignments SET is_active = false, unassigned_at = $1 WHERE vehicle_id = $2 AND is_active = true`,
		now, vehicleID,
	)
	if err != nil {
		return err
	}
	_, err = r.db.ExecContext(ctx,
		`UPDATE vehicles SET assigned_driver_id = NULL, updated_at = $1 WHERE id = $2`,
		now, vehicleID,
	)
	return err
}

func (r *fleetRepo) ListAssignmentsByFleet(ctx context.Context, fleetID uuid.UUID) ([]domain.FleetAssignment, error) {
	query := `
		SELECT fa.id, fa.fleet_id, fa.vehicle_id, fa.driver_id, fa.assigned_at, fa.unassigned_at, fa.is_active,
		       u.name as driver_name, u.phone as driver_phone,
		       v.make as vehicle_make, v.model as vehicle_model, v.plate_number
		FROM fleet_assignments fa
		JOIN drivers d ON d.id = fa.driver_id
		JOIN users u ON u.id = d.user_id
		JOIN vehicles v ON v.id = fa.vehicle_id
		WHERE fa.fleet_id = $1
		ORDER BY fa.assigned_at DESC
	`
	rows, err := r.db.QueryContext(ctx, query, fleetID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var assignments []domain.FleetAssignment
	for rows.Next() {
		a := domain.FleetAssignment{}
		err := rows.Scan(
			&a.ID, &a.FleetID, &a.VehicleID, &a.DriverID, &a.AssignedAt, &a.UnassignedAt, &a.IsActive,
			&a.DriverName, &a.DriverPhone,
			&a.VehicleMake, &a.VehicleModel, &a.PlateNumber,
		)
		if err != nil {
			return nil, err
		}
		assignments = append(assignments, a)
	}
	return assignments, nil
}

func (r *fleetRepo) GetActiveAssignmentByVehicle(ctx context.Context, vehicleID uuid.UUID) (*domain.FleetAssignment, error) {
	query := `
		SELECT fa.id, fa.fleet_id, fa.vehicle_id, fa.driver_id, fa.assigned_at, fa.unassigned_at, fa.is_active,
		       u.name, u.phone,
		       v.make, v.model, v.plate_number
		FROM fleet_assignments fa
		JOIN drivers d ON d.id = fa.driver_id
		JOIN users u ON u.id = d.user_id
		JOIN vehicles v ON v.id = fa.vehicle_id
		WHERE fa.vehicle_id = $1 AND fa.is_active = true
		LIMIT 1
	`
	a := &domain.FleetAssignment{}
	err := r.db.QueryRowContext(ctx, query, vehicleID).Scan(
		&a.ID, &a.FleetID, &a.VehicleID, &a.DriverID, &a.AssignedAt, &a.UnassignedAt, &a.IsActive,
		&a.DriverName, &a.DriverPhone,
		&a.VehicleMake, &a.VehicleModel, &a.PlateNumber,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return a, nil
}
