package handler

import (
	"strconv"

	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/domain"
	"github.com/zekdrive/api/internal/service"
)

type DeliveryHandler struct {
	deliveryService service.DeliveryService
	driverService   service.DriverService
	validate        *validator.Validate
}

func NewDeliveryHandler(deliveryService service.DeliveryService, driverService service.DriverService) *DeliveryHandler {
	return &DeliveryHandler{
		deliveryService: deliveryService,
		driverService:   driverService,
		validate:        validator.New(),
	}
}

func (h *DeliveryHandler) RequestDelivery(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	senderID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	var req domain.CreateDeliveryRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	delivery, err := h.deliveryService.RequestDelivery(c.Context(), senderID, &req)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusCreated).JSON(delivery)
}

func (h *DeliveryHandler) AcceptDelivery(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	deliveryIDStr := c.Params("id")
	deliveryID, err := uuid.Parse(deliveryIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid delivery id"})
	}

	d, err := h.driverService.GetByUserID(c.Context(), userID)
	if err != nil || d == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "driver profile not found"})
	}

	delivery, err := h.deliveryService.AcceptDelivery(c.Context(), deliveryID, d.ID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(delivery)
}

func (h *DeliveryHandler) UpdateStatus(c *fiber.Ctx) error {
	deliveryIDStr := c.Params("id")
	deliveryID, err := uuid.Parse(deliveryIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid delivery id"})
	}

	var req domain.UpdateDeliveryStatusRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cannot parse request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	delivery, err := h.deliveryService.UpdateStatus(c.Context(), deliveryID, req.Status)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(delivery)
}

func (h *DeliveryHandler) CancelDelivery(c *fiber.Ctx) error {
	deliveryIDStr := c.Params("id")
	deliveryID, err := uuid.Parse(deliveryIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid delivery id"})
	}

	delivery, err := h.deliveryService.CancelDelivery(c.Context(), deliveryID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(delivery)
}

func (h *DeliveryHandler) GetByID(c *fiber.Ctx) error {
	deliveryIDStr := c.Params("id")
	deliveryID, err := uuid.Parse(deliveryIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid delivery id"})
	}

	delivery, err := h.deliveryService.GetByID(c.Context(), deliveryID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if delivery == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "delivery order not found"})
	}

	return c.JSON(delivery)
}

func (h *DeliveryHandler) ListSenderHistory(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	senderID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	limit, _ := strconv.Atoi(c.Query("limit", "10"))
	offset, _ := strconv.Atoi(c.Query("offset", "0"))

	deliveries, err := h.deliveryService.ListBySenderID(c.Context(), senderID, limit, offset)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(deliveries)
}

func (h *DeliveryHandler) ListDriverHistory(c *fiber.Ctx) error {
	userIDVal := c.Locals("userID")
	userID, ok := userIDVal.(uuid.UUID)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	d, err := h.driverService.GetByUserID(c.Context(), userID)
	if err != nil || d == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "driver profile not found"})
	}

	limit, _ := strconv.Atoi(c.Query("limit", "10"))
	offset, _ := strconv.Atoi(c.Query("offset", "0"))

	deliveries, err := h.deliveryService.ListByDriverID(c.Context(), d.ID, limit, offset)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(deliveries)
}
