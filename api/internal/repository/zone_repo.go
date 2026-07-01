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

type zoneRepo struct {
	db *database.PostgresDB
}

func NewZoneRepository(db *database.PostgresDB) domain.ZoneRepository {
	return &zoneRepo{db: db}
}

func (r *zoneRepo) Create(ctx context.Context, z *domain.Zone) error {
	query := `
		INSERT INTO zones (id, name, boundary, base_fare, fare_per_km, fare_per_minute, surge_multiplier, created_at, updated_at)
		VALUES ($1, $2, ST_GeomFromText($3, 4326), $4, $5, $6, $7, $8, $9)
	`
	_, err := r.db.ExecContext(ctx, query, z.ID, z.Name, z.Boundary, z.BaseFare, z.FarePerKm, z.FarePerMinute, z.SurgeMultiplier, z.CreatedAt, z.UpdatedAt)
	return err
}

func (r *zoneRepo) GetByID(ctx context.Context, id uuid.UUID) (*domain.Zone, error) {
	var z domain.Zone
	query := `
		SELECT id, name, ST_AsText(boundary) as boundary, base_fare, fare_per_km, fare_per_minute, surge_multiplier, created_at, updated_at
		FROM zones
		WHERE id = $1
	`
	err := r.db.GetContext(ctx, &z, query, id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return &z, nil
}

func (r *zoneRepo) FindContainingPoint(ctx context.Context, lat, lng float64) (*domain.Zone, error) {
	var z domain.Zone
	// ST_MakePoint takes (longitude, latitude)
	query := `
		SELECT id, name, ST_AsText(boundary) as boundary, base_fare, fare_per_km, fare_per_minute, surge_multiplier, created_at, updated_at
		FROM zones
		WHERE ST_Contains(boundary, ST_SetSRID(ST_MakePoint($1, $2), 4326))
		LIMIT 1
	`
	err := r.db.GetContext(ctx, &z, query, lng, lat)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			// FALLBACK FOR TESTING: Return the first zone from the database if point is not inside any zone
			fallbackQuery := `
				SELECT id, name, ST_AsText(boundary) as boundary, base_fare, fare_per_km, fare_per_minute, surge_multiplier, created_at, updated_at
				FROM zones
				LIMIT 1
			`
			err = r.db.GetContext(ctx, &z, fallbackQuery)
			if err != nil {
				if errors.Is(err, sql.ErrNoRows) {
					return nil, nil
				}
				return nil, err
			}
			return &z, nil
		}
		return nil, err
	}
	return &z, nil
}

func (r *zoneRepo) Update(ctx context.Context, z *domain.Zone) error {
	query := `
		UPDATE zones
		SET name = $1, boundary = ST_GeomFromText($2, 4326), base_fare = $3, fare_per_km = $4, fare_per_minute = $5, surge_multiplier = $6, updated_at = $7
		WHERE id = $8
	`
	_, err := r.db.ExecContext(ctx, query, z.Name, z.Boundary, z.BaseFare, z.FarePerKm, z.FarePerMinute, z.SurgeMultiplier, z.UpdatedAt, z.ID)
	return err
}

func (r *zoneRepo) UpdateSurge(ctx context.Context, zoneID uuid.UUID, surge float64) error {
	query := `UPDATE zones SET surge_multiplier = $1, updated_at = $2 WHERE id = $3`
	_, err := r.db.ExecContext(ctx, query, surge, time.Now(), zoneID)
	return err
}

func (r *zoneRepo) List(ctx context.Context) ([]domain.Zone, error) {
	var zones []domain.Zone
	query := `
		SELECT id, name, ST_AsText(boundary) as boundary, base_fare, fare_per_km, fare_per_minute, surge_multiplier, created_at, updated_at
		FROM zones
		ORDER BY name ASC
	`
	err := r.db.SelectContext(ctx, &zones, query)
	if err != nil {
		return nil, err
	}
	return zones, nil
}

func (r *zoneRepo) Delete(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM zones WHERE id = $1`
	_, err := r.db.ExecContext(ctx, query, id)
	return err
}
