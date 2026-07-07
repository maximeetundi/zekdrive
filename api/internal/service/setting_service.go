package service

import (
	"context"
	"encoding/json"
	"os"
	"strconv"
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
		// Seed default depuis les variables d'environnement
		commissionRate := 15
		if v := os.Getenv("PLATFORM_COMMISSION_RATE"); v != "" {
			if n, err := strconv.Atoi(v); err == nil {
				commissionRate = n
			}
		}
		searchRadius := 5
		if v := os.Getenv("RIDE_SEARCH_RADIUS_KM"); v != "" {
			if n, err := strconv.Atoi(v); err == nil {
				searchRadius = n
			}
		}
		dispatchTimeout := 30
		if v := os.Getenv("DISPATCH_TIMEOUT_SECONDS"); v != "" {
			if n, err := strconv.Atoi(v); err == nil {
				dispatchTimeout = n
			}
		}
		supportEmail := os.Getenv("SUPPORT_EMAIL")
		if supportEmail == "" {
			supportEmail = "support@zekdrive.cm"
		}
		supportPhone := os.Getenv("SUPPORT_PHONE")
		if supportPhone == "" {
			supportPhone = "+237690000000"
		}
		defaultLang := os.Getenv("PLATFORM_LANG")
		if defaultLang == "" {
			defaultLang = "fr"
		}

		appConfig = map[string]interface{}{
			"dispatchTimeout": dispatchTimeout,
			"searchRadius":    searchRadius,
			"commissionRate":  commissionRate,
			"supportEmail":    supportEmail,
			"supportPhone":    supportPhone,
			"defaultLang":     defaultLang,
		}
		now := time.Now()
		newSetting := &domain.Setting{
			ID:           uuid.New(),
			KeyName:      "app_config",
			LiveValues:   appConfig,
			TestValues:   appConfig,
			SettingsType: "app_config",
			Mode:         "live",
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

	defaultGateways := []map[string]interface{}{
		// MTN Mobile Money Cameroun (prioritaire)
		{
			"id":          "gw_mtn_momo",
			"name":        "MTN Mobile Money Cameroon",
			"desc":        "Support MTN MoMo USSD push payments — principal opérateur Cameroun.",
			"enabled":     os.Getenv("MTN_MOMO_API_KEY") != "",
			"publicKey":   os.Getenv("MTN_MOMO_SUBSCRIPTION_KEY"),
			"secretToken": os.Getenv("MTN_MOMO_API_SECRET"),
		},
		// Orange Money Cameroun
		{
			"id":          "gw_orange_money",
			"name":        "Orange Money WebPay API",
			"desc":        "Support Orange Money USSD push payments with mobile auth prompts.",
			"enabled":     os.Getenv("ORANGE_MONEY_API_KEY") != "",
			"publicKey":   os.Getenv("ORANGE_MONEY_API_KEY"),
			"secretToken": os.Getenv("ORANGE_MONEY_API_SECRET"),
		},
		// Dohone (agrégateur Cameroun)
		{
			"id":          "gw_dohone",
			"name":        "Dohone Mobile Money",
			"desc":        "Support local Mobile Money payments in Cameroon (Orange, MTN, Express Union) via Dohone aggregator.",
			"enabled":     os.Getenv("DOHONE_MERCHANT_KEY") != "",
			"publicKey":   os.Getenv("DOHONE_MERCHANT_KEY"),
			"secretToken": os.Getenv("DOHONE_HASH_CODE"),
		},
		// CinetPay
		{
			"id":          "gw_cinetpay",
			"name":        "CinetPay Aggregator",
			"desc":        "Support multi-country Mobile Money and cards payments in Francophone Africa via CinetPay.",
			"enabled":     os.Getenv("CINETPAY_API_KEY") != "",
			"publicKey":   os.Getenv("CINETPAY_API_KEY"),
			"secretToken": os.Getenv("CINETPAY_SITE_ID"),
		},
		// Stripe (international)
		{
			"id":          "gw_stripe",
			"name":        "Stripe International Gateway",
			"desc":        "Support credit/debit visa and mastercard payouts and client fares.",
			"enabled":     os.Getenv("STRIPE_PUBLIC_KEY") != "",
			"publicKey":   os.Getenv("STRIPE_PUBLIC_KEY"),
			"secretToken": os.Getenv("STRIPE_SECRET_KEY"),
		},
		// PayPal
		{
			"id":      "gw_paypal",
			"name":    "PayPal Global Gateway",
			"desc":    "Support global credit cards and account funding via PayPal.",
			"enabled": false,
		},
	}

	var gateways []interface{}
	dbGateways := make(map[string]domain.Setting)
	for _, row := range gatewayRows {
		dbGateways[row.KeyName] = row
	}

	for _, gw := range defaultGateways {
		idStr := gw["id"].(string)
		if row, exists := dbGateways[idStr]; exists {
			gateways = append(gateways, row.LiveValues)
		} else {
			now := time.Now()
			newSetting := &domain.Setting{
				ID:           uuid.New(),
				KeyName:      idStr,
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
	}

	// 3. Fetch Auth Config
	authConfigSetting, err := s.settingRepo.GetByKey(ctx, "auth_config")
	if err != nil {
		return nil, err
	}

	var authConfig interface{}
	if authConfigSetting == nil {
		// Lire depuis variables d'environnement
		smtpPort := 465
		if v := os.Getenv("SMTP_PORT"); v != "" {
			if n, err := strconv.Atoi(v); err == nil {
				smtpPort = n
			}
		}
		smtpHost := os.Getenv("SMTP_HOST")
		smtpUser := os.Getenv("SMTP_USER")
		smtpPassword := os.Getenv("SMTP_PASSWORD") // ne pas logger!
		smtpFromEmail := os.Getenv("SMTP_FROM_EMAIL")
		if smtpFromEmail == "" {
			smtpFromEmail = "support@zekdrive.cm"
		}
		smtpFromName := os.Getenv("SMTP_FROM_NAME")
		if smtpFromName == "" {
			smtpFromName = "ZekDrive Support"
		}
		whatsappURL := os.Getenv("WHATSAPP_URL")
		if whatsappURL == "" {
			whatsappURL = "http://openwa-api:2785"
		}
		whatsappSessionID := os.Getenv("WHATSAPP_SESSION_ID")
		whatsappAPIKey := os.Getenv("WHATSAPP_API_KEY")
		smsProvider := os.Getenv("SMS_PROVIDER")
		smsAPIKey := os.Getenv("SMS_API_KEY")
		smsAPISecret := os.Getenv("SMS_API_SECRET")
		smsSender := os.Getenv("SMS_SENDER_PHONE")

		authConfig = map[string]interface{}{
			"sms_enabled":             smsAPIKey != "",
			"whatsapp_enabled":        whatsappAPIKey != "",
			"email_password_enabled":  smtpHost != "",
			"smtp_host":               smtpHost,
			"smtp_port":               smtpPort,
			"smtp_user":               smtpUser,
			"smtp_password":           smtpPassword,
			"smtp_from_email":         smtpFromEmail,
			"smtp_from_name":          smtpFromName,
			"smtp_use_tls":            true,
			"whatsapp_url":            whatsappURL,
			"whatsapp_session_id":     whatsappSessionID,
			"whatsapp_api_key":        whatsappAPIKey,
			"sms_provider":            smsProvider,
			"sms_api_key":             smsAPIKey,
			"sms_api_secret":          smsAPISecret,
			"sms_sender":              smsSender,
		}
		now := time.Now()
		newSetting := &domain.Setting{
			ID:           uuid.New(),
			KeyName:      "auth_config",
			LiveValues:   authConfig,
			TestValues:   authConfig,
			SettingsType: "auth_config",
			Mode:         "live",
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
