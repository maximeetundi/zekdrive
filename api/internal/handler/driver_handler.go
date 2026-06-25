package handler

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/domain"
	"github.com/zekdrive/api/internal/service"
)

type DriverHandler struct {
	driverService  service.DriverService
	settingService domain.SettingService
	validate       *validator.Validate
}

func NewDriverHandler(driverService service.DriverService, settingService domain.SettingService) *DriverHandler {
	return &DriverHandler{
		driverService:  driverService,
		settingService: settingService,
		validate:       validator.New(),
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
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	d, err := h.driverService.RegisterDriver(c.Context(), userID, req.LicenseNumber)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
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
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
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
				"id":            d.ID.String(),
				"driver_id":     d.ID.String(),
				"balance":       d.WalletBalance,
				"currency_code": d.WalletCurrency,
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

	if err := h.driverService.UpdateLocation(c.Context(), d.ID, lat, lng); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
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
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	if err := h.driverService.UpdateStatus(c.Context(), d.ID, req.Status); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
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
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
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
	supportEmail := "support@zekdrive.com"
	supportPhone := "+221 33 800 0000"

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

	configMap := fiber.Map{
		"is_demo":                    true,
		"maintenance_mode":           false,
		"required_pin_to_start_trip": false,
		"add_intermediate_points":    true,
		"business_name":              "ZekDrive",
		"logo":                       "logo.png",
		"bid_on_fare":                false,
		"driver_completion_radius":   10.0,
		"country_code":               "SN",
		"business_address":           "Dakar, Senegal",
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
		"currency_code":            "XOF",
		"currency_symbol":          "FCFA",
		"currency_symbol_position": "right",
		"about_us": fiber.Map{
			"image":             "",
			"name":              "About Us",
			"short_description": "ZekDrive",
			"long_description":  "ZekDrive description",
		},
		"privacy_policy": fiber.Map{
			"image":             "",
			"name":              "Privacy Policy",
			"short_description": "Privacy Policy",
			"long_description":  "Privacy Policy description",
		},
		"terms_and_conditions": fiber.Map{
			"image":             "",
			"name":              "Terms & Conditions",
			"short_description": "Terms & Conditions",
			"long_description":  "Terms & Conditions description",
		},
		"legal": fiber.Map{
			"image":             "",
			"name":              "Legal Notice",
			"short_description": "Legal Notice",
			"long_description":  "Legal Notice description",
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
