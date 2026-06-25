package handler

import (
	"strings"

	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/zekdrive/api/internal/domain"
	"github.com/zekdrive/api/internal/service"
)

type AuthHandler struct {
	authService service.AuthService
	validate    *validator.Validate
}

func NewAuthHandler(authService service.AuthService) *AuthHandler {
	return &AuthHandler{
		authService: authService,
		validate:    validator.New(),
	}
}

func (h *AuthHandler) Register(c *fiber.Ctx) error {
	var raw map[string]interface{}
	if err := c.BodyParser(&raw); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	var req domain.RegisterRequest
	_ = c.BodyParser(&req)

	// Map first_name and last_name to Name if Name is empty
	if req.Name == "" {
		firstName, _ := raw["first_name"].(string)
		lastName, _ := raw["last_name"].(string)
		if firstName != "" || lastName != "" {
			req.Name = strings.TrimSpace(firstName + " " + lastName)
		}
	}

	// Map phone from raw body if phone is empty
	if req.Phone == "" {
		phone, _ := raw["phone"].(string)
		req.Phone = phone
	}

	// Generate a fallback unique email if not provided (common for User app WhatsApp-only signup)
	if req.Email == "" {
		email, _ := raw["email"].(string)
		if email != "" {
			req.Email = email
		} else if req.Phone != "" {
			cleanPhone := strings.TrimPrefix(req.Phone, "+")
			req.Email = cleanPhone + "@zekdrive.local"
		}
	}

	// Map role based on request path if role is empty or not standard
	if req.Role == "" {
		role, _ := raw["role"].(string)
		if role != "" {
			req.Role = domain.UserRole(role)
		} else {
			if strings.Contains(c.Path(), "/customer/") {
				req.Role = "rider"
			} else if strings.Contains(c.Path(), "/driver/") {
				req.Role = "pro"
				req.ProProfiles = "driver"
			}
		}
	}

	// Ensure password is mapped
	if req.Password == "" {
		password, _ := raw["password"].(string)
		req.Password = password
	}

	// Map identification type and number
	if req.IdentificationType == "" {
		req.IdentificationType, _ = raw["identification_type"].(string)
	}
	if req.IdentificationNumber == "" {
		req.IdentificationNumber, _ = raw["identification_number"].(string)
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	u, err := h.authService.Register(c.Context(), &req)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	if strings.Contains(c.Path(), "/customer/") || strings.Contains(c.Path(), "/driver/") {
		return c.Status(fiber.StatusOK).JSON(fiber.Map{
			"data": u,
		})
	}

	return c.Status(fiber.StatusOK).JSON(u)
}

func (h *AuthHandler) Login(c *fiber.Ctx) error {
	var req domain.LoginRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	if req.Email == "" && req.PhoneOrEmail == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "email or phone_or_email is required"})
	}

	resp, err := h.authService.Login(c.Context(), &req)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": err.Error()})
	}

	if strings.Contains(c.Path(), "/customer/") || strings.Contains(c.Path(), "/driver/") {
		isPhoneVerified := 1
		if !resp.User.IsPhoneVerified {
			isPhoneVerified = 0
			// Auto-send OTP when phone is not verified
			otpReq := domain.SendWhatsAppOTPRequest{
				Phone: resp.User.Phone,
			}
			_ = h.authService.SendWhatsAppOTP(c.Context(), &otpReq)

			return c.Status(fiber.StatusAccepted).JSON(fiber.Map{
				"data": fiber.Map{
					"token":               resp.AccessToken,
					"is_active":           true,
					"is_phone_verified":   isPhoneVerified,
					"is_profile_verified": 1,
				},
			})
		}

		return c.JSON(fiber.Map{
			"data": fiber.Map{
				"token":               resp.AccessToken,
				"is_active":           true,
				"is_phone_verified":   isPhoneVerified,
				"is_profile_verified": 1,
			},
		})
	}

	return c.JSON(resp)
}

func (h *AuthHandler) RefreshToken(c *fiber.Ctx) error {
	var req domain.RefreshTokenRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	resp, err := h.authService.RefreshToken(c.Context(), req.RefreshToken)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(resp)
}

func (h *AuthHandler) SendWhatsAppOTP(c *fiber.Ctx) error {
	var req domain.SendWhatsAppOTPRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	err := h.authService.SendWhatsAppOTP(c.Context(), &req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{"message": "code de validation envoyé par WhatsApp"})
}

func (h *AuthHandler) VerifyWhatsAppOTP(c *fiber.Ctx) error {
	var req domain.VerifyWhatsAppOTPRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	// Map role dynamically if empty
	if req.Role == "" {
		if strings.Contains(c.Path(), "/customer/") {
			req.Role = "rider"
		} else if strings.Contains(c.Path(), "/driver/") {
			req.Role = "pro"
		}
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	resp, err := h.authService.VerifyWhatsAppOTP(c.Context(), &req)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": err.Error()})
	}

	if strings.Contains(c.Path(), "/customer/") || strings.Contains(c.Path(), "/driver/") {
		return c.JSON(fiber.Map{
			"data": fiber.Map{
				"token":               resp.AccessToken,
				"is_active":           true,
				"is_phone_verified":   1,
				"is_profile_verified": 1,
			},
		})
	}

	return c.JSON(resp)
}
