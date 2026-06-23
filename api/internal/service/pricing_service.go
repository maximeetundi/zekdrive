package service

import (
	"context"
	"fmt"
	"math"

	"github.com/zekdrive/api/internal/domain"
)

type PricingService interface {
	EstimatePrice(ctx context.Context, req *domain.EstimatePriceRequest) (*domain.PriceEstimation, error)
}

type pricingService struct {
	zoneRepo    domain.ZoneRepository
	geoService  GeoService
	pricingRepo domain.PricingRepository
}

func NewPricingService(zoneRepo domain.ZoneRepository, geoService GeoService, pricingRepo domain.PricingRepository) PricingService {
	return &pricingService{
		zoneRepo:    zoneRepo,
		geoService:  geoService,
		pricingRepo: pricingRepo,
	}
}

func (s *pricingService) EstimatePrice(ctx context.Context, req *domain.EstimatePriceRequest) (*domain.PriceEstimation, error) {
	// Calculate distance
	distance := s.geoService.CalculateDistance(req.PickupLat, req.PickupLng, req.DropoffLat, req.DropoffLng)
	duration := s.geoService.EstimateDuration(distance)

	// Defaults in case no zone is found
	baseFare := 5.00
	farePerKm := 1.50
	farePerMinute := 0.25
	surgeMultiplier := 1.00

	// Find containing zone
	zone, err := s.zoneRepo.FindContainingPoint(ctx, req.PickupLat, req.PickupLng)
	if err == nil && zone != nil {
		baseFare = zone.BaseFare
		farePerKm = zone.FarePerKm
		farePerMinute = zone.FarePerMinute
		surgeMultiplier = zone.SurgeMultiplier
	}

	// Apply type multipliers
	typeMultiplier := 1.0
	switch req.Type {
	case domain.VehicleTypePremium:
		typeMultiplier = 1.6
	case domain.VehicleTypeDelivery:
		typeMultiplier = 1.1
	case domain.VehicleTypeEconomy:
		typeMultiplier = 1.0
	}

	finalBaseFare := baseFare * typeMultiplier
	distanceFare := distance * farePerKm * typeMultiplier
	durationFare := duration * farePerMinute * typeMultiplier

	total := (finalBaseFare + distanceFare + durationFare) * surgeMultiplier
	// Round to two decimal places
	total = math.Round(total*100) / 100

	estimation := &domain.PriceEstimation{
		BaseFare:        math.Round(finalBaseFare*100) / 100,
		DistanceFare:    math.Round(distanceFare*100) / 100,
		DurationFare:    math.Round(durationFare*100) / 100,
		SurgeMultiplier: surgeMultiplier,
		TotalFare:       total,
		DistanceKm:      math.Round(distance*100) / 100,
		DurationMin:     math.Round(duration*100) / 100,
	}

	// Cache in Redis
	cacheKey := fmt.Sprintf("%.4f,%.4f-%.4f,%.4f-%s", req.PickupLat, req.PickupLng, req.DropoffLat, req.DropoffLng, req.Type)
	s.pricingRepo.SaveEstimation(ctx, cacheKey, estimation)

	return estimation, nil
}
