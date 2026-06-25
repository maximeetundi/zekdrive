package handler

import (
	"github.com/gofiber/fiber/v2"
	"github.com/zekdrive/api/internal/domain"
)

type SettingHandler struct {
	settingService domain.SettingService
}

func NewSettingHandler(settingService domain.SettingService) *SettingHandler {
	return &SettingHandler{settingService: settingService}
}

func (h *SettingHandler) GetSettings(c *fiber.Ctx) error {
	settings, err := h.settingService.GetSettings(c.Context())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(settings)
}

func (h *SettingHandler) SaveSettings(c *fiber.Ctx) error {
	var body map[string]interface{}
	if err := c.BodyParser(&body); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	err := h.settingService.SaveSettings(c.Context(), body)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{"status": "success", "message": "settings saved successfully"})
}
