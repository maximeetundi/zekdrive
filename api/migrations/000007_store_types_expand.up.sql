-- Migration 007: Expand store types
-- Add new store type values: cafe, bakery, butcher, fishmonger, beauty, clothing, hardware, furniture, electronics

-- Drop existing CHECK constraint on type if present (postgres uses generated constraint names)
ALTER TABLE stores DROP CONSTRAINT IF EXISTS stores_type_check;
ALTER TABLE stores DROP CONSTRAINT IF EXISTS chk_store_type;

-- The type column is VARCHAR — no need to add a new constraint since Go validation handles it.
-- We just ensure the column exists (it was added in migration 005).
ALTER TABLE stores ALTER COLUMN type SET DEFAULT 'other';

-- Update comment for documentation
COMMENT ON COLUMN stores.type IS
  'restaurant | cafe | bakery | grocery | butcher | fishmonger | pharmacy | beauty | clothing | boutique | hardware | furniture | electronics | other';
