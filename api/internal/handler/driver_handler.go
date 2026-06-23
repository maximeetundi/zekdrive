package handler

import (
	"strconv"

	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/domain"
	"github.com/zekdrive/api/internal/service"
)

type DriverHandler struct {
	driverService service.DriverService
	validate      *validator.Validate
}

func NewDriverHandler(driverService service.DriverService) *DriverHandler {
	return &DriverHandler{
		driverService: driverService,
		validate:      validator.New(),
	}
}

type registerDriverReq struct {
	LicenseNumber string `json:"license_number" validate:"required,min=5"`
}

func (h *DriverHandler) Register(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	var req registerDriverReq
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	d, err := h.driverService.RegisterDriver(c.Context(), userID, req.LicenseNumber)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusCreated).JSON(d)
}

func (h *DriverHandler) GetMe(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	d, err := h.driverService.GetByUserID(c.Context(), userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if d == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "driver profile not found"})
	}

	return c.JSON(d)
}

func (h *DriverHandler) UpdateLocation(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	// Fetch driver ID associated with user
	d, err := h.driverService.GetByUserID(c.Context(), userID)
	if err != nil || d == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "driver profile not found"})
	}

	var req domain.UpdateLocationRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	if err := h.driverService.UpdateLocation(c.Context(), d.ID, req.Latitude, req.Longitude); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{"status": "location updated"})
}

func (h *DriverHandler) UpdateStatus(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	d, err := h.driverService.GetByUserID(c.Context(), userID)
	if err != nil || d == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "driver profile not found"})
	}

	var req domain.UpdateStatusRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	if err := h.driverService.UpdateStatus(c.Context(), d.ID, req.Status); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{"status": "status updated"})
}

func (h *DriverHandler) FindNearby(c *fiber.Ctx) error {
	latStr := c.Query("lat")
	lngStr := c.Query("lng")
	radStr := c.Query("radius", "5000") // 5km default

	lat, err := strconv.ParseFloat(latStr, 64)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid latitude"})
	}

	lng, err := strconv.ParseFloat(lngStr, 64)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid longitude"})
	}

	radius, err := strconv.ParseFloat(radStr, 64)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid radius"})
	}

	drivers, err := h.driverService.FindNearby(c.Context(), lat, lng, radius, 10)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(drivers)
}
