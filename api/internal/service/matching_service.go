package service

import (
	"context"
	"log"

	"github.com/zekdrive/api/internal/domain"
)

type MatchingService interface {
	FindBestDriver(ctx context.Context, lat, lng float64, requestedType domain.VehicleType) (*domain.Driver, error)
}

type matchingService struct {
	driverRepo  domain.DriverRepository
	vehicleRepo domain.VehicleRepository
}

func NewMatchingService(driverRepo domain.DriverRepository, vehicleRepo domain.VehicleRepository) MatchingService {
	return &matchingService{
		driverRepo:  driverRepo,
		vehicleRepo: vehicleRepo,
	}
}

func (s *matchingService) FindBestDriver(ctx context.Context, lat, lng float64, requestedType domain.VehicleType) (*domain.Driver, error) {
	// Search radius starts at 5km (5000m), limit to 10 nearest drivers
	nearbyDrivers, err := s.driverRepo.FindNearby(ctx, lat, lng, 5000.0, 15)
	if err != nil {
		return nil, err
	}

	for _, driver := range nearbyDrivers {
		// Fetch vehicle details for this driver
		vehicle, err := s.vehicleRepo.GetByDriverID(ctx, driver.ID)
		if err != nil {
			log.Printf("Error fetching vehicle for driver %s: %v", driver.ID, err)
			continue
		}
		if vehicle == nil {
			log.Printf("Driver %s has no registered vehicle, skipping", driver.ID)
			continue
		}

		// Matching rule:
		// - If requested type is Economy, both Economy and Premium vehicles can serve.
		// - If requested type is Premium, only Premium vehicles can serve.
		// - If requested type is Delivery, only Delivery vehicles can serve.
		isCompatible := false
		switch requestedType {
		case domain.VehicleTypeEconomy:
			isCompatible = vehicle.Type == domain.VehicleTypeEconomy || vehicle.Type == domain.VehicleTypePremium
		case domain.VehicleTypePremium:
			isCompatible = vehicle.Type == domain.VehicleTypePremium
		case domain.VehicleTypeDelivery:
			isCompatible = vehicle.Type == domain.VehicleTypeDelivery
		}

		if isCompatible {
			// Return the closest compatible online driver
			// (nearbyDrivers is already ordered by distance ASC)
			driver.Vehicle = vehicle
			return &driver, nil
		}
	}

	return nil, nil // No matching driver found
}
