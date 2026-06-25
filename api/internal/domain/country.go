package domain

import (
	"database/sql"
	"time"
)

// Country represents a world country with its currency info
type Country struct {
	Code           string    `json:"code" db:"code"`
	Code3          string    `json:"code3" db:"code3"`
	NameFr         string    `json:"name_fr" db:"name_fr"`
	NameEn         string    `json:"name_en" db:"name_en"`
	CurrencyCode   string    `json:"currency_code" db:"currency_code"`
	CurrencyNameFr string    `json:"currency_name_fr" db:"currency_name_fr"`
	CurrencyNameEn string    `json:"currency_name_en" db:"currency_name_en"`
	CurrencySymbol string    `json:"currency_symbol" db:"currency_symbol"`
	PhoneCode      string    `json:"phone_code" db:"phone_code"`
	FlagEmoji      string    `json:"flag_emoji" db:"flag_emoji"`
	Continent      string    `json:"continent" db:"continent"`
	IsActive       bool      `json:"is_active" db:"is_active"`
	CreatedAt      time.Time `json:"created_at" db:"created_at"`
	// Joined
	Config *CountryConfig `json:"config,omitempty" db:"-"`
}

// CountryConfig holds per-country pricing and platform configuration
type CountryConfig struct {
	CountryCode    string  `json:"country_code" db:"country_code"`
	// VTC Pricing
	BaseFare       float64 `json:"base_fare" db:"base_fare"`
	PerKmRate      float64 `json:"per_km_rate" db:"per_km_rate"`
	PerMinRate     float64 `json:"per_min_rate" db:"per_min_rate"`
	MinFare        float64 `json:"min_fare" db:"min_fare"`
	AirportSurcharge float64 `json:"airport_surcharge" db:"airport_surcharge"`
	// Delivery
	DeliveryBase   float64 `json:"delivery_base" db:"delivery_base"`
	DeliveryPerKm  float64 `json:"delivery_per_km" db:"delivery_per_km"`
	DeliveryMin    float64 `json:"delivery_min" db:"delivery_min"`
	// Commissions
	CommissionRide     float64 `json:"commission_ride" db:"commission_ride"`
	CommissionDelivery float64 `json:"commission_delivery" db:"commission_delivery"`
	CommissionStore    float64 `json:"commission_store" db:"commission_store"`
	ServiceFee         float64 `json:"service_fee" db:"service_fee"`
	// Driver bonuses
	DriverBonusBronze float64 `json:"driver_bonus_bronze" db:"driver_bonus_bronze"`
	DriverBonusSilver float64 `json:"driver_bonus_silver" db:"driver_bonus_silver"`
	DriverBonusGold   float64 `json:"driver_bonus_gold" db:"driver_bonus_gold"`
	// Payments
	PaymentCash        bool   `json:"payment_cash" db:"payment_cash"`
	PaymentMobileMoney bool   `json:"payment_mobile_money" db:"payment_mobile_money"`
	PaymentCard        bool   `json:"payment_card" db:"payment_card"`
	MobileMoneyProviders string `json:"mobile_money_providers" db:"mobile_money_providers"`
	// Legal
	VatRate       float64 `json:"vat_rate" db:"vat_rate"`
	DriverAgeMin  int     `json:"driver_age_min" db:"driver_age_min"`
	// Meta — nullable
	LaunchDate sql.NullString `json:"launch_date" db:"launch_date"`
	Notes      sql.NullString `json:"notes" db:"notes"`
	UpdatedAt  time.Time      `json:"updated_at" db:"updated_at"`
}

// CountryRepository interface
type CountryRepository interface {
	ListAll(ctx interface{}) ([]Country, error)
	ListActive(ctx interface{}) ([]Country, error)
	GetByCode(ctx interface{}, code string) (*Country, error)
	SetActive(ctx interface{}, code string, active bool) error
	GetConfig(ctx interface{}, code string) (*CountryConfig, error)
	UpsertConfig(ctx interface{}, cfg CountryConfig) error
}

