package service

import (
	"context"
	"errors"
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/domain"
)

type TripService interface {
	RequestTrip(ctx context.Context, riderID uuid.UUID, req *domain.CreateTripRequest) (*domain.Trip, error)
	AcceptTrip(ctx context.Context, tripID, driverID uuid.UUID) (*domain.Trip, error)
	UpdateStatus(ctx context.Context, tripID uuid.UUID, status domain.TripStatus) (*domain.Trip, error)
	CancelTrip(ctx context.Context, tripID uuid.UUID) (*domain.Trip, error)
	GetByID(ctx context.Context, id uuid.UUID) (*domain.Trip, error)
	GetActiveTripByRiderID(ctx context.Context, riderID uuid.UUID) (*domain.Trip, error)
	GetActiveTripByDriverID(ctx context.Context, driverID uuid.UUID) (*domain.Trip, error)
	ListByRiderID(ctx context.Context, riderID uuid.UUID, limit, offset int) ([]domain.Trip, error)
	ListByDriverID(ctx context.Context, driverID uuid.UUID, limit, offset int) ([]domain.Trip, error)
}

type tripService struct {
	tripRepo        domain.TripRepository
	driverService   DriverService
	pricingService  PricingService
	matchingService MatchingService
	geoService      GeoService
	notifier        NotificationService
}

func NewTripService(
	tripRepo domain.TripRepository,
	driverService DriverService,
	pricingService PricingService,
	matchingService MatchingService,
	geoService GeoService,
	notifier NotificationService,
) TripService {
	return &tripService{
		tripRepo:        tripRepo,
		driverService:   driverService,
		pricingService:  pricingService,
		matchingService: matchingService,
		geoService:      geoService,
		notifier:        notifier,
	}
}

func (s *tripService) RequestTrip(ctx context.Context, riderID uuid.UUID, req *domain.CreateTripRequest) (*domain.Trip, error) {
	// Check if rider already has an active trip
	active, err := s.tripRepo.GetActiveTripByRiderID(ctx, riderID)
	if err != nil {
		return nil, err
	}
	if active != nil {
		return nil, errors.New("you already have an active trip")
	}

	// Calculate Fare
	estReq := &domain.EstimatePriceRequest{
		PickupLat:  req.PickupLat,
		PickupLng:  req.PickupLng,
		DropoffLat: req.DropoffLat,
		DropoffLng: req.DropoffLng,
		Type:       req.VehicleType,
	}
	estimation, err := s.pricingService.EstimatePrice(ctx, estReq)
	if err != nil {
		return nil, err
	}

	// Generate route
	routeStr, err := s.geoService.GenerateRoute(req.PickupLat, req.PickupLng, req.DropoffLat, req.DropoffLng)
	if err != nil {
		return nil, err
	}

	now := time.Now()
	trip := &domain.Trip{
		ID:             uuid.New(),
		RiderID:        riderID,
		PickupLat:      req.PickupLat,
		PickupLng:      req.PickupLng,
		DropoffLat:     req.DropoffLat,
		DropoffLng:     req.DropoffLng,
		PickupAddress:  req.PickupAddress,
		DropoffAddress: req.DropoffAddress,
		Status:         domain.TripStatusRequested,
		Fare:           estimation.TotalFare,
		PaymentStatus:  domain.PaymentPending,
		RouteCoords:    &routeStr,
		CreatedAt:      now,
		UpdatedAt:      now,
	}

	if err := s.tripRepo.Create(ctx, trip); err != nil {
		return nil, err
	}

	// Try matching driver
	matchedDriver, err := s.matchingService.FindBestDriver(ctx, req.PickupLat, req.PickupLng, req.VehicleType)
	if err != nil {
		log.Printf("Matching driver error: %v", err)
	}

	if matchedDriver != nil {
		// Found! Assign driver immediately
		trip.DriverID = &matchedDriver.ID
		trip.Status = domain.TripStatusAccepted
		trip.UpdatedAt = time.Now()

		if err := s.tripRepo.Update(ctx, trip); err != nil {
			return nil, err
		}

		// Update driver status to busy
		s.driverService.UpdateStatus(ctx, matchedDriver.ID, domain.DriverStatusBusy)

		// Notify driver and rider
		s.notifier.SendNotification(ctx, matchedDriver.UserID, "New Ride Assigned", "Please pick up passenger at "+trip.PickupAddress, map[string]interface{}{"trip_id": trip.ID})
		s.notifier.SendNotification(ctx, riderID, "Driver Found", "Your driver is on the way!", map[string]interface{}{"trip_id": trip.ID})
	} else {
		// No driver found initially
		s.notifier.SendNotification(ctx, riderID, "Searching for Driver", "We are searching for drivers near you.", map[string]interface{}{"trip_id": trip.ID})
	}

	// Fetch full model details
	return s.tripRepo.GetByID(ctx, trip.ID)
}

