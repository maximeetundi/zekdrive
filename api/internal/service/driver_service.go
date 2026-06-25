package service

import (
	"context"
	"encoding/json"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/database"
	"github.com/zekdrive/api/internal/domain"
)

type DriverService interface {
	RegisterDriver(ctx context.Context, userID uuid.UUID, licenseNumber string) (*domain.Driver, error)
	GetByID(ctx context.Context, id uuid.UUID) (*domain.Driver, error)
	GetByUserID(ctx context.Context, userID uuid.UUID) (*domain.Driver, error)
	UpdateLocation(ctx context.Context, driverID uuid.UUID, lat, lng float64) error
	UpdateStatus(ctx context.Context, driverID uuid.UUID, status domain.DriverStatus) error
	FindNearby(ctx context.Context, lat, lng float64, radiusMeters float64, limit int) ([]domain.Driver, error)
	List(ctx context.Context, status domain.DriverStatus, limit, offset int) ([]domain.Driver, error)
}

type driverLocationMessage struct {
	DriverID  uuid.UUID `json:"driver_id"`
	Latitude  float64   `json:"latitude"`
	Longitude float64   `json:"longitude"`
	Timestamp int64     `json:"timestamp"`
}

type driverService struct {
	driverRepo domain.DriverRepository
	userRepo   domain.UserRepository
	redis      *database.RedisClient
}

func NewDriverService(driverRepo domain.DriverRepository, userRepo domain.UserRepository, redis *database.RedisClient) DriverService {
	return &driverService{
		driverRepo: driverRepo,
		userRepo:   userRepo,
		redis:      redis,
	}
}

func (s *driverService) RegisterDriver(ctx context.Context, userID uuid.UUID, licenseNumber string) (*domain.Driver, error) {
	// Verify user exists and has driver role
	u, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if u == nil {
		return nil, errors.New("user not found")
	}
	if u.Role != domain.RoleDriver {
		return nil, errors.New("user does not have a driver role")
	}

	// Verify driver doesn't already exist
	existing, err := s.driverRepo.GetByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if existing != nil {
		return nil, errors.New("driver registration already exists for this user")
	}

	now := time.Now()
	d := &domain.Driver{
		ID:            uuid.New(),
		UserID:        userID,
		LicenseNumber: licenseNumber,
		Status:        domain.DriverStatusOffline,
		Rating:        5.00,
		CreatedAt:     now,
		UpdatedAt:     now,
	}

	if err := s.driverRepo.Create(ctx, d); err != nil {
		return nil, err
	}

	d.User = u
	return d, nil
}

func (s *driverService) GetByID(ctx context.Context, id uuid.UUID) (*domain.Driver, error) {
	return s.driverRepo.GetByID(ctx, id)
}

func (s *driverService) GetByUserID(ctx context.Context, userID uuid.UUID) (*domain.Driver, error) {
	d, err := s.driverRepo.GetByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if d == nil {
		// Self-healing: if the user exists and has driver/pro role, create the driver record automatically!
		u, err := s.userRepo.GetByID(ctx, userID)
		if err == nil && u != nil && (u.Role == domain.RoleDriver || u.Role == domain.RolePro) {
			now := time.Now()
			licenseNum := u.Phone
			if licenseNum == "" {
				licenseNum = "AUTO-" + u.ID.String()[:8]
			}
			d = &domain.Driver{
				ID:            uuid.New(),
				UserID:        userID,
				LicenseNumber: licenseNum,
				Status:        domain.DriverStatusOffline,
				Rating:        5.00,
				Country:       "",
				KycStatus:     "pending",
				KycDocument:   "",
				CreatedAt:     now,
				UpdatedAt:     now,
			}
			err = s.driverRepo.Create(ctx, d)
			if err != nil {
				return nil, err
			}
		}
	}
	return d, nil
}

func (s *driverService) UpdateLocation(ctx context.Context, driverID uuid.UUID, lat, lng float64) error {
	if err := s.driverRepo.UpdateLocation(ctx, driverID, lat, lng); err != nil {
		return err
	}

	// Publish location update to Redis pub/sub for WebSocket sync
	msg := driverLocationMessage{
		DriverID:  driverID,
		Latitude:  lat,
		Longitude: lng,
		Timestamp: time.Now().Unix(),
	}

	msgBytes, err := json.Marshal(msg)
	if err == nil {
		// Publish to channel "driver:location" and driver-specific channel
		s.redis.Publish(ctx, "driver:location", msgBytes)
		s.redis.Publish(ctx, "driver:location:"+driverID.String(), msgBytes)
	}

	return nil
}

func (s *driverService) UpdateStatus(ctx context.Context, driverID uuid.UUID, status domain.DriverStatus) error {
	return s.driverRepo.UpdateStatus(ctx, driverID, status)
}

func (s *driverService) FindNearby(ctx context.Context, lat, lng float64, radiusMeters float64, limit int) ([]domain.Driver, error) {
	return s.driverRepo.FindNearby(ctx, lat, lng, radiusMeters, limit)
}

func (s *driverService) List(ctx context.Context, status domain.DriverStatus, limit, offset int) ([]domain.Driver, error) {
	return s.driverRepo.List(ctx, status, limit, offset)
}
