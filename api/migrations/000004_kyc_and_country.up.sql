-- Add country and KYC fields to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS country VARCHAR(50) DEFAULT 'Senegal';
ALTER TABLE users ADD COLUMN IF NOT EXISTS kyc_status VARCHAR(20) DEFAULT 'unsubmitted'; -- 'unsubmitted', 'pending', 'approved', 'rejected'
ALTER TABLE users ADD COLUMN IF NOT EXISTS kyc_document VARCHAR(255) DEFAULT '';

-- Add country and KYC fields to drivers table
ALTER TABLE drivers ADD COLUMN IF NOT EXISTS country VARCHAR(50) DEFAULT 'Senegal';
ALTER TABLE drivers ADD COLUMN IF NOT EXISTS kyc_status VARCHAR(20) DEFAULT 'unsubmitted'; -- 'unsubmitted', 'pending', 'approved', 'rejected'
ALTER TABLE drivers ADD COLUMN IF NOT EXISTS kyc_document VARCHAR(255) DEFAULT '';

-- Add KYC fields to vehicles table
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS kyc_status VARCHAR(20) DEFAULT 'unsubmitted'; -- 'unsubmitted', 'pending', 'approved', 'rejected'
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS kyc_document VARCHAR(255) DEFAULT '';
