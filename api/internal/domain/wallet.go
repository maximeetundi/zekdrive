package domain

import (
	"time"

	"github.com/google/uuid"
)

// DriverWallet — solde du compte pro chauffeur
type DriverWallet struct {
	ID             uuid.UUID `json:"id"`
	DriverID       uuid.UUID `json:"driver_id"`
	Balance        float64   `json:"balance"`
	CurrencyCode   string    `json:"currency_code"`
	MinBalance     float64   `json:"min_balance"`
	IsLocked       bool      `json:"is_locked"`
	TotalRecharged float64   `json:"total_recharged"`
	TotalDeducted  float64   `json:"total_deducted"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
	// Joined
	DriverName  string `json:"driver_name,omitempty"`
	DriverPhone string `json:"driver_phone,omitempty"`
}

// WalletTransaction — historique des mouvements
type WalletTransaction struct {
	ID            uuid.UUID  `json:"id"`
	DriverID      uuid.UUID  `json:"driver_id"`
	TripID        *uuid.UUID `json:"trip_id,omitempty"`
	Type          string     `json:"type"`
	Amount        float64    `json:"amount"`
	BalanceBefore float64    `json:"balance_before"`
	BalanceAfter  float64    `json:"balance_after"`
	CurrencyCode  string     `json:"currency_code"`
	DescriptionFr string     `json:"description_fr"`
	DescriptionEn string     `json:"description_en"`
	PaymentMethod string     `json:"payment_method"`
	Reference     string     `json:"reference"`
	Status        string     `json:"status"`
	CreatedAt     time.Time  `json:"created_at"`
}

// RechargeRequest — recharge du wallet
type RechargeRequest struct {
	Amount        float64 `json:"amount" validate:"required,gt=0"`
	PaymentMethod string  `json:"payment_method" validate:"required"`
	PhoneNumber   string  `json:"phone_number"`
	Reference     string  `json:"reference"`
}

// WalletRepository — interface
type WalletRepository interface {
	GetOrCreate(ctx interface{}, driverID uuid.UUID, currency string) (*DriverWallet, error)
	GetBalance(ctx interface{}, driverID uuid.UUID) (*DriverWallet, error)
	Recharge(ctx interface{}, driverID uuid.UUID, amount float64, method, ref, currency string) (*DriverWallet, error)
	DeductCommission(ctx interface{}, driverID, tripID uuid.UUID, amount float64, descFr, descEn, currency string) error
	AddBonus(ctx interface{}, driverID uuid.UUID, amount float64, bonusType, currency string) error
	ListTransactions(ctx interface{}, driverID uuid.UUID, limit int) ([]WalletTransaction, error)
	CanAcceptTrip(ctx interface{}, driverID uuid.UUID) (bool, error)
	LockWallet(ctx interface{}, driverID uuid.UUID, locked bool) error
	SetMinBalance(ctx interface{}, driverID uuid.UUID, minBalance float64) error
	AdminListWallets(ctx interface{}) ([]DriverWallet, error)
	AdminRecharge(ctx interface{}, driverID uuid.UUID, amount float64, ref, currency string) (*DriverWallet, error)
}
