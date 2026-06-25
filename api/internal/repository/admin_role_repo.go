package repository

import (
	"context"
	"database/sql"
	"errors"

	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/database"
	"github.com/zekdrive/api/internal/domain"
)

type adminRoleRepo struct {
	db *database.PostgresDB
}

func NewAdminRoleRepository(db *database.PostgresDB) domain.AdminRoleRepository {
	return &adminRoleRepo{db: db}
}

// ─── Roles ────────────────────────────────────────────────────────────────────

func (r *adminRoleRepo) ListRoles(ctx interface{}) ([]domain.AdminRole, error) {
	var roles []domain.AdminRole
	query := `SELECT id, name, label, description, color, is_system, created_at, updated_at FROM admin_roles ORDER BY created_at`
	err := r.db.SelectContext(ctx.(context.Context), &roles, query)
	return roles, err
}

func (r *adminRoleRepo) GetRoleByID(ctx interface{}, id uuid.UUID) (*domain.AdminRole, error) {
	var role domain.AdminRole
	err := r.db.GetContext(ctx.(context.Context), &role,
		`SELECT id, name, label, description, color, is_system, created_at, updated_at FROM admin_roles WHERE id=$1`, id)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	return &role, err
}

func (r *adminRoleRepo) GetRolePermissions(ctx interface{}, roleID uuid.UUID) ([]domain.AdminPermission, error) {
	var perms []domain.AdminPermission
	query := `
		SELECT p.id, p.key, p.label, p.group_name, p.description, p.created_at
		FROM admin_permissions p
		INNER JOIN admin_role_permissions rp ON rp.permission_id = p.id
		WHERE rp.role_id = $1
		ORDER BY p.group_name, p.key
	`
	err := r.db.SelectContext(ctx.(context.Context), &perms, query, roleID)
	return perms, err
}

func (r *adminRoleRepo) UpdateRolePermissions(ctx interface{}, roleID uuid.UUID, permissionIDs []uuid.UUID) error {
	tx, err := r.db.BeginTxx(ctx.(context.Context), nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// Remove existing permissions for this role (if non-system)
	if _, err := tx.ExecContext(ctx.(context.Context),
		`DELETE FROM admin_role_permissions WHERE role_id=$1`, roleID); err != nil {
		return err
	}

	// Insert new
	for _, pid := range permissionIDs {
		if _, err := tx.ExecContext(ctx.(context.Context),
			`INSERT INTO admin_role_permissions(role_id, permission_id) VALUES($1,$2) ON CONFLICT DO NOTHING`,
			roleID, pid); err != nil {
			return err
		}
	}

	return tx.Commit()
}

func (r *adminRoleRepo) ListPermissions(ctx interface{}) ([]domain.AdminPermission, error) {
	var perms []domain.AdminPermission
	query := `SELECT id, key, label, group_name, description, created_at FROM admin_permissions ORDER BY group_name, key`
	err := r.db.SelectContext(ctx.(context.Context), &perms, query)
	return perms, err
}

// ─── Admin Users ──────────────────────────────────────────────────────────────

func (r *adminRoleRepo) ListAdminUsers(ctx interface{}) ([]domain.AdminUser, error) {
	var users []domain.AdminUser
	query := `
		SELECT
			au.user_id, au.role_id, au.is_active, au.last_login, au.created_by, au.created_at, au.updated_at,
			u.name, u.email, u.phone,
			COALESCE(ar.name, '')  AS role_name,
			COALESCE(ar.label, '') AS role_label,
			COALESCE(ar.color, '') AS role_color
		FROM admin_users au
		INNER JOIN users u ON u.id = au.user_id
		LEFT JOIN admin_roles ar ON ar.id = au.role_id
		ORDER BY au.created_at DESC
	`
	err := r.db.SelectContext(ctx.(context.Context), &users, query)
	return users, err
}

func (r *adminRoleRepo) GetAdminUser(ctx interface{}, userID uuid.UUID) (*domain.AdminUser, error) {
	var u domain.AdminUser
	query := `
		SELECT
			au.user_id, au.role_id, au.is_active, au.last_login, au.created_by, au.created_at, au.updated_at,
			u.name, u.email, u.phone,
			COALESCE(ar.name, '')  AS role_name,
			COALESCE(ar.label, '') AS role_label,
			COALESCE(ar.color, '') AS role_color
		FROM admin_users au
		INNER JOIN users u ON u.id = au.user_id
		LEFT JOIN admin_roles ar ON ar.id = au.role_id
		WHERE au.user_id = $1
	`
	err := r.db.GetContext(ctx.(context.Context), &u, query, userID)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	return &u, err
}

func (r *adminRoleRepo) UpsertAdminUser(ctx interface{}, userID uuid.UUID, roleID uuid.UUID) error {
	_, err := r.db.ExecContext(ctx.(context.Context), `
		INSERT INTO admin_users (user_id, role_id, is_active, updated_at)
		VALUES ($1, $2, TRUE, NOW())
		ON CONFLICT (user_id) DO UPDATE
		  SET role_id = EXCLUDED.role_id, is_active = TRUE, updated_at = NOW()
	`, userID, roleID)
	return err
}

func (r *adminRoleRepo) DeactivateAdminUser(ctx interface{}, userID uuid.UUID) error {
	_, err := r.db.ExecContext(ctx.(context.Context),
		`UPDATE admin_users SET is_active=FALSE, updated_at=NOW() WHERE user_id=$1`, userID)
	return err
}

func (r *adminRoleRepo) HasPermission(ctx interface{}, userID uuid.UUID, permKey string) (bool, error) {
	var count int
	err := r.db.GetContext(ctx.(context.Context), &count, `
		SELECT COUNT(*)
		FROM admin_users au
		INNER JOIN admin_role_permissions rp ON rp.role_id = au.role_id
		INNER JOIN admin_permissions p ON p.id = rp.permission_id
		WHERE au.user_id = $1 AND au.is_active = TRUE AND p.key = $2
	`, userID, permKey)
	return count > 0, err
}
