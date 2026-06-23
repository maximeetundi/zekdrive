package repository

import (
	"context"
	"database/sql"
	"errors"

	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/database"
	"github.com/zekdrive/api/internal/domain"
)

type vehicleRepo struct {
	db *database.PostgresDB
}

func NewVehicleRepository(db *database.PostgresDB) domain.VehicleRepository {
	return &vehicleRepo{db: db}
}

func (r *vehicleRepo) Create(ctx context.Context, v *domain.Vehicle) error {
	query := `
		INSERT INTO vehicles (id, driver_id, make, model, year, plate_number, color, type, created_at, updated_at)
		VALUES (:id, :driver_id, :make, :model, :year, :plate_number, :color, :type, :created_at, :updated_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, v)
	return err
}

func (r *vehicleRepo) GetByID(ctx context.Context, id uuid.UUID) (*domain.Vehicle, error) {
	var v domain.Vehicle
	query := `SELECT id, driver_id, make, model, year, plate_number, color, type, created_at, updated_at FROM vehicles WHERE id = $1`
	err := r.db.GetContext(ctx, &v, query, id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return &v, nil
}

func (r *vehicleRepo) GetByDriverID(ctx context.Context, driverID uuid.UUID) (*domain.Vehicle, error) {
	var v domain.Vehicle
	query := `SELECT id, driver_id, make, model, year, plate_number, color, type, created_at, updated_at FROM vehicles WHERE driver_id = $1`
	err := r.db.GetContext(ctx, &v, query, driverID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return &v, nil
}

func (r *vehicleRepo) Update(ctx context.Context, v *domain.Vehicle) error {
	query := `
		UPDATE vehicles 
		SET make = :make, model = :model, year = :year, plate_number = :plate_number, color = :color, type = :type, updated_at = :updated_at
		WHERE id = :id
	`
	_, err := r.db.NamedExecContext(ctx, query, v)
	return err
}

func (r *vehicleRepo) Delete(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM vehicles WHERE id = $1`
	_, err := r.db.ExecContext(ctx, query, id)
	return err
}
