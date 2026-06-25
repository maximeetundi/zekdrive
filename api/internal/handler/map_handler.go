package handler

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/config"
	"github.com/zekdrive/api/internal/domain"
)

type MapHandler struct {
	cfg          *config.Config
	tripRepo     domain.TripRepository
	deliveryRepo domain.DeliveryRepository
	driverRepo   domain.DriverRepository
}

func NewMapHandler(cfg *config.Config, tripRepo domain.TripRepository, deliveryRepo domain.DeliveryRepository, driverRepo domain.DriverRepository) *MapHandler {
	return &MapHandler{
		cfg:          cfg,
		tripRepo:     tripRepo,
		deliveryRepo: deliveryRepo,
		driverRepo:   driverRepo,
	}
}

func (h *MapHandler) Geocode(c *fiber.Ctx) error {
	latStr := c.Query("lat")
	lngStr := c.Query("lng")

	if latStr == "" || lngStr == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "lat and lng parameters are required"})
	}

	// Call Nominatim
	nominatimURL := fmt.Sprintf("https://nominatim.openstreetmap.org/reverse?lat=%s&lon=%s&format=json&accept-language=fr", latStr, lngStr)

	client := &http.Client{Timeout: 10 * time.Second}
	req, err := http.NewRequestWithContext(c.Context(), "GET", nominatimURL, nil)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "failed to build request"})
	}
	req.Header.Set("User-Agent", "ZekDrive/1.0 (admin@zekdrive.com)")

	resp, err := client.Do(req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "failed to contact open maps provider"})
	}
	defer resp.Body.Close()

	var result struct {
		DisplayName string `json:"display_name"`
		Address     struct {
			CountryCode string `json:"country_code"`
		} `json:"address"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "failed to parse maps response"})
	}

	// Format response to match google maps format that mobile app expects
	return c.JSON(fiber.Map{
		"response_code": "200",
		"message":       "success",
		"data": fiber.Map{
			"country_code": strings.ToUpper(result.Address.CountryCode),
			"results": []fiber.Map{
				{
					"formatted_address": result.DisplayName,
				},
			},
		},
	})
}

func (h *MapHandler) SearchLocation(c *fiber.Ctx) error {
	searchText := c.Query("search_text")
	if searchText == "" {
		return c.JSON(fiber.Map{
			"response_code": "200",
			"message":       "success",
			"data": fiber.Map{
				"predictions": []interface{}{},
			},
		})
	}

	// Call Nominatim Search
	nominatimURL := fmt.Sprintf("https://nominatim.openstreetmap.org/search?q=%s&format=json&limit=10&accept-language=fr", url.QueryEscape(searchText))

	client := &http.Client{Timeout: 10 * time.Second}
	req, err := http.NewRequestWithContext(c.Context(), "GET", nominatimURL, nil)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "failed to build request"})
	}
	req.Header.Set("User-Agent", "ZekDrive/1.0 (admin@zekdrive.com)")

	resp, err := client.Do(req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "failed to contact open maps provider"})
	}
	defer resp.Body.Close()

	type NominatimSearchItem struct {
		PlaceID     int    `json:"place_id"`
		DisplayName string `json:"display_name"`
		Lat         string `json:"lat"`
		Lon         string `json:"lon"`
	}

	var items []NominatimSearchItem
	if err := json.NewDecoder(resp.Body).Decode(&items); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "failed to parse search response"})
	}

	predictions := make([]fiber.Map, 0, len(items))
	for _, item := range items {
		// Use lat:lng:displayName as the fake place_id so we don't have to query Nominatim again for details!
		fakePlaceID := fmt.Sprintf("%s:%s:%s", item.Lat, item.Lon, item.DisplayName)
		predictions = append(predictions, fiber.Map{
			"description": item.DisplayName,
			"place_id":    fakePlaceID,
			"id":          strconv.Itoa(item.PlaceID),
			"reference":   fakePlaceID,
		})
	}

	return c.JSON(fiber.Map{
		"response_code": "200",
		"message":       "success",
		"data": fiber.Map{
			"predictions": predictions,
		},
	})
}

func (h *MapHandler) PlaceDetails(c *fiber.Ctx) error {
	placeID := c.Query("placeid")
	if placeID == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "placeid query parameter is required"})
	}

	// Split by ":" to parse lat, lng, and display name
	parts := strings.Split(placeID, ":")
	if len(parts) < 3 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid placeid format"})
	}

	lat, err := strconv.ParseFloat(parts[0], 64)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid latitude in placeid"})
	}

	lng, err := strconv.ParseFloat(parts[1], 64)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid longitude in placeid"})
	}

	displayName := strings.Join(parts[2:], ":")

	return c.JSON(fiber.Map{
		"response_code": "200",
		"message":       "success",
		"data": fiber.Map{
			"status": "OK",
			"result": fiber.Map{
				"place_id":          placeID,
				"formatted_address": displayName,
				"name":              displayName,
				"geometry": fiber.Map{
					"location": fiber.Map{
						"lat": lat,
						"lng": lng,
					},
				},
			},
		},
	})
}

func (h *MapHandler) DistanceAPI(c *fiber.Ctx) error {
	originLat := c.Query("origin_lat")
	originLng := c.Query("origin_lng")
	destLat := c.Query("destination_lat")
	destLng := c.Query("destination_lng")

	if originLat == "" || originLng == "" || destLat == "" || destLng == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "origin_lat, origin_lng, destination_lat, destination_lng are required"})
	}

	// Query OSRM
	osrmURL := fmt.Sprintf("https://router.project-osrm.org/route/v1/driving/%s,%s;%s,%s?overview=false", originLng, originLat, destLng, destLat)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Get(osrmURL)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "failed to query routing engine"})
	}
	defer resp.Body.Close()

	type OSRMRoute struct {
		Distance float64 `json:"distance"`
		Duration float64 `json:"duration"`
	}

	type OSRMResponse struct {
		Routes []OSRMRoute `json:"routes"`
		Code   string      `json:"code"`
	}

	var osrmResponse OSRMResponse
	if err := json.NewDecoder(resp.Body).Decode(&osrmResponse); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "failed to parse routing response"})
	}

	distanceValue := 0.0
	durationValue := 0.0

	if len(osrmResponse.Routes) > 0 {
		distanceValue = osrmResponse.Routes[0].Distance // in meters
		durationValue = osrmResponse.Routes[0].Duration // in seconds
	}

	distanceKm := distanceValue / 1000.0
	durationMin := durationValue / 60.0

	return c.JSON(fiber.Map{
		"rows": []fiber.Map{
			{
				"elements": []fiber.Map{
					{
						"distance": fiber.Map{
							"text":  fmt.Sprintf("%.1f km", distanceKm),
							"value": int(distanceValue),
						},
						"duration": fiber.Map{
							"text":  fmt.Sprintf("%.0f mins", durationMin),
							"value": int(durationValue),
						},
						"status": "OK",
					},
				},
			},
		},
		"status": "OK",
	})
}

func (h *MapHandler) GetRoutes(c *fiber.Ctx) error {
	type GetRoutesRequest struct {
		TripRequestID string `json:"trip_request_id"`
	}

	var req GetRoutesRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if req.TripRequestID == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "trip_request_id is required"})
	}

	tripID, err := uuid.Parse(req.TripRequestID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid trip_request_id format"})
	}

	var startLat, startLng, endLat, endLng float64
	var driverID *uuid.UUID
	var status string

	// Try fetching standard trip
	trip, err := h.tripRepo.GetByID(c.Context(), tripID)
	if err == nil && trip != nil {
		status = string(trip.Status)
		driverID = trip.DriverID

		// Default: pickup to dropoff
		startLat = trip.PickupLat
		startLng = trip.PickupLng
		endLat = trip.DropoffLat
		endLng = trip.DropoffLng

		// If driver is assigned and active (accepted, arriving, or in_progress), route from driver's current location
		if driverID != nil && (status == string(domain.TripStatusAccepted) || status == string(domain.TripStatusArriving) || status == string(domain.TripStatusInProgress)) {
			driver, err := h.driverRepo.GetByID(c.Context(), *driverID)
			if err == nil && driver != nil && driver.Latitude != nil && driver.Longitude != nil {
				startLat = *driver.Latitude
				startLng = *driver.Longitude

				if status == string(domain.TripStatusInProgress) {
					// Route driver to dropoff
					endLat = trip.DropoffLat
					endLng = trip.DropoffLng
				} else {
					// Route driver to pickup
					endLat = trip.PickupLat
					endLng = trip.PickupLng
				}
			}
		}
	} else {
		// Try fetching delivery
		delivery, err := h.deliveryRepo.GetByID(c.Context(), tripID)
		if err != nil || delivery == nil {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "trip or delivery not found"})
		}
		status = string(delivery.Status)
		driverID = delivery.DriverID

		// Default: pickup to dropoff
		startLat = delivery.PickupLat
		startLng = delivery.PickupLng
		endLat = delivery.DropoffLat
		endLng = delivery.DropoffLng

		// If driver is assigned and active (assigned or picked_up), route from driver's current location
		if driverID != nil && (status == string(domain.DeliveryStatusAssigned) || status == string(domain.DeliveryStatusPickedUp)) {
			driver, err := h.driverRepo.GetByID(c.Context(), *driverID)
			if err == nil && driver != nil && driver.Latitude != nil && driver.Longitude != nil {
				startLat = *driver.Latitude
				startLng = *driver.Longitude

				if status == string(domain.DeliveryStatusPickedUp) {
					// Route driver to dropoff
					endLat = delivery.DropoffLat
					endLng = delivery.DropoffLng
				} else {
					// Route driver to pickup
					endLat = delivery.PickupLat
					endLng = delivery.PickupLng
				}
			}
		}
	}

	// Call OSRM with polyline output format
	osrmURL := fmt.Sprintf("https://router.project-osrm.org/route/v1/driving/%f,%f;%f,%f?overview=full&geometries=polyline", startLng, startLat, endLng, endLat)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Get(osrmURL)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "failed to query routing engine"})
	}
	defer resp.Body.Close()

	type OSRMFullRoute struct {
		Distance float64 `json:"distance"` // meters
		Duration float64 `json:"duration"` // seconds
		Geometry string  `json:"geometry"` // Google polyline format!
	}

	type OSRMFullResponse struct {
		Routes []OSRMFullRoute `json:"routes"`
		Code   string          `json:"code"`
	}

	var osrmResponse OSRMFullResponse
	if err := json.NewDecoder(resp.Body).Decode(&osrmResponse); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "failed to parse routing response"})
	}

	distanceKm := 0.0
	durationMin := 0.0
	durationSec := 0
	geometry := ""

	if len(osrmResponse.Routes) > 0 {
		distanceKm = osrmResponse.Routes[0].Distance / 1000.0
		durationMin = osrmResponse.Routes[0].Duration / 60.0
		durationSec = int(osrmResponse.Routes[0].Duration)
		geometry = osrmResponse.Routes[0].Geometry
	}

	return c.JSON([]fiber.Map{
		{
			"distance":         distanceKm,
			"distance_text":    fmt.Sprintf("%.1f km", distanceKm),
			"duration":         fmt.Sprintf("%.0f mins", durationMin),
			"duration_sec":     durationSec,
			"status":           "OK",
			"drive_mode":       "driving",
			"encoded_polyline": geometry,
		},
	})
}
