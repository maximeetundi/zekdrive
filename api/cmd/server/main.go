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
	"github.com/zekdrive/api/internal/config"
	"github.com/zekdrive/api/internal/database"
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
	driverRepo := repository.NewDriverRepository(pgDB)
	vehicleRepo := repository.NewVehicleRepository(pgDB)
	zoneRepo := repository.NewZoneRepository(pgDB)
	pricingRepo := repository.NewPricingRepository(redisClient)
	tripRepo := repository.NewTripRepository(pgDB)
	deliveryRepo := repository.NewDeliveryRepository(pgDB)

	// 5. Initialize Services
	authService := service.NewAuthService(cfg, userRepo, redisClient)
	userService := service.NewUserService(userRepo)
	driverService := service.NewDriverService(driverRepo, userRepo, redisClient)
	geoService := service.NewGeoService()
	pricingService := service.NewPricingService(zoneRepo, geoService, pricingRepo)
	matchingService := service.NewMatchingService(driverRepo, vehicleRepo)
	notifierService := service.NewNotificationService(redisClient)
	tripService := service.NewTripService(tripRepo, driverService, pricingService, matchingService, geoService, notifierService)
	deliveryService := service.NewDeliveryService(deliveryRepo, driverService, pricingService, matchingService, notifierService)

	// 6. Initialize WebSocket Hub
	wsHub := websocket.NewHub(redisClient)
	go wsHub.Run()
	log.Println("WebSocket Hub initialized and running")

	// 7. Initialize Handlers
	authHandler := handler.NewAuthHandler(authService)
	userHandler := handler.NewUserHandler(userService)
	driverHandler := handler.NewDriverHandler(driverService)
	tripHandler := handler.NewTripHandler(tripService, driverService)
	deliveryHandler := handler.NewDeliveryHandler(deliveryService, driverService)
	vehicleHandler := handler.NewVehicleHandler(vehicleRepo, driverService)
	zoneHandler := handler.NewZoneHandler(zoneRepo)
	pricingHandler := handler.NewPricingHandler(pricingService)
	adminHandler := handler.NewAdminHandler(pgDB, zoneRepo)
	wsHandler := handler.NewWSHandler(wsHub, authService, driverRepo)
	mapHandler := handler.NewMapHandler(cfg, tripRepo, deliveryRepo, driverRepo)

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
