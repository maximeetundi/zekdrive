package handler

import (
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/domain"
)

type WalletHandler struct {
	repo domain.WalletRepository
}

func NewWalletHandler(repo domain.WalletRepository) *WalletHandler {
	return &WalletHandler{repo: repo}
}

// ── ROUTES CHAUFFEUR (PRO) ────────────────────────────────────────────────────

// GET /api/pro/wallet
func (h *WalletHandler) GetMyWallet(c *fiber.Ctx) error {
	driverID, err := driverIDFromCtx(c)
	if err != nil {
		return c.Status(401).JSON(fiber.Map{"error": "unauthorized"})
	}
	wallet, err := h.repo.GetOrCreate(c.Context(), driverID, "XAF")
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}
	return c.JSON(wallet)
}

// GET /api/pro/wallet/transactions
func (h *WalletHandler) ListMyTransactions(c *fiber.Ctx) error {
	driverID, err := driverIDFromCtx(c)
	if err != nil {
		return c.Status(401).JSON(fiber.Map{"error": "unauthorized"})
	}
	txns, err := h.repo.ListTransactions(c.Context(), driverID, 50)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}
	if txns == nil {
		txns = []domain.WalletTransaction{}
	}
	return c.JSON(txns)
}

// POST /api/pro/wallet/recharge
// Body: { amount, payment_method, phone_number, reference }
func (h *WalletHandler) Recharge(c *fiber.Ctx) error {
	driverID, err := driverIDFromCtx(c)
	if err != nil {
		return c.Status(401).JSON(fiber.Map{"error": "unauthorized"})
	}
	var req domain.RechargeRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid body"})
	}
	if req.Amount <= 0 {
		return c.Status(400).JSON(fiber.Map{"error": "amount must be > 0"})
	}
	// Récupérer la devise depuis le wallet existant
	w, err := h.repo.GetBalance(c.Context(), driverID)
	currency := "XAF"
	if err == nil {
		currency = w.CurrencyCode
	}
	wallet, err := h.repo.Recharge(c.Context(), driverID, req.Amount, req.PaymentMethod, req.Reference, currency)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}
	return c.JSON(fiber.Map{
		"success": true,
		"wallet":  wallet,
		"message_fr": "Compte pro rechargé avec succès",
		"message_en": "Pro account topped up successfully",
	})
}

// ── ROUTES ADMIN ─────────────────────────────────────────────────────────────

// GET /api/admin/wallets
func (h *WalletHandler) AdminListWallets(c *fiber.Ctx) error {
	wallets, err := h.repo.AdminListWallets(c.Context())
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}
	if wallets == nil {
		wallets = []domain.DriverWallet{}
	}
	return c.JSON(wallets)
}

// POST /api/admin/wallets/:driverID/recharge
func (h *WalletHandler) AdminRecharge(c *fiber.Ctx) error {
	driverID, err := uuid.Parse(c.Params("driverID"))
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid driver id"})
	}
	var req struct {
		Amount   float64 `json:"amount"`
		Currency string  `json:"currency"`
		Ref      string  `json:"reference"`
	}
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid body"})
	}
	if req.Currency == "" {
		req.Currency = "XAF"
	}
	wallet, err := h.repo.AdminRecharge(c.Context(), driverID, req.Amount, req.Ref, req.Currency)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}
	return c.JSON(fiber.Map{"success": true, "wallet": wallet})
}

// POST /api/admin/wallets/:driverID/bonus
func (h *WalletHandler) AdminAddBonus(c *fiber.Ctx) error {
	driverID, err := uuid.Parse(c.Params("driverID"))
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid driver id"})
	}
	var req struct {
		Amount    float64 `json:"amount"`
		BonusType string  `json:"bonus_type"` // bonus_bronze, bonus_silver, bonus_gold
		Currency  string  `json:"currency"`
	}
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid body"})
	}
	if req.Currency == "" {
		req.Currency = "XAF"
	}
	if err := h.repo.AddBonus(c.Context(), driverID, req.Amount, req.BonusType, req.Currency); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}
	return c.JSON(fiber.Map{"success": true, "bonus_type": req.BonusType, "amount": req.Amount})
}

// PUT /api/admin/wallets/:driverID/min-balance
func (h *WalletHandler) AdminSetMinBalance(c *fiber.Ctx) error {
	driverID, err := uuid.Parse(c.Params("driverID"))
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid driver id"})
	}
	var req struct {
		MinBalance float64 `json:"min_balance"`
	}
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid body"})
	}
	if err := h.repo.SetMinBalance(c.Context(), driverID, req.MinBalance); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}
	return c.JSON(fiber.Map{"success": true, "min_balance": req.MinBalance})
}

// PUT /api/admin/wallets/:driverID/lock
func (h *WalletHandler) AdminLockWallet(c *fiber.Ctx) error {
	driverID, err := uuid.Parse(c.Params("driverID"))
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid driver id"})
	}
	var req struct {
		Locked bool `json:"locked"`
	}
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid body"})
	}
	if err := h.repo.LockWallet(c.Context(), driverID, req.Locked); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}
	return c.JSON(fiber.Map{"success": true, "locked": req.Locked})
}

