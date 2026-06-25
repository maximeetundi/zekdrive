package handler

import (
	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/domain"
)

type FleetHandler struct {
	fleetService domain.FleetService
	validate     *validator.Validate
}

func NewFleetHandler(fleetService domain.FleetService) *FleetHandler {
	return &FleetHandler{
		fleetService: fleetService,
		validate:     validator.New(),
	}
}

// ── Pro Profile ──────────────────────────────────────────────────────────────

// GET /api/pro/profile-summary
// Returns the full summary of the logged-in Pro user's profiles
func (h *FleetHandler) GetProProfileSummary(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	summary, err := h.fleetService.GetProProfileSummary(c.Context(), userID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(summary)
}

// POST /api/pro/activate-profile
// Activates a new sub-profile (driver, fleet_owner, or merchant) for the Pro user
func (h *FleetHandler) ActivateProProfile(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	var req domain.ActivateProProfileRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request"})
	}
	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	if err := h.fleetService.ActivateProProfile(c.Context(), userID, req.Profile); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	// Return updated summary
	summary, _ := h.fleetService.GetProProfileSummary(c.Context(), userID)
	return c.JSON(fiber.Map{
		"message": "Profile activated successfully",
		"summary": summary,
	})
}

// ── Fleet CRUD ───────────────────────────────────────────────────────────────

// POST /api/pro/fleets
func (h *FleetHandler) CreateFleet(c *fiber.Ctx) error {
	userID := c.Locals("userID").(uuid.UUID)

	var req domain.CreateFleetRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request"})
	}
	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	fleet, err := h.fleetService.CreateFleet(c.Context(), userID, &req)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(fleet)
}

// GET /api/pro/fleets
func (h *FleetHandler) ListMyFleets(c *fiber.Ctx) error {
	userID := c.Locals("userID").(uuid.UUID)

	fleets, err := h.fleetService.ListOwnerFleets(c.Context(), userID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fleets)
}

// GET /api/pro/fleets/:id
func (h *FleetHandler) GetFleet(c *fiber.Ctx) error {
	fleetID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid fleet id"})
	}

	fleet, err := h.fleetService.GetFleet(c.Context(), fleetID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fleet)
}

// PUT /api/pro/fleets/:id
func (h *FleetHandler) UpdateFleet(c *fiber.Ctx) error {
	userID := c.Locals("userID").(uuid.UUID)
	fleetID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid fleet id"})
	}

	var req domain.CreateFleetRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request"})
	}

	fleet, err := h.fleetService.UpdateFleet(c.Context(), userID, fleetID, &req)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fleet)
}

// DELETE /api/pro/fleets/:id
func (h *FleetHandler) DeleteFleet(c *fiber.Ctx) error {
	userID := c.Locals("userID").(uuid.UUID)
	fleetID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid fleet id"})
	}

	if err := h.fleetService.DeleteFleet(c.Context(), userID, fleetID); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.SendStatus(fiber.StatusNoContent)
}

// ── Vehicle management ───────────────────────────────────────────────────────

// POST /api/pro/fleets/:id/vehicles
func (h *FleetHandler) AddVehicleToFleet(c *fiber.Ctx) error {
	userID := c.Locals("userID").(uuid.UUID)

	var req domain.AddVehicleToFleetRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request"})
	}
	req.FleetID = c.Params("id")
	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	vehicle, err := h.fleetService.AddVehicleToFleet(c.Context(), userID, &req)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(vehicle)
}

// GET /api/pro/fleets/:id/vehicles
func (h *FleetHandler) ListFleetVehicles(c *fiber.Ctx) error {
	userID := c.Locals("userID").(uuid.UUID)
	fleetID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid fleet id"})
	}

	vehicles, err := h.fleetService.ListFleetVehicles(c.Context(), userID, fleetID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(vehicles)
}

// GET /api/pro/vehicles
// All vehicles owned by this pro user (across all fleets)
func (h *FleetHandler) ListAllMyVehicles(c *fiber.Ctx) error {
	userID := c.Locals("userID").(uuid.UUID)

	vehicles, err := h.fleetService.ListAllOwnerVehicles(c.Context(), userID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(vehicles)
}

// ── Driver assignment ────────────────────────────────────────────────────────

// POST /api/pro/vehicles/:id/assign-driver
func (h *FleetHandler) AssignDriver(c *fiber.Ctx) error {
	userID := c.Locals("userID").(uuid.UUID)

	var req domain.AssignDriverToVehicleRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request"})
	}
	req.VehicleID = c.Params("id")
	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	assignment, err := h.fleetService.AssignDriverToVehicle(c.Context(), userID, &req)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(assignment)
}

// DELETE /api/pro/vehicles/:id/assign-driver
func (h *FleetHandler) UnassignDriver(c *fiber.Ctx) error {
	userID := c.Locals("userID").(uuid.UUID)
	vehicleID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid vehicle id"})
	}

	if err := h.fleetService.UnassignDriverFromVehicle(c.Context(), userID, vehicleID); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.SendStatus(fiber.StatusNoContent)
}

// GET /api/pro/fleets/:id/assignments
func (h *FleetHandler) ListFleetAssignments(c *fiber.Ctx) error {
	userID := c.Locals("userID").(uuid.UUID)
	fleetID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid fleet id"})
	}

	assignments, err := h.fleetService.ListFleetAssignments(c.Context(), userID, fleetID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(assignments)
}
