package handler

import (
	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/zekdrive/api/internal/domain"
	"github.com/zekdrive/api/internal/service"
)

type PricingHandler struct {
	pricingService service.PricingService
	validate       *validator.Validate
}

func NewPricingHandler(pricingService service.PricingService) *PricingHandler {
	return &PricingHandler{
		pricingService: pricingService,
		validate:       validator.New(),
	}
}

func (h *PricingHandler) Estimate(c *fiber.Ctx) error {
	var req domain.EstimatePriceRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	estimation, err := h.pricingService.EstimatePrice(c.Context(), &req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(estimation)
}
