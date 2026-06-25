-- Rollback migration 006
DROP TABLE IF EXISTS fleet_assignments;
DROP TABLE IF EXISTS fleets;
ALTER TABLE vehicles DROP COLUMN IF EXISTS fleet_id;
ALTER TABLE vehicles DROP COLUMN IF EXISTS assigned_driver_id;
ALTER TABLE vehicles DROP COLUMN IF EXISTS owner_id;
ALTER TABLE drivers DROP COLUMN IF EXISTS commission_rate;
ALTER TABLE users DROP COLUMN IF EXISTS pro_profiles;
-- Restore UNIQUE constraint on vehicles.driver_id
ALTER TABLE vehicles ADD CONSTRAINT vehicles_driver_id_key UNIQUE (driver_id);
