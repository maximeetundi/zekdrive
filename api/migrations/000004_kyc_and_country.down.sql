-- Remove country and KYC fields from users table
ALTER TABLE users DROP COLUMN IF EXISTS country;
ALTER TABLE users DROP COLUMN IF EXISTS kyc_status;
ALTER TABLE users DROP COLUMN IF EXISTS kyc_document;

-- Remove country and KYC fields from drivers table
ALTER TABLE drivers DROP COLUMN IF EXISTS country;
ALTER TABLE drivers DROP COLUMN IF EXISTS kyc_status;
ALTER TABLE drivers DROP COLUMN IF EXISTS kyc_document;

-- Remove KYC fields from vehicles table
ALTER TABLE vehicles DROP COLUMN IF EXISTS kyc_status;
ALTER TABLE vehicles DROP COLUMN IF EXISTS kyc_document;
