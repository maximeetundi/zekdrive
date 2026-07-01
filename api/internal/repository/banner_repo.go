package repository

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"github.com/zekdrive/api/internal/domain"
)

type bannerRepository struct {
	db *sqlx.DB
}

func NewBannerRepository(db *sqlx.DB) domain.BannerRepository {
	return &bannerRepository{db: db}
}

func (r *bannerRepository) List(ctx context.Context) ([]domain.Banner, error) {
	var banners []domain.Banner
	query := `SELECT id, name, description, time_period, display_position, redirect_link, banner_group, 
              to_char(start_date, 'YYYY-MM-DD') as start_date, to_char(end_date, 'YYYY-MM-DD') as end_date,
              image, created_at, updated_at FROM banners ORDER BY created_at DESC`
	err := r.db.SelectContext(ctx, &banners, query)
	if err != nil {
		return nil, err
	}
	return banners, nil
}

func (r *bannerRepository) GetByID(ctx context.Context, id uuid.UUID) (*domain.Banner, error) {
	var b domain.Banner
	query := `SELECT id, name, description, time_period, display_position, redirect_link, banner_group, 
              to_char(start_date, 'YYYY-MM-DD') as start_date, to_char(end_date, 'YYYY-MM-DD') as end_date,
              image, created_at, updated_at FROM banners WHERE id = $1`
	err := r.db.GetContext(ctx, &b, query, id)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &b, nil
}

func (r *bannerRepository) Create(ctx context.Context, b *domain.Banner) error {
	query := `INSERT INTO banners (id, name, description, time_period, display_position, redirect_link, banner_group, start_date, end_date, image, created_at, updated_at)
              VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)`
	_, err := r.db.ExecContext(ctx, query, b.ID, b.Name, b.Description, b.TimePeriod, b.DisplayPosition, b.RedirectLink, b.BannerGroup, b.StartDate, b.EndDate, b.Image, b.CreatedAt, b.UpdatedAt)
	return err
}

func (r *bannerRepository) Update(ctx context.Context, b *domain.Banner) error {
	query := `UPDATE banners SET name = $1, description = $2, time_period = $3, display_position = $4, redirect_link = $5, banner_group = $6, start_date = $7, end_date = $8, image = $9, updated_at = $10 WHERE id = $11`
	_, err := r.db.ExecContext(ctx, query, b.Name, b.Description, b.TimePeriod, b.DisplayPosition, b.RedirectLink, b.BannerGroup, b.StartDate, b.EndDate, b.Image, b.UpdatedAt, b.ID)
	return err
}

func (r *bannerRepository) Delete(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM banners WHERE id = $1`
	_, err := r.db.ExecContext(ctx, query, id)
	return err
}
