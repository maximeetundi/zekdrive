package service

import (
	"encoding/json"
	"math"
)

type GeoService interface {
	CalculateDistance(lat1, lon1, lat2, lon2 float64) float64 // in km
	EstimateDuration(distanceKm float64) float64             // in minutes
	GenerateRoute(lat1, lon1, lat2, lon2 float64) (string, error) // JSON coordinates
}

type geoService struct{}

func NewGeoService() GeoService {
	return &geoService{}
}

func (s *geoService) CalculateDistance(lat1, lon1, lat2, lon2 float64) float64 {
	const earthRadius = 6371.0 // in km

	latR1 := lat1 * math.Pi / 180.0
	lonR1 := lon1 * math.Pi / 180.0
	latR2 := lat2 * math.Pi / 180.0
	lonR2 := lon2 * math.Pi / 180.0

	dlat := latR2 - latR1
	dlon := lonR2 - lonR1

	a := math.Sin(dlat/2)*math.Sin(dlat/2) +
		math.Cos(latR1)*math.Cos(latR2)*
			math.Sin(dlon/2)*math.Sin(dlon/2)

	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

	return earthRadius * c
}

func (s *geoService) EstimateDuration(distanceKm float64) float64 {
	// Assume average city speed is 35 km/h
	const averageSpeedKmh = 35.0
	hours := distanceKm / averageSpeedKmh
	minutes := hours * 60.0
	if minutes < 2.0 {
		return 2.0 // Minimum 2 minutes
	}
	return math.Round(minutes*100) / 100
}

func (s *geoService) GenerateRoute(lat1, lon1, lat2, lon2 float64) (string, error) {
	// Generate mock intermediate route points (5 points interpolation)
	points := make([][2]float64, 0, 5)
	points = append(points, [2]float64{lon1, lat1})

	for i := 1; i <= 3; i++ {
		ratio := float64(i) / 4.0
		// Linear interpolation with a tiny bit of random detour/curve to look realistic
		lat := lat1 + (lat2-lat1)*ratio
		lon := lon1 + (lon2-lon1)*ratio

		// Add subtle curved noise (e.g. 0.001 degrees)
		noiseLat := math.Sin(ratio*math.Pi) * 0.0015
		noiseLon := math.Cos(ratio*math.Pi) * 0.0015
		points = append(points, [2]float64{lon + noiseLon, lat + noiseLat})
	}

	points = append(points, [2]float64{lon2, lat2})

	bytes, err := json.Marshal(points)
	if err != nil {
		return "", err
	}
	return string(bytes), nil
}
