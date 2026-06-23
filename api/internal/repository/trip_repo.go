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

type tripRepo struct {
	db *database.PostgresDB
}

func NewTripRepository(db *database.PostgresDB) domain.TripRepository {
	return &tripRepo{db: db}
}

func (r *tripRepo) Create(ctx context.Context, t *domain.Trip) error {
	query := `
		INSERT INTO trips (
			id, rider_id, driver_id, pickup_location, dropoff_location, 
			pickup_address, dropoff_address, status, fare, payment_status, 
			route_coords, created_at, updated_at
		) VALUES (
			$1, $2, $3, ST_SetSRID(ST_MakePoint($4, $5), 4326), ST_SetSRID(ST_MakePoint($6, $7), 4326), 
			$8, $9, $10, $11, $12, $13, $14, $15
		)
	`
	_, err := r.db.ExecContext(ctx, query,
		t.ID, t.RiderID, t.DriverID, t.PickupLng, t.PickupLat, t.DropoffLng, t.DropoffLat,
		t.PickupAddress, t.DropoffAddress, t.Status, t.Fare, t.PaymentStatus, t.RouteCoords,
		t.CreatedAt, t.UpdatedAt,
	)
	return err
}

func (r *tripRepo) GetByID(ctx context.Context, id uuid.UUID) (*domain.Trip, error) {
	query := `
		SELECT 
			t.id, t.rider_id, t.driver_id, t.pickup_address, t.dropoff_address, t.status, t.fare, t.payment_status, t.route_coords, t.created_at, t.updated_at,
			ST_Y(t.pickup_location::geometry) as pickup_lat, ST_X(t.pickup_location::geometry) as pickup_lng,
			ST_Y(t.dropoff_location::geometry) as dropoff_lat, ST_X(t.dropoff_location::geometry) as dropoff_lng,
			r.name as rider_name, r.email as rider_email, r.phone as rider_phone,
			d.license_number as driver_license, d.status as driver_status, d.rating as driver_rating,
			du.name as driver_name, du.phone as driver_phone
		FROM trips t
		JOIN users r ON t.rider_id = r.id
		LEFT JOIN drivers d ON t.driver_id = d.id
		LEFT JOIN users du ON d.user_id = du.id
		WHERE t.id = $1
	`
	row := r.db.QueryRowContext(ctx, query, id)
	return scanTrip(row)
}

func (r *tripRepo) Update(ctx context.Context, t *domain.Trip) error {
	query := `
		UPDATE trips
		SET 
			driver_id = $1, 
			pickup_location = ST_SetSRID(ST_MakePoint($2, $3), 4326), 
			dropoff_location = ST_SetSRID(ST_MakePoint($4, $5), 4326),
			pickup_address = $6, 
			dropoff_address = $7, 
			status = $8, 
			fare = $9, 
			payment_status = $10, 
			route_coords = $11, 
			updated_at = $12
		WHERE id = $13
	`
	_, err := r.db.ExecContext(ctx, query,
		t.DriverID, t.PickupLng, t.PickupLat, t.DropoffLng, t.DropoffLat,
		t.PickupAddress, t.DropoffAddress, t.Status, t.Fare, t.PaymentStatus, t.RouteCoords,
		t.UpdatedAt, t.ID,
	)
	return err
}

func (r *tripRepo) UpdateStatus(ctx context.Context, id uuid.UUID, status domain.TripStatus) error {
	query := `UPDATE trips SET status = $1, updated_at = $2 WHERE id = $3`
	_, err := r.db.ExecContext(ctx, query, status, time.Now(), id)
	return err
}

func (r *tripRepo) UpdateDriver(ctx context.Context, id uuid.UUID, driverID uuid.UUID) error {
	query := `UPDATE trips SET driver_id = $1, updated_at = $2 WHERE id = $3`
	_, err := r.db.ExecContext(ctx, query, driverID, time.Now(), id)
	return err
}

func (r *tripRepo) UpdatePaymentStatus(ctx context.Context, id uuid.UUID, status domain.PaymentStatus) error {
	query := `UPDATE trips SET payment_status = $1, updated_at = $2 WHERE id = $3`
	_, err := r.db.ExecContext(ctx, query, status, time.Now(), id)
	return err
}

