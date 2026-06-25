package service

import (
	"context"
	"errors"
	"fmt"
	"math/rand"
	"time"

	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/domain"
)

type storeService struct {
	storeRepo       domain.StoreRepository
	userRepo        domain.UserRepository
	driverRepo      domain.DriverRepository
	pricingService  PricingService
	matchingService MatchingService
	notifier        NotificationService
}

func NewStoreService(
	storeRepo domain.StoreRepository,
	userRepo domain.UserRepository,
	driverRepo domain.DriverRepository,
	pricingService PricingService,
	matchingService MatchingService,
	notifier NotificationService,
) domain.StoreService {
	return &storeService{
		storeRepo:       storeRepo,
		userRepo:        userRepo,
		driverRepo:      driverRepo,
		pricingService:  pricingService,
		matchingService: matchingService,
		notifier:        notifier,
	}
}

// Store Profile

func (s *storeService) CreateOrUpdateStore(ctx context.Context, userID uuid.UUID, req *domain.CreateStoreRequest) (*domain.Store, error) {
	existing, err := s.storeRepo.GetStoreByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}

	now := time.Now()
	if existing != nil {
		existing.Name = req.Name
		existing.Description = req.Description
		existing.ImageUrl = req.ImageUrl
		existing.Address = req.Address
		existing.Latitude = req.Latitude
		existing.Longitude = req.Longitude
		existing.Type = req.Type
		existing.Category = req.Category
		existing.UpdatedAt = now
		if err := s.storeRepo.UpdateStore(ctx, existing); err != nil {
			return nil, err
		}
		return existing, nil
	}

	store := &domain.Store{
		ID:          uuid.New(),
		UserID:      userID,
		Name:        req.Name,
		Description: req.Description,
		ImageUrl:    req.ImageUrl,
		Address:     req.Address,
		Latitude:    req.Latitude,
		Longitude:   req.Longitude,
		Rating:      5.0,
		IsActive:    true,
		Type:        req.Type,
		Category:    req.Category,
		CreatedAt:   now,
		UpdatedAt:   now,
	}

	if err := s.storeRepo.CreateStore(ctx, store); err != nil {
		return nil, err
	}

	// Initialize default 7-day schedule (open 08:00 - 22:00)
	for day := 0; day <= 6; day++ {
		schedule := &domain.StoreSchedule{
			ID:        uuid.New(),
			StoreID:   store.ID,
			DayOfWeek: day,
			OpenTime:  "08:00",
			CloseTime: "22:00",
			IsClosed:  false,
		}
		_ = s.storeRepo.UpsertSchedule(ctx, schedule)
	}

	return store, nil
}

func (s *storeService) GetStoreProfile(ctx context.Context, userID uuid.UUID) (*domain.Store, error) {
	store, err := s.storeRepo.GetStoreByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if store == nil {
		return nil, errors.New("store profile not found for user")
	}

	schedules, err := s.storeRepo.GetSchedules(ctx, store.ID)
	if err == nil {
		store.Schedule = schedules
	}
	return store, nil
}

func (s *storeService) GetStoreDetails(ctx context.Context, storeID uuid.UUID) (*domain.Store, error) {
	store, err := s.storeRepo.GetStoreByID(ctx, storeID)
	if err != nil {
		return nil, err
	}
	if store == nil {
		return nil, errors.New("store not found")
	}

	schedules, err := s.storeRepo.GetSchedules(ctx, store.ID)
	if err == nil {
		store.Schedule = schedules
	}
	return store, nil
}

func (s *storeService) ListNearbyStores(ctx context.Context, lat, lng float64, search string, storeType string) ([]domain.Store, error) {
	// Radius default 50km
	radius := 50000.0
	stores, err := s.storeRepo.ListNearbyStores(ctx, lat, lng, radius, search, storeType)
	if err != nil {
		return nil, err
	}

	// Fetch schedules for each store
	for i := range stores {
		scheds, _ := s.storeRepo.GetSchedules(ctx, stores[i].ID)
		stores[i].Schedule = scheds
	}
	return stores, nil
}

