-- ============================================================
-- Migration 006 : Pro User Multi-Profile System
-- Allows a Pro user to be simultaneously:
--   - A driver (chauffeur)
--   - A fleet owner (propriétaire de parc automobile)
--   - A merchant (gérant restaurant/boutique)
-- ============================================================

-- 1. Add pro_profiles to users
--    Stores a comma-separated list of active Pro profiles.
--    Possible values: 'driver', 'fleet_owner', 'merchant'
--    A user can have any combination, e.g. 'driver,fleet_owner'
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS pro_profiles VARCHAR(100) DEFAULT '';

-- Update existing driver-role users to have 'driver' in their pro_profiles
UPDATE users SET pro_profiles = 'driver' WHERE role = 'driver' AND pro_profiles = '';
-- Update existing store-role users to have 'merchant' in their pro_profiles
UPDATE users SET pro_profiles = 'merchant' WHERE role = 'store' AND pro_profiles = '';

-- 2. Expand user roles to include 'pro' as a unified Pro user type
--    'pro' users can have multiple sub-profiles via pro_profiles column.
--    We keep backward compat: existing 'driver' and 'store' roles still work.

-- 3. Vehicles: support fleet ownership
--    Remove UNIQUE constraint on driver_id (fleet owner can have multiple vehicles)
--    Add owner_id (the user who OWNS the vehicle, may differ from the driver)
--    Add assigned_driver_id (the driver currently driving it)
ALTER TABLE vehicles DROP CONSTRAINT IF EXISTS vehicles_driver_id_key;

-- Add owner_id: the Pro user who owns the vehicle (fleet owner or self-owning driver)
ALTER TABLE vehicles
    ADD COLUMN IF NOT EXISTS owner_id UUID REFERENCES users(id) ON DELETE SET NULL;

-- Add assigned_driver_id: the driver profile currently assigned to drive this vehicle
ALTER TABLE vehicles
    ADD COLUMN IF NOT EXISTS assigned_driver_id UUID REFERENCES drivers(id) ON DELETE SET NULL;

-- Migrate existing data: set owner_id to the user linked to each driver
UPDATE vehicles v
SET owner_id = d.user_id,
    assigned_driver_id = v.driver_id
FROM drivers d
WHERE v.driver_id = d.id AND v.owner_id IS NULL;

-- 4. Fleet table: a named fleet belonging to a fleet owner
CREATE TABLE IF NOT EXISTS fleets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT DEFAULT '',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Link vehicles to a fleet (optional)
ALTER TABLE vehicles
    ADD COLUMN IF NOT EXISTS fleet_id UUID REFERENCES fleets(id) ON DELETE SET NULL;

-- 5. Fleet driver assignments history
CREATE TABLE IF NOT EXISTS fleet_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fleet_id UUID NOT NULL REFERENCES fleets(id) ON DELETE CASCADE,
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    unassigned_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN NOT NULL DEFAULT true
);

-- 6. Driver commission rules (for fleet owners splitting revenue with drivers)
ALTER TABLE drivers
    ADD COLUMN IF NOT EXISTS commission_rate DECIMAL(5,2) DEFAULT 80.00; -- Driver keeps 80% by default

-- Indexes
CREATE INDEX IF NOT EXISTS idx_vehicles_owner_id ON vehicles(owner_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_assigned_driver_id ON vehicles(assigned_driver_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_fleet_id ON vehicles(fleet_id);
CREATE INDEX IF NOT EXISTS idx_fleets_owner_id ON fleets(owner_id);
CREATE INDEX IF NOT EXISTS idx_fleet_assignments_fleet_id ON fleet_assignments(fleet_id);
CREATE INDEX IF NOT EXISTS idx_fleet_assignments_driver_id ON fleet_assignments(driver_id);
CREATE INDEX IF NOT EXISTS idx_fleet_assignments_vehicle_id ON fleet_assignments(vehicle_id);
