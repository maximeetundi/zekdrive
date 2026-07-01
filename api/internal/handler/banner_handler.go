package handler

import (
	"fmt"
	"path/filepath"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/domain"
)

type BannerHandler struct {
	bannerRepo domain.BannerRepository
}

func NewBannerHandler(bannerRepo domain.BannerRepository) *BannerHandler {
	return &BannerHandler{bannerRepo: bannerRepo}
}

func (h *BannerHandler) ListPublic(c *fiber.Ctx) error {
	banners, err := h.bannerRepo.List(c.Context())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{
		"total_size": len(banners),
		"limit":      "100",
		"offset":     "1",
		"data":       banners,
	})
}

func (h *BannerHandler) AdminList(c *fiber.Ctx) error {
	banners, err := h.bannerRepo.List(c.Context())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(banners)
}

func (h *BannerHandler) Create(c *fiber.Ctx) error {
	name := c.FormValue("name")
	description := c.FormValue("description")
	timePeriod := c.FormValue("time_period")
	displayPosition := c.FormValue("display_position")
	redirectLink := c.FormValue("redirect_link")
	bannerGroup := c.FormValue("banner_group")
	startDate := c.FormValue("start_date")
	endDate := c.FormValue("end_date")

	if name == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "name is required"})
	}

	if timePeriod == "" {
		timePeriod = "all"
	}
	if displayPosition == "" {
		displayPosition = "top"
	}
	if bannerGroup == "" {
		bannerGroup = "all"
	}
	if startDate == "" {
		startDate = time.Now().Format("2006-01-01")
	}
	if endDate == "" {
		endDate = time.Now().AddDate(1, 0, 0).Format("2006-01-01")
	}

	// Handle Image Upload
	file, err := c.FormFile("image")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "image file is required"})
	}

	fileName := fmt.Sprintf("banner_%d%s", time.Now().UnixNano(), filepath.Ext(file.Filename))
	uploadPath := filepath.Join("./uploads/promotion/banner", fileName)
	if err := c.SaveFile(file, uploadPath); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "failed to save image"})
	}

	b := &domain.Banner{
		ID:              uuid.New(),
		Name:            name,
		Description:     description,
		TimePeriod:      timePeriod,
		DisplayPosition: displayPosition,
		RedirectLink:    redirectLink,
		BannerGroup:     bannerGroup,
		StartDate:       startDate,
		EndDate:         endDate,
		Image:           fileName,
		CreatedAt:       time.Now(),
		UpdatedAt:       time.Now(),
	}

	if err := h.bannerRepo.Create(c.Context(), b); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(b)
}

func (h *BannerHandler) Update(c *fiber.Ctx) error {
	idStr := c.Params("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid banner id"})
	}

	b, err := h.bannerRepo.GetByID(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if b == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "banner not found"})
	}

	name := c.FormValue("name")
	description := c.FormValue("description")
	timePeriod := c.FormValue("time_period")
	displayPosition := c.FormValue("display_position")
	redirectLink := c.FormValue("redirect_link")
	bannerGroup := c.FormValue("banner_group")
	startDate := c.FormValue("start_date")
	endDate := c.FormValue("end_date")

	if name != "" {
		b.Name = name
	}
	if description != "" {
		b.Description = description
	}
	if timePeriod != "" {
		b.TimePeriod = timePeriod
	}
	if displayPosition != "" {
		b.DisplayPosition = displayPosition
	}
	if redirectLink != "" {
		b.RedirectLink = redirectLink
	}
	if bannerGroup != "" {
		b.BannerGroup = bannerGroup
	}
	if startDate != "" {
		b.StartDate = startDate
	}
	if endDate != "" {
		b.EndDate = endDate
	}

	// Handle Image Upload (Optional on update)
	file, err := c.FormFile("image")
	if err == nil && file != nil {
		fileName := fmt.Sprintf("banner_%d%s", time.Now().UnixNano(), filepath.Ext(file.Filename))
		uploadPath := filepath.Join("./uploads/promotion/banner", fileName)
		if err := c.SaveFile(file, uploadPath); err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "failed to save image"})
		}
		b.Image = fileName
	}

	b.UpdatedAt = time.Now()

	if err := h.bannerRepo.Update(c.Context(), b); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(b)
}

func (h *BannerHandler) Delete(c *fiber.Ctx) error {
	idStr := c.Params("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid banner id"})
	}

	if err := h.bannerRepo.Delete(c.Context(), id); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{"message": "banner deleted successfully"})
}
