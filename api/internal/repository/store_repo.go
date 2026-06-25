package repository

import (
	"context"
	"database/sql"
	"errors"

	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/database"
	"github.com/zekdrive/api/internal/domain"
)

type storeRepo struct {
	db *database.PostgresDB
}

func NewStoreRepository(db *database.PostgresDB) domain.StoreRepository {
	return &storeRepo{db: db}
}

// Store Profile

func (r *storeRepo) CreateStore(ctx context.Context, s *domain.Store) error {
	query := `
		INSERT INTO stores (id, user_id, name, description, image_url, location, address, rating, is_active, type, category, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, ST_SetSRID(ST_MakePoint($6, $7), 4326), $8, $9, $10, $11, $12, $13, $14)
	`
	_, err := r.db.ExecContext(ctx, query,
		s.ID, s.UserID, s.Name, s.Description, s.ImageUrl,
		s.Longitude, s.Latitude, s.Address, s.Rating, s.IsActive, string(s.Type), s.Category, s.CreatedAt, s.UpdatedAt,
	)
	return err
}

func (r *storeRepo) GetStoreByID(ctx context.Context, id uuid.UUID) (*domain.Store, error) {
	query := `
		SELECT 
			id, user_id, name, description, image_url, address, rating, is_active, type, category, created_at, updated_at,
			ST_Y(location::geometry) as latitude,
			ST_X(location::geometry) as longitude
		FROM stores
		WHERE id = $1
	`
	s := &domain.Store{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&s.ID, &s.UserID, &s.Name, &s.Description, &s.ImageUrl, &s.Address, &s.Rating, &s.IsActive, &s.Type, &s.Category, &s.CreatedAt, &s.UpdatedAt,
		&s.Latitude, &s.Longitude,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return s, nil
}

func (r *storeRepo) GetStoreByUserID(ctx context.Context, userID uuid.UUID) (*domain.Store, error) {
	query := `
		SELECT 
			id, user_id, name, description, image_url, address, rating, is_active, type, category, created_at, updated_at,
			ST_Y(location::geometry) as latitude,
			ST_X(location::geometry) as longitude
		FROM stores
		WHERE user_id = $1
	`
	s := &domain.Store{}
	err := r.db.QueryRowContext(ctx, query, userID).Scan(
		&s.ID, &s.UserID, &s.Name, &s.Description, &s.ImageUrl, &s.Address, &s.Rating, &s.IsActive, &s.Type, &s.Category, &s.CreatedAt, &s.UpdatedAt,
		&s.Latitude, &s.Longitude,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return s, nil
}

func (r *storeRepo) UpdateStore(ctx context.Context, s *domain.Store) error {
	query := `
		UPDATE stores
		SET name = $1, description = $2, image_url = $3, address = $4, rating = $5, is_active = $6,
			location = ST_SetSRID(ST_MakePoint($7, $8), 4326), type = $9, category = $10, updated_at = $11
		WHERE id = $12
	`
	_, err := r.db.ExecContext(ctx, query,
		s.Name, s.Description, s.ImageUrl, s.Address, s.Rating, s.IsActive,
		s.Longitude, s.Latitude, string(s.Type), s.Category, s.UpdatedAt, s.ID,
	)
	return err
}

func (r *storeRepo) ListNearbyStores(ctx context.Context, lat, lng float64, radius float64, search string, storeType string) ([]domain.Store, error) {
	query := `
		SELECT 
			id, user_id, name, description, image_url, address, rating, is_active, type, category, created_at, updated_at,
			ST_Y(location::geometry) as latitude,
			ST_X(location::geometry) as longitude,
			ST_Distance(location::geography, ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography) as distance
		FROM stores
		WHERE is_active = true
		  AND ($3 = '' OR name ILIKE '%' || $3 || '%' OR description ILIKE '%' || $3 || '%')
		  AND ($5 = '' OR type = $5)
		  AND ST_DWithin(location::geography, ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography, $4)
		ORDER BY distance ASC
	`
	rows, err := r.db.QueryContext(ctx, query, lng, lat, search, radius, storeType)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var stores []domain.Store
	for rows.Next() {
		s := domain.Store{}
		err := rows.Scan(
			&s.ID, &s.UserID, &s.Name, &s.Description, &s.ImageUrl, &s.Address, &s.Rating, &s.IsActive, &s.Type, &s.Category, &s.CreatedAt, &s.UpdatedAt,
			&s.Latitude, &s.Longitude, &s.Distance,
		)
		if err != nil {
			return nil, err
		}
		stores = append(stores, s)
	}
	return stores, nil
}

// ListAllStores returns a paginated list of all stores for admin panel usage
func (r *storeRepo) ListAllStores(ctx context.Context, storeType string, search string, limit, offset int) ([]domain.Store, error) {
	query := `
		SELECT 
			id, user_id, name, description, image_url, address, rating, is_active, type, category, created_at, updated_at,
			ST_Y(location::geometry) as latitude,
			ST_X(location::geometry) as longitude
		FROM stores
		WHERE ($1 = '' OR type = $1)
		  AND ($2 = '' OR name ILIKE '%' || $2 || '%' OR description ILIKE '%' || $2 || '%')
		ORDER BY created_at DESC
		LIMIT $3 OFFSET $4
	`
	rows, err := r.db.QueryContext(ctx, query, storeType, search, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var stores []domain.Store
	for rows.Next() {
		s := domain.Store{}
		err := rows.Scan(
			&s.ID, &s.UserID, &s.Name, &s.Description, &s.ImageUrl, &s.Address, &s.Rating, &s.IsActive, &s.Type, &s.Category, &s.CreatedAt, &s.UpdatedAt,
			&s.Latitude, &s.Longitude,
		)
		if err != nil {
			return nil, err
		}
		stores = append(stores, s)
	}
	return stores, nil
}

// Schedules

func (r *storeRepo) GetSchedules(ctx context.Context, storeID uuid.UUID) ([]domain.StoreSchedule, error) {
	query := `
		SELECT id, store_id, day_of_week, open_time, close_time, is_closed
		FROM store_schedules
		WHERE store_id = $1
		ORDER BY day_of_week ASC
	`
	rows, err := r.db.QueryContext(ctx, query, storeID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var schedules []domain.StoreSchedule
	for rows.Next() {
		s := domain.StoreSchedule{}
		err := rows.Scan(&s.ID, &s.StoreID, &s.DayOfWeek, &s.OpenTime, &s.CloseTime, &s.IsClosed)
		if err != nil {
			return nil, err
		}
		schedules = append(schedules, s)
	}
	return schedules, nil
}

func (r *storeRepo) UpsertSchedule(ctx context.Context, s *domain.StoreSchedule) error {
	query := `
		INSERT INTO store_schedules (id, store_id, day_of_week, open_time, close_time, is_closed)
		VALUES ($1, $2, $3, $4, $5, $6)
		ON CONFLICT (store_id, day_of_week) 
		DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = EXCLUDED.is_closed
	`
	_, err := r.db.ExecContext(ctx, query, s.ID, s.StoreID, s.DayOfWeek, s.OpenTime, s.CloseTime, s.IsClosed)
	return err
}

// Products

func (r *storeRepo) CreateProduct(ctx context.Context, p *domain.Product) error {
	query := `
		INSERT INTO products (id, store_id, name, description, price, image_url, is_featured, is_deliverable, is_active, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
	`
	_, err := r.db.ExecContext(ctx, query,
		p.ID, p.StoreID, p.Name, p.Description, p.Price, p.ImageUrl,
		p.IsFeatured, p.IsDeliverable, p.IsActive, p.CreatedAt, p.UpdatedAt,
	)
	return err
}

func (r *storeRepo) GetProductByID(ctx context.Context, id uuid.UUID) (*domain.Product, error) {
	query := `
		SELECT id, store_id, name, description, price, image_url, is_featured, is_deliverable, is_active, created_at, updated_at
		FROM products
		WHERE id = $1
	`
	p := &domain.Product{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&p.ID, &p.StoreID, &p.Name, &p.Description, &p.Price, &p.ImageUrl,
		&p.IsFeatured, &p.IsDeliverable, &p.IsActive, &p.CreatedAt, &p.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return p, nil
}

func (r *storeRepo) UpdateProduct(ctx context.Context, p *domain.Product) error {
	query := `
		UPDATE products
		SET name = $1, description = $2, price = $3, image_url = $4, is_featured = $5, is_deliverable = $6, is_active = $7, updated_at = $8
		WHERE id = $9
	`
	_, err := r.db.ExecContext(ctx, query,
		p.Name, p.Description, p.Price, p.ImageUrl, p.IsFeatured, p.IsDeliverable, p.IsActive, p.UpdatedAt, p.ID,
	)
	return err
}

func (r *storeRepo) DeleteProduct(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM products WHERE id = $1`
	_, err := r.db.ExecContext(ctx, query, id)
	return err
}

func (r *storeRepo) ListProducts(ctx context.Context, storeID uuid.UUID, activeOnly bool) ([]domain.Product, error) {
	query := `
		SELECT id, store_id, name, description, price, image_url, is_featured, is_deliverable, is_active, created_at, updated_at
		FROM products
		WHERE store_id = $1
	`
	if activeOnly {
		query += " AND is_active = true"
	}
	query += " ORDER BY is_featured DESC, name ASC"

	rows, err := r.db.QueryContext(ctx, query, storeID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var products []domain.Product
	for rows.Next() {
		p := domain.Product{}
		err := rows.Scan(
			&p.ID, &p.StoreID, &p.Name, &p.Description, &p.Price, &p.ImageUrl,
			&p.IsFeatured, &p.IsDeliverable, &p.IsActive, &p.CreatedAt, &p.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		products = append(products, p)
	}
	return products, nil
}

// Orders

func (r *storeRepo) CreateOrder(ctx context.Context, o *domain.StoreOrder) error {
	tx, err := r.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// Insert order
	var orderQuery string
	var errOrder error
	if o.DeliveryType == "delivery" {
		orderQuery = `
			INSERT INTO store_orders (id, customer_id, store_id, driver_id, status, delivery_type, delivery_address, delivery_location, delivery_fare, items_total, total_fare, payment_status, pickup_otp, created_at, updated_at)
			VALUES ($1, $2, $3, $4, $5, $6, $7, ST_SetSRID(ST_MakePoint($8, $9), 4326), $10, $11, $12, $13, $14, $15, $16)
		`
		_, errOrder = tx.ExecContext(ctx, orderQuery,
			o.ID, o.CustomerID, o.StoreID, o.DriverID, o.Status, o.DeliveryType,
			o.DeliveryAddress, o.DeliveryLng, o.DeliveryLat, o.DeliveryFare, o.ItemsTotal,
			o.TotalFare, o.PaymentStatus, o.PickupOTP, o.CreatedAt, o.UpdatedAt,
		)
	} else {
		orderQuery = `
			INSERT INTO store_orders (id, customer_id, store_id, driver_id, status, delivery_type, delivery_fare, items_total, total_fare, payment_status, pickup_otp, created_at, updated_at)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
		`
		_, errOrder = tx.ExecContext(ctx, orderQuery,
			o.ID, o.CustomerID, o.StoreID, o.DriverID, o.Status, o.DeliveryType,
			o.DeliveryFare, o.ItemsTotal, o.TotalFare, o.PaymentStatus, o.PickupOTP, o.CreatedAt, o.UpdatedAt,
		)
	}

	if errOrder != nil {
		return errOrder
	}

	// Insert items
	itemQuery := `
		INSERT INTO store_order_items (id, order_id, product_id, quantity, price)
		VALUES ($1, $2, $3, $4, $5)
	`
	for _, item := range o.Items {
		_, err = tx.ExecContext(ctx, itemQuery, uuid.New(), o.ID, item.ProductID, item.Quantity, item.Price)
		if err != nil {
			return err
		}
	}

	return tx.Commit()
}

func (r *storeRepo) GetOrderByID(ctx context.Context, id uuid.UUID) (*domain.StoreOrder, error) {
	query := `
		SELECT 
			o.id, o.customer_id, o.store_id, o.driver_id, o.status, o.delivery_type, 
			o.delivery_address, o.delivery_fare, o.items_total, o.total_fare, 
			o.payment_status, o.pickup_otp, o.created_at, o.updated_at,
			COALESCE(ST_Y(o.delivery_location::geometry), 0.0) as delivery_lat,
			COALESCE(ST_X(o.delivery_location::geometry), 0.0) as delivery_lng,
			u.name as customer_name, u.phone as customer_phone,
			s.name as store_name, s.address as store_address
		FROM store_orders o
		JOIN users u ON o.customer_id = u.id
		JOIN stores s ON o.store_id = s.id
		WHERE o.id = $1
	`
	o := &domain.StoreOrder{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&o.ID, &o.CustomerID, &o.StoreID, &o.DriverID, &o.Status, &o.DeliveryType,
		&o.DeliveryAddress, &o.DeliveryFare, &o.ItemsTotal, &o.TotalFare,
		&o.PaymentStatus, &o.PickupOTP, &o.CreatedAt, &o.UpdatedAt,
		&o.DeliveryLat, &o.DeliveryLng,
		&o.CustomerName, &o.CustomerPhone,
		&o.StoreName, &o.StoreAddress,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	// Fetch items
	itemQuery := `
		SELECT oi.id, oi.order_id, oi.product_id, oi.quantity, oi.price, p.name as product_name
		FROM store_order_items oi
		JOIN products p ON oi.product_id = p.id
		WHERE oi.order_id = $1
	`
	rows, err := r.db.QueryContext(ctx, itemQuery, o.ID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		item := domain.StoreOrderItem{}
		err := rows.Scan(&item.ID, &item.OrderID, &item.ProductID, &item.Quantity, &item.Price, &item.ProductName)
		if err != nil {
			return nil, err
		}
		o.Items = append(o.Items, item)
	}

	return o, nil
}

func (r *storeRepo) UpdateOrder(ctx context.Context, o *domain.StoreOrder) error {
	var query string
	var err error
	if o.DeliveryType == "delivery" && o.DeliveryLat != 0.0 {
		query = `
			UPDATE store_orders
			SET driver_id = $1, status = $2, payment_status = $3, delivery_address = $4,
				delivery_location = ST_SetSRID(ST_MakePoint($5, $6), 4326), updated_at = $7
			WHERE id = $8
		`
		_, err = r.db.ExecContext(ctx, query, o.DriverID, o.Status, o.PaymentStatus, o.DeliveryAddress, o.DeliveryLng, o.DeliveryLat, o.UpdatedAt, o.ID)
	} else {
		query = `
			UPDATE store_orders
			SET driver_id = $1, status = $2, payment_status = $3, updated_at = $4
			WHERE id = $5
		`
		_, err = r.db.ExecContext(ctx, query, o.DriverID, o.Status, o.PaymentStatus, o.UpdatedAt, o.ID)
	}
	return err
}

func (r *storeRepo) ListOrdersByCustomerID(ctx context.Context, customerID uuid.UUID, limit, offset int) ([]domain.StoreOrder, error) {
	query := `
		SELECT 
			o.id, o.customer_id, o.store_id, o.driver_id, o.status, o.delivery_type, 
			o.delivery_address, o.delivery_fare, o.items_total, o.total_fare, 
			o.payment_status, o.pickup_otp, o.created_at, o.updated_at,
			COALESCE(ST_Y(o.delivery_location::geometry), 0.0) as delivery_lat,
			COALESCE(ST_X(o.delivery_location::geometry), 0.0) as delivery_lng,
			u.name as customer_name, u.phone as customer_phone,
			s.name as store_name, s.address as store_address
		FROM store_orders o
		JOIN users u ON o.customer_id = u.id
		JOIN stores s ON o.store_id = s.id
		WHERE o.customer_id = $1
		ORDER BY o.created_at DESC
		LIMIT $2 OFFSET $3
	`
	rows, err := r.db.QueryContext(ctx, query, customerID, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var orders []domain.StoreOrder
	for rows.Next() {
		o := domain.StoreOrder{}
		err := rows.Scan(
			&o.ID, &o.CustomerID, &o.StoreID, &o.DriverID, &o.Status, &o.DeliveryType,
			&o.DeliveryAddress, &o.DeliveryFare, &o.ItemsTotal, &o.TotalFare,
			&o.PaymentStatus, &o.PickupOTP, &o.CreatedAt, &o.UpdatedAt,
			&o.DeliveryLat, &o.DeliveryLng,
			&o.CustomerName, &o.CustomerPhone,
			&o.StoreName, &o.StoreAddress,
		)
		if err != nil {
			return nil, err
		}
		orders = append(orders, o)
	}
	return orders, nil
}

func (r *storeRepo) ListOrdersByStoreID(ctx context.Context, storeID uuid.UUID, limit, offset int) ([]domain.StoreOrder, error) {
	query := `
		SELECT 
			o.id, o.customer_id, o.store_id, o.driver_id, o.status, o.delivery_type, 
			o.delivery_address, o.delivery_fare, o.items_total, o.total_fare, 
			o.payment_status, o.pickup_otp, o.created_at, o.updated_at,
			COALESCE(ST_Y(o.delivery_location::geometry), 0.0) as delivery_lat,
			COALESCE(ST_X(o.delivery_location::geometry), 0.0) as delivery_lng,
			u.name as customer_name, u.phone as customer_phone,
			s.name as store_name, s.address as store_address
		FROM store_orders o
		JOIN users u ON o.customer_id = u.id
		JOIN stores s ON o.store_id = s.id
		WHERE o.store_id = $1
		ORDER BY o.created_at DESC
		LIMIT $2 OFFSET $3
	`
	rows, err := r.db.QueryContext(ctx, query, storeID, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var orders []domain.StoreOrder
	for rows.Next() {
		o := domain.StoreOrder{}
		err := rows.Scan(
			&o.ID, &o.CustomerID, &o.StoreID, &o.DriverID, &o.Status, &o.DeliveryType,
			&o.DeliveryAddress, &o.DeliveryFare, &o.ItemsTotal, &o.TotalFare,
			&o.PaymentStatus, &o.PickupOTP, &o.CreatedAt, &o.UpdatedAt,
			&o.DeliveryLat, &o.DeliveryLng,
			&o.CustomerName, &o.CustomerPhone,
			&o.StoreName, &o.StoreAddress,
		)
		if err != nil {
			return nil, err
		}
		orders = append(orders, o)
	}
	return orders, nil
}

func (r *storeRepo) ListOrdersForDriver(ctx context.Context, driverID uuid.UUID, limit, offset int) ([]domain.StoreOrder, error) {
	query := `
		SELECT 
			o.id, o.customer_id, o.store_id, o.driver_id, o.status, o.delivery_type, 
			o.delivery_address, o.delivery_fare, o.items_total, o.total_fare, 
			o.payment_status, o.pickup_otp, o.created_at, o.updated_at,
			COALESCE(ST_Y(o.delivery_location::geometry), 0.0) as delivery_lat,
			COALESCE(ST_X(o.delivery_location::geometry), 0.0) as delivery_lng,
			u.name as customer_name, u.phone as customer_phone,
			s.name as store_name, s.address as store_address
		FROM store_orders o
		JOIN users u ON o.customer_id = u.id
		JOIN stores s ON o.store_id = s.id
		WHERE o.driver_id = $1
		ORDER BY o.created_at DESC
		LIMIT $2 OFFSET $3
	`
	rows, err := r.db.QueryContext(ctx, query, driverID, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var orders []domain.StoreOrder
	for rows.Next() {
		o := domain.StoreOrder{}
		err := rows.Scan(
			&o.ID, &o.CustomerID, &o.StoreID, &o.DriverID, &o.Status, &o.DeliveryType,
			&o.DeliveryAddress, &o.DeliveryFare, &o.ItemsTotal, &o.TotalFare,
			&o.PaymentStatus, &o.PickupOTP, &o.CreatedAt, &o.UpdatedAt,
			&o.DeliveryLat, &o.DeliveryLng,
			&o.CustomerName, &o.CustomerPhone,
			&o.StoreName, &o.StoreAddress,
		)
		if err != nil {
			return nil, err
		}
		orders = append(orders, o)
	}
	return orders, nil
}

func (r *storeRepo) ListActiveDeliveryOrders(ctx context.Context) ([]domain.StoreOrder, error) {
	query := `
		SELECT 
			o.id, o.customer_id, o.store_id, o.driver_id, o.status, o.delivery_type, 
			o.delivery_address, o.delivery_fare, o.items_total, o.total_fare, 
			o.payment_status, o.pickup_otp, o.created_at, o.updated_at,
			COALESCE(ST_Y(o.delivery_location::geometry), 0.0) as delivery_lat,
			COALESCE(ST_X(o.delivery_location::geometry), 0.0) as delivery_lng,
			u.name as customer_name, u.phone as customer_phone,
			s.name as store_name, s.address as store_address
		FROM store_orders o
		JOIN users u ON o.customer_id = u.id
		JOIN stores s ON o.store_id = s.id
		WHERE o.delivery_type = 'delivery' AND o.status IN ('accepted', 'preparing', 'ready_for_pickup', 'delivering')
		ORDER BY o.created_at DESC
	`
	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var orders []domain.StoreOrder
	for rows.Next() {
		o := domain.StoreOrder{}
		err := rows.Scan(
			&o.ID, &o.CustomerID, &o.StoreID, &o.DriverID, &o.Status, &o.DeliveryType,
			&o.DeliveryAddress, &o.DeliveryFare, &o.ItemsTotal, &o.TotalFare,
			&o.PaymentStatus, &o.PickupOTP, &o.CreatedAt, &o.UpdatedAt,
			&o.DeliveryLat, &o.DeliveryLng,
			&o.CustomerName, &o.CustomerPhone,
			&o.StoreName, &o.StoreAddress,
		)
		if err != nil {
			return nil, err
		}
		orders = append(orders, o)
	}
	return orders, nil
}
