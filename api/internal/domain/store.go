package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

// StoreType differentiates the kind of store
type StoreType string

const (
	// Restauration
	StoreTypeRestaurant StoreType = "restaurant"   // Restaurant / Maquis / Fast-food
	StoreTypeCafe       StoreType = "cafe"          // Café / Salon de thé / Pâtisserie
	StoreTypeBakery     StoreType = "bakery"        // Boulangerie

	// Commerce alimentaire
	StoreTypeGrocery    StoreType = "grocery"       // Épicerie / Superette
	StoreTypeButcher    StoreType = "butcher"       // Boucherie / Charcuterie
	StoreTypeFishmonger StoreType = "fishmonger"    // Poissonnerie

	// Santé & Beauté
	StoreTypePharmacy   StoreType = "pharmacy"      // Pharmacie
	StoreTypeBeauty     StoreType = "beauty"        // Cosmétiques / Coiffure / Beauté

	// Mode & Textile
	StoreTypeClothing   StoreType = "clothing"      // Vêtements / Mode / Prêt-à-porter
	StoreTypeBoutique   StoreType = "boutique"      // Boutique générale / Multi-articles

	// Maison & Matériaux
	StoreTypeHardware   StoreType = "hardware"      // Quincaillerie / Bricolage
	StoreTypeFurniture  StoreType = "furniture"     // Meubles / Décoration

	// High-Tech
	StoreTypeElectronics StoreType = "electronics"  // Électronique / Téléphonie / Informatique

	// Autre
	StoreTypeOther      StoreType = "other"         // Autre / Non catégorisé
)

