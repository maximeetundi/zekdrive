package handler

import (
	"context"
	"encoding/json"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/database"
	"github.com/zekdrive/api/internal/domain"
	"github.com/zekdrive/api/internal/service"
)

type DriverHandler struct {
	driverService  service.DriverService
	settingService domain.SettingService
	validate       *validator.Validate
	redis          *database.RedisClient
}

func NewDriverHandler(driverService service.DriverService, settingService domain.SettingService, redis *database.RedisClient) *DriverHandler {
	return &DriverHandler{
		driverService:  driverService,
		settingService: settingService,
		validate:       validator.New(),
		redis:          redis,
	}
}

type registerDriverReq struct {
	LicenseNumber string `json:"license_number" validate:"required,min=5"`
}

func (h *DriverHandler) Register(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	var req registerDriverReq
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}

	d, err := h.driverService.RegisterDriver(c.Context(), userID, req.LicenseNumber)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}

	if strings.Contains(c.Path(), "/customer/") || strings.Contains(c.Path(), "/driver/") {
		return c.Status(fiber.StatusCreated).JSON(fiber.Map{
			"data": d,
		})
	}

	return c.Status(fiber.StatusCreated).JSON(d)
}

func (h *DriverHandler) GetMe(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	d, err := h.driverService.GetByUserID(c.Context(), userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}
	if d == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "driver profile not found"})
	}

	if strings.Contains(c.Path(), "/customer/") || strings.Contains(c.Path(), "/driver/") {
		firstName := d.User.Name
		lastName := ""
		parts := strings.SplitN(d.User.Name, " ", 2)
		if len(parts) > 0 {
			firstName = parts[0]
		}
		if len(parts) > 1 {
			lastName = parts[1]
		}

		currencyCode, currencySymbol := getCurrencyByCountry(d.User.Country)
		profileData := fiber.Map{
			"id":                     d.ID.String(),
			"first_name":             firstName,
			"last_name":              lastName,
			"phone":                  d.User.Phone,
			"email":                  d.User.Email,
			"identification_number":  d.LicenseNumber,
			"identification_type":    "identity_card",
			"profile_image":          "",
			"user_type":              "driver",
			"details": fiber.Map{
				"id":        d.ID.String(),
				"user_id":   d.UserID.String(),
				"is_online": "0",
			},
			"wallet": fiber.Map{
				"id":                 d.ID.String(),
				"driver_id":          d.ID.String(),
				"balance":            d.WalletBalance,
				"payable_balance":    d.WalletBalance,
				"receivable_balance": d.WalletBalance,
				"received_balance":   0.0,
				"pending_balance":    0.0,
				"wallet_balance":     d.WalletBalance,
				"total_withdrawn":    0.0,
				"currency_code":      currencyCode,
				"currency_symbol":    currencySymbol,
			},
			"loyalty_points": 0.0,
			"rating":         d.Rating,
		}

		if d.Status == domain.DriverStatusOnline {
			profileData["details"].(fiber.Map)["is_online"] = "1"
		}

		return c.JSON(fiber.Map{
			"response_code": "200",
			"message":       "success",
			"data":          profileData,
		})
	}

	return c.JSON(d)
}