func (s *tripService) AcceptTrip(ctx context.Context, tripID, driverID uuid.UUID) (*domain.Trip, error) {
	trip, err := s.tripRepo.GetByID(ctx, tripID)
	if err != nil {
		return nil, err
	}
	if trip == nil {
		return nil, errors.New("trip not found")
	}
	if trip.Status != domain.TripStatusRequested {
		return nil, errors.New("trip is already matched or cancelled")
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

	trip.DriverID = &driverID
	trip.Status = domain.TripStatusAccepted
	trip.UpdatedAt = time.Now()

	if err := s.tripRepo.Update(ctx, trip); err != nil {
		return nil, err
	}

	// Set status to Busy
	s.driverService.UpdateStatus(ctx, driverID, domain.DriverStatusBusy)

	// Send Notifications
	s.notifier.SendNotification(ctx, trip.RiderID, "Trip Accepted", "Your driver has accepted the ride!", map[string]interface{}{"trip_id": trip.ID})
	s.notifier.SendNotification(ctx, driver.UserID, "Trip Confirmed", "Go to "+trip.PickupAddress, map[string]interface{}{"trip_id": trip.ID})

	return s.tripRepo.GetByID(ctx, tripID)
}

func (s *tripService) UpdateStatus(ctx context.Context, tripID uuid.UUID, status domain.TripStatus) (*domain.Trip, error) {
	trip, err := s.tripRepo.GetByID(ctx, tripID)
	if err != nil {
		return nil, err
	}
	if trip == nil {
		return nil, errors.New("trip not found")
	}

	trip.Status = status
	trip.UpdatedAt = time.Now()

	if err := s.tripRepo.UpdateStatus(ctx, tripID, status); err != nil {
		return nil, err
	}

	switch status {
	case domain.TripStatusArriving:
		s.notifier.SendNotification(ctx, trip.RiderID, "Driver Arrived", "Your driver is waiting outside.", map[string]interface{}{"trip_id": trip.ID})
	case domain.TripStatusInProgress:
		s.notifier.SendNotification(ctx, trip.RiderID, "Trip Started", "Have a safe ride!", map[string]interface{}{"trip_id": trip.ID})
	case domain.TripStatusCompleted:
		// Settle payment state
		s.tripRepo.UpdatePaymentStatus(ctx, tripID, domain.PaymentPaid)
		// Release driver
		if trip.DriverID != nil {
			s.driverService.UpdateStatus(ctx, *trip.DriverID, domain.DriverStatusOnline)
			s.notifier.SendNotification(ctx, trip.Driver.UserID, "Trip Completed", "Earnings details are available in your wallet.", map[string]interface{}{"trip_id": trip.ID})
		}
		s.notifier.SendNotification(ctx, trip.RiderID, "Trip Completed", "Thank you for riding with us!", map[string]interface{}{"trip_id": trip.ID})
	}

	return s.tripRepo.GetByID(ctx, tripID)
}

func (s *tripService) CancelTrip(ctx context.Context, tripID uuid.UUID) (*domain.Trip, error) {
	trip, err := s.tripRepo.GetByID(ctx, tripID)
	if err != nil {
		return nil, err
	}
	if trip == nil {
		return nil, errors.New("trip not found")
	}

	if trip.Status == domain.TripStatusCompleted || trip.Status == domain.TripStatusCancelled {
		return nil, errors.New("trip is already finished")
	}

	if err := s.tripRepo.UpdateStatus(ctx, tripID, domain.TripStatusCancelled); err != nil {
		return nil, err
	}

	// Release driver
	if trip.DriverID != nil {
		s.driverService.UpdateStatus(ctx, *trip.DriverID, domain.DriverStatusOnline)
		s.notifier.SendNotification(ctx, trip.Driver.UserID, "Trip Cancelled", "Passenger cancelled the trip request.", map[string]interface{}{"trip_id": trip.ID})
	}
	s.notifier.SendNotification(ctx, trip.RiderID, "Trip Cancelled", "Your trip was cancelled.", map[string]interface{}{"trip_id": trip.ID})

	return s.tripRepo.GetByID(ctx, tripID)
}

func (s *tripService) GetByID(ctx context.Context, id uuid.UUID) (*domain.Trip, error) {
	return s.tripRepo.GetByID(ctx, id)
}

func (s *tripService) GetActiveTripByRiderID(ctx context.Context, riderID uuid.UUID) (*domain.Trip, error) {
	return s.tripRepo.GetActiveTripByRiderID(ctx, riderID)
}

func (s *tripService) GetActiveTripByDriverID(ctx context.Context, driverID uuid.UUID) (*domain.Trip, error) {
	return s.tripRepo.GetActiveTripByDriverID(ctx, driverID)
}

func (s *tripService) ListByRiderID(ctx context.Context, riderID uuid.UUID, limit, offset int) ([]domain.Trip, error) {
	return s.tripRepo.ListByRiderID(ctx, riderID, limit, offset)
}

func (s *tripService) ListByDriverID(ctx context.Context, driverID uuid.UUID, limit, offset int) ([]domain.Trip, error) {
	return s.tripRepo.ListByDriverID(ctx, driverID, limit, offset)
}
