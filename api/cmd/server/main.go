package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"github.com/zekdrive/api/internal/config"
	"github.com/zekdrive/api/internal/database"
	"github.com/zekdrive/api/internal/domain"
	"github.com/zekdrive/api/internal/handler"
	"github.com/zekdrive/api/internal/middleware"
	"github.com/zekdrive/api/internal/repository"
	"github.com/zekdrive/api/internal/router"
	"github.com/zekdrive/api/internal/service"
	"github.com/zekdrive/api/internal/websocket"
)

func main() {
	log.Println("Starting ZekDrive Backend API...")

	// 1. Load Configurations
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Critical Error: Failed to load config: %v", err)
	}

	// 2. Initialize PostgreSQL
	pgDB, err := database.NewPostgresDB(cfg)
	if err != nil {
		log.Fatalf("Critical Error: PostgreSQL initialization failed: %v", err)
	}
	defer pgDB.Close()

	// 3. Initialize Redis
	redisClient, err := database.NewRedisClient(cfg)
	if err != nil {
		log.Fatalf("Critical Error: Redis initialization failed: %v", err)
	}
	defer redisClient.Close()

	// 4. Initialize Repositories
	userRepo := repository.NewUserRepository(pgDB)

	// Seed Admin User if not exists
	ctx := context.Background()
	existingAdmin, err := userRepo.GetByEmail(ctx, "admin@zekdrive.com")
	if err != nil {
		log.Printf("Warning: Failed to check for existing admin: %v", err)
	} else if existingAdmin == nil {
		log.Println("Seeding default admin user...")
		hashedPassword, err := bcrypt.GenerateFromPassword([]byte("admin123"), bcrypt.DefaultCost)
		if err != nil {
			log.Printf("Warning: Failed to hash admin password: %v", err)
		} else {
			adminUser := &domain.User{
				ID:        uuid.New(),
				Name:      "Super Admin ZekDrive",
				Email:     "admin@zekdrive.com",
				Password:  string(hashedPassword),
				Phone:     "+221770000000",
				Role:      domain.RoleAdmin,
				CreatedAt: time.Now(),
				UpdatedAt: time.Now(),
			}
			if err := userRepo.Create(ctx, adminUser); err != nil {
				log.Printf("Warning: Failed to seed admin user: %v", err)
			} else {
				log.Println("Default admin user successfully seeded (admin@zekdrive.com / admin123)")
			}
		}
	}

	// Seed admin_users RBAC: link admin@zekdrive.com → super_admin role
	// (role UUID seeded in migration 008)
	superAdminRoleID := uuid.MustParse("a0000001-0000-0000-0000-000000000001")
	adminRoleRepo := repository.NewAdminRoleRepository(pgDB)
	adminForRbac, rbacErr := userRepo.GetByEmail(ctx, "admin@zekdrive.com")
	if rbacErr != nil {
		log.Printf("Warning: Failed to fetch admin for RBAC: %v", rbacErr)
	} else if adminForRbac != nil {
		if err := adminRoleRepo.UpsertAdminUser(ctx, adminForRbac.ID, superAdminRoleID); err != nil {
			log.Printf("Warning: RBAC seed failed: %v", err)
		} else {
			log.Println("RBAC seeded: admin@zekdrive.com → super_admin")
		}
	}

	driverRepo := repository.NewDriverRepository(pgDB)
	vehicleRepo := repository.NewVehicleRepository(pgDB)
	zoneRepo := repository.NewZoneRepository(pgDB)
	pricingRepo := repository.NewPricingRepository(redisClient)
	tripRepo := repository.NewTripRepository(pgDB)
	deliveryRepo := repository.NewDeliveryRepository(pgDB)
	storeRepo := repository.NewStoreRepository(pgDB)
	settingRepo := repository.NewSettingRepository(pgDB)
	fleetRepo := repository.NewFleetRepository(pgDB)
	countryRepo := repository.NewCountryRepository(pgDB)
	walletRepo  := repository.NewWalletRepository(pgDB)

	// 5. Initialize Services
	authService := service.NewAuthService(cfg, userRepo, driverRepo, redisClient, settingRepo)
	userService := service.NewUserService(userRepo)
	driverService := service.NewDriverService(driverRepo, userRepo, redisClient)
	geoService := service.NewGeoService()
	pricingService := service.NewPricingService(zoneRepo, geoService, pricingRepo)
	matchingService := service.NewMatchingService(driverRepo, vehicleRepo)
	notifierService := service.NewNotificationService(redisClient)
	tripService := service.NewTripService(tripRepo, driverService, pricingService, matchingService, geoService, notifierService)
	deliveryService := service.NewDeliveryService(deliveryRepo, driverService, pricingService, matchingService, notifierService)
	storeService := service.NewStoreService(storeRepo, userRepo, driverRepo, pricingService, matchingService, notifierService)
	settingService := service.NewSettingService(settingRepo)
	fleetService := service.NewFleetService(fleetRepo, userRepo, driverRepo, storeRepo)

	// 6. Initialize WebSocket Hub
	wsHub := websocket.NewHub(redisClient)
	go wsHub.Run()
	log.Println("WebSocket Hub initialized and running")

	// 7. Initialize Handlers
	authHandler := handler.NewAuthHandler(authService)
	userHandler := handler.NewUserHandler(userService, settingService)
	driverHandler := handler.NewDriverHandler(driverService, settingService)
	tripHandler := handler.NewTripHandler(tripService, driverService)
	deliveryHandler := handler.NewDeliveryHandler(deliveryService, driverService)
	vehicleHandler := handler.NewVehicleHandler(vehicleRepo, driverService)
	zoneHandler := handler.NewZoneHandler(zoneRepo)
	pricingHandler := handler.NewPricingHandler(pricingService)
	adminHandler := handler.NewAdminHandler(pgDB, zoneRepo)
	wsHandler := handler.NewWSHandler(wsHub, authService, driverRepo)
	mapHandler := handler.NewMapHandler(cfg, tripRepo, deliveryRepo, driverRepo)
	storeHandler := handler.NewStoreHandler(storeService, driverService)
	settingHandler := handler.NewSettingHandler(settingService)
	fleetHandler := handler.NewFleetHandler(fleetService)
	countryHandler := handler.NewCountryHandler(countryRepo)
	walletHandler := handler.NewWalletHandler(walletRepo)

	// 8. Initialize Middlewares
	authMiddleware := middleware.NewAuthMiddleware(authService)

	// 9. Initialize Router and Setup Routes
	r := router.NewRouter(
		authHandler,
		userHandler,
		driverHandler,
		tripHandler,
		deliveryHandler,
		vehicleHandler,
		zoneHandler,
		pricingHandler,
		adminHandler,
		wsHandler,
		mapHandler,
		storeHandler,
		settingHandler,
		fleetHandler,
		countryHandler,
		walletHandler,
		authMiddleware,
	)

	// 10. Start Fiber Server
	app := fiber.New(fiber.Config{
		AppName:      "ZekDrive API Service",
		BodyLimit:    10 * 1024 * 1024, // 10MB limit
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
	})

	r.SetupRoutes(app)

	// Listen in separate goroutine for graceful shutdown
	go func() {
		addr := fmt.Sprintf(":%s", cfg.Port)
		log.Printf("ZekDrive API Server is listening on address: %s", addr)
		if err := app.Listen(addr); err != nil {
			log.Fatalf("Server listen failed: %v", err)
		}
	}()

	// 11. Graceful Shutdown Configuration
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)

	<-quit
	log.Println("Gracefully shutting down server...")

	// Create shutdown context with timeout
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := app.ShutdownWithContext(ctx); err != nil {
		log.Fatalf("Server shutdown forced: %v", err)
	}

	log.Println("Server successfully stopped. Exiting.")
}
