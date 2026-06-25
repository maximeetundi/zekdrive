package domain

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type UserRole string

const (
	RoleRider  UserRole = "rider"
	RoleDriver UserRole = "driver"
	RoleAdmin  UserRole = "admin"
	RoleStore  UserRole = "store"
	RolePro    UserRole = "pro" // Unified Pro user: can have multiple sub-profiles
)

type User struct {
	ID          uuid.UUID `json:"id" db:"id"`
	Name        string    `json:"name" db:"name"`
	Email       string    `json:"email" db:"email"`
	Password    string    `json:"-" db:"password"`
	Phone       string    `json:"phone" db:"phone"`
	Role        UserRole  `json:"role" db:"role"`
	Country     string    `json:"country" db:"country"`
	KycStatus   string    `json:"kyc_status" db:"kyc_status"`
	KycDocument string    `json:"kyc_document" db:"kyc_document"`
	// ProProfiles: comma-separated active Pro sub-profiles ("driver", "fleet_owner", "merchant")
	// Only relevant when Role == "pro" (or legacy "driver"/"store")
	ProProfiles string    `json:"pro_profiles" db:"pro_profiles"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
}

type RegisterRequest struct {
	Name                 string         `json:"name" validate:"required,min=2,max=100"`
	Email                string         `json:"email" validate:"required,email"`
	Password             string         `json:"password" validate:"required,min=6"`
	Phone                string         `json:"phone" validate:"required,min=8,max=20"`
	Role                 UserRole       `json:"role" validate:"required,oneof=rider driver admin store pro"`
	ProProfiles          string         `json:"pro_profiles"` // e.g. "driver" or "driver,fleet_owner" or "merchant"
	IdentificationType   string         `json:"identification_type"`
	IdentificationNumber string         `json:"identification_number"`
}

type LoginRequest struct {
	Email        string `json:"email"`
	PhoneOrEmail string `json:"phone_or_email"`
	Password     string `json:"password" validate:"required"`
}

type LoginResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	User         User   `json:"user"`
}

type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token" validate:"required"`
}

type SendWhatsAppOTPRequest struct {
	Phone string `json:"phone" validate:"required,min=8,max=20"`
}

type VerifyWhatsAppOTPRequest struct {
	Phone string   `json:"phone" validate:"required,min=8,max=20"`
	Code  string   `json:"code" validate:"required,len=6"`
	Name  string   `json:"name"`
	Role  UserRole `json:"role"`
}

type UserRepository interface {
	Create(ctx context.Context, user *User) error
	GetByID(ctx context.Context, id uuid.UUID) (*User, error)
	GetByEmail(ctx context.Context, email string) (*User, error)
	GetByPhone(ctx context.Context, phone string) (*User, error)
	Update(ctx context.Context, user *User) error
	Delete(ctx context.Context, id uuid.UUID) error
	List(ctx context.Context, limit, offset int) ([]User, error)
}
