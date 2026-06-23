package service

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/domain"
)

type UserService interface {
	GetByID(ctx context.Context, id uuid.UUID) (*domain.User, error)
	GetByEmail(ctx context.Context, email string) (*domain.User, error)
	Update(ctx context.Context, id uuid.UUID, name, phone string) (*domain.User, error)
	Delete(ctx context.Context, id uuid.UUID) error
	List(ctx context.Context, limit, offset int) ([]domain.User, error)
}

type userService struct {
	userRepo domain.UserRepository
}

func NewUserService(userRepo domain.UserRepository) UserService {
	return &userService{userRepo: userRepo}
}

func (s *userService) GetByID(ctx context.Context, id uuid.UUID) (*domain.User, error) {
	return s.userRepo.GetByID(ctx, id)
}

func (s *userService) GetByEmail(ctx context.Context, email string) (*domain.User, error) {
	return s.userRepo.GetByEmail(ctx, email)
}

func (s *userService) Update(ctx context.Context, id uuid.UUID, name, phone string) (*domain.User, error) {
	u, err := s.userRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if u == nil {
		return nil, nil
	}

	u.Name = name
	u.Phone = phone
	u.UpdatedAt = time.Now()

	if err := s.userRepo.Update(ctx, u); err != nil {
		return nil, err
	}
	return u, nil
}

func (s *userService) Delete(ctx context.Context, id uuid.UUID) error {
	return s.userRepo.Delete(ctx, id)
}

func (s *userService) List(ctx context.Context, limit, offset int) ([]domain.User, error) {
	return s.userRepo.List(ctx, limit, offset)
}
