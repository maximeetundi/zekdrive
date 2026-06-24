package handler

import (
	"fmt"
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/service"
)

type UserHandler struct {
	userService service.UserService
}

func NewUserHandler(userService service.UserService) *UserHandler {
	return &UserHandler{userService: userService}
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
		return c.JSON(fiber.Map{"data": u})
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

	configMap := fiber.Map{
		"is_demo":                    true,
		"maintenance_mode":           false,
		"required_pin_to_start_trip": false,
		"add_intermediate_points":    true,
		"business_name":              "ZekDrive",
		"logo":                       "logo.png",
		"bid_on_fare":                false,
		"country_code":               "FR",
		"business_address":           "Paris, France",
		"business_contact_phone":     "+33100000000",
		"business_contact_email":     "contact@zekdrive.com",
		"business_support_phone":     "+33100000000",
		"business_support_email":     "support@zekdrive.com",
		"conversion_status":          false,
		"conversion_rate":            0.0,
		"websocket_url":              host,
		"websocket_port":             port,
		"websocket_key":              "drivemond",
		"base_url":                   baseURL,
		"review_status":              true,
		"level_status":               false,
		"search_radius":              10000.0,
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
		"currency_decimal_point":   "2",
		"trip_request_active_time": 10,
		"currency_code":            "EUR",
		"currency_symbol":          "€",
		"currency_symbol_position": "left",
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
		"verification":     false,
		"sms_verification":   false,
		"email_verification": false,
		"facebook_login":     false,
		"google_login":       false,
		"otp_resend_time":    60,
		"vat_tax":            1.0,
		"payment_gateways":   []interface{}{},
	}

	return c.JSON(configMap)
}
