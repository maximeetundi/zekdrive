package repository

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/database"
	"github.com/zekdrive/api/internal/domain"
)

type settingRepo struct {
	db *database.PostgresDB
}

type settingRow struct {
	ID             uuid.UUID `db:"id"`
	KeyName        string    `db:"key_name"`
	LiveValues     []byte    `db:"live_values"`
	TestValues     []byte    `db:"test_values"`
	SettingsType   string    `db:"settings_type"`
	Mode           string    `db:"mode"`
	IsActive       bool      `db:"is_active"`
	AdditionalData []byte    `db:"additional_data"`
	CreatedAt      time.Time `db:"created_at"`
	UpdatedAt      time.Time `db:"updated_at"`
}

func NewSettingRepository(db *database.PostgresDB) domain.SettingRepository {
	return &settingRepo{db: db}
}

func (r *settingRepo) Upsert(ctx context.Context, s *domain.Setting) error {
	liveValBytes, err := json.Marshal(s.LiveValues)
	if err != nil {
		return err
	}
	testValBytes, err := json.Marshal(s.TestValues)
	if err != nil {
		return err
	}
	additionalDataBytes, err := json.Marshal(s.AdditionalData)
	if err != nil {
		return err
	}

	query := `
		INSERT INTO settings (id, key_name, live_values, test_values, settings_type, mode, is_active, additional_data, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		ON CONFLICT (key_name)
		DO UPDATE SET live_values = EXCLUDED.live_values, test_values = EXCLUDED.test_values, 
		              settings_type = EXCLUDED.settings_type, mode = EXCLUDED.mode, 
		              is_active = EXCLUDED.is_active, additional_data = EXCLUDED.additional_data, 
		              updated_at = EXCLUDED.updated_at
	`
	_, err = r.db.ExecContext(ctx, query,
		s.ID, s.KeyName, liveValBytes, testValBytes, s.SettingsType, s.Mode, s.IsActive, additionalDataBytes, s.CreatedAt, s.UpdatedAt,
	)
	return err
}

func (r *settingRepo) GetByKey(ctx context.Context, keyName string) (*domain.Setting, error) {
	query := `
		SELECT id, key_name, live_values, test_values, settings_type, mode, is_active, additional_data, created_at, updated_at
		FROM settings
		WHERE key_name = $1
	`
	var row settingRow
	err := r.db.GetContext(ctx, &row, query, keyName)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	return toDomainSetting(&row)
}

func (r *settingRepo) ListByType(ctx context.Context, settingsType string) ([]domain.Setting, error) {
	query := `
		SELECT id, key_name, live_values, test_values, settings_type, mode, is_active, additional_data, created_at, updated_at
		FROM settings
		WHERE settings_type = $1
	`
	var rows []settingRow
	err := r.db.SelectContext(ctx, &rows, query, settingsType)
	if err != nil {
		return nil, err
	}

	var list []domain.Setting
	for _, row := range rows {
		s, err := toDomainSetting(&row)
		if err != nil {
			return nil, err
		}
		list = append(list, *s)
	}
	return list, nil
}

func toDomainSetting(row *settingRow) (*domain.Setting, error) {
	var live interface{}
	var test interface{}
	var addData interface{}

	if len(row.LiveValues) > 0 {
		_ = json.Unmarshal(row.LiveValues, &live)
	}
	if len(row.TestValues) > 0 {
		_ = json.Unmarshal(row.TestValues, &test)
	}
	if len(row.AdditionalData) > 0 {
		_ = json.Unmarshal(row.AdditionalData, &addData)
	}

	return &domain.Setting{
		ID:             row.ID,
		KeyName:        row.KeyName,
		LiveValues:     live,
		TestValues:     test,
		SettingsType:   row.SettingsType,
		Mode:           row.Mode,
		IsActive:       row.IsActive,
		AdditionalData: addData,
		CreatedAt:      row.CreatedAt,
		UpdatedAt:      row.UpdatedAt,
	}, nil
}
