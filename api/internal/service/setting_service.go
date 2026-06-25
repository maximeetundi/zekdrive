package service

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/domain"
)

type settingService struct {
	settingRepo domain.SettingRepository
}

func NewSettingService(settingRepo domain.SettingRepository) domain.SettingService {
	return &settingService{settingRepo: settingRepo}
}

func (s *settingService) GetSettings(ctx context.Context) (map[string]interface{}, error) {
	// 1. Fetch App Config
	appConfigSetting, err := s.settingRepo.GetByKey(ctx, "app_config")
	if err != nil {
		return nil, err
	}

	var appConfig interface{}
	if appConfigSetting == nil {
		// Seed default app configurations
		appConfig = map[string]interface{}{
			"dispatchTimeout": 30,
			"searchRadius":    8,
			"commissionRate":  15,
			"supportEmail":    "support@zekdrive.com",
			"supportPhone":    "+221 33 800 0000",
			"defaultLang":     "fr",
		}
		now := time.Now()
		newSetting := &domain.Setting{
			ID:           uuid.New(),
			KeyName:      "app_config",
			LiveValues:   appConfig,
			TestValues:   appConfig,
			SettingsType: "app_config",
			Mode:         "test",
			IsActive:     true,
			CreatedAt:    now,
			UpdatedAt:    now,
		}
		_ = s.settingRepo.Upsert(ctx, newSetting)
	} else {
		appConfig = appConfigSetting.LiveValues
	}

	// 2. Fetch Payment Configs
	gatewayRows, err := s.settingRepo.ListByType(ctx, "payment_config")
	if err != nil {
		return nil, err
	}

	var gateways []interface{}
	if len(gatewayRows) == 0 {
		// Seed default payment gateways
		defaultGateways := []map[string]interface{}{
			{
				"id":          "gw_wave",
				"name":        "Wave Senegal Gateway",
				"desc":        "Support local Wave QR-code payments directly from mobile app redirects.",
				"enabled":     true,
				"publicKey":   "pk_live_wave_51m92Fkd208mD2l",
				"secretToken": "sk_live_wave_secret_token_100x",
			},
			{
				"id":          "gw_orange_money",
				"name":        "Orange Money WebPay API",
				"desc":        "Support Orange Money USSD push payments with mobile auth prompts.",
				"enabled":     true,
				"publicKey":   "pk_live_orange_448kd901msda",
				"secretToken": "sk_live_orange_secret_token_99y",
			},
			{
				"id":          "gw_stripe",
				"name":        "Stripe International Gateway",
				"desc":        "Support credit/debit visa and mastercard payouts and client fares.",
				"enabled":     false,
				"publicKey":   "pk_live_stripe_823190salkdm",
				"secretToken": "sk_live_stripe_secret_token_33z",
			},
		}

		for _, gw := range defaultGateways {
			now := time.Now()
			newSetting := &domain.Setting{
				ID:           uuid.New(),
				KeyName:      gw["id"].(string),
				LiveValues:   gw,
				TestValues:   gw,
				SettingsType: "payment_config",
				Mode:         "test",
				IsActive:     gw["enabled"].(bool),
				CreatedAt:    now,
				UpdatedAt:    now,
			}
			_ = s.settingRepo.Upsert(ctx, newSetting)
			gateways = append(gateways, gw)
		}
	} else {
		for _, row := range gatewayRows {
			gateways = append(gateways, row.LiveValues)
		}
	}

	// 3. Fetch Auth Config
	authConfigSetting, err := s.settingRepo.GetByKey(ctx, "auth_config")
	if err != nil {
		return nil, err
	}

	var authConfig interface{}
	if authConfigSetting == nil {
		authConfig = map[string]interface{}{
			"sms_enabled":             false,
			"whatsapp_enabled":        true,
			"email_password_enabled": true,
			"smtp_host":               "smtp.mailtrap.io",
			"smtp_port":               2525,
			"smtp_user":               "user_name_here",
			"smtp_password":           "password_here",
			"whatsapp_url":            "http://openwa-api:2785",
			"whatsapp_session_id":     "bdcc38d6-840f-4fce-b0b6-8365063d7fc4",
			"whatsapp_api_key":        "owa_k1_eee56788a1354467c70629006b57db1e97c8f4988d4f8bab1cb415faf2067d5e",
			"sms_provider":            "twilio",
			"sms_api_key":             "your_twilio_sid",
			"sms_api_secret":          "your_twilio_token",
			"sms_sender":              "+1234567890",
		}
		now := time.Now()
		newSetting := &domain.Setting{
			ID:           uuid.New(),
			KeyName:      "auth_config",
			LiveValues:   authConfig,
			TestValues:   authConfig,
			SettingsType: "auth_config",
			Mode:         "test",
			IsActive:     true,
			CreatedAt:    now,
			UpdatedAt:    now,
		}
		_ = s.settingRepo.Upsert(ctx, newSetting)
		authConfig = newSetting.LiveValues
	} else {
		authConfig = authConfigSetting.LiveValues
	}

	return map[string]interface{}{
		"app_config":  appConfig,
		"gateways":    gateways,
		"auth_config": authConfig,
	}, nil
}

