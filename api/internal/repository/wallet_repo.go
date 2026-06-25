package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/zekdrive/api/internal/database"
	"github.com/zekdrive/api/internal/domain"
)

type WalletRepository struct {
	db *database.PostgresDB
}

func NewWalletRepository(db *database.PostgresDB) *WalletRepository {
	return &WalletRepository{db: db}
}

// GetOrCreate retourne le wallet du chauffeur, le crée s'il n'existe pas
func (r *WalletRepository) GetOrCreate(ctx interface{}, driverID uuid.UUID, currency string) (*domain.DriverWallet, error) {
	c := ctx.(context.Context)
	_, err := r.db.ExecContext(c, `
		INSERT INTO driver_wallets (driver_id, currency_code)
		VALUES ($1, $2)
		ON CONFLICT (driver_id) DO NOTHING
	`, driverID, currency)
	if err != nil {
		return nil, err
	}
	return r.GetBalance(ctx, driverID)
}

// GetBalance retourne le wallet actuel
func (r *WalletRepository) GetBalance(ctx interface{}, driverID uuid.UUID) (*domain.DriverWallet, error) {
	c := ctx.(context.Context)
	var w domain.DriverWallet
	err := r.db.QueryRowContext(c, `
		SELECT w.id, w.driver_id, w.balance, w.currency_code, w.min_balance,
		       w.is_locked, w.total_recharged, w.total_deducted, w.created_at, w.updated_at,
		       COALESCE(u.name,'') as driver_name, COALESCE(u.phone,'') as driver_phone
		FROM driver_wallets w
		JOIN drivers d ON d.id = w.driver_id
		JOIN users u ON u.id = d.user_id
		WHERE w.driver_id = $1
	`, driverID).Scan(
		&w.ID, &w.DriverID, &w.Balance, &w.CurrencyCode, &w.MinBalance,
		&w.IsLocked, &w.TotalRecharged, &w.TotalDeducted, &w.CreatedAt, &w.UpdatedAt,
		&w.DriverName, &w.DriverPhone,
	)
	if err != nil {
		return nil, err
	}
	return &w, nil
}

// CanAcceptTrip vérifie si le chauffeur peut accepter une mission
func (r *WalletRepository) CanAcceptTrip(ctx interface{}, driverID uuid.UUID) (bool, error) {
	c := ctx.(context.Context)
	var ok bool
	err := r.db.QueryRowContext(c, `
		SELECT (balance >= min_balance AND is_locked = FALSE)
		FROM driver_wallets WHERE driver_id = $1
	`, driverID).Scan(&ok)
	if err != nil {
		// Pas de wallet = on autorise (nouveau chauffeur)
		return true, nil
	}
	return ok, nil
}

// Recharge ajoute du solde au wallet
func (r *WalletRepository) Recharge(ctx interface{}, driverID uuid.UUID, amount float64, method, ref, currency string) (*domain.DriverWallet, error) {
	c := ctx.(context.Context)
	tx, err := r.db.BeginTx(c, nil)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback()

	// Récupérer solde actuel
	var before float64
	err = tx.QueryRowContext(c, `SELECT balance FROM driver_wallets WHERE driver_id=$1 FOR UPDATE`, driverID).Scan(&before)
	if err != nil {
		return nil, fmt.Errorf("wallet not found: %w", err)
	}

	after := before + amount

	// Mettre à jour wallet
	_, err = tx.ExecContext(c, `
		UPDATE driver_wallets
		SET balance=$1, total_recharged=total_recharged+$2, is_locked=FALSE, updated_at=NOW()
		WHERE driver_id=$3
	`, after, amount, driverID)
	if err != nil {
		return nil, err
	}

	// Enregistrer transaction
	descFr := fmt.Sprintf("Recharge compte pro — %.0f %s via %s", amount, currency, method)
	descEn := fmt.Sprintf("Pro account top-up — %.0f %s via %s", amount, currency, method)
	_, err = tx.ExecContext(c, `
		INSERT INTO wallet_transactions
		(driver_id, type, amount, balance_before, balance_after, currency_code,
		 description_fr, description_en, payment_method, reference, status)
		VALUES ($1,'recharge',$2,$3,$4,$5,$6,$7,$8,$9,'completed')
	`, driverID, amount, before, after, currency, descFr, descEn, method, ref)
	if err != nil {
		return nil, err
	}

	if err = tx.Commit(); err != nil {
		return nil, err
	}
	return r.GetBalance(ctx, driverID)
}