func (s *storeService) ListAllStores(ctx context.Context, storeType string, search string, limit, offset int) ([]domain.Store, error) {
	return s.storeRepo.ListAllStores(ctx, storeType, search, limit, offset)
}

// Schedules

func (s *storeService) UpdateSchedules(ctx context.Context, userID uuid.UUID, req *domain.UpdateScheduleRequest) ([]domain.StoreSchedule, error) {
	store, err := s.storeRepo.GetStoreByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if store == nil {
		return nil, errors.New("store profile not found")
	}

	for _, item := range req.Schedules {
		schedule := &domain.StoreSchedule{
			ID:        uuid.New(),
			StoreID:   store.ID,
			DayOfWeek: item.DayOfWeek,
			OpenTime:  item.OpenTime,
			CloseTime: item.CloseTime,
			IsClosed:  item.IsClosed,
		}
		if err := s.storeRepo.UpsertSchedule(ctx, schedule); err != nil {
			return nil, err
		}
	}

	return s.storeRepo.GetSchedules(ctx, store.ID)
}

func (s *storeService) GetSchedules(ctx context.Context, storeID uuid.UUID) ([]domain.StoreSchedule, error) {
	return s.storeRepo.GetSchedules(ctx, storeID)
}

// Products

func (s *storeService) CreateProduct(ctx context.Context, userID uuid.UUID, req *domain.CreateProductRequest) (*domain.Product, error) {
	store, err := s.storeRepo.GetStoreByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if store == nil {
		return nil, errors.New("store profile not found")
	}

	now := time.Now()
	product := &domain.Product{
		ID:            uuid.New(),
		StoreID:       store.ID,
		Name:          req.Name,
		Description:   req.Description,
		Price:         req.Price,
		ImageUrl:      req.ImageUrl,
		IsFeatured:    req.IsFeatured,
		IsDeliverable: req.IsDeliverable,
		IsActive:      req.IsActive,
		CreatedAt:     now,
		UpdatedAt:     now,
	}

	if err := s.storeRepo.CreateProduct(ctx, product); err != nil {
		return nil, err
	}
	return product, nil
}

func (s *storeService) UpdateProduct(ctx context.Context, userID uuid.UUID, productID uuid.UUID, req *domain.CreateProductRequest) (*domain.Product, error) {
	store, err := s.storeRepo.GetStoreByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if store == nil {
		return nil, errors.New("store profile not found")
	}

	product, err := s.storeRepo.GetProductByID(ctx, productID)
	if err != nil {
		return nil, err
	}
	if product == nil {
		return nil, errors.New("product not found")
	}
	if product.StoreID != store.ID {
		return nil, errors.New("unauthorized to update this product")
	}

	product.Name = req.Name
	product.Description = req.Description
	product.Price = req.Price
	product.ImageUrl = req.ImageUrl
	product.IsFeatured = req.IsFeatured
	product.IsDeliverable = req.IsDeliverable
	product.IsActive = req.IsActive
	product.UpdatedAt = time.Now()

	if err := s.storeRepo.UpdateProduct(ctx, product); err != nil {
		return nil, err
	}
	return product, nil
}

func (s *storeService) DeleteProduct(ctx context.Context, userID uuid.UUID, productID uuid.UUID) error {
	store, err := s.storeRepo.GetStoreByUserID(ctx, userID)
	if err != nil {
		return err
	}
	if store == nil {
		return errors.New("store profile not found")
	}

	product, err := s.storeRepo.GetProductByID(ctx, productID)
	if err != nil {
		return err
	}
	if product == nil {
		return errors.New("product not found")
	}
	if product.StoreID != store.ID {
		return errors.New("unauthorized to delete this product")
	}

	return s.storeRepo.DeleteProduct(ctx, productID)
}

func (s *storeService) ListProductsForStoreOwner(ctx context.Context, userID uuid.UUID) ([]domain.Product, error) {
	store, err := s.storeRepo.GetStoreByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if store == nil {
		return nil, errors.New("store profile not found")
	}

	return s.storeRepo.ListProducts(ctx, store.ID, false)
}

func (s *storeService) ListProductsForCustomer(ctx context.Context, storeID uuid.UUID) ([]domain.Product, error) {
	return s.storeRepo.ListProducts(ctx, storeID, true)
}

