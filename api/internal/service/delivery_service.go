package service

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/domain"
)

type DeliveryService interface {
	RequestDelivery(ctx context.Context, senderID uuid.UUID, req *domain.CreateDeliveryRequest) (*domain.Delivery, error)
	AcceptDelivery(ctx context.Context, deliveryID, driverID uuid.UUID) (*domain.Delivery, error)
	UpdateStatus(ctx context.Context, deliveryID uuid.UUID, status domain.DeliveryStatus) (*domain.Delivery, error)
	CancelDelivery(ctx context.Context, deliveryID uuid.UUID) (*domain.Delivery, error)
	GetByID(ctx context.Context, id uuid.UUID) (*domain.Delivery, error)
	ListBySenderID(ctx context.Context, senderID uuid.UUID, limit, offset int) ([]domain.Delivery, error)
	ListByDriverID(ctx context.Context, driverID uuid.UUID, limit, offset int) ([]domain.Delivery, error)
}

type deliveryService struct {
	deliveryRepo    domain.DeliveryRepository
	driverService   DriverService
	pricingService  PricingService
	matchingService MatchingService
	notifier        NotificationService
}

func NewDeliveryService(
	deliveryRepo domain.DeliveryRepository,
	driverService DriverService,
	pricingService PricingService,
	matchingService MatchingService,
	notifier NotificationService,
) DeliveryService {
	return &deliveryService{
		deliveryRepo:    deliveryRepo,
		driverService:   driverService,
		pricingService:  pricingService,
		matchingService: matchingService,
		notifier:        notifier,
	}
}

func (s *deliveryService) RequestDelivery(ctx context.Context, senderID uuid.UUID, req *domain.CreateDeliveryRequest) (*domain.Delivery, error) {
	// Estimate pricing
	estReq := &domain.EstimatePriceRequest{
		PickupLat:  req.PickupLat,
		PickupLng:  req.PickupLng,
		DropoffLat: req.DropoffLat,
		DropoffLng: req.DropoffLng,
		Type:       domain.VehicleTypeDelivery,
	}
	estimation, err := s.pricingService.EstimatePrice(ctx, estReq)
	if err != nil {
		return nil, err
	}

	now := time.Now()
	delivery := &domain.Delivery{
		ID:             uuid.New(),
		SenderID:       senderID,
		PickupLat:      req.PickupLat,
		PickupLng:      req.PickupLng,
		DropoffLat:     req.DropoffLat,
		DropoffLng:     req.DropoffLng,
		RecipientName:  req.RecipientName,
		RecipientPhone: req.RecipientPhone,
		PackageDetails: req.PackageDetails,
		Status:         domain.DeliveryStatusRequested,
		Fare:           estimation.TotalFare,
		CreatedAt:      now,
		UpdatedAt:      now,
	}

	if err := s.deliveryRepo.Create(ctx, delivery); err != nil {
		return nil, err
	}

	// Try matching driver with delivery vehicle
	matchedDriver, err := s.matchingService.FindBestDriver(ctx, req.PickupLat, req.PickupLng, domain.VehicleTypeDelivery)
	if err == nil && matchedDriver != nil {
		// Found! Assign driver immediately
		delivery.DriverID = &matchedDriver.ID
		delivery.Status = domain.DeliveryStatusAssigned
		delivery.UpdatedAt = time.Now()

		if err := s.deliveryRepo.Update(ctx, delivery); err != nil {
			return nil, err
		}

		// Update driver status to busy
		s.driverService.UpdateStatus(ctx, matchedDriver.ID, domain.DriverStatusBusy)

		// Notify driver and sender
		s.notifier.SendNotification(ctx, matchedDriver.UserID, "New Delivery Assigned", "Please pick up delivery package for "+delivery.RecipientName, map[string]interface{}{"delivery_id": delivery.ID})
		s.notifier.SendNotification(ctx, senderID, "Delivery Courier Found", "A courier has been dispatched to pick up your package.", map[string]interface{}{"delivery_id": delivery.ID})

		// Pusher Compatibility Event: customer-trip-request to driver
		_ = s.notifier.PublishPusherEvent(ctx, "private-customer-trip-request."+matchedDriver.ID.String(), "customer-trip-request."+matchedDriver.ID.String(), map[string]string{"trip_id": delivery.ID.String()})
		// Pusher Compatibility Event: driver-trip-accepted to sender
		_ = s.notifier.PublishPusherEvent(ctx, "private-driver-trip-accepted."+delivery.ID.String(), "driver-trip-accepted."+delivery.ID.String(), map[string]string{"id": delivery.ID.String(), "type": "parcel"})
	} else {
		// No courier found initially
		s.notifier.SendNotification(ctx, senderID, "Searching for Courier", "We are searching for delivery couriers near you.", map[string]interface{}{"delivery_id": delivery.ID})
	}

	return s.deliveryRepo.GetByID(ctx, delivery.ID)
}

