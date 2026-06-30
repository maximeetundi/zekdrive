package handler

import (
	"fmt"
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/domain"
	"github.com/zekdrive/api/internal/service"
)

type UserHandler struct {
	userService    service.UserService
	settingService domain.SettingService
}

func NewUserHandler(userService service.UserService, settingService domain.SettingService) *UserHandler {
	return &UserHandler{
		userService:    userService,
		settingService: settingService,
	}
}

func (h *UserHandler) GetMe(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	u, err := h.userService.GetByID(c.Context(), userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if u == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "user not found"})
	}

	if strings.Contains(c.Path(), "/customer/") || strings.Contains(c.Path(), "/driver/") {
		firstName := u.Name
		lastName := ""
		parts := strings.SplitN(u.Name, " ", 2)
		if len(parts) > 0 {
			firstName = parts[0]
		}
		if len(parts) > 1 {
			lastName = parts[1]
		}

		profileData := fiber.Map{
			"id":                 u.ID.String(),
			"first_name":         firstName,
			"last_name":          lastName,
			"email":              u.Email,
			"phone":              u.Phone,
			"is_active":          1,
			"user_rating":        "5.0",
			"total_ride_count":   0,
			"completion_percent": 100.0,
			"loyalty_points":     0,
			"wallet": fiber.Map{
				"id":                 u.ID.String(),
				"payable_balance":    0.0,
				"receivable_balance": 0.0,
				"pending_balance":    0.0,
				"wallet_balance":     0.0,
				"total_withdrawn":    0.0,
			},
			"level": fiber.Map{
				"id":          "level-default-id",
				"sequence":    1,
				"name":        "Bronze",
				"reward_type": "none",
				"image":       "",
			},
		}

		return c.JSON(fiber.Map{
			"response_code": "200",
			"message":       "success",
			"data":          profileData,
		})
	}

	return c.JSON(u)
}

type updateProfileReq struct {
	Name  string `json:"name" validate:"required,min=2"`
	Phone string `json:"phone" validate:"required,min=8"`
}

func (h *UserHandler) UpdateProfile(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	var req updateProfileReq
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	u, err := h.userService.Update(c.Context(), userID, req.Name, req.Phone)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	if strings.Contains(c.Path(), "/customer/") || strings.Contains(c.Path(), "/driver/") {
		return c.JSON(fiber.Map{"data": u})
	}

	return c.JSON(u)
}

func (h *UserHandler) GetCustomerConfig(c *fiber.Ctx) error {
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
	searchRadius := 10000.0
	supportEmail := "support@zekdrive.com"
	supportPhone := "+221 33 800 0000"
	var paymentGateways []interface{} = []interface{}{}

	if err == nil && settings != nil {
		if appConfig, ok := settings["app_config"].(map[string]interface{}); ok {
			if dt, ok := appConfig["dispatchTimeout"].(float64); ok {
				dispatchTimeout = int(dt)
			} else if dtInt, ok := appConfig["dispatchTimeout"].(int); ok {
				dispatchTimeout = dtInt
			}
			if sr, ok := appConfig["searchRadius"].(float64); ok {
				searchRadius = sr * 1000.0
			} else if srInt, ok := appConfig["searchRadius"].(int); ok {
				searchRadius = float64(srInt) * 1000.0
			}
			if se, ok := appConfig["supportEmail"].(string); ok {
				supportEmail = se
			}
			if sp, ok := appConfig["supportPhone"].(string); ok {
				supportPhone = sp
			}
		}

		if gateways, ok := settings["gateways"].([]interface{}); ok {
			for _, gwVal := range gateways {
				if gw, ok := gwVal.(map[string]interface{}); ok {
					enabled := false
					if en, ok := gw["enabled"].(bool); ok {
						enabled = en
					}
					if enabled {
						idStr, _ := gw["id"].(string)
						nameStr, _ := gw["name"].(string)
						gatewayKey := strings.Replace(idStr, "gw_", "", 1)
						paymentGateways = append(paymentGateways, fiber.Map{
							"gateway":       gatewayKey,
							"gateway_title": nameStr,
							"gateway_image": gatewayKey + ".png",
						})
					}
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
		"country_code":               "SN",
		"business_address":           "Dakar, Senegal",
		"business_contact_phone":     supportPhone,
		"business_contact_email":     supportEmail,
		"business_support_phone":     supportPhone,
		"business_support_email":     supportEmail,
		"conversion_status":          false,
		"conversion_rate":            0.0,
		"websocket_url":              host,
		"websocket_port":             port,
		"websocket_key":              "drivemond",
		"base_url":                   baseURL,
		"review_status":              true,
		"level_status":               false,
		"search_radius":              searchRadius,
		"popular_tips":               5,
		"driver_completion_radius":   1000.0,
		"image_base_url": fiber.Map{
			"profile_image_driver": imageBaseURLStr + "driver/profile",
			"banner":                 imageBaseURLStr + "promotion/banner",
			"vehicle_category":       imageBaseURLStr + "vehicle/category",
			"vehicle_model":          imageBaseURLStr + "vehicle/model",
			"vehicle_brand":          imageBaseURLStr + "vehicle/brand",
			"profile_image":          imageBaseURLStr + "customer/profile",
			"identity_image":         imageBaseURLStr + "customer/identity",
			"documents":              imageBaseURLStr + "customer/document",
			"level":                  imageBaseURLStr + "customer/level",
			"pages":                  imageBaseURLStr + "business/pages",
			"conversation":           imageBaseURLStr + "conversation",
			"parcel":                 imageBaseURLStr + "parcel/category",
			"payment_method":         imageBaseURLStr + "payment_modules/gateway_image",
		},
		"currency_decimal_point":   "0",
		"trip_request_active_time": dispatchTimeout,
		"currency_code":            "XOF",
		"currency_symbol":          "FCFA",
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
		"verification":     false,
		"sms_verification":   false,
		"email_verification": false,
		"facebook_login":     false,
		"google_login":       false,
		"otp_resend_time":    60,
		"vat_tax":            1.0,
		"payment_gateways":   paymentGateways,
	}

	return c.JSON(configMap)
}