// Orders

func (s *storeService) CreateOrder(ctx context.Context, customerID uuid.UUID, req *domain.CreateStoreOrderRequest) (*domain.StoreOrder, error) {
	store, err := s.storeRepo.GetStoreByID(ctx, req.StoreID)
	if err != nil {
		return nil, err
	}
	if store == nil {
		return nil, errors.New("store not found")
	}

	// Verify schedules: check if store is closed today
	now := time.Now()
	dayOfWeek := int(now.Weekday())
	schedules, err := s.storeRepo.GetSchedules(ctx, store.ID)
	if err == nil {
		for _, sched := range schedules {
			if sched.DayOfWeek == dayOfWeek && sched.IsClosed {
				return nil, errors.New("store is closed today")
			}
		}
	}

	var items []domain.StoreOrderItem
	var itemsTotal float64 = 0.0

	for _, reqItem := range req.Items {
		product, err := s.storeRepo.GetProductByID(ctx, reqItem.ProductID)
		if err != nil {
			return nil, err
		}
		if product == nil || product.StoreID != store.ID || !product.IsActive {
			return nil, fmt.Errorf("product %s is not active or does not belong to store", reqItem.ProductID)
		}

		if req.DeliveryType == "delivery" && !product.IsDeliverable {
			return nil, fmt.Errorf("product %s is not deliverable", product.Name)
		}

		itemTotal := product.Price * float64(reqItem.Quantity)
		itemsTotal += itemTotal

		items = append(items, domain.StoreOrderItem{
			ProductID: product.ID,
			Quantity:  reqItem.Quantity,
			Price:     product.Price,
		})
	}

	deliveryFare := 0.0
	if req.DeliveryType == "delivery" {
		// Calculate estimation
		estReq := &domain.EstimatePriceRequest{
			PickupLat:  store.Latitude,
			PickupLng:  store.Longitude,
			DropoffLat: req.DeliveryLat,
			DropoffLng: req.DeliveryLng,
			Type:       domain.VehicleTypeDelivery,
		}
		est, err := s.pricingService.EstimatePrice(ctx, estReq)
		if err != nil {
			// Fallback basic fare calculation (5.0 base + 1.5 per km approximation or simple default)
			deliveryFare = 5.0
		} else {
			deliveryFare = est.TotalFare
		}
	}

	// Generate OTP
	rand.Seed(time.Now().UnixNano())
	otp := fmt.Sprintf("%06d", rand.Intn(1000000))

	order := &domain.StoreOrder{
		ID:              uuid.New(),
		CustomerID:      customerID,
		StoreID:         store.ID,
		Status:          "pending",
		DeliveryType:    req.DeliveryType,
		DeliveryAddress: req.DeliveryAddress,
		DeliveryLat:     req.DeliveryLat,
		DeliveryLng:     req.DeliveryLng,
		DeliveryFare:    deliveryFare,
		ItemsTotal:      itemsTotal,
		TotalFare:       itemsTotal + deliveryFare,
		PaymentStatus:   "pending",
		PickupOTP:       otp,
		Items:           items,
		CreatedAt:       now,
		UpdatedAt:       now,
	}

	if err := s.storeRepo.CreateOrder(ctx, order); err != nil {
		return nil, err
	}

	// Notify store owner
	s.notifier.SendNotification(ctx, store.UserID, "New Order Received", fmt.Sprintf("You have received a new order for %.2f", order.TotalFare), map[string]interface{}{"order_id": order.ID})
	_ = s.notifier.PublishPusherEvent(ctx, "private-store-orders."+store.ID.String(), "new-order", map[string]string{"order_id": order.ID.String()})

	return s.GetOrder(ctx, order.ID)
}

func (s *storeService) GetOrder(ctx context.Context, orderID uuid.UUID) (*domain.StoreOrder, error) {
	order, err := s.storeRepo.GetOrderByID(ctx, orderID)
	if err != nil {
		return nil, err
	}
	if order == nil {
		return nil, errors.New("order not found")
	}

	if order.DriverID != nil {
		driver, _ := s.driverRepo.GetByID(ctx, *order.DriverID)
		order.Driver = driver
	}
	return order, nil
}

