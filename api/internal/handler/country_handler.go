package handler

import (
	"github.com/gofiber/fiber/v2"
	"github.com/zekdrive/api/internal/domain"
)

type CountryHandler struct {
	repo domain.CountryRepository
}

func NewCountryHandler(repo domain.CountryRepository) *CountryHandler {
	return &CountryHandler{repo: repo}
}

// GET /api/admin/countries
func (h *CountryHandler) ListAll(c *fiber.Ctx) error {
	countries, err := h.repo.ListAll(c.Context())
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(countries)
}

// GET /api/admin/countries/active
func (h *CountryHandler) ListActive(c *fiber.Ctx) error {
	countries, err := h.repo.ListActive(c.Context())
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(countries)
}

// GET /api/admin/countries/:code
func (h *CountryHandler) GetByCode(c *fiber.Ctx) error {
	code := c.Params("code")
	country, err := h.repo.GetByCode(c.Context(), code)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	if country == nil {
		return c.Status(404).JSON(fiber.Map{"error": "country not found"})
	}
	return c.JSON(country)
}

// PUT /api/admin/countries/:code/active
func (h *CountryHandler) SetActive(c *fiber.Ctx) error {
	code := c.Params("code")
	var body struct {
		Active bool `json:"active"`
	}
	if err := c.BodyParser(&body); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid body"})
	}
	if err := h.repo.SetActive(c.Context(), code, body.Active); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"success": true, "code": code, "active": body.Active})
}

// GET /api/admin/countries/:code/config
func (h *CountryHandler) GetConfig(c *fiber.Ctx) error {
	code := c.Params("code")
	cfg, err := h.repo.GetConfig(c.Context(), code)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	if cfg == nil {
		return c.Status(404).JSON(fiber.Map{"error": "no config for this country"})
	}
	return c.JSON(cfg)
}

// PUT /api/admin/countries/:code/config
func (h *CountryHandler) UpsertConfig(c *fiber.Ctx) error {
	code := c.Params("code")
	var cfg domain.CountryConfig
	if err := c.BodyParser(&cfg); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid body"})
	}
	cfg.CountryCode = code
	if err := h.repo.UpsertConfig(c.Context(), cfg); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"success": true})
}

// GET /api/countries/active  (public — for mobile apps)
func (h *CountryHandler) PublicListActive(c *fiber.Ctx) error {
	countries, err := h.repo.ListActive(c.Context())
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(countries)
}

// GET /api/countries/:code/config  (public — for mobile apps to fetch pricing)
func (h *CountryHandler) PublicGetConfig(c *fiber.Ctx) error {
	code := c.Params("code")
	cfg, err := h.repo.GetConfig(c.Context(), code)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	if cfg == nil {
		return c.Status(404).JSON(fiber.Map{"error": "no config"})
	}
	return c.JSON(cfg)
}
