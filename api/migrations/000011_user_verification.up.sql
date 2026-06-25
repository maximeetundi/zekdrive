ALTER TABLE users ADD COLUMN IF NOT EXISTS is_phone_verified BOOLEAN DEFAULT false;
UPDATE users SET is_phone_verified = true;