func (s *storeService) UpdateOrderStatusByStore(ctx context.Context, userID uuid.UUID, orderID uuid.UUID, status string) (*domain.StoreOrder, error) {
	store, err := s.storeRepo.GetStoreByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if store == nil {
		return nil, errors.New("store profile not found")
	}

	order, err := s.storeRepo.GetOrderByID(ctx, orderID)
	if err != nil {
		return nil, err
	}
	if order == nil {
		return nil, errors.New("order not found")
	}
	if order.StoreID != store.ID {
		return nil, errors.New("unauthorized to update this order")
	}

	order.Status = status
	order.UpdatedAt = time.Now()

	// Handle courier matching when store accepts/starts preparing order
	if (status == "accepted" || status == "preparing") && order.DeliveryType == "delivery" && order.DriverID == nil {
		matchedDriver, err := s.matchingService.FindBestDriver(ctx, store.Latitude, store.Longitude, domain.VehicleTypeDelivery)
		if err == nil && matchedDriver != nil {
			order.DriverID = &matchedDriver.ID
			order.Status = "preparing" // status is preparing when courier is found

			// Notify driver and customer
			s.notifier.SendNotification(ctx, matchedDriver.UserID, "New Store Delivery", "Please pick up order at "+store.Name, map[string]interface{}{"order_id": order.ID})
			s.notifier.SendNotification(ctx, order.CustomerID, "Delivery Driver Assigned", "A courier is heading to the store to pick up your order.", map[string]interface{}{"order_id": order.ID})

			// Pusher events
			_ = s.notifier.PublishPusherEvent(ctx, "private-customer-trip-request."+matchedDriver.ID.String(), "customer-trip-request."+matchedDriver.ID.String(), map[string]string{"trip_id": order.ID.String(), "type": "store_order"})
			_ = s.notifier.PublishPusherEvent(ctx, "private-driver-trip-accepted."+order.ID.String(), "driver-trip-accepted."+order.ID.String(), map[string]string{"id": order.ID.String(), "type": "store_order"})
		} else {
			// No courier found initially, fallback search
			s.notifier.SendNotification(ctx, order.CustomerID, "Searching for Delivery Driver", "Store accepted order, searching for a nearby courier.", map[string]interface{}{"order_id": order.ID})
		}
	}

	// Update driver back to online if completed or cancelled
	if (status == "completed" || status == "cancelled") && order.DriverID != nil {
		_ = s.driverRepo.UpdateStatus(ctx, *order.DriverID, domain.DriverStatusOnline)
	}

	if err := s.storeRepo.UpdateOrder(ctx, order); err != nil {
		return nil, err
	}

	// Notify customer
	s.notifier.SendNotification(ctx, order.CustomerID, "Order Update", fmt.Sprintf("Your order status is now: %s", status), map[string]interface{}{"order_id": order.ID})
	_ = s.notifier.PublishPusherEvent(ctx, "private-customer-order."+order.CustomerID.String(), "order-status-update", map[string]string{"order_id": order.ID.String(), "status": status})

	return s.GetOrder(ctx, order.ID)
}