func (r *tripRepo) GetActiveTripByRiderID(ctx context.Context, riderID uuid.UUID) (*domain.Trip, error) {
	query := `
		SELECT 
			t.id, t.rider_id, t.driver_id, t.pickup_address, t.dropoff_address, t.status, t.fare, t.payment_status, t.route_coords, t.created_at, t.updated_at,
			ST_Y(t.pickup_location::geometry) as pickup_lat, ST_X(t.pickup_location::geometry) as pickup_lng,
			ST_Y(t.dropoff_location::geometry) as dropoff_lat, ST_X(t.dropoff_location::geometry) as dropoff_lng,
			r.name as rider_name, r.email as rider_email, r.phone as rider_phone,
			d.license_number as driver_license, d.status as driver_status, d.rating as driver_rating,
			du.name as driver_name, du.phone as driver_phone
		FROM trips t
		JOIN users r ON t.rider_id = r.id
		LEFT JOIN drivers d ON t.driver_id = d.id
		LEFT JOIN users du ON d.user_id = du.id
		WHERE t.rider_id = $1 AND t.status NOT IN ('completed', 'cancelled')
		LIMIT 1
	`
	row := r.db.QueryRowContext(ctx, query, riderID)
	return scanTrip(row)
}

func (r *tripRepo) GetActiveTripByDriverID(ctx context.Context, driverID uuid.UUID) (*domain.Trip, error) {
	query := `
		SELECT 
			t.id, t.rider_id, t.driver_id, t.pickup_address, t.dropoff_address, t.status, t.fare, t.payment_status, t.route_coords, t.created_at, t.updated_at,
			ST_Y(t.pickup_location::geometry) as pickup_lat, ST_X(t.pickup_location::geometry) as pickup_lng,
			ST_Y(t.dropoff_location::geometry) as dropoff_lat, ST_X(t.dropoff_location::geometry) as dropoff_lng,
			r.name as rider_name, r.email as rider_email, r.phone as rider_phone,
			d.license_number as driver_license, d.status as driver_status, d.rating as driver_rating,
			du.name as driver_name, du.phone as driver_phone
		FROM trips t
		JOIN users r ON t.rider_id = r.id
		LEFT JOIN drivers d ON t.driver_id = d.id
		LEFT JOIN users du ON d.user_id = du.id
		WHERE t.driver_id = $1 AND t.status NOT IN ('completed', 'cancelled')
		LIMIT 1
	`
	row := r.db.QueryRowContext(ctx, query, driverID)
	return scanTrip(row)
}

