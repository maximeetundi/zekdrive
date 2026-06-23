package domain

import "context"

type EstimatePriceRequest struct {
	PickupLat  float64     `json:"pickup_lat" validate:"required,latitude"`
	PickupLng  float64     `json:"pickup_lng" validate:"required,longitude"`
	DropoffLat float64     `json:"dropoff_lat" validate:"required,latitude"`
	DropoffLng float64     `json:"dropoff_lng" validate:"required,longitude"`
	Type       VehicleType `json:"type" validate:"required,oneof=economy premium delivery"`
}

type PriceEstimation struct {
	BaseFare        float64 `json:"base_fare"`
	DistanceFare    float64 `json:"distance_fare"`
	DurationFare    float64 `json:"duration_fare"`
	SurgeMultiplier float64 `json:"surge_multiplier"`
	TotalFare       float64 `json:"total_fare"`
	DistanceKm      float64 `json:"distance_km"`
	DurationMin     float64 `json:"duration_minutes"`
}

type PricingRepository interface {
	SaveEstimation(ctx context.Context, key string, estimation *PriceEstimation) error
	GetEstimation(ctx context.Context, key string) (*PriceEstimation, error)
}