// DeductCommission déduit la commission plateforme après une course cash
func (r *WalletRepository) DeductCommission(ctx interface{}, driverID, tripID uuid.UUID, amount float64, descFr, descEn, currency string) error {
	c := ctx.(context.Context)
	tx, err := r.db.BeginTx(c, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	var before, minBalance float64
	err = tx.QueryRowContext(c, `
		SELECT balance, min_balance FROM driver_wallets WHERE driver_id=$1 FOR UPDATE
	`, driverID).Scan(&before, &minBalance)
	if err != nil {
		return fmt.Errorf("wallet not found: %w", err)
	}

	after := before - amount
	locked := after < minBalance

	_, err = tx.ExecContext(c, `
		UPDATE driver_wallets
		SET balance=$1, total_deducted=total_deducted+$2, is_locked=$3, updated_at=NOW()
		WHERE driver_id=$4
	`, after, amount, locked, driverID)
	if err != nil {
		return err
	}

	_, err = tx.ExecContext(c, `
		INSERT INTO wallet_transactions
		(driver_id, trip_id, type, amount, balance_before, balance_after, currency_code,
		 description_fr, description_en, payment_method, status)
		VALUES ($1,$2,'commission_deduction',$3,$4,$5,$6,$7,$8,'cash','completed')
	`, driverID, tripID, amount, before, after, currency, descFr, descEn)
	if err != nil {
		return err
	}

	return tx.Commit()
}

// AddBonus ajoute un bonus chauffeur (bronze/silver/gold)
func (r *WalletRepository) AddBonus(ctx interface{}, driverID uuid.UUID, amount float64, bonusType, currency string) error {
	c := ctx.(context.Context)
	tx, err := r.db.BeginTx(c, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	var before float64
	err = tx.QueryRowContext(c, `SELECT balance FROM driver_wallets WHERE driver_id=$1 FOR UPDATE`, driverID).Scan(&before)
	if err != nil {
		return fmt.Errorf("wallet not found: %w", err)
	}

	after := before + amount
	labels := map[string][2]string{
		"bonus_bronze": {"Bonus Bronze — 50 courses/semaine", "Bronze Bonus — 50 trips/week"},
		"bonus_silver": {"Bonus Argent — 100 courses/semaine", "Silver Bonus — 100 trips/week"},
		"bonus_gold":   {"Bonus Or — 150 courses/semaine", "Gold Bonus — 150 trips/week"},
	}
	label := labels[bonusType]
	if label[0] == "" {
		label = [2]string{"Bonus chauffeur", "Driver bonus"}
	}

	_, err = tx.ExecContext(c, `
		UPDATE driver_wallets SET balance=$1, is_locked=FALSE, updated_at=NOW() WHERE driver_id=$2
	`, after, driverID)
	if err != nil {
		return err
	}
	_, err = tx.ExecContext(c, `
		INSERT INTO wallet_transactions
		(driver_id, type, amount, balance_before, balance_after, currency_code,
		 description_fr, description_en, payment_method, status)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,'platform','completed')
	`, driverID, bonusType, amount, before, after, currency, label[0], label[1])
	if err != nil {
		return err
	}

	return tx.Commit()
}

// ListTransactions retourne les dernières transactions
func (r *WalletRepository) ListTransactions(ctx interface{}, driverID uuid.UUID, limit int) ([]domain.WalletTransaction, error) {
	c := ctx.(context.Context)
	if limit <= 0 {
		limit = 50
	}
	rows, err := r.db.QueryContext(c, `
		SELECT id, driver_id, trip_id, type, amount, balance_before, balance_after,
		       currency_code, COALESCE(description_fr,''), COALESCE(description_en,''),
		       COALESCE(payment_method,''), COALESCE(reference,''), status, created_at
		FROM wallet_transactions
		WHERE driver_id=$1
		ORDER BY created_at DESC
		LIMIT $2
	`, driverID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []domain.WalletTransaction
	for rows.Next() {
		var t domain.WalletTransaction
		if err := rows.Scan(
			&t.ID, &t.DriverID, &t.TripID, &t.Type, &t.Amount,
			&t.BalanceBefore, &t.BalanceAfter, &t.CurrencyCode,
			&t.DescriptionFr, &t.DescriptionEn, &t.PaymentMethod, &t.Reference,
			&t.Status, &t.CreatedAt,
		); err != nil {
			continue
		}
		list = append(list, t)
	}
	return list, nil
}

// LockWallet verrouille / déverrouille le wallet
func (r *WalletRepository) LockWallet(ctx interface{}, driverID uuid.UUID, locked bool) error {
	c := ctx.(context.Context)
	_, err := r.db.ExecContext(c, `UPDATE driver_wallets SET is_locked=$1, updated_at=NOW() WHERE driver_id=$2`, locked, driverID)
	return err
}

// SetMinBalance définit le solde minimum requis pour accepter des courses
func (r *WalletRepository) SetMinBalance(ctx interface{}, driverID uuid.UUID, minBalance float64) error {
	c := ctx.(context.Context)
	_, err := r.db.ExecContext(c, `UPDATE driver_wallets SET min_balance=$1, updated_at=NOW() WHERE driver_id=$2`, minBalance, driverID)
	return err
}

// AdminListWallets retourne tous les wallets
func (r *WalletRepository) AdminListWallets(ctx interface{}) ([]domain.DriverWallet, error) {
	c := ctx.(context.Context)
	rows, err := r.db.QueryContext(c, `
		SELECT w.id, w.driver_id, w.balance, w.currency_code, w.min_balance,
		       w.is_locked, w.total_recharged, w.total_deducted, w.created_at, w.updated_at,
		       COALESCE(u.name,'') as driver_name, COALESCE(u.phone,'') as driver_phone
		FROM driver_wallets w
		JOIN drivers d ON d.id = w.driver_id
		JOIN users u ON u.id = d.user_id
		ORDER BY w.balance ASC
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []domain.DriverWallet
	for rows.Next() {
		var w domain.DriverWallet
		if err := rows.Scan(
			&w.ID, &w.DriverID, &w.Balance, &w.CurrencyCode, &w.MinBalance,
			&w.IsLocked, &w.TotalRecharged, &w.TotalDeducted, &w.CreatedAt, &w.UpdatedAt,
			&w.DriverName, &w.DriverPhone,
		); err != nil {
			continue
		}
		list = append(list, w)
	}
	return list, nil
}

// AdminRecharge recharge manuellement le wallet d'un chauffeur (par un admin)
func (r *WalletRepository) AdminRecharge(ctx interface{}, driverID uuid.UUID, amount float64, ref, currency string) (*domain.DriverWallet, error) {
	return r.Recharge(ctx, driverID, amount, "admin", ref, currency)
}