func (r *tripRepo) ListByRiderID(ctx context.Context, riderID uuid.UUID, limit, offset int) ([]domain.Trip, error) {
	query := `
		SELECT 
			t.id, t.rider_id, t.driver_id, t.pickup_address, t.dropoff_address, t.status, t.fare, t.payment_status, t.route_coords, t.created_at, t.updated_at,
			ST_Y(t.pickup_location::geometry) as pickup_lat, ST_X(t.pickup_location::geometry) as pickup_lng,
			ST_Y(t.dropoff_location::geometry) as dropoff_lat, ST_X(t.dropoff_location::geometry) as dropoff_lng,
			r.name as rider_name, r.email as rider_email, r.phone as rider_phone,
			d.license_number as driver_license, d.status as driver_status, d.rating as driver_rating,
			du.name as driver_name, du.phone as driver_phone
		FROM trips t
		JOIN users r ON t.rider_id = r.id
		LEFT JOIN drivers d ON t.driver_id = d.id
		LEFT JOIN users du ON d.user_id = du.id
		WHERE t.rider_id = $1
		ORDER BY t.created_at DESC
		LIMIT $2 OFFSET $3
	`
	rows, err := r.db.QueryContext(ctx, query, riderID, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var trips []domain.Trip
	for rows.Next() {
		t, err := scanTripRows(rows)
		if err != nil {
			return nil, err
		}
		trips = append(trips, *t)
	}
	return trips, nil
}

func (r *tripRepo) ListByDriverID(ctx context.Context, driverID uuid.UUID, limit, offset int) ([]domain.Trip, error) {
	query := `
		SELECT 
			t.id, t.rider_id, t.driver_id, t.pickup_address, t.dropoff_address, t.status, t.fare, t.payment_status, t.route_coords, t.created_at, t.updated_at,
			ST_Y(t.pickup_location::geometry) as pickup_lat, ST_X(t.pickup_location::geometry) as pickup_lng,
			ST_Y(t.dropoff_location::geometry) as dropoff_lat, ST_X(t.dropoff_location::geometry) as dropoff_lng,
			r.name as rider_name, r.email as rider_email, r.phone as rider_phone,
			d.license_number as driver_license, d.status as driver_status, d.rating as driver_rating,
			du.name as driver_name, du.phone as driver_phone
		FROM trips t
		JOIN users r ON t.rider_id = r.id
		LEFT JOIN drivers d ON t.driver_id = d.id
		LEFT JOIN users du ON d.user_id = du.id
		WHERE t.driver_id = $1
		ORDER BY t.created_at DESC
		LIMIT $2 OFFSET $3
	`
	rows, err := r.db.QueryContext(ctx, query, driverID, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var trips []domain.Trip
	for rows.Next() {
		t, err := scanTripRows(rows)
		if err != nil {
			return nil, err
		}
		trips = append(trips, *t)
	}
	return trips, nil
}

// Helpers for scanning
func scanTrip(row *sql.Row) (*domain.Trip, error) {
	var t domain.Trip
	var rUser domain.User
	var dLicense, dStatus sql.NullString
	var dRating sql.NullFloat64
	var dName, dPhone sql.NullString
	var driverIDNull uuid.NullUUID
	var routeCoords sql.NullString

	err := row.Scan(
		&t.ID, &t.RiderID, &driverIDNull, &t.PickupAddress, &t.DropoffAddress, &t.Status, &t.Fare, &t.PaymentStatus, &routeCoords, &t.CreatedAt, &t.UpdatedAt,
		&t.PickupLat, &t.PickupLng, &t.DropoffLat, &t.DropoffLng,
		&rUser.Name, &rUser.Email, &rUser.Phone,
		&dLicense, &dStatus, &dRating, &dName, &dPhone,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	t.Rider = &domain.User{
		ID:    t.RiderID,
		Name:  rUser.Name,
		Email: rUser.Email,
		Phone: rUser.Phone,
		Role:  domain.RoleRider,
	}

	if routeCoords.Valid {
		str := routeCoords.String
		t.RouteCoords = &str
	}

	if driverIDNull.Valid {
		id := driverIDNull.UUID
		t.DriverID = &id

		t.Driver = &domain.Driver{
			ID:            id,
			LicenseNumber: dLicense.String,
			Status:        domain.DriverStatus(dStatus.String),
			Rating:        dRating.Float64,
			User: &domain.User{
				Name:  dName.String,
				Phone: dPhone.String,
				Role:  domain.RoleDriver,
			},
		}
	}

	return &t, nil
}

func scanTripRows(rows *sql.Rows) (*domain.Trip, error) {
	var t domain.Trip
	var rUser domain.User
	var dLicense, dStatus sql.NullString
	var dRating sql.NullFloat64
	var dName, dPhone sql.NullString
	var driverIDNull uuid.NullUUID
	var routeCoords sql.NullString

	err := rows.Scan(
		&t.ID, &t.RiderID, &driverIDNull, &t.PickupAddress, &t.DropoffAddress, &t.Status, &t.Fare, &t.PaymentStatus, &routeCoords, &t.CreatedAt, &t.UpdatedAt,
		&t.PickupLat, &t.PickupLng, &t.DropoffLat, &t.DropoffLng,
		&rUser.Name, &rUser.Email, &rUser.Phone,
		&dLicense, &dStatus, &dRating, &dName, &dPhone,
	)
	if err != nil {
		return nil, err
	}

	t.Rider = &domain.User{
		ID:    t.RiderID,
		Name:  rUser.Name,
		Email: rUser.Email,
		Phone: rUser.Phone,
		Role:  domain.RoleRider,
	}

	if routeCoords.Valid {
		str := routeCoords.String
		t.RouteCoords = &str
	}

	if driverIDNull.Valid {
		id := driverIDNull.UUID
		t.DriverID = &id

		t.Driver = &domain.Driver{
			ID:            id,
			LicenseNumber: dLicense.String,
			Status:        domain.DriverStatus(dStatus.String),
			Rating:        dRating.Float64,
			User: &domain.User{
				Name:  dName.String,
				Phone: dPhone.String,
				Role:  domain.RoleDriver,
			},
		}
	}

	return &t, nil
}
