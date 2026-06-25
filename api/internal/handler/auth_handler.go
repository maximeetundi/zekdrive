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
	var req domain.RegisterRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	u, err := h.authService.Register(c.Context(), &req)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	if strings.Contains(c.Path(), "/customer/") || strings.Contains(c.Path(), "/driver/") {
		return c.Status(fiber.StatusCreated).JSON(fiber.Map{
			"data": u,
		})
	}

	return c.Status(fiber.StatusCreated).JSON(u)
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
