package router

import (
	"github.com/gofiber/fiber/v2"
	"github.com/zekdrive/api/internal/domain"
	"github.com/zekdrive/api/internal/handler"
	"github.com/zekdrive/api/internal/middleware"
)

type Router struct {
	authHandler     *handler.AuthHandler
	userHandler     *handler.UserHandler
	driverHandler   *handler.DriverHandler
	tripHandler     *handler.TripHandler
	deliveryHandler *handler.DeliveryHandler
	vehicleHandler  *handler.VehicleHandler
	zoneHandler     *handler.ZoneHandler
	pricingHandler  *handler.PricingHandler
	adminHandler    *handler.AdminHandler
	wsHandler       *handler.WSHandler
	mapHandler      *handler.MapHandler

	authMiddleware fiber.Handler
}

func NewRouter(
	authHandler *handler.AuthHandler,
	userHandler *handler.UserHandler,
	driverHandler *handler.DriverHandler,
	tripHandler *handler.TripHandler,
	deliveryHandler *handler.DeliveryHandler,
	vehicleHandler *handler.VehicleHandler,
	zoneHandler *handler.ZoneHandler,
	pricingHandler *handler.PricingHandler,
	adminHandler *handler.AdminHandler,
	wsHandler *handler.WSHandler,
	mapHandler *handler.MapHandler,
	authMiddleware fiber.Handler,
) *Router {
	return &Router{
		authHandler:     authHandler,
		userHandler:     userHandler,
		driverHandler:   driverHandler,
		tripHandler:     tripHandler,
		deliveryHandler: deliveryHandler,
		vehicleHandler:  vehicleHandler,
		zoneHandler:     zoneHandler,
		pricingHandler:  pricingHandler,
		adminHandler:    adminHandler,
		wsHandler:       wsHandler,
		mapHandler:      mapHandler,
		authMiddleware:  authMiddleware,
	}
}

