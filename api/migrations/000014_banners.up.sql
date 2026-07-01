CREATE TABLE banners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    time_period VARCHAR(50) DEFAULT 'all',
    display_position VARCHAR(50) DEFAULT 'top',
    redirect_link VARCHAR(255) DEFAULT '',
    banner_group VARCHAR(50) DEFAULT 'all',
    start_date DATE DEFAULT '2026-01-01',
    end_date DATE DEFAULT '2026-12-31',
    image VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO banners (id, name, description, time_period, display_position, redirect_link, banner_group, start_date, end_date, image) VALUES
('b0000001-0000-0000-0000-000000000001', 'ZekDrive Promo', 'Obtenez 10% de réduction sur votre premier trajet !', 'all', 'top', '', 'all', '2026-01-01', '2026-12-31', 'promo_banner_1.jpg'),
('b0000002-0000-0000-0000-000000000002', 'Lancement Dakar', 'ZekDrive est disponible partout à Dakar !', 'all', 'top', '', 'all', '2026-01-01', '2026-12-31', 'promo_banner_2.jpg');
