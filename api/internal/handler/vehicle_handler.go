package handler

import (
	"time"

	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/domain"
	"github.com/zekdrive/api/internal/service"
)

type VehicleHandler struct {
	vehicleRepo   domain.VehicleRepository
	driverService service.DriverService
	validate      *validator.Validate
}

func NewVehicleHandler(vehicleRepo domain.VehicleRepository, driverService service.DriverService) *VehicleHandler {
	return &VehicleHandler{
		vehicleRepo:   vehicleRepo,
		driverService: driverService,
		validate:      validator.New(),
	}
}

type registerVehicleReq struct {
	Make        string             `json:"make" validate:"required"`
	Model       string             `json:"model" validate:"required"`
	Year        int                `json:"year" validate:"required,gt=1990"`
	PlateNumber string             `json:"plate_number" validate:"required"`
	Color       string             `json:"color" validate:"required"`
	Type        domain.VehicleType `json:"type" validate:"required,oneof=economy premium delivery"`
}

func (h *VehicleHandler) Register(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	d, err := h.driverService.GetByUserID(c.Context(), userID)
	if err != nil || d == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "driver profile not found"})
	}

	// Verify if driver already has a vehicle
	existing, err := h.vehicleRepo.GetByDriverID(c.Context(), d.ID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if existing != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "vehicle already registered for this driver"})
	}

	var req registerVehicleReq
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	now := time.Now()
	v := &domain.Vehicle{
		ID:          uuid.New(),
		DriverID:    d.ID,
		Make:        req.Make,
		Model:       req.Model,
		Year:        req.Year,
		PlateNumber: req.PlateNumber,
		Color:       req.Color,
		Type:        req.Type,
		CreatedAt:   now,
		UpdatedAt:   now,
	}

	if err := h.vehicleRepo.Create(c.Context(), v); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusCreated).JSON(v)
}

func (h *VehicleHandler) GetMe(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	d, err := h.driverService.GetByUserID(c.Context(), userID)
	if err != nil || d == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "driver profile not found"})
	}

	v, err := h.vehicleRepo.GetByDriverID(c.Context(), d.ID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if v == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "no vehicle found for this driver"})
	}

	return c.JSON(v)
}

func (h *VehicleHandler) Update(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	d, err := h.driverService.GetByUserID(c.Context(), userID)
	if err != nil || d == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "driver profile not found"})
	}

	v, err := h.vehicleRepo.GetByDriverID(c.Context(), d.ID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if v == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "no vehicle found to update"})
	}

	var req registerVehicleReq
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	v.Make = req.Make
	v.Model = req.Model
	v.Year = req.Year
	v.PlateNumber = req.PlateNumber
	v.Color = req.Color
	v.Type = req.Type
	v.UpdatedAt = time.Now()

	if err := h.vehicleRepo.Update(c.Context(), v); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(v)
}
