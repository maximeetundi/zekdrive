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
	storeHandler    *handler.StoreHandler
	settingHandler  *handler.SettingHandler
	fleetHandler    *handler.FleetHandler
	countryHandler  *handler.CountryHandler
	walletHandler   *handler.WalletHandler

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
	storeHandler *handler.StoreHandler,
	settingHandler *handler.SettingHandler,
	fleetHandler *handler.FleetHandler,
	countryHandler *handler.CountryHandler,
	walletHandler  *handler.WalletHandler,
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
		storeHandler:    storeHandler,
		settingHandler:  settingHandler,
		fleetHandler:    fleetHandler,
		countryHandler:  countryHandler,
		walletHandler:   walletHandler,
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

	// Pusher WebSocket Compatibility Layer
	app.Get("/app/:key", r.wsHandler.PusherHandler())
	app.Post("/broadcasting/auth", r.wsHandler.PusherAuth)

	api := app.Group("/api")

	// Public: countries & currencies (no auth — mobile apps need this at startup)
	api.Get("/countries", r.countryHandler.PublicListActive)
	api.Get("/countries/:code/config", r.countryHandler.PublicGetConfig)

	// Public Auth Group
	auth := api.Group("/auth")
	auth.Post("/register", r.authHandler.Register)
	auth.Post("/login", r.authHandler.Login)
	auth.Post("/refresh", r.authHandler.RefreshToken)
	auth.Post("/whatsapp/send-otp", r.authHandler.SendWhatsAppOTP)
	auth.Post("/whatsapp/verify-otp", r.authHandler.VerifyWhatsAppOTP)

	// ── CUSTOMER & DRIVER MOBILE COMPATIBILITY & OPEN-SOURCE MAPS LAYER (PUBLIC) ──
	app.Get("/api/customer/configuration", r.userHandler.GetCustomerConfig)
	app.Get("/api/driver/configuration", r.driverHandler.GetDriverConfig)

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

	app.Post("/api/driver/auth/registration", r.authHandler.Register)
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

	// Store Owner Routes
	storeGroup := protected.Group("/store", middleware.RequireRole(domain.RoleStore))
	storeGroup.Post("/", r.storeHandler.CreateOrUpdateStore)
	storeGroup.Get("/profile", r.storeHandler.GetStoreProfile)
	storeGroup.Put("/schedules", r.storeHandler.UpdateSchedules)
	storeGroup.Post("/products", r.storeHandler.CreateProduct)
	storeGroup.Put("/products/:id", r.storeHandler.UpdateProduct)
	storeGroup.Delete("/products/:id", r.storeHandler.DeleteProduct)
	storeGroup.Get("/products", r.storeHandler.ListStoreProducts)
	storeGroup.Get("/orders", r.storeHandler.ListStoreOrders)
	storeGroup.Put("/orders/:id/status", r.storeHandler.UpdateOrderStatusByStore)

	// Customer Store Routes
	customerStores := protected.Group("/customer/stores")
	customerStores.Get("/", r.storeHandler.ListNearbyStores)
	customerStores.Get("/:id", r.storeHandler.GetStoreDetails)
	customerStores.Get("/:id/products", r.storeHandler.ListCustomerProducts)
	customerStores.Post("/orders", r.storeHandler.CreateOrder)
	customerStores.Get("/orders", r.storeHandler.ListCustomerOrders)
	customerStores.Get("/orders/:id", r.storeHandler.GetOrderDetails)

	// Driver Store Courier Routes
	driverStores := protected.Group("/driver/store/orders", middleware.RequireRole(domain.RoleDriver))
	driverStores.Get("/", r.storeHandler.ListDriverOrders)
	driverStores.Post("/:id/accept", r.storeHandler.AcceptDeliveryOrder)
	driverStores.Put("/:id/status", r.storeHandler.UpdateOrderStatusByDriver)

	// ── PRO USER MULTI-PROFILE ROUTES ─────────────────────────────────────────
	// Any authenticated user can activate Pro profiles and manage their fleets.
	// Access is controlled at the service level (checking ownership).
	pro := protected.Group("/pro")

	// Pro profile summary (who am I as a Pro user?)
	pro.Get("/profile-summary", r.fleetHandler.GetProProfileSummary)
	// Activate a new sub-profile (driver | fleet_owner | merchant)
	pro.Post("/activate-profile", r.fleetHandler.ActivateProProfile)

	// Fleet management (for fleet_owner profile)
	pro.Get("/fleets", r.fleetHandler.ListMyFleets)
	pro.Post("/fleets", r.fleetHandler.CreateFleet)
	pro.Get("/fleets/:id", r.fleetHandler.GetFleet)
	pro.Put("/fleets/:id", r.fleetHandler.UpdateFleet)
	pro.Delete("/fleets/:id", r.fleetHandler.DeleteFleet)
	pro.Post("/fleets/:id/vehicles", r.fleetHandler.AddVehicleToFleet)
	pro.Get("/fleets/:id/vehicles", r.fleetHandler.ListFleetVehicles)
	pro.Get("/fleets/:id/assignments", r.fleetHandler.ListFleetAssignments)

	// Vehicle management (all vehicles owned by the Pro user)
	pro.Get("/vehicles", r.fleetHandler.ListAllMyVehicles)
	pro.Post("/vehicles/:id/assign-driver", r.fleetHandler.AssignDriver)
	pro.Delete("/vehicles/:id/assign-driver", r.fleetHandler.UnassignDriver)

	// ── WALLET CHAUFFEUR (compte pro — modèle Yango) ────────────────────────
	pro.Get("/wallet", r.walletHandler.GetMyWallet)
	pro.Get("/wallet/transactions", r.walletHandler.ListMyTransactions)
	pro.Post("/wallet/recharge", r.walletHandler.Recharge)

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
	admin.Get("/settings", r.settingHandler.GetSettings)
	admin.Post("/settings", r.settingHandler.SaveSettings)
	// Admin: manage stores (restaurants & boutiques)
	admin.Get("/stores", r.storeHandler.AdminListStores)

	// ── CUSTOMER & DRIVER MOBILE COMPATIBILITY & OPEN-SOURCE MAPS LAYER (PROTECTED) ──
	app.Post("/api/customer/config/get-routes", r.authMiddleware, r.mapHandler.GetRoutes)
	app.Get("/api/driver/get-routes", r.authMiddleware, r.mapHandler.GetRoutes)

	app.Get("/api/customer/info", r.authMiddleware, r.userHandler.GetMe)
	app.Put("/api/customer/update/profile", r.authMiddleware, r.userHandler.UpdateProfile)

	app.Get("/api/driver/info", r.authMiddleware, r.driverHandler.GetMe)
	app.Put("/api/driver/update/profile", r.authMiddleware, r.userHandler.UpdateProfile)
	app.Post("/api/driver/update-online-status", r.authMiddleware, r.driverHandler.UpdateStatus)
	app.Post("/api/user/store-live-location", r.authMiddleware, r.driverHandler.UpdateLocation)

	// ── COUNTRY & CURRENCY ROUTES ─────────────────────────────────────────────
	// Public: mobile apps fetch active countries + pricing
	app.Get("/api/countries", r.countryHandler.PublicListActive)
	app.Get("/api/countries/:code/config", r.countryHandler.PublicGetConfig)

	// Admin: full management
	admin.Get("/countries", r.countryHandler.ListAll)
	admin.Get("/countries/active", r.countryHandler.ListActive)
	admin.Get("/countries/:code", r.countryHandler.GetByCode)
	admin.Put("/countries/:code/active", r.countryHandler.SetActive)
	admin.Get("/countries/:code/config", r.countryHandler.GetConfig)
	admin.Put("/countries/:code/config", r.countryHandler.UpsertConfig)

	// Admin: KYC management
	admin.Get("/kyc", r.adminHandler.ListKYC)
	admin.Put("/kyc/:id/approve", r.adminHandler.ApproveKYC)
	admin.Put("/kyc/:id/reject", r.adminHandler.RejectKYC)

	// Admin: roles & permissions
	admin.Get("/roles", r.adminHandler.ListRoles)
	admin.Get("/permissions", r.adminHandler.ListPermissions)
	admin.Put("/roles/:id/permissions", r.adminHandler.UpdateRolePermissions)
	admin.Get("/admin-users", r.adminHandler.ListAdminUsers)
	admin.Post("/admin-users", r.adminHandler.UpsertAdminUser)
	admin.Put("/admin-users/:id/deactivate", r.adminHandler.DeactivateAdminUser)

	// ── Admin: Wallets chauffeurs (modèle Yango) ──────────────────────────────
	admin.Get("/wallets", r.walletHandler.AdminListWallets)
	admin.Get("/wallets/:driverID/transactions", r.walletHandler.AdminListTransactions)
	admin.Post("/wallets/:driverID/recharge", r.walletHandler.AdminRecharge)
	admin.Post("/wallets/:driverID/bonus", r.walletHandler.AdminAddBonus)
	admin.Put("/wallets/:driverID/min-balance", r.walletHandler.AdminSetMinBalance)
	admin.Put("/wallets/:driverID/lock", r.walletHandler.AdminLockWallet)
}
