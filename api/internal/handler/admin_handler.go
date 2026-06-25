package handler

import (
	"database/sql"

	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/database"
	"github.com/zekdrive/api/internal/domain"
	"github.com/zekdrive/api/internal/repository"
)

type AdminHandler struct {
	db           *database.PostgresDB
	zoneRepo     domain.ZoneRepository
	adminRoleRepo domain.AdminRoleRepository
	validate     *validator.Validate
}

func NewAdminHandler(db *database.PostgresDB, zoneRepo domain.ZoneRepository) *AdminHandler {
	return &AdminHandler{
		db:           db,
		zoneRepo:     zoneRepo,
		adminRoleRepo: repository.NewAdminRoleRepository(db),
		validate:     validator.New(),
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

// ─── RBAC: Roles ──────────────────────────────────────────────────────────────

func (h *AdminHandler) ListRoles(c *fiber.Ctx) error {
	roles, err := h.adminRoleRepo.ListRoles(c.Context())
	if err != nil { return c.Status(500).JSON(fiber.Map{"error": err.Error()}) }
	for i := range roles {
		perms, _ := h.adminRoleRepo.GetRolePermissions(c.Context(), roles[i].ID)
		roles[i].Permissions = perms
	}
	return c.JSON(roles)
}

func (h *AdminHandler) ListPermissions(c *fiber.Ctx) error {
	perms, err := h.adminRoleRepo.ListPermissions(c.Context())
	if err != nil { return c.Status(500).JSON(fiber.Map{"error": err.Error()}) }
	return c.JSON(perms)
}

func (h *AdminHandler) UpdateRolePermissions(c *fiber.Ctx) error {
	roleID, err := uuid.Parse(c.Params("id"))
	if err != nil { return c.Status(400).JSON(fiber.Map{"error": "invalid role id"}) }
	var req domain.UpdateRolePermissionsRequest
	if err := c.BodyParser(&req); err != nil { return c.Status(400).JSON(fiber.Map{"error": "invalid body"}) }
	if err := h.adminRoleRepo.UpdateRolePermissions(c.Context(), roleID, req.PermissionIDs); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"success": true})
}

// ─── RBAC: Admin Users ─────────────────────────────────────────────────────────

func (h *AdminHandler) ListAdminUsers(c *fiber.Ctx) error {
	users, err := h.adminRoleRepo.ListAdminUsers(c.Context())
	if err != nil { return c.Status(500).JSON(fiber.Map{"error": err.Error()}) }
	return c.JSON(users)
}

func (h *AdminHandler) UpsertAdminUser(c *fiber.Ctx) error {
	var req domain.UpsertAdminUserRequest
	if err := c.BodyParser(&req); err != nil { return c.Status(400).JSON(fiber.Map{"error": "invalid body"}) }
	if err := h.adminRoleRepo.UpsertAdminUser(c.Context(), req.UserID, req.RoleID); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"success": true})
}

func (h *AdminHandler) DeactivateAdminUser(c *fiber.Ctx) error {
	userID, err := uuid.Parse(c.Params("id"))
	if err != nil { return c.Status(400).JSON(fiber.Map{"error": "invalid user id"}) }
	if err := h.adminRoleRepo.DeactivateAdminUser(c.Context(), userID); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"success": true})
}

// ─── KYC Management (stub — full impl via driver/user repos) ──────────────────

func (h *AdminHandler) ListKYC(c *fiber.Ctx) error {
	rows, err := h.db.QueryContext(c.Context(), `
		SELECT u.id, u.name, u.email, u.phone, u.kyc_status, u.country,
		       'user' as entity_type, u.created_at
		FROM users u WHERE u.role='user'
		UNION ALL
		SELECT u.id, u.name, u.email, u.phone, d.kyc_status, u.country,
		       'driver' as entity_type, u.created_at
		FROM drivers d JOIN users u ON u.id=d.user_id
		ORDER BY created_at DESC LIMIT 100
	`)
	if err != nil { return c.Status(500).JSON(fiber.Map{"error": err.Error()}) }
	defer rows.Close()
	var result []fiber.Map
	for rows.Next() {
		var id, name, email, phone, kycStatus, country, entityType string
		var createdAt interface{}
		_ = rows.Scan(&id, &name, &email, &phone, &kycStatus, &country, &entityType, &createdAt)
		result = append(result, fiber.Map{
			"id": id, "name": name, "email": email, "phone": phone,
			"kyc_status": kycStatus, "country": country,
			"entity_type": entityType, "submitted_at": createdAt,
			"doc_type_fr": "Carte Nationale d'Identité", "doc_type_en": "National ID Card",
			"doc_number": "---",
		})
	}
	return c.JSON(result)
}

func (h *AdminHandler) ApproveKYC(c *fiber.Ctx) error {
	id := c.Params("id")
	_, err := h.db.ExecContext(c.Context(),
		`UPDATE users SET kyc_status='approved' WHERE id=$1`, id)
	if err != nil { return c.Status(500).JSON(fiber.Map{"error": err.Error()}) }
	// Also update drivers table if driver
	_, _ = h.db.ExecContext(c.Context(),
		`UPDATE drivers SET kyc_status='approved' WHERE user_id=$1`, id)
	return c.JSON(fiber.Map{"success": true, "id": id, "status": "approved"})
}

func (h *AdminHandler) RejectKYC(c *fiber.Ctx) error {
	id := c.Params("id")
	var body struct { Reason string `json:"reason"` }
	_ = c.BodyParser(&body)
	_, err := h.db.ExecContext(c.Context(),
		`UPDATE users SET kyc_status='rejected' WHERE id=$1`, id)
	if err != nil { return c.Status(500).JSON(fiber.Map{"error": err.Error()}) }
	_, _ = h.db.ExecContext(c.Context(),
		`UPDATE drivers SET kyc_status='rejected' WHERE user_id=$1`, id)
	return c.JSON(fiber.Map{"success": true, "id": id, "status": "rejected", "reason": body.Reason})
}
