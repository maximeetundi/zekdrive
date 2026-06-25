-- Add store type column to differentiate restaurants from boutiques/shops
ALTER TABLE stores
    ADD COLUMN IF NOT EXISTS type VARCHAR(20) NOT NULL DEFAULT 'restaurant'
        CHECK (type IN ('restaurant', 'boutique', 'grocery', 'pharmacy', 'other'));

-- Add category column for further sub-classification (e.g. "Fast-food", "Clothing", etc.)
ALTER TABLE stores
    ADD COLUMN IF NOT EXISTS category VARCHAR(100) DEFAULT '';

-- Index for faster filtering by type
CREATE INDEX IF NOT EXISTS idx_stores_type ON stores (type);
