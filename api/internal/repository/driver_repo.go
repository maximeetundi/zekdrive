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

type driverRepo struct {
	db *database.PostgresDB
}

func NewDriverRepository(db *database.PostgresDB) domain.DriverRepository {
	return &driverRepo{db: db}
}

func (r *driverRepo) Create(ctx context.Context, d *domain.Driver) error {
	query := `
		INSERT INTO drivers (id, user_id, license_number, status, rating, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`
	_, err := r.db.ExecContext(ctx, query, d.ID, d.UserID, d.LicenseNumber, d.Status, d.Rating, d.CreatedAt, d.UpdatedAt)
	return err
}

func (r *driverRepo) GetByID(ctx context.Context, id uuid.UUID) (*domain.Driver, error) {
	query := `
		SELECT 
			d.id, d.user_id, d.license_number, d.status, d.rating, d.created_at, d.updated_at,
			ST_Y(d.location::geometry) as latitude,
			ST_X(d.location::geometry) as longitude,
			u.id as "user_id_fk", u.name, u.email, u.phone, u.role
		FROM drivers d
		JOIN users u ON d.user_id = u.id
		WHERE d.id = $1
	`
	row := r.db.QueryRowContext(ctx, query, id)
	return scanDriver(row)
}

func (r *driverRepo) GetByUserID(ctx context.Context, userID uuid.UUID) (*domain.Driver, error) {
	query := `
		SELECT 
			d.id, d.user_id, d.license_number, d.status, d.rating, d.created_at, d.updated_at,
			ST_Y(d.location::geometry) as latitude,
			ST_X(d.location::geometry) as longitude,
			u.id as "user_id_fk", u.name, u.email, u.phone, u.role
		FROM drivers d
		JOIN users u ON d.user_id = u.id
		WHERE d.user_id = $1
	`
	row := r.db.QueryRowContext(ctx, query, userID)
	return scanDriver(row)
}

func (r *driverRepo) Update(ctx context.Context, d *domain.Driver) error {
	var err error
	if d.Latitude != nil && d.Longitude != nil {
		query := `
			UPDATE drivers 
			SET license_number = $1, status = $2, rating = $3, 
				location = ST_SetSRID(ST_MakePoint($4, $5), 4326), updated_at = $6
			WHERE id = $7
		`
		_, err = r.db.ExecContext(ctx, query, d.LicenseNumber, d.Status, d.Rating, *d.Longitude, *d.Latitude, d.UpdatedAt, d.ID)
	} else {
		query := `
			UPDATE drivers 
			SET license_number = $1, status = $2, rating = $3, updated_at = $4
			WHERE id = $5
		`
		_, err = r.db.ExecContext(ctx, query, d.LicenseNumber, d.Status, d.Rating, d.UpdatedAt, d.ID)
	}
	return err
}

func (r *driverRepo) UpdateLocation(ctx context.Context, driverID uuid.UUID, lat, lng float64) error {
	query := `
		UPDATE drivers 
		SET location = ST_SetSRID(ST_MakePoint($1, $2), 4326), updated_at = $3
		WHERE id = $4
	`
	_, err := r.db.ExecContext(ctx, query, lng, lat, time.Now(), driverID)
	return err
}

func (r *driverRepo) UpdateStatus(ctx context.Context, driverID uuid.UUID, status domain.DriverStatus) error {
	query := `
		UPDATE drivers 
		SET status = $1, updated_at = $2
		WHERE id = $3
	`
	_, err := r.db.ExecContext(ctx, query, status, time.Now(), driverID)
	return err
}

func (r *driverRepo) FindNearby(ctx context.Context, lat, lng float64, radiusMeters float64, limit int) ([]domain.Driver, error) {
	query := `
		SELECT 
			d.id, d.user_id, d.license_number, d.status, d.rating, d.created_at, d.updated_at,
			ST_Y(d.location::geometry) as latitude,
			ST_X(d.location::geometry) as longitude,
			u.id as "user_id_fk", u.name, u.email, u.phone, u.role
		FROM drivers d
		JOIN users u ON d.user_id = u.id
		WHERE d.status = 'online'
		  AND ST_DWithin(d.location::geography, ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography, $3)
		ORDER BY ST_Distance(d.location::geography, ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography) ASC
		LIMIT $4
	`
	rows, err := r.db.QueryContext(ctx, query, lng, lat, radiusMeters, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var drivers []domain.Driver
	for rows.Next() {
		d, err := scanDriverRows(rows)
		if err != nil {
			return nil, err
		}
		drivers = append(drivers, *d)
	}
	return drivers, nil
}

func (r *driverRepo) List(ctx context.Context, status domain.DriverStatus, limit, offset int) ([]domain.Driver, error) {
	var rows *sql.Rows
	var err error

	if status != "" {
		query := `
			SELECT 
				d.id, d.user_id, d.license_number, d.status, d.rating, d.created_at, d.updated_at,
				ST_Y(d.location::geometry) as latitude,
				ST_X(d.location::geometry) as longitude,
				u.id as "user_id_fk", u.name, u.email, u.phone, u.role
			FROM drivers d
			JOIN users u ON d.user_id = u.id
			WHERE d.status = $1
			ORDER BY d.created_at DESC
			LIMIT $2 OFFSET $3
		`
		rows, err = r.db.QueryContext(ctx, query, status, limit, offset)
	} else {
		query := `
			SELECT 
				d.id, d.user_id, d.license_number, d.status, d.rating, d.created_at, d.updated_at,
				ST_Y(d.location::geometry) as latitude,
				ST_X(d.location::geometry) as longitude,
				u.id as "user_id_fk", u.name, u.email, u.phone, u.role
			FROM drivers d
			JOIN users u ON d.user_id = u.id
			ORDER BY d.created_at DESC
			LIMIT $1 OFFSET $2
		`
		rows, err = r.db.QueryContext(ctx, query, limit, offset)
	}

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var drivers []domain.Driver
	for rows.Next() {
		d, err := scanDriverRows(rows)
		if err != nil {
			return nil, err
		}
		drivers = append(drivers, *d)
	}
	return drivers, nil
}

// Helpers to avoid copy-pasting scanner logic
func scanDriver(row *sql.Row) (*domain.Driver, error) {
	var d domain.Driver
	var u domain.User
	var lat, lng sql.NullFloat64
	var userIDFk uuid.UUID

	err := row.Scan(
		&d.ID, &d.UserID, &d.LicenseNumber, &d.Status, &d.Rating, &d.CreatedAt, &d.UpdatedAt,
		&lat, &lng,
		&userIDFk, &u.Name, &u.Email, &u.Phone, &u.Role,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	if lat.Valid {
		d.Latitude = &lat.Float64
	}
	if lng.Valid {
		d.Longitude = &lng.Float64
	}

	u.ID = userIDFk
	d.User = &u
	return &d, nil
}

func scanDriverRows(rows *sql.Rows) (*domain.Driver, error) {
	var d domain.Driver
	var u domain.User
	var lat, lng sql.NullFloat64
	var userIDFk uuid.UUID

	err := rows.Scan(
		&d.ID, &d.UserID, &d.LicenseNumber, &d.Status, &d.Rating, &d.CreatedAt, &d.UpdatedAt,
		&lat, &lng,
		&userIDFk, &u.Name, &u.Email, &u.Phone, &u.Role,
	)
	if err != nil {
		return nil, err
	}

	if lat.Valid {
		d.Latitude = &lat.Float64
	}
	if lng.Valid {
		d.Longitude = &lng.Float64
	}

	u.ID = userIDFk
	d.User = &u
	return &d, nil
}