func (s *storeService) UpdateOrderStatusByDriver(ctx context.Context, driverID uuid.UUID, orderID uuid.UUID, status string) (*domain.StoreOrder, error) {
	order, err := s.storeRepo.GetOrderByID(ctx, orderID)
	if err != nil {
		return nil, err
	}
	if order == nil {
		return nil, errors.New("order not found")
	}
	if order.DriverID == nil || *order.DriverID != driverID {
		return nil, errors.New("unauthorized: you are not the assigned driver for this order")
	}

	order.Status = status
	order.UpdatedAt = time.Now()

	// Update driver status based on flow
	if status == "delivering" {
		_ = s.driverRepo.UpdateStatus(ctx, driverID, domain.DriverStatusBusy)
	} else if status == "delivered" || status == "completed" {
		_ = s.driverRepo.UpdateStatus(ctx, driverID, domain.DriverStatusOnline)
		order.PaymentStatus = "paid"
	}

	if err := s.storeRepo.UpdateOrder(ctx, order); err != nil {
		return nil, err
	}

	// Notify customer and store
	s.notifier.SendNotification(ctx, order.CustomerID, "Order Update", fmt.Sprintf("Your delivery courier is now: %s", status), map[string]interface{}{"order_id": order.ID})
	storeProfile, _ := s.storeRepo.GetStoreByID(ctx, order.StoreID)
	if storeProfile != nil {
		s.notifier.SendNotification(ctx, storeProfile.UserID, "Order Update", fmt.Sprintf("Courier updated order status to: %s", status), map[string]interface{}{"order_id": order.ID})
	}

	_ = s.notifier.PublishPusherEvent(ctx, "private-customer-order."+order.CustomerID.String(), "order-status-update", map[string]string{"order_id": order.ID.String(), "status": status})

	return s.GetOrder(ctx, order.ID)
}

func (s *storeService) ListCustomerOrders(ctx context.Context, customerID uuid.UUID, limit, offset int) ([]domain.StoreOrder, error) {
	orders, err := s.storeRepo.ListOrdersByCustomerID(ctx, customerID, limit, offset)
	if err != nil {
		return nil, err
	}

	for i := range orders {
		orderFull, _ := s.GetOrder(ctx, orders[i].ID)
		if orderFull != nil {
			orders[i].Items = orderFull.Items
			orders[i].Driver = orderFull.Driver
		}
	}
	return orders, nil
}

func (s *storeService) ListStoreOrders(ctx context.Context, userID uuid.UUID, limit, offset int) ([]domain.StoreOrder, error) {
	store, err := s.storeRepo.GetStoreByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if store == nil {
		return nil, errors.New("store profile not found")
	}

	orders, err := s.storeRepo.ListOrdersByStoreID(ctx, store.ID, limit, offset)
	if err != nil {
		return nil, err
	}

	for i := range orders {
		orderFull, _ := s.GetOrder(ctx, orders[i].ID)
		if orderFull != nil {
			orders[i].Items = orderFull.Items
			orders[i].Driver = orderFull.Driver
		}
	}
	return orders, nil
}

func (s *storeService) ListDriverOrders(ctx context.Context, driverID uuid.UUID, limit, offset int) ([]domain.StoreOrder, error) {
	orders, err := s.storeRepo.ListOrdersForDriver(ctx, driverID, limit, offset)
	if err != nil {
		return nil, err
	}

	for i := range orders {
		orderFull, _ := s.GetOrder(ctx, orders[i].ID)
		if orderFull != nil {
			orders[i].Items = orderFull.Items
			orders[i].Driver = orderFull.Driver
		}
	}
	return orders, nil
}

func (s *storeService) AcceptDeliveryOrder(ctx context.Context, driverID uuid.UUID, orderID uuid.UUID) (*domain.StoreOrder, error) {
	order, err := s.storeRepo.GetOrderByID(ctx, orderID)
	if err != nil {
		return nil, err
	}
	if order == nil {
		return nil, errors.New("order not found")
	}
	if order.DeliveryType != "delivery" {
		return nil, errors.New("order is for pickup, not delivery")
	}
	if order.DriverID != nil {
		return nil, errors.New("order already has an assigned driver")
	}

	order.DriverID = &driverID
	order.Status = "preparing" // assign driver and keep preparing or change to accepted
	order.UpdatedAt = time.Now()

	if err := s.storeRepo.UpdateOrder(ctx, order); err != nil {
		return nil, err
	}

	// Update driver status to busy
	_ = s.driverRepo.UpdateStatus(ctx, driverID, domain.DriverStatusBusy)

	s.notifier.SendNotification(ctx, order.CustomerID, "Courier Found", "A delivery courier accepted to deliver your order.", map[string]interface{}{"order_id": order.ID})
	_ = s.notifier.PublishPusherEvent(ctx, "private-driver-trip-accepted."+order.ID.String(), "driver-trip-accepted."+order.ID.String(), map[string]string{"id": order.ID.String(), "type": "store_order"})

	return s.GetOrder(ctx, order.ID)
}