func (s *deliveryService) AcceptDelivery(ctx context.Context, deliveryID, driverID uuid.UUID) (*domain.Delivery, error) {
	delivery, err := s.deliveryRepo.GetByID(ctx, deliveryID)
	if err != nil {
		return nil, err
	}
	if delivery == nil {
		return nil, errors.New("delivery job not found")
	}
	if delivery.Status != domain.DeliveryStatusRequested {
		return nil, errors.New("delivery is already matched or cancelled")
	}

	driver, err := s.driverService.GetByID(ctx, driverID)
	if err != nil {
		return nil, err
	}
	if driver == nil {
		return nil, errors.New("driver not found")
	}
	if driver.Status != domain.DriverStatusOnline {
		return nil, errors.New("driver is not online")
	}

	delivery.DriverID = &driverID
	delivery.Status = domain.DeliveryStatusAssigned
	delivery.UpdatedAt = time.Now()

	if err := s.deliveryRepo.Update(ctx, delivery); err != nil {
		return nil, err
	}

	// Set status to Busy
	s.driverService.UpdateStatus(ctx, driverID, domain.DriverStatusBusy)

	// Send Notifications
	s.notifier.SendNotification(ctx, delivery.SenderID, "Courier Assigned", "Your courier has accepted the job!", map[string]interface{}{"delivery_id": delivery.ID})
	s.notifier.SendNotification(ctx, driver.UserID, "Delivery Confirmed", "Go pick up the package from sender.", map[string]interface{}{"delivery_id": delivery.ID})

	// Pusher Compatibility Event: driver-trip-accepted to sender
	_ = s.notifier.PublishPusherEvent(ctx, "private-driver-trip-accepted."+delivery.ID.String(), "driver-trip-accepted."+delivery.ID.String(), map[string]string{"id": delivery.ID.String(), "type": "parcel"})

	return s.deliveryRepo.GetByID(ctx, deliveryID)
}

