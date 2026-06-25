CREATE TABLE IF NOT EXISTS settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key_name VARCHAR(100) UNIQUE NOT NULL,
    live_values JSONB,
    test_values JSONB,
    settings_type VARCHAR(50) NOT NULL,
    mode VARCHAR(10) NOT NULL DEFAULT 'test', -- 'test', 'live'
    is_active BOOLEAN NOT NULL DEFAULT false,
    additional_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