// GET /api/admin/wallets/:driverID/transactions
func (h *WalletHandler) AdminListTransactions(c *fiber.Ctx) error {
	driverID, err := uuid.Parse(c.Params("driverID"))
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid driver id"})
	}
	txns, err := h.repo.ListTransactions(c.Context(), driverID, 100)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}
	if txns == nil {
		txns = []domain.WalletTransaction{}
	}
	return c.JSON(txns)
}

// ── Helper ────────────────────────────────────────────────────────────────────

func driverIDFromCtx(c *fiber.Ctx) (uuid.UUID, error) {
	// L'ID driver est stocké par le middleware auth dans le contexte Fiber
	raw := c.Locals("driver_id")
	if raw == nil {
		// Fallback: utiliser user_id (sera lié au driver via user_id=driver.user_id)
		raw = c.Locals("user_id")
	}
	if raw == nil {
		return uuid.Nil, fiber.ErrUnauthorized
	}
	switch v := raw.(type) {
	case uuid.UUID:
		return v, nil
	case string:
		return uuid.Parse(v)
	}
	return uuid.Nil, fiber.ErrUnauthorized
}

func (h *WalletHandler) InitializeRecharge(c *fiber.Ctx) error {
	driverID, err := driverIDFromCtx(c)
	if err != nil {
		return c.Status(401).JSON(fiber.Map{"error": "unauthorized"})
	}

	type InitRequest struct {
		Amount      float64 `json:"amount"`
		Gateway     string  `json:"gateway"` // "dohone_orange", "dohone_mtn", "cinetpay", "stripe", "paypal"
		PhoneNumber string  `json:"phone_number"`
	}

	var req InitRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid body"})
	}

	if req.Amount <= 0 {
		return c.Status(400).JSON(fiber.Map{"error": "amount must be > 0"})
	}

	ref := fmt.Sprintf("REF-%d-%s", time.Now().UnixNano()/1e6, strings.ToUpper(req.Gateway))

	w, err := h.repo.GetBalance(c.Context(), driverID)
	currency := "XAF"
	if err == nil {
		currency = w.CurrencyCode
	}

	err = h.repo.CreatePendingTransaction(c.Context(), driverID, req.Amount, req.Gateway, ref, currency)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": friendlyValidationError(err)})
	}

	if strings.HasPrefix(req.Gateway, "dohone") {
		operator := "OM"
		if strings.HasSuffix(req.Gateway, "mtn") {
			operator = "MOMO"
		}

		go func() {
			dohoneURL := fmt.Sprintf("https://www.my-dohone.com/dohone/pay?rD=defaultMerchantKey&rT=%s&rA=%.0f&rC=%s&rP=%s&rPhone=%s", ref, req.Amount, currency, operator, req.PhoneNumber)
			_, _ = http.Get(dohoneURL)
		}()

		return c.JSON(fiber.Map{
			"success":    true,
			"status":     "initiated",
			"reference":  ref,
			"message_fr": "Lancement du paiement Mobile Money via Dohone. Veuillez valider le message USSD push sur votre mobile avec votre code PIN.",
			"message_en": "Launching Mobile Money payment via Dohone. Please approve the USSD push popup on your mobile with your PIN.",
		})
	} else if req.Gateway == "cinetpay" {
		paymentURL := fmt.Sprintf("https://checkout.cinetpay.com/payment/%s", ref)
		return c.JSON(fiber.Map{
			"success":     true,
			"status":      "redirect",
			"payment_url": paymentURL,
			"reference":   ref,
		})
	} else {
		return c.JSON(fiber.Map{
			"success":     true,
			"status":      "redirect",
			"payment_url": "https://api.driver.maximeetundi.store/payments/manual?ref=" + ref,
			"reference":   ref,
		})
	}
}

func (h *WalletHandler) DohoneNotify(c *fiber.Ctx) error {
	ref := c.Query("idTrans", "")
	status := c.Query("status", "")
	if ref == "" {
		type DohoneBody struct {
			IdTrans string `json:"idTrans" xml:"idTrans" form:"idTrans"`
			Status  string `json:"status" xml:"status" form:"status"`
		}
		var b DohoneBody
		if err := c.BodyParser(&b); err == nil {
			ref = b.IdTrans
			status = b.Status
		}
	}

	if ref == "" {
		return c.Status(400).SendString("Missing idTrans")
	}

	if strings.ToUpper(status) == "SUCCES" || strings.ToUpper(status) == "SUCCESS" {
		_, err := h.repo.CompletePendingTransaction(c.Context(), ref)
		if err != nil {
			return c.Status(500).SendString(err.Error())
		}
	}

	return c.SendString("OK")
}

func (h *WalletHandler) CinetPayNotify(c *fiber.Ctx) error {
	type CinetPayBody struct {
		CpmTransID     string `json:"cpm_trans_id"`
		CpmTransStatus string `json:"cpm_trans_status"`
	}
	var b CinetPayBody
	if err := c.BodyParser(&b); err != nil {
		return c.Status(400).SendString("Invalid body")
	}

	if b.CpmTransID == "" {
		return c.Status(400).SendString("Missing transaction_id")
	}

	if strings.ToUpper(b.CpmTransStatus) == "ACCEPTED" {
		_, err := h.repo.CompletePendingTransaction(c.Context(), b.CpmTransID)
		if err != nil {
			return c.Status(500).SendString(err.Error())
		}
	}

	return c.SendString("OK")
}
