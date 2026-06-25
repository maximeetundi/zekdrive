-- Revert store type migration
ALTER TABLE stores DROP COLUMN IF EXISTS type;
ALTER TABLE stores DROP COLUMN IF EXISTS category;
DROP INDEX IF EXISTS idx_stores_type;
