package repository

import (
	"context"
	"encoding/json"
	"time"

	"github.com/redis/go-redis/v9"
	"github.com/zekdrive/api/internal/database"
	"github.com/zekdrive/api/internal/domain"
)

type pricingRepo struct {
	redis *database.RedisClient
}

func NewPricingRepository(redis *database.RedisClient) domain.PricingRepository {
	return &pricingRepo{redis: redis}
}

func (r *pricingRepo) SaveEstimation(ctx context.Context, key string, estimation *domain.PriceEstimation) error {
	data, err := json.Marshal(estimation)
	if err != nil {
		return err
	}
	return r.redis.Set(ctx, "price_estimate:"+key, data, 10*time.Minute).Err()
}

func (r *pricingRepo) GetEstimation(ctx context.Context, key string) (*domain.PriceEstimation, error) {
	data, err := r.redis.Get(ctx, "price_estimate:"+key).Result()
	if err != nil {
		if err == redis.Nil {
			return nil, nil
		}
		return nil, err
	}

	var estimation domain.PriceEstimation
	if err := json.Unmarshal([]byte(data), &estimation); err != nil {
		return nil, err
	}
	return &estimation, nil
}
