package middleware

import (
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/limiter"
)

func NewRateLimiterMiddleware() fiber.Handler {
	return limiter.New(limiter.Config{
		Max:        300, // 300 requêtes par minute par IP (≈ 5 req/s)
		Expiration: 1 * time.Minute,
		KeyGenerator: func(c *fiber.Ctx) string {
			// Clé = IP + route pour un rate-limit plus granulaire
			return c.IP()
		},
		// Exclure les routes GPS temps réel (très fréquentes)
		Next: func(c *fiber.Ctx) bool {
			path := c.Path()
			return strings.Contains(path, "store-live-location") ||
				strings.Contains(path, "get-live-location") ||
				strings.Contains(path, "/health")
		},
		LimitReached: func(c *fiber.Ctx) error {
			return c.Status(fiber.StatusTooManyRequests).JSON(fiber.Map{
				"error": "too many requests, please try again later",
			})
		},
	})
}