func (s *settingService) SaveSettings(ctx context.Context, data map[string]interface{}) error {
	now := time.Now()

	// 1. Save App Config
	if appConfig, ok := data["app_config"]; ok {
		existing, _ := s.settingRepo.GetByKey(ctx, "app_config")
		var id uuid.UUID
		if existing != nil {
			id = existing.ID
		} else {
			id = uuid.New()
		}

		appSetting := &domain.Setting{
			ID:           id,
			KeyName:      "app_config",
			LiveValues:   appConfig,
			TestValues:   appConfig,
			SettingsType: "app_config",
			Mode:         "live",
			IsActive:     true,
			CreatedAt:    now,
			UpdatedAt:    now,
		}
		if err := s.settingRepo.Upsert(ctx, appSetting); err != nil {
			return err
		}
	}

	// 2. Save Gateways
	if gatewaysRaw, ok := data["gateways"]; ok {
		// Convert to list
		gatewaysBytes, err := json.Marshal(gatewaysRaw)
		if err == nil {
			var gateways []map[string]interface{}
			err = json.Unmarshal(gatewaysBytes, &gateways)
			if err == nil {
				for _, gw := range gateways {
					idStr, ok := gw["id"].(string)
					if !ok {
						continue
					}

					enabled := false
					if enabledVal, ok := gw["enabled"].(bool); ok {
						enabled = enabledVal
					}

					existing, _ := s.settingRepo.GetByKey(ctx, idStr)
					var rowID uuid.UUID
					if existing != nil {
						rowID = existing.ID
					} else {
						rowID = uuid.New()
					}

					gwSetting := &domain.Setting{
						ID:           rowID,
						KeyName:      idStr,
						LiveValues:   gw,
						TestValues:   gw,
						SettingsType: "payment_config",
						Mode:         "live",
						IsActive:     enabled,
						CreatedAt:    now,
						UpdatedAt:    now,
					}
					_ = s.settingRepo.Upsert(ctx, gwSetting)
				}
			}
		}
	}

	// 3. Save Auth Config
	if authConfig, ok := data["auth_config"]; ok {
		existing, _ := s.settingRepo.GetByKey(ctx, "auth_config")
		var id uuid.UUID
		if existing != nil {
			id = existing.ID
		} else {
			id = uuid.New()
		}

		authSetting := &domain.Setting{
			ID:           id,
			KeyName:      "auth_config",
			LiveValues:   authConfig,
			TestValues:   authConfig,
			SettingsType: "auth_config",
			Mode:         "live",
			IsActive:     true,
			CreatedAt:    now,
			UpdatedAt:    now,
		}
		if err := s.settingRepo.Upsert(ctx, authSetting); err != nil {
			return err
		}
	}

	return nil
}
