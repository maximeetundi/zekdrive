package handler

import (
	"context"
	"encoding/json"
	"fmt"
	"strconv"
	"strings"

	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/database"
	"github.com/zekdrive/api/internal/domain"
	"github.com/zekdrive/api/internal/service"
)

type TripHandler struct {
	tripService   service.TripService
	driverService service.DriverService
	validate      *validator.Validate
	redis         *database.RedisClient
}

func NewTripHandler(tripService service.TripService, driverService service.DriverService, redis *database.RedisClient) *TripHandler {
	return &TripHandler{
		tripService:   tripService,
		driverService: driverService,
		validate:      validator.New(),
		redis:         redis,
	}
}

func (h *TripHandler) RequestTrip(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	riderID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	var req domain.CreateTripRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}

	trip, err := h.tripService.RequestTrip(c.Context(), riderID, &req)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}

	return c.Status(fiber.StatusCreated).JSON(trip)
}

func (h *TripHandler) AcceptTrip(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	tripIDStr := c.Params("id")
	tripID, err := uuid.Parse(tripIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid trip id"})
	}

	// Retrieve driver associated with user
	d, err := h.driverService.GetByUserID(c.Context(), userID)
	if err != nil || d == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "driver profile not found"})
	}

	trip, err := h.tripService.AcceptTrip(c.Context(), tripID, d.ID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}

	return c.JSON(trip)
}

func (h *TripHandler) UpdateStatus(c *fiber.Ctx) error {
	tripIDStr := c.Params("id")
	tripID, err := uuid.Parse(tripIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid trip id"})
	}

	var req domain.UpdateTripStatusRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}

	trip, err := h.tripService.UpdateStatus(c.Context(), tripID, req.Status)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}

	return c.JSON(trip)
}

func (h *TripHandler) CancelTrip(c *fiber.Ctx) error {
	tripIDStr := c.Params("id")
	tripID, err := uuid.Parse(tripIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid trip id"})
	}

	trip, err := h.tripService.CancelTrip(c.Context(), tripID)
	if err != nil {
		if strings.Contains(err.Error(), "not found") {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "Course introuvable"})
		}
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}

	return c.JSON(trip)
}

func (h *TripHandler) GetByID(c *fiber.Ctx) error {
	tripIDStr := c.Params("id")
	tripID, err := uuid.Parse(tripIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid trip id"})
	}

	trip, err := h.tripService.GetByID(c.Context(), tripID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}
	if trip == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "trip not found"})
	}

	return c.JSON(trip)
}

// GetDriverLiveLocation retourne la position GPS actuelle du chauffeur pour un trip donné.
// Lit d'abord Redis (cache chaud, <1ms) puis fallback BDD si le chauffeur est inactif.
func (h *TripHandler) GetDriverLiveLocation(c *fiber.Ctx) error {
	tripIDStr := c.Query("trip_request_id")
	if tripIDStr == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "trip_request_id is required"})
	}
	tripID, err := uuid.Parse(tripIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid trip_request_id"})
	}
	trip, err := h.tripService.GetByID(c.Context(), tripID)
	if err != nil || trip == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "trip not found"})
	}
	if trip.DriverID == nil {
		return c.JSON(fiber.Map{"data": nil})
	}

	driverIDStr := trip.DriverID.String()

	// 1. Lire depuis Redis cache (position fraîche envoyée par l'app Pro)
	cacheKey := fmt.Sprintf("driver:loc:%s", driverIDStr)
	cached, redisErr := h.redis.Get(context.Background(), cacheKey).Result()
	if redisErr == nil && cached != "" {
		var loc map[string]float64
		if json.Unmarshal([]byte(cached), &loc) == nil {
			return c.JSON(fiber.Map{
				"data": fiber.Map{
					"latitude":  loc["latitude"],
					"longitude": loc["longitude"],
				},
			})
		}
	}

	// 2. Fallback BDD si cache expiré (chauffeur inactif depuis >90s)
	driver, err := h.driverService.GetByID(c.Context(), *trip.DriverID)
	if err != nil || driver == nil {
		return c.JSON(fiber.Map{"data": nil})
	}
	return c.JSON(fiber.Map{
		"data": fiber.Map{
			"latitude":  driver.Latitude,
			"longitude": driver.Longitude,
		},
	})
}


func (h *TripHandler) GetActive(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	roleVal := c.Locals("role")
	role, _ := roleVal.(domain.UserRole)

	var trip *domain.Trip
	var err error

	if role == domain.RoleDriver {
		d, errGet := h.driverService.GetByUserID(c.Context(), userID)
		if errGet != nil || d == nil {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "driver profile not found"})
		}
		trip, err = h.tripService.GetActiveTripByDriverID(c.Context(), d.ID)
	} else {
		trip, err = h.tripService.GetActiveTripByRiderID(c.Context(), userID)
	}

	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}
	if trip == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "no active trip found"})
	}

	return c.JSON(trip)
}

func (h *TripHandler) ListRiderHistory(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	riderID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	limit, _ := strconv.Atoi(c.Query("limit", "10"))
	offset, _ := strconv.Atoi(c.Query("offset", "0"))

	trips, err := h.tripService.ListByRiderID(c.Context(), riderID, limit, offset)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}

	return c.JSON(trips)
}

func (h *TripHandler) ListDriverHistory(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	d, err := h.driverService.GetByUserID(c.Context(), userID)
	if err != nil || d == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "driver profile not found"})
	}

	limit, _ := strconv.Atoi(c.Query("limit", "10"))
	offset, _ := strconv.Atoi(c.Query("offset", "0"))

	trips, err := h.tripService.ListByDriverID(c.Context(), d.ID, limit, offset)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}

	return c.JSON(trips)
}