type Store struct {
	ID          uuid.UUID `json:"id" db:"id"`
	UserID      uuid.UUID `json:"user_id" db:"user_id"`
	Name        string    `json:"name" db:"name"`
	Description string    `json:"description" db:"description"`
	ImageUrl    string    `json:"image_url" db:"image_url"`
	Latitude    float64   `json:"latitude" db:"latitude"`
	Longitude   float64   `json:"longitude" db:"longitude"`
	Address     string    `json:"address" db:"address"`
	Rating      float64   `json:"rating" db:"rating"`
	IsActive    bool      `json:"is_active" db:"is_active"`
	Type        StoreType `json:"type" db:"type"`       // restaurant, boutique, grocery, pharmacy, other
	Category    string    `json:"category" db:"category"` // e.g. "Fast-food", "Clothing"
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`

	Distance float64         `json:"distance,omitempty"` // Distance in meters (for geo queries)
	Schedule []StoreSchedule `json:"schedule,omitempty"`
}

type StoreSchedule struct {
	ID        uuid.UUID `json:"id" db:"id"`
	StoreID   uuid.UUID `json:"store_id" db:"store_id"`
	DayOfWeek int       `json:"day_of_week" db:"day_of_week"` // 0 = Sunday, 1 = Monday, etc.
	OpenTime  string    `json:"open_time" db:"open_time"`   // "08:00"
	CloseTime string    `json:"close_time" db:"close_time"`  // "22:00"
	IsClosed  bool      `json:"is_closed" db:"is_closed"`
}

type Product struct {
	ID            uuid.UUID `json:"id" db:"id"`
	StoreID       uuid.UUID `json:"store_id" db:"store_id"`
	Name          string    `json:"name" db:"name"`
	Description   string    `json:"description" db:"description"`
	Price         float64   `json:"price" db:"price"`
	ImageUrl      string    `json:"image_url" db:"image_url"`
	IsFeatured    bool      `json:"is_featured" db:"is_featured"`
	IsDeliverable bool      `json:"is_deliverable" db:"is_deliverable"`
	IsActive      bool      `json:"is_active" db:"is_active"`
	CreatedAt     time.Time `json:"created_at" db:"created_at"`
	UpdatedAt     time.Time `json:"updated_at" db:"updated_at"`
}

type StoreOrder struct {
	ID               uuid.UUID        `json:"id" db:"id"`
	CustomerID       uuid.UUID        `json:"customer_id" db:"customer_id"`
	StoreID          uuid.UUID        `json:"store_id" db:"store_id"`
	DriverID         *uuid.UUID       `json:"driver_id" db:"driver_id"`
	Status           string           `json:"status" db:"status"` // pending, accepted, preparing, ready_for_pickup, delivering, delivered, completed, cancelled
	DeliveryType     string           `json:"delivery_type" db:"delivery_type"` // delivery, pickup
	DeliveryAddress  string           `json:"delivery_address" db:"delivery_address"`
	DeliveryLat      float64          `json:"delivery_lat" db:"delivery_lat"`
	DeliveryLng      float64          `json:"delivery_lng" db:"delivery_lng"`
	DeliveryFare     float64          `json:"delivery_fare" db:"delivery_fare"`
	ItemsTotal       float64          `json:"items_total" db:"items_total"`
	TotalFare        float64          `json:"total_fare" db:"total_fare"`
	PaymentStatus    string           `json:"payment_status" db:"payment_status"`
	PickupOTP        string           `json:"pickup_otp" db:"pickup_otp"`
	CreatedAt        time.Time        `json:"created_at" db:"created_at"`
	UpdatedAt        time.Time        `json:"updated_at" db:"updated_at"`

	// Relations
	CustomerName string           `json:"customer_name,omitempty" db:"customer_name"`
	CustomerPhone string          `json:"customer_phone,omitempty" db:"customer_phone"`
	StoreName    string           `json:"store_name,omitempty" db:"store_name"`
	StoreAddress string           `json:"store_address,omitempty" db:"store_address"`
	Items        []StoreOrderItem `json:"items,omitempty"`
	Driver       *Driver          `json:"driver,omitempty"`
}

type StoreOrderItem struct {
	ID          uuid.UUID `json:"id" db:"id"`
	OrderID     uuid.UUID `json:"order_id" db:"order_id"`
	ProductID   uuid.UUID `json:"product_id" db:"product_id"`
	Quantity    int       `json:"quantity" db:"quantity"`
	Price       float64   `json:"price" db:"price"`
	ProductName string    `json:"product_name,omitempty" db:"product_name"`
}

// Request payload types

type CreateStoreRequest struct {
	Name        string    `json:"name" validate:"required,min=2,max=100"`
	Description string    `json:"description"`
	ImageUrl    string    `json:"image_url"`
	Latitude    float64   `json:"latitude" validate:"required,latitude"`
	Longitude   float64   `json:"longitude" validate:"required,longitude"`
	Address     string    `json:"address" validate:"required"`
	Type        StoreType `json:"type" validate:"required,oneof=restaurant cafe bakery grocery butcher fishmonger pharmacy beauty clothing boutique hardware furniture electronics other"`
	Category    string    `json:"category"`
}

type UpdateScheduleItem struct {
	DayOfWeek int    `json:"day_of_week" validate:"required,min=0,max=6"`
	OpenTime  string `json:"open_time" validate:"required"`
	CloseTime string `json:"close_time" validate:"required"`
	IsClosed  bool   `json:"is_closed"`
}

type UpdateScheduleRequest struct {
	Schedules []UpdateScheduleItem `json:"schedules" validate:"required"`
}

type CreateProductRequest struct {
	Name          string  `json:"name" validate:"required,min=2,max=100"`
	Description   string  `json:"description"`
	Price         float64 `json:"price" validate:"required,gt=0"`
	ImageUrl      string  `json:"image_url"`
	IsFeatured    bool    `json:"is_featured"`
	IsDeliverable bool    `json:"is_deliverable"`
	IsActive      bool    `json:"is_active"`
}

type OrderItemRequest struct {
	ProductID uuid.UUID `json:"product_id" validate:"required"`
	Quantity  int       `json:"quantity" validate:"required,gt=0"`
}

type CreateStoreOrderRequest struct {
	StoreID         uuid.UUID          `json:"store_id" validate:"required"`
	DeliveryType    string             `json:"delivery_type" validate:"required,oneof=delivery pickup"`
	DeliveryAddress string             `json:"delivery_address"`
	DeliveryLat     float64            `json:"delivery_lat"`
	DeliveryLng     float64            `json:"delivery_lng"`
	Items           []OrderItemRequest `json:"items" validate:"required,divby=1"`
}

type UpdateStoreOrderStatus struct {
	Status string `json:"status" validate:"required,oneof=accepted preparing ready_for_pickup delivering delivered completed cancelled"`
}

// Interfaces

type StoreRepository interface {
	// Store profile
	CreateStore(ctx context.Context, store *Store) error
	GetStoreByID(ctx context.Context, id uuid.UUID) (*Store, error)
	GetStoreByUserID(ctx context.Context, userID uuid.UUID) (*Store, error)
	UpdateStore(ctx context.Context, store *Store) error
	ListNearbyStores(ctx context.Context, lat, lng float64, radius float64, search string, storeType string) ([]Store, error)
	ListAllStores(ctx context.Context, storeType string, search string, limit, offset int) ([]Store, error)

	// Schedules
	GetSchedules(ctx context.Context, storeID uuid.UUID) ([]StoreSchedule, error)
	UpsertSchedule(ctx context.Context, schedule *StoreSchedule) error

	// Products
	CreateProduct(ctx context.Context, product *Product) error
	GetProductByID(ctx context.Context, id uuid.UUID) (*Product, error)
	UpdateProduct(ctx context.Context, product *Product) error
	DeleteProduct(ctx context.Context, id uuid.UUID) error
	ListProducts(ctx context.Context, storeID uuid.UUID, activeOnly bool) ([]Product, error)

	// Orders
	CreateOrder(ctx context.Context, order *StoreOrder) error
	GetOrderByID(ctx context.Context, id uuid.UUID) (*StoreOrder, error)
	UpdateOrder(ctx context.Context, order *StoreOrder) error
	ListOrdersByCustomerID(ctx context.Context, customerID uuid.UUID, limit, offset int) ([]StoreOrder, error)
	ListOrdersByStoreID(ctx context.Context, storeID uuid.UUID, limit, offset int) ([]StoreOrder, error)
	ListOrdersForDriver(ctx context.Context, driverID uuid.UUID, limit, offset int) ([]StoreOrder, error)
	ListActiveDeliveryOrders(ctx context.Context) ([]StoreOrder, error)
}

type StoreService interface {
	// Store Profile
	CreateOrUpdateStore(ctx context.Context, userID uuid.UUID, req *CreateStoreRequest) (*Store, error)
	GetStoreProfile(ctx context.Context, userID uuid.UUID) (*Store, error)
	GetStoreDetails(ctx context.Context, storeID uuid.UUID) (*Store, error)
	ListNearbyStores(ctx context.Context, lat, lng float64, search string, storeType string) ([]Store, error)
	ListAllStores(ctx context.Context, storeType string, search string, limit, offset int) ([]Store, error)

	// Schedules
	UpdateSchedules(ctx context.Context, userID uuid.UUID, req *UpdateScheduleRequest) ([]StoreSchedule, error)
	GetSchedules(ctx context.Context, storeID uuid.UUID) ([]StoreSchedule, error)

	// Products
	CreateProduct(ctx context.Context, userID uuid.UUID, req *CreateProductRequest) (*Product, error)
	UpdateProduct(ctx context.Context, userID uuid.UUID, productID uuid.UUID, req *CreateProductRequest) (*Product, error)
	DeleteProduct(ctx context.Context, userID uuid.UUID, productID uuid.UUID) error
	ListProductsForStoreOwner(ctx context.Context, userID uuid.UUID) ([]Product, error)
	ListProductsForCustomer(ctx context.Context, storeID uuid.UUID) ([]Product, error)

	// Orders
	CreateOrder(ctx context.Context, customerID uuid.UUID, req *CreateStoreOrderRequest) (*StoreOrder, error)
	GetOrder(ctx context.Context, orderID uuid.UUID) (*StoreOrder, error)
	UpdateOrderStatusByStore(ctx context.Context, userID uuid.UUID, orderID uuid.UUID, status string) (*StoreOrder, error)
	UpdateOrderStatusByDriver(ctx context.Context, driverID uuid.UUID, orderID uuid.UUID, status string) (*StoreOrder, error)
	ListCustomerOrders(ctx context.Context, customerID uuid.UUID, limit, offset int) ([]StoreOrder, error)
	ListStoreOrders(ctx context.Context, userID uuid.UUID, limit, offset int) ([]StoreOrder, error)
	ListDriverOrders(ctx context.Context, driverID uuid.UUID, limit, offset int) ([]StoreOrder, error)
	AcceptDeliveryOrder(ctx context.Context, driverID uuid.UUID, orderID uuid.UUID) (*StoreOrder, error)
}