func (r *Router) SetupRoutes(app *fiber.App) {
	// Root Logger & CORS & Rate limiter middlewares
	app.Use(middleware.NewCORSMiddleware())
	app.Use(middleware.NewLoggerMiddleware())
	app.Use(middleware.NewRateLimiterMiddleware())

	// Health Check
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "healthy", "service": "zekdrive-api"})
	})

	// WebSockets
	// Upgrade handshakes are filtered by token
	app.Get("/ws", r.wsHandler.Upgrade(), r.wsHandler.Handler())

	api := app.Group("/api")

	// Public Auth Group
	auth := api.Group("/auth")
	auth.Post("/register", r.authHandler.Register)
	auth.Post("/login", r.authHandler.Login)
	auth.Post("/refresh", r.authHandler.RefreshToken)
	auth.Post("/whatsapp/send-otp", r.authHandler.SendWhatsAppOTP)
	auth.Post("/whatsapp/verify-otp", r.authHandler.VerifyWhatsAppOTP)

	// ── CUSTOMER & DRIVER MOBILE COMPATIBILITY & OPEN-SOURCE MAPS LAYER (PUBLIC) ──
	app.Get("/api/customer/config/geocode-api", r.mapHandler.Geocode)
	app.Get("/api/customer/config/place-api-autocomplete", r.mapHandler.SearchLocation)
	app.Get("/api/customer/config/place-api-details", r.mapHandler.PlaceDetails)
	app.Get("/api/customer/config/distance_api", r.mapHandler.DistanceAPI)

	app.Get("/api/driver/config/geocode-api", r.mapHandler.Geocode)

	// Auth Compatibility
	app.Post("/api/customer/auth/registration", r.authHandler.Register)
	app.Post("/api/customer/auth/login", r.authHandler.Login)
	app.Post("/api/customer/auth/send-otp", r.authHandler.SendWhatsAppOTP)
	app.Post("/api/customer/auth/otp-verification", r.authHandler.VerifyWhatsAppOTP)

	app.Post("/api/driver/auth/registration", r.driverHandler.Register)
	app.Post("/api/driver/auth/login", r.authHandler.Login)
	app.Post("/api/driver/auth/send-otp", r.authHandler.SendWhatsAppOTP)
	app.Post("/api/driver/auth/otp-verification", r.authHandler.VerifyWhatsAppOTP)

	// Protected Routes Group
	protected := api.Group("", r.authMiddleware)

	// User Routes
	users := protected.Group("/users")
	users.Get("/me", r.userHandler.GetMe)
	users.Put("/me", r.userHandler.UpdateProfile)

	// Driver Routes
	drivers := protected.Group("/drivers")
	drivers.Post("/register", r.driverHandler.Register)
	drivers.Get("/me", r.driverHandler.GetMe)
	drivers.Post("/location", r.driverHandler.UpdateLocation)
	drivers.Post("/status", r.driverHandler.UpdateStatus)
	drivers.Get("/nearby", r.driverHandler.FindNearby)

	// Vehicle Routes (restricted to drivers only)
	vehicles := protected.Group("/vehicles", middleware.RequireRole(domain.RoleDriver))
	vehicles.Post("/", r.vehicleHandler.Register)
	vehicles.Get("/me", r.vehicleHandler.GetMe)
	vehicles.Put("/me", r.vehicleHandler.Update)

	// Trip Routes
	trips := protected.Group("/trips")
	trips.Post("/", r.tripHandler.RequestTrip)
	trips.Get("/active", r.tripHandler.GetActive)
	trips.Get("/rider", r.tripHandler.ListRiderHistory)
	trips.Get("/driver", middleware.RequireRole(domain.RoleDriver), r.tripHandler.ListDriverHistory)
	trips.Get("/:id", r.tripHandler.GetByID)
	trips.Post("/:id/accept", middleware.RequireRole(domain.RoleDriver), r.tripHandler.AcceptTrip)
	trips.Put("/:id/status", middleware.RequireRole(domain.RoleDriver), r.tripHandler.UpdateStatus)
	trips.Post("/:id/cancel", r.tripHandler.CancelTrip)

	// Delivery Routes
	deliveries := protected.Group("/deliveries")
	deliveries.Post("/", r.deliveryHandler.RequestDelivery)
	deliveries.Get("/sender", r.deliveryHandler.ListSenderHistory)
	deliveries.Get("/driver", middleware.RequireRole(domain.RoleDriver), r.deliveryHandler.ListDriverHistory)
	deliveries.Get("/:id", r.deliveryHandler.GetByID)
	deliveries.Post("/:id/accept", middleware.RequireRole(domain.RoleDriver), r.deliveryHandler.AcceptDelivery)
	deliveries.Put("/:id/status", middleware.RequireRole(domain.RoleDriver), r.deliveryHandler.UpdateStatus)
	deliveries.Post("/:id/cancel", r.deliveryHandler.CancelDelivery)

	// Pricing Estimate
	pricing := protected.Group("/pricing")
	pricing.Post("/estimate", r.pricingHandler.Estimate)

	// Zone view routes
	zones := protected.Group("/zones")
	zones.Get("/", r.zoneHandler.List)
	zones.Get("/:id", r.zoneHandler.GetByID)
	// Zone Admin management
	zones.Post("/", middleware.RequireRole(domain.RoleAdmin), r.zoneHandler.Create)
	zones.Delete("/:id", middleware.RequireRole(domain.RoleAdmin), r.zoneHandler.Delete)

	// Admin Actions
	admin := protected.Group("/admin", middleware.RequireRole(domain.RoleAdmin))
	admin.Get("/stats", r.adminHandler.GetSystemStats)
	admin.Put("/zones/:id/surge", r.adminHandler.UpdateZoneSurge)

	// ── CUSTOMER & DRIVER MOBILE COMPATIBILITY & OPEN-SOURCE MAPS LAYER (PROTECTED) ──
	app.Post("/api/customer/config/get-routes", r.authMiddleware, r.mapHandler.GetRoutes)
	app.Get("/api/driver/get-routes", r.authMiddleware, r.mapHandler.GetRoutes)

	app.Get("/api/customer/info", r.authMiddleware, r.userHandler.GetMe)
	app.Put("/api/customer/update/profile", r.authMiddleware, r.userHandler.UpdateProfile)

	app.Get("/api/driver/info", r.authMiddleware, r.driverHandler.GetMe)
	app.Put("/api/driver/update/profile", r.authMiddleware, r.userHandler.UpdateProfile)
	app.Post("/api/driver/update-online-status", r.authMiddleware, r.driverHandler.UpdateStatus)
}