func (s *deliveryService) UpdateStatus(ctx context.Context, deliveryID uuid.UUID, status domain.DeliveryStatus) (*domain.Delivery, error) {
	delivery, err := s.deliveryRepo.GetByID(ctx, deliveryID)
	if err != nil {
		return nil, err
	}
	if delivery == nil {
		return nil, errors.New("delivery not found")
	}

	delivery.Status = status
	delivery.UpdatedAt = time.Now()

	if err := s.deliveryRepo.UpdateStatus(ctx, deliveryID, status); err != nil {
		return nil, err
	}

	switch status {
	case domain.DeliveryStatusPickedUp:
		s.notifier.SendNotification(ctx, delivery.SenderID, "Package Picked Up", "Your package is in transit.", map[string]interface{}{"delivery_id": delivery.ID})
		// Pusher Compatibility Event: driver-trip-started to sender
		_ = s.notifier.PublishPusherEvent(ctx, "private-driver-trip-started."+delivery.ID.String(), "driver-trip-started."+delivery.ID.String(), map[string]string{"id": delivery.ID.String(), "type": "parcel"})
	case domain.DeliveryStatusDelivered:
		// Release driver
		if delivery.DriverID != nil {
			s.driverService.UpdateStatus(ctx, *delivery.DriverID, domain.DriverStatusOnline)
			s.notifier.SendNotification(ctx, delivery.Driver.UserID, "Delivery Finished", "You are ready for the next job.", map[string]interface{}{"delivery_id": delivery.ID})
		}
		s.notifier.SendNotification(ctx, delivery.SenderID, "Package Delivered", "Your package has been successfully delivered to "+delivery.RecipientName, map[string]interface{}{"delivery_id": delivery.ID})
		// Pusher Compatibility Event: driver-trip-completed to sender
		_ = s.notifier.PublishPusherEvent(ctx, "private-driver-trip-completed."+delivery.ID.String(), "driver-trip-completed."+delivery.ID.String(), map[string]string{"id": delivery.ID.String(), "type": "parcel"})
	}

	return s.deliveryRepo.GetByID(ctx, deliveryID)
}

func (s *deliveryService) CancelDelivery(ctx context.Context, deliveryID uuid.UUID) (*domain.Delivery, error) {
	delivery, err := s.deliveryRepo.GetByID(ctx, deliveryID)
	if err != nil {
		return nil, err
	}
	if delivery == nil {
		return nil, errors.New("delivery not found")
	}

	if delivery.Status == domain.DeliveryStatusDelivered || delivery.Status == domain.DeliveryStatusCancelled {
		return nil, errors.New("delivery is already finished")
	}

	if err := s.deliveryRepo.UpdateStatus(ctx, deliveryID, domain.DeliveryStatusCancelled); err != nil {
		return nil, err
	}

	// Release driver
	if delivery.DriverID != nil {
		s.driverService.UpdateStatus(ctx, *delivery.DriverID, domain.DriverStatusOnline)
		s.notifier.SendNotification(ctx, delivery.Driver.UserID, "Delivery Cancelled", "Sender cancelled the delivery job.", map[string]interface{}{"delivery_id": delivery.ID})
		
		// Pusher Compatibility Event: customer-trip-cancelled to driver
		_ = s.notifier.PublishPusherEvent(ctx, "private-customer-trip-cancelled."+delivery.ID.String()+"."+delivery.DriverID.String(), "customer-trip-cancelled."+delivery.ID.String()+"."+delivery.DriverID.String(), map[string]string{"trip_id": delivery.ID.String()})
	}
	s.notifier.SendNotification(ctx, delivery.SenderID, "Delivery Cancelled", "Your delivery order was cancelled.", map[string]interface{}{"delivery_id": delivery.ID})

	// Pusher Compatibility Event: driver-trip-cancelled to sender
	_ = s.notifier.PublishPusherEvent(ctx, "private-driver-trip-cancelled."+delivery.ID.String(), "driver-trip-cancelled."+delivery.ID.String(), map[string]string{"id": delivery.ID.String()})

	return s.deliveryRepo.GetByID(ctx, deliveryID)
}

func (s *deliveryService) GetByID(ctx context.Context, id uuid.UUID) (*domain.Delivery, error) {
	return s.deliveryRepo.GetByID(ctx, id)
}

func (s *deliveryService) ListBySenderID(ctx context.Context, senderID uuid.UUID, limit, offset int) ([]domain.Delivery, error) {
	return s.deliveryRepo.ListBySenderID(ctx, senderID, limit, offset)
}

func (s *deliveryService) ListByDriverID(ctx context.Context, driverID uuid.UUID, limit, offset int) ([]domain.Delivery, error) {
	return s.deliveryRepo.ListByDriverID(ctx, driverID, limit, offset)
}
