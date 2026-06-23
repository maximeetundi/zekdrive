package middleware

import (
	"os"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/rs/zerolog"
)

func NewLoggerMiddleware() fiber.Handler {
	logger := zerolog.New(os.Stdout).With().Timestamp().Logger()

	return func(c *fiber.Ctx) error {
		start := time.Now()

		// Process request
		err := c.Next()

		duration := time.Since(start)

		event := logger.Info()
		if err != nil {
			event = logger.Error().Err(err)
		}

		event.
			Str("method", c.Method()).
			Str("path", c.Path()).
			Int("status", c.Response().StatusCode()).
			Str("ip", c.IP()).
			Str("latency", duration.String()).
			Msg("HTTP request processed")

		return err
	}
}
