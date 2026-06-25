package repository

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"github.com/zekdrive/api/internal/database"
	"github.com/zekdrive/api/internal/domain"
)

type countryRepo struct {
	db *database.PostgresDB
}

func NewCountryRepository(db *database.PostgresDB) domain.CountryRepository {
	return &countryRepo{db: db}
}

func (r *countryRepo) ListAll(ctx interface{}) ([]domain.Country, error) {
	var countries []domain.Country
	err := r.db.SelectContext(ctx.(context.Context), &countries,
		`SELECT code,code3,name_fr,name_en,currency_code,currency_name_fr,currency_name_en,
		        currency_symbol,phone_code,flag_emoji,continent,is_active,created_at
		 FROM countries ORDER BY continent, name_fr`)
	return countries, err
}

func (r *countryRepo) ListActive(ctx interface{}) ([]domain.Country, error) {
	var countries []domain.Country
	err := r.db.SelectContext(ctx.(context.Context), &countries,
		`SELECT code,code3,name_fr,name_en,currency_code,currency_name_fr,currency_name_en,
		        currency_symbol,phone_code,flag_emoji,continent,is_active,created_at
		 FROM countries WHERE is_active=TRUE ORDER BY name_fr`)
	return countries, err
}

func (r *countryRepo) GetByCode(ctx interface{}, code string) (*domain.Country, error) {
	var c domain.Country
	err := r.db.GetContext(ctx.(context.Context), &c,
		`SELECT code,code3,name_fr,name_en,currency_code,currency_name_fr,currency_name_en,
		        currency_symbol,phone_code,flag_emoji,continent,is_active,created_at
		 FROM countries WHERE code=$1`, code)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	return &c, err
}

func (r *countryRepo) SetActive(ctx interface{}, code string, active bool) error {
	_, err := r.db.ExecContext(ctx.(context.Context),
		`UPDATE countries SET is_active=$1 WHERE code=$2`, active, code)
	return err
}

func (r *countryRepo) GetConfig(ctx interface{}, code string) (*domain.CountryConfig, error) {
	var cfg domain.CountryConfig
	err := r.db.GetContext(ctx.(context.Context), &cfg,
		`SELECT * FROM country_configs WHERE country_code=$1`, code)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	return &cfg, err
}

func (r *countryRepo) UpsertConfig(ctx interface{}, cfg domain.CountryConfig) error {
	cfg.UpdatedAt = time.Now()
	_, err := r.db.NamedExecContext(ctx.(context.Context), `
		INSERT INTO country_configs (
			country_code, base_fare, per_km_rate, per_min_rate, min_fare, airport_surcharge,
			delivery_base, delivery_per_km, delivery_min,
			commission_ride, commission_delivery, commission_store, service_fee,
			driver_bonus_bronze, driver_bonus_silver, driver_bonus_gold,
			payment_cash, payment_mobile_money, payment_card, mobile_money_providers,
			vat_rate, driver_age_min, launch_date, notes, updated_at
		) VALUES (
			:country_code, :base_fare, :per_km_rate, :per_min_rate, :min_fare, :airport_surcharge,
			:delivery_base, :delivery_per_km, :delivery_min,
			:commission_ride, :commission_delivery, :commission_store, :service_fee,
			:driver_bonus_bronze, :driver_bonus_silver, :driver_bonus_gold,
			:payment_cash, :payment_mobile_money, :payment_card, :mobile_money_providers,
			:vat_rate, :driver_age_min, :launch_date, :notes, :updated_at
		) ON CONFLICT (country_code) DO UPDATE SET
			base_fare=EXCLUDED.base_fare, per_km_rate=EXCLUDED.per_km_rate,
			per_min_rate=EXCLUDED.per_min_rate, min_fare=EXCLUDED.min_fare,
			airport_surcharge=EXCLUDED.airport_surcharge,
			delivery_base=EXCLUDED.delivery_base, delivery_per_km=EXCLUDED.delivery_per_km,
			delivery_min=EXCLUDED.delivery_min,
			commission_ride=EXCLUDED.commission_ride, commission_delivery=EXCLUDED.commission_delivery,
			commission_store=EXCLUDED.commission_store, service_fee=EXCLUDED.service_fee,
			driver_bonus_bronze=EXCLUDED.driver_bonus_bronze, driver_bonus_silver=EXCLUDED.driver_bonus_silver,
			driver_bonus_gold=EXCLUDED.driver_bonus_gold,
			payment_cash=EXCLUDED.payment_cash, payment_mobile_money=EXCLUDED.payment_mobile_money,
			payment_card=EXCLUDED.payment_card, mobile_money_providers=EXCLUDED.mobile_money_providers,
			vat_rate=EXCLUDED.vat_rate, driver_age_min=EXCLUDED.driver_age_min,
			launch_date=EXCLUDED.launch_date, notes=EXCLUDED.notes, updated_at=EXCLUDED.updated_at
	`, cfg)
	return err
}
