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

type deliveryRepo struct {
	db *database.PostgresDB
}

func NewDeliveryRepository(db *database.PostgresDB) domain.DeliveryRepository {
	return &deliveryRepo{db: db}
}

func (r *deliveryRepo) Create(ctx context.Context, d *domain.Delivery) error {
	query := `
		INSERT INTO deliveries (
			id, sender_id, driver_id, trip_id, pickup_location, dropoff_location,
			recipient_name, recipient_phone, package_details, status, fare, created_at, updated_at
		) VALUES (
			$1, $2, $3, $4, ST_SetSRID(ST_MakePoint($5, $6), 4326), ST_SetSRID(ST_MakePoint($7, $8), 4326),
			$9, $10, $11, $12, $13, $14, $15
		)
	`
	_, err := r.db.ExecContext(ctx, query,
		d.ID, d.SenderID, d.DriverID, d.TripID, d.PickupLng, d.PickupLat, d.DropoffLng, d.DropoffLat,
		d.RecipientName, d.RecipientPhone, d.PackageDetails, d.Status, d.Fare, d.CreatedAt, d.UpdatedAt,
	)
	return err
}

func (r *deliveryRepo) GetByID(ctx context.Context, id uuid.UUID) (*domain.Delivery, error) {
	query := `
		SELECT 
			d.id, d.sender_id, d.driver_id, d.trip_id, d.recipient_name, d.recipient_phone, d.package_details, d.status, d.fare, d.created_at, d.updated_at,
			ST_Y(d.pickup_location::geometry) as pickup_lat, ST_X(d.pickup_location::geometry) as pickup_lng,
			ST_Y(d.dropoff_location::geometry) as dropoff_lat, ST_X(d.dropoff_location::geometry) as dropoff_lng,
			s.name as sender_name, s.email as sender_email, s.phone as sender_phone,
			dr.license_number as driver_license, dr.status as driver_status, dr.rating as driver_rating,
			dru.name as driver_name, dru.phone as driver_phone
		FROM deliveries d
		JOIN users s ON d.sender_id = s.id
		LEFT JOIN drivers dr ON d.driver_id = dr.id
		LEFT JOIN users dru ON dr.user_id = dru.id
		WHERE d.id = $1
	`
	row := r.db.QueryRowContext(ctx, query, id)
	return scanDelivery(row)
}

func (r *deliveryRepo) Update(ctx context.Context, d *domain.Delivery) error {
	query := `
		UPDATE deliveries
		SET
			driver_id = $1,
			trip_id = $2,
			pickup_location = ST_SetSRID(ST_MakePoint($3, $4), 4326),
			dropoff_location = ST_SetSRID(ST_MakePoint($5, $6), 4326),
			recipient_name = $7,
			recipient_phone = $8,
			package_details = $9,
			status = $10,
			fare = $11,
			updated_at = $12
		WHERE id = $13
	`
	_, err := r.db.ExecContext(ctx, query,
		d.DriverID, d.TripID, d.PickupLng, d.PickupLat, d.DropoffLng, d.DropoffLat,
		d.RecipientName, d.RecipientPhone, d.PackageDetails, d.Status, d.Fare, d.UpdatedAt, d.ID,
	)
	return err
}

func (r *deliveryRepo) UpdateStatus(ctx context.Context, id uuid.UUID, status domain.DeliveryStatus) error {
	query := `UPDATE deliveries SET status = $1, updated_at = $2 WHERE id = $3`
	_, err := r.db.ExecContext(ctx, query, status, time.Now(), id)
	return err
}

func (r *deliveryRepo) UpdateDriver(ctx context.Context, id uuid.UUID, driverID uuid.UUID) error {
	query := `UPDATE deliveries SET driver_id = $1, updated_at = $2 WHERE id = $3`
	_, err := r.db.ExecContext(ctx, query, driverID, time.Now(), id)
	return err
}