func (h *DriverHandler) UpdateLocation(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	// Fetch driver ID associated with user
	d, err := h.driverService.GetByUserID(c.Context(), userID)
	if err != nil || d == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "driver profile not found"})
	}

	// Dynamic body parser to accept either string or float64 for coordinates (e.g. from /api/user/store-live-location)
	var reqMap map[string]interface{}
	if err := c.BodyParser(&reqMap); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	var lat, lng float64

	// Parse latitude
	if latVal, exists := reqMap["latitude"]; exists {
		switch v := latVal.(type) {
		case float64:
			lat = v
		case string:
			var err error
			lat, err = strconv.ParseFloat(v, 64)
			if err != nil {
				return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid latitude format"})
			}
		default:
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "latitude must be float or string"})
		}
	} else {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "latitude is required"})
	}

	// Parse longitude
	if lngVal, exists := reqMap["longitude"]; exists {
		switch v := lngVal.(type) {
		case float64:
			lng = v
		case string:
			var err error
			lng, err = strconv.ParseFloat(v, 64)
			if err != nil {
				return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid longitude format"})
			}
		default:
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "longitude must be float or string"})
		}
	} else {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "longitude is required"})
	}

	// 1. Mettre à jour le cache Redis (lecture ultra-rapide pour get-live-location)
	locPayload, _ := json.Marshal(map[string]float64{"latitude": lat, "longitude": lng})
	cacheKey := fmt.Sprintf("driver:loc:%s", d.ID.String())
	h.redis.Set(context.Background(), cacheKey, locPayload, 90*time.Second)

	// 2. Publier sur Redis Pub/Sub → WebSocket Hub broadcast aux passagers abonnés
	pubPayload, _ := json.Marshal(map[string]interface{}{
		"driver_id": d.ID.String(),
		"latitude":  lat,
		"longitude": lng,
		"ts":        time.Now().Unix(),
	})
	h.redis.Publish(context.Background(), fmt.Sprintf("driver:location:%s", d.ID.String()), pubPayload)

	// 3. Écrire en BDD seulement si la dernière écriture date de >30s (throttle)
	throttleKey := fmt.Sprintf("driver:loc:db_flush:%s", d.ID.String())
	set, _ := h.redis.SetNX(context.Background(), throttleKey, "1", 30*time.Second).Result()
	if set {
		// Premier appel de la fenêtre : écrire en BDD
		if err := h.driverService.UpdateLocation(c.Context(), d.ID, lat, lng); err != nil {
			// Log mais ne pas bloquer la réponse — le cache Redis est à jour
			fmt.Printf("[WARN] DB location flush failed for driver %s: %v\n", d.ID, err)
		}
	}

	return c.JSON(fiber.Map{"status": "location updated"})
}

func (h *DriverHandler) UpdateStatus(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	d, err := h.driverService.GetByUserID(c.Context(), userID)
	if err != nil || d == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "driver profile not found"})
	}

	var req domain.UpdateStatusRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}

	if err := h.driverService.UpdateStatus(c.Context(), d.ID, req.Status); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}

	return c.JSON(fiber.Map{"status": "status updated"})
}

func (h *DriverHandler) FindNearby(c *fiber.Ctx) error {
	latStr := c.Query("lat")
	lngStr := c.Query("lng")
	radStr := c.Query("radius", "5000") // 5km default

	lat, err := strconv.ParseFloat(latStr, 64)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid latitude"})
	}

	lng, err := strconv.ParseFloat(lngStr, 64)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid longitude"})
	}

	radius, err := strconv.ParseFloat(radStr, 64)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid radius"})
	}

	drivers, err := h.driverService.FindNearby(c.Context(), lat, lng, radius, 10)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}

	return c.JSON(drivers)
}

