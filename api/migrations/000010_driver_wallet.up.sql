-- Migration 010: Driver wallet system (modèle Yango)
-- Le chauffeur doit recharger son compte pro avant d'accepter des missions.
-- Pour chaque course cash complétée, la commission est déduite de son solde.

CREATE TABLE IF NOT EXISTS driver_wallets (
    id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id       UUID         NOT NULL REFERENCES drivers(id) ON DELETE CASCADE UNIQUE,
    balance         NUMERIC(15,2) DEFAULT 0.00,
    currency_code   CHAR(3)      NOT NULL DEFAULT 'XOF',
    min_balance     NUMERIC(15,2) DEFAULT 0.00,   -- seuil min pour accepter missions
    is_locked       BOOLEAN      DEFAULT FALSE,    -- bloqué si solde insuffisant
    total_recharged NUMERIC(15,2) DEFAULT 0.00,
    total_deducted  NUMERIC(15,2) DEFAULT 0.00,
    created_at      TIMESTAMPTZ  DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS wallet_transactions (
    id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id       UUID         NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    trip_id         UUID,        -- référence optionnelle à la course
    type            VARCHAR(30)  NOT NULL,
    -- 'recharge' | 'commission_deduction' | 'bonus_bronze' | 'bonus_silver' |
    -- 'bonus_gold' | 'refund' | 'withdrawal' | 'admin_credit'
    amount          NUMERIC(15,2) NOT NULL,
    balance_before  NUMERIC(15,2) NOT NULL,
    balance_after   NUMERIC(15,2) NOT NULL,
    currency_code   CHAR(3)      NOT NULL DEFAULT 'XOF',
    description_fr  VARCHAR(200),
    description_en  VARCHAR(200),
    payment_method  VARCHAR(50),   -- orange_money, wave, mtn_money, card, admin
    reference       VARCHAR(100),  -- référence paiement opérateur
    status          VARCHAR(20)    DEFAULT 'completed',
    created_at      TIMESTAMPTZ    DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wallet_txn_driver  ON wallet_transactions(driver_id);
CREATE INDEX IF NOT EXISTS idx_wallet_txn_type    ON wallet_transactions(type);
CREATE INDEX IF NOT EXISTS idx_wallet_txn_created ON wallet_transactions(created_at DESC);