func (r *deliveryRepo) ListBySenderID(ctx context.Context, senderID uuid.UUID, limit, offset int) ([]domain.Delivery, error) {
	query := `
		SELECT 
			d.id, d.sender_id, d.driver_id, d.trip_id, d.recipient_name, d.recipient_phone, d.package_details, d.status, d.fare, d.created_at, d.updated_at,
			ST_Y(d.pickup_location::geometry) as pickup_lat, ST_X(d.pickup_location::geometry) as pickup_lng,
			ST_Y(d.dropoff_location::geometry) as dropoff_lat, ST_X(d.dropoff_location::geometry) as dropoff_lng,
			s.name as sender_name, s.email as sender_email, s.phone as sender_phone,
			dr.license_number as driver_license, dr.status as driver_status, dr.rating as driver_rating,
			dru.name as driver_name, dru.phone as driver_phone
		FROM deliveries d
		JOIN users s ON d.sender_id = s.id
		LEFT JOIN drivers dr ON d.driver_id = dr.id
		LEFT JOIN users dru ON dr.user_id = dru.id
		WHERE d.sender_id = $1
		ORDER BY d.created_at DESC
		LIMIT $2 OFFSET $3
	`
	rows, err := r.db.QueryContext(ctx, query, senderID, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var deliveries []domain.Delivery
	for rows.Next() {
		del, err := scanDeliveryRows(rows)
		if err != nil {
			return nil, err
		}
		deliveries = append(deliveries, *del)
	}
	return deliveries, nil
}

func (r *deliveryRepo) ListByDriverID(ctx context.Context, driverID uuid.UUID, limit, offset int) ([]domain.Delivery, error) {
	query := `
		SELECT 
			d.id, d.sender_id, d.driver_id, d.trip_id, d.recipient_name, d.recipient_phone, d.package_details, d.status, d.fare, d.created_at, d.updated_at,
			ST_Y(d.pickup_location::geometry) as pickup_lat, ST_X(d.pickup_location::geometry) as pickup_lng,
			ST_Y(d.dropoff_location::geometry) as dropoff_lat, ST_X(d.dropoff_location::geometry) as dropoff_lng,
			s.name as sender_name, s.email as sender_email, s.phone as sender_phone,
			dr.license_number as driver_license, dr.status as driver_status, dr.rating as driver_rating,
			dru.name as driver_name, dru.phone as driver_phone
		FROM deliveries d
		JOIN users s ON d.sender_id = s.id
		LEFT JOIN drivers dr ON d.driver_id = dr.id
		LEFT JOIN users dru ON dr.user_id = dru.id
		WHERE d.driver_id = $1
		ORDER BY d.created_at DESC
		LIMIT $2 OFFSET $3
	`
	rows, err := r.db.QueryContext(ctx, query, driverID, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var deliveries []domain.Delivery
	for rows.Next() {
		del, err := scanDeliveryRows(rows)
		if err != nil {
			return nil, err
		}
		deliveries = append(deliveries, *del)
	}
	return deliveries, nil
}

// Helpers for scanning
func scanDelivery(row *sql.Row) (*domain.Delivery, error) {
	var d domain.Delivery
	var sUser domain.User
	var drLicense, drStatus sql.NullString
	var drRating sql.NullFloat64
	var drName, drPhone sql.NullString
	var driverIDNull, tripIDNull uuid.NullUUID

	err := row.Scan(
		&d.ID, &d.SenderID, &driverIDNull, &tripIDNull, &d.RecipientName, &d.RecipientPhone, &d.PackageDetails, &d.Status, &d.Fare, &d.CreatedAt, &d.UpdatedAt,
		&d.PickupLat, &d.PickupLng, &d.DropoffLat, &d.DropoffLng,
		&sUser.Name, &sUser.Email, &sUser.Phone,
		&drLicense, &drStatus, &drRating, &drName, &drPhone,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	d.Sender = &domain.User{
		ID:    d.SenderID,
		Name:  sUser.Name,
		Email: sUser.Email,
		Phone: sUser.Phone,
		Role:  domain.RoleRider,
	}

	if tripIDNull.Valid {
		id := tripIDNull.UUID
		d.TripID = &id
	}

	if driverIDNull.Valid {
		id := driverIDNull.UUID
		d.DriverID = &id

		d.Driver = &domain.Driver{
			ID:            id,
			LicenseNumber: drLicense.String,
			Status:        domain.DriverStatus(drStatus.String),
			Rating:        drRating.Float64,
			User: &domain.User{
				Name:  drName.String,
				Phone: drPhone.String,
				Role:  domain.RoleDriver,
			},
		}
	}

	return &d, nil
}

func scanDeliveryRows(rows *sql.Rows) (*domain.Delivery, error) {
	var d domain.Delivery
	var sUser domain.User
	var drLicense, drStatus sql.NullString
	var drRating sql.NullFloat64
	var drName, drPhone sql.NullString
	var driverIDNull, tripIDNull uuid.NullUUID

	err := rows.Scan(
		&d.ID, &d.SenderID, &driverIDNull, &tripIDNull, &d.RecipientName, &d.RecipientPhone, &d.PackageDetails, &d.Status, &d.Fare, &d.CreatedAt, &d.UpdatedAt,
		&d.PickupLat, &d.PickupLng, &d.DropoffLat, &d.DropoffLng,
		&sUser.Name, &sUser.Email, &sUser.Phone,
		&drLicense, &drStatus, &drRating, &drName, &drPhone,
	)
	if err != nil {
		return nil, err
	}

	d.Sender = &domain.User{
		ID:    d.SenderID,
		Name:  sUser.Name,
		Email: sUser.Email,
		Phone: sUser.Phone,
		Role:  domain.RoleRider,
	}

	if tripIDNull.Valid {
		id := tripIDNull.UUID
		d.TripID = &id
	}

	if driverIDNull.Valid {
		id := driverIDNull.UUID
		d.DriverID = &id

		d.Driver = &domain.Driver{
			ID:            id,
			LicenseNumber: drLicense.String,
			Status:        domain.DriverStatus(drStatus.String),
			Rating:        drRating.Float64,
			User: &domain.User{
				Name:  drName.String,
				Phone: drPhone.String,
				Role:  domain.RoleDriver,
			},
		}
	}

	return &d, nil
}