func (h *DriverHandler) GetDriverConfig(c *fiber.Ctx) error {
	host := c.Hostname()
	port := "443"
	fullHost := c.Get("Host")
	if strings.Contains(fullHost, ":") {
		parts := strings.Split(fullHost, ":")
		host = parts[0]
		port = parts[1]
	}

	scheme := "http"
	if c.Secure() {
		scheme = "https"
	}
	baseURL := fmt.Sprintf("%s://%s/api/", scheme, fullHost)
	imageBaseURLStr := fmt.Sprintf("%s://%s/uploads/", scheme, fullHost)

	settings, err := h.settingService.GetSettings(c.Context())
	dispatchTimeout := 10
	supportEmail := "support@zekdrive.cm"
	supportPhone := "+237690000000"

	if err == nil && settings != nil {
		if appConfig, ok := settings["app_config"].(map[string]interface{}); ok {
			if dt, ok := appConfig["dispatchTimeout"].(float64); ok {
				dispatchTimeout = int(dt)
			} else if dtInt, ok := appConfig["dispatchTimeout"].(int); ok {
				dispatchTimeout = dtInt
			}
			if se, ok := appConfig["supportEmail"].(string); ok {
				supportEmail = se
			}
			if sp, ok := appConfig["supportPhone"].(string); ok {
				supportPhone = sp
			}
		}
	}

	// Résolution dynamique devise + pays selon le chauffeur connecté
	cfgCurrencyCode := "XAF"
	cfgCurrencySymbol := "FCFA"
	cfgCountryCode := "CM"
	if userIDVal := c.Locals("userID"); userIDVal != nil {
		if uid, ok2 := userIDVal.(uuid.UUID); ok2 {
			if d, err2 := h.driverService.GetByUserID(c.Context(), uid); err2 == nil && d != nil && d.User.Country != "" {
				cfgCurrencyCode, cfgCurrencySymbol = getCurrencyByCountry(d.User.Country)
				cfgCountryCode = strings.ToUpper(d.User.Country)
				if len(cfgCountryCode) > 2 {
					cfgCountryCode = "CM"
				}
			}
		}
	}

	configMap := fiber.Map{
		"is_demo":                    true,
		"maintenance_mode":           false,
		"required_pin_to_start_trip": false,
		"add_intermediate_points":    true,
		"business_name":              "ZekDrive",
		"logo":                       "logo.png",
		"bid_on_fare":                false,
		"driver_completion_radius":   10.0,
		"country_code":               cfgCountryCode,
		"business_address":           "Yaoundé, Cameroun",
		"business_contact_phone":     supportPhone,
		"business_contact_email":     supportEmail,
		"business_support_phone":     supportPhone,
		"business_support_email":     supportEmail,
		"conversion_status":          false,
				"conversion_rate":            0.0,
		"base_url":                   baseURL,
		"websocket_url":              host,
		"websocket_port":             port,
		"websocket_key":              "drivemond",
		"map_api_key":                "AIzaSyBLzkqJWnCO_OucXE-aoUdj9rtqfcuZo54",
		"map_api_key_server":         "AIzaSyBLzkqJWnCO_OucXE-aoUdj9rtqfcuZo54",
		"review_status":              true,
		"level_status":               false,
		"image_base_url": fiber.Map{
			"profile_image_customer": imageBaseURLStr + "customer/profile",
			"banner":                 imageBaseURLStr + "promotion/banner",
			"vehicle_category":       imageBaseURLStr + "vehicle/category",
			"vehicle_model":          imageBaseURLStr + "vehicle/model",
			"vehicle_brand":          imageBaseURLStr + "vehicle/brand",
			"profile_image":          imageBaseURLStr + "driver/profile",
			"identity_image":         imageBaseURLStr + "driver/identity",
			"documents":              imageBaseURLStr + "driver/document",
			"pages":                  imageBaseURLStr + "business/pages",
			"conversation":           imageBaseURLStr + "conversation",
			"parcel":                 imageBaseURLStr + "parcel/category",
		},
		"otp_resend_time":          60,
		"trip_request_active_time": dispatchTimeout,
		"currency_decimal_point":   "0",
		"currency_code":            cfgCurrencyCode,
		"currency_symbol":          cfgCurrencySymbol,
		"currency_symbol_position": "right",
		"about_us": fiber.Map{
			"image":             "",
			"name":              AboutUsName,
			"short_description": AboutUsShort,
			"long_description":  AboutUsLong,
		},
		"privacy_policy": fiber.Map{
			"image":             "",
			"name":              PrivacyPolicyName,
			"short_description": PrivacyPolicyShort,
			"long_description":  PrivacyPolicyLong,
		},
		"terms_and_conditions": fiber.Map{
			"image":             "",
			"name":              TermsAndConditionsName,
			"short_description": TermsAndConditionsShort,
			"long_description":  TermsAndConditionsLong,
		},
		"legal": fiber.Map{
			"image":             "",
			"name":              LegalNoticeName,
			"short_description": LegalNoticeShort,
			"long_description":  LegalNoticeLong,
		},
		"verification":      false,
		"sms_verification":   false,
		"email_verification": false,
		"facebook_login":     false,
		"google_login":       false,
		"self_registration":  true,
	}

	return c.JSON(configMap)
}
