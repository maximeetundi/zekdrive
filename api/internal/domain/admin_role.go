package domain

import (
	"time"

	"github.com/google/uuid"
)

// ─────────────────────────────────────────────
// Admin Role
// ─────────────────────────────────────────────

type AdminRole struct {
	ID          uuid.UUID `json:"id" db:"id"`
	Name        string    `json:"name" db:"name"`
	Label       string    `json:"label" db:"label"`
	Description string    `json:"description" db:"description"`
	Color       string    `json:"color" db:"color"`
	IsSystem    bool      `json:"is_system" db:"is_system"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
	// Populated on list
	Permissions []AdminPermission `json:"permissions,omitempty" db:"-"`
}

// ─────────────────────────────────────────────
// Admin Permission
// ─────────────────────────────────────────────

type AdminPermission struct {
	ID          uuid.UUID `json:"id" db:"id"`
	Key         string    `json:"key" db:"key"`
	Label       string    `json:"label" db:"label"`
	GroupName   string    `json:"group_name" db:"group_name"`
	Description string    `json:"description" db:"description"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
}

// ─────────────────────────────────────────────
// Admin User (admin panel account)
// ─────────────────────────────────────────────

type AdminUser struct {
	UserID    uuid.UUID  `json:"user_id" db:"user_id"`
	RoleID    *uuid.UUID `json:"role_id" db:"role_id"`
	IsActive  bool       `json:"is_active" db:"is_active"`
	LastLogin *time.Time `json:"last_login" db:"last_login"`
	CreatedBy *uuid.UUID `json:"created_by" db:"created_by"`
	CreatedAt time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt time.Time  `json:"updated_at" db:"updated_at"`
	// Joined fields
	Name      string     `json:"name" db:"name"`
	Email     string     `json:"email" db:"email"`
	Phone     string     `json:"phone" db:"phone"`
	RoleName  string     `json:"role_name" db:"role_name"`
	RoleLabel string     `json:"role_label" db:"role_label"`
	RoleColor string     `json:"role_color" db:"role_color"`
}

// ─────────────────────────────────────────────
// Repository interfaces
// ─────────────────────────────────────────────

type AdminRoleRepository interface {
	ListRoles(ctx interface{}) ([]AdminRole, error)
	GetRoleByID(ctx interface{}, id uuid.UUID) (*AdminRole, error)
	GetRolePermissions(ctx interface{}, roleID uuid.UUID) ([]AdminPermission, error)
	UpdateRolePermissions(ctx interface{}, roleID uuid.UUID, permissionIDs []uuid.UUID) error
	ListPermissions(ctx interface{}) ([]AdminPermission, error)

	// Admin users
	ListAdminUsers(ctx interface{}) ([]AdminUser, error)
	GetAdminUser(ctx interface{}, userID uuid.UUID) (*AdminUser, error)
	UpsertAdminUser(ctx interface{}, userID uuid.UUID, roleID uuid.UUID) error
	DeactivateAdminUser(ctx interface{}, userID uuid.UUID) error
	HasPermission(ctx interface{}, userID uuid.UUID, permKey string) (bool, error)
}

// ─────────────────────────────────────────────
// Request/Response DTOs
// ─────────────────────────────────────────────

type UpdateRolePermissionsRequest struct {
	PermissionIDs []uuid.UUID `json:"permission_ids" validate:"required"`
}

type UpsertAdminUserRequest struct {
	UserID uuid.UUID `json:"user_id" validate:"required"`
	RoleID uuid.UUID `json:"role_id" validate:"required"`
}
