package handler

import (
	"database/sql"

	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/database"
	"github.com/zekdrive/api/internal/domain"
)

type AdminHandler struct {
	db       *database.PostgresDB
	zoneRepo domain.ZoneRepository
	validate *validator.Validate
}

func NewAdminHandler(db *database.PostgresDB, zoneRepo domain.ZoneRepository) *AdminHandler {
	return &AdminHandler{
		db:       db,
		zoneRepo: zoneRepo,
		validate: validator.New(),
	}
}

type updateSurgeReq struct {
	SurgeMultiplier float64 `json:"surge_multiplier" validate:"required,gt=0"`
}

func (h *AdminHandler) UpdateZoneSurge(c *fiber.Ctx) error {
	idStr := c.Params("id")
	zoneID, err := uuid.Parse(idStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid zone id"})
	}

	var req updateSurgeReq
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	if err := h.zoneRepo.UpdateSurge(c.Context(), zoneID, req.SurgeMultiplier); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{"status": "surge multiplier updated"})
}

func (h *AdminHandler) GetSystemStats(c *fiber.Ctx) error {
	var totalUsers, totalDrivers, activeTrips, completedTrips, activeDeliveries int

	// Simple aggregate queries
	err := h.db.QueryRowContext(c.Context(), "SELECT COUNT(*) FROM users").Scan(&totalUsers)
	if err != nil && err != sql.ErrNoRows {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	err = h.db.QueryRowContext(c.Context(), "SELECT COUNT(*) FROM drivers WHERE status = 'online'").Scan(&totalDrivers)
	if err != nil && err != sql.ErrNoRows {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	err = h.db.QueryRowContext(c.Context(), "SELECT COUNT(*) FROM trips WHERE status IN ('requested', 'accepted', 'arriving', 'in_progress')").Scan(&activeTrips)
	if err != nil && err != sql.ErrNoRows {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	err = h.db.QueryRowContext(c.Context(), "SELECT COUNT(*) FROM trips WHERE status = 'completed'").Scan(&completedTrips)
	if err != nil && err != sql.ErrNoRows {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	err = h.db.QueryRowContext(c.Context(), "SELECT COUNT(*) FROM deliveries WHERE status IN ('requested', 'assigned', 'picked_up')").Scan(&activeDeliveries)
	if err != nil && err != sql.ErrNoRows {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{
		"total_registered_users": totalUsers,
		"active_online_drivers":  totalDrivers,
		"ongoing_active_trips":   activeTrips,
		"completed_trips":        completedTrips,
		"ongoing_deliveries":     activeDeliveries,
	})
}
