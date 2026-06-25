package repository

import (
	"context"
	"database/sql"
	"errors"

	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/database"
	"github.com/zekdrive/api/internal/domain"
)

type userRepo struct {
	db *database.PostgresDB
}

func NewUserRepository(db *database.PostgresDB) domain.UserRepository {
	return &userRepo{db: db}
}

func (r *userRepo) Create(ctx context.Context, u *domain.User) error {
	query := `
		INSERT INTO users (id, name, email, password, phone, role, country, kyc_status, kyc_document, pro_profiles, is_phone_verified, created_at, updated_at)
		VALUES (:id, :name, :email, :password, :phone, :role, :country, :kyc_status, :kyc_document, :pro_profiles, :is_phone_verified, :created_at, :updated_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, u)
	return err
}

func (r *userRepo) GetByID(ctx context.Context, id uuid.UUID) (*domain.User, error) {
	var u domain.User
	query := `SELECT id, name, email, password, phone, role, country, kyc_status, kyc_document, pro_profiles, is_phone_verified, created_at, updated_at FROM users WHERE id = $1`
	err := r.db.GetContext(ctx, &u, query, id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return &u, nil
}

func (r *userRepo) GetByEmail(ctx context.Context, email string) (*domain.User, error) {
	var u domain.User
	query := `SELECT id, name, email, password, phone, role, country, kyc_status, kyc_document, pro_profiles, is_phone_verified, created_at, updated_at FROM users WHERE email = $1`
	err := r.db.GetContext(ctx, &u, query, email)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return &u, nil
}

func (r *userRepo) GetByPhone(ctx context.Context, phone string) (*domain.User, error) {
	var u domain.User
	query := `SELECT id, name, email, password, phone, role, country, kyc_status, kyc_document, pro_profiles, is_phone_verified, created_at, updated_at FROM users WHERE phone = $1`
	err := r.db.GetContext(ctx, &u, query, phone)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return &u, nil
}

func (r *userRepo) Update(ctx context.Context, u *domain.User) error {
	query := `
		UPDATE users 
		SET name = :name, email = :email, password = :password, phone = :phone, role = :role, country = :country, kyc_status = :kyc_status, kyc_document = :kyc_document, pro_profiles = :pro_profiles, is_phone_verified = :is_phone_verified, updated_at = :updated_at
		WHERE id = :id
	`
	_, err := r.db.NamedExecContext(ctx, query, u)
	return err
}

func (r *userRepo) Delete(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM users WHERE id = $1`
	_, err := r.db.ExecContext(ctx, query, id)
	return err
}

func (r *userRepo) List(ctx context.Context, limit, offset int) ([]domain.User, error) {
	var users []domain.User
	query := `SELECT id, name, email, password, phone, role, country, kyc_status, kyc_document, pro_profiles, is_phone_verified, created_at, updated_at FROM users ORDER BY created_at DESC LIMIT $1 OFFSET $2`
	err := r.db.SelectContext(ctx, &users, query, limit, offset)
	if err != nil {
		return nil, err
	}
	return users, nil
}
