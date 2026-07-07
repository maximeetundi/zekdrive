package handler

import (
	"strconv"
	"time"

	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/domain"
)

type ZoneHandler struct {
	zoneRepo domain.ZoneRepository
	validate *validator.Validate
}

func NewZoneHandler(zoneRepo domain.ZoneRepository) *ZoneHandler {
	return &ZoneHandler{
		zoneRepo: zoneRepo,
		validate: validator.New(),
	}
}

func (h *ZoneHandler) Create(c *fiber.Ctx) error {
	var req domain.CreateZoneRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}

	now := time.Now()
	z := &domain.Zone{
		ID:              uuid.New(),
		Name:            req.Name,
		Boundary:        req.Boundary,
		BaseFare:        req.BaseFare,
		FarePerKm:       req.FarePerKm,
		FarePerMinute:   req.FarePerMinute,
		SurgeMultiplier: req.SurgeMultiplier,
		CreatedAt:       now,
		UpdatedAt:       now,
	}

	if err := h.zoneRepo.Create(c.Context(), z); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}

	return c.Status(fiber.StatusCreated).JSON(z)
}

func (h *ZoneHandler) GetByID(c *fiber.Ctx) error {
	idStr := c.Params("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid zone id"})
	}

	z, err := h.zoneRepo.GetByID(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}
	if z == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "zone not found"})
	}

	return c.JSON(z)
}

func (h *ZoneHandler) List(c *fiber.Ctx) error {
	zones, err := h.zoneRepo.List(c.Context())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}
	return c.JSON(zones)
}

func (h *ZoneHandler) Delete(c *fiber.Ctx) error {
	idStr := c.Params("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid zone id"})
	}

	if err := h.zoneRepo.Delete(c.Context(), id); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}

	return c.JSON(fiber.Map{"status": "zone deleted"})
}

func (h *ZoneHandler) GetZoneID(c *fiber.Ctx) error {
	latStr := c.Query("lat")
	lngStr := c.Query("lng")

	var lat, lng float64
	if latStr != "" && lngStr != "" {
		var err error
		lat, err = strconv.ParseFloat(latStr, 64)
		if err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid latitude"})
		}
		lng, err = strconv.ParseFloat(lngStr, 64)
		if err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid longitude"})
		}
	}

	// Default to Yaoundé center if no coordinates provided
	if lat == 0 && lng == 0 {
		lat = 3.8480
		lng = 11.5021
	}

	zone, err := h.zoneRepo.FindContainingPoint(c.Context(), lat, lng)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}
	if zone == nil {
		allZones, listErr := h.zoneRepo.List(c.Context())
		if listErr == nil && len(allZones) > 0 {
			zone = &allZones[0]
		}
	}
	if zone == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "service not available in this area"})
	}

	return c.JSON(fiber.Map{
		"data": fiber.Map{
			"id":      zone.ID.String(),
			"zone_id": zone.ID.String(),
			"name":    zone.Name,
		},
	})
}
