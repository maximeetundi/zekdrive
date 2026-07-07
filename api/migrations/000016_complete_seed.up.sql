-- Migration 016: Complete Initial Seed — Admin Account + Vehicle Categories + Cameroon Config
-- After `docker compose down -v`, this ensures a fully operational platform from first startup.
-- ⚠️  Admin credentials: admin@zekdrive.cm / admin123  (change in production!)

-- ─────────────────────────────────────────────────────────────────
-- 1. SEED: Super Admin Account
--    Email : admin@zekdrive.cm
--    Mot de passe : admin123  (bcrypt cost=10, same hash as seed users)
--    ⚠️  À changer impérativement en production via le panel admin!
-- ─────────────────────────────────────────────────────────────────
INSERT INTO users (
    id, name, email, password, phone, role,
    pro_profiles, is_phone_verified, created_at, updated_at
) VALUES (
    'a0000000-0000-0000-0000-000000000001',
    'Super Admin ZekDrive',
    'admin@zekdrive.cm',
    '$2b$10$Ia6MAfxZLOcXzYhRF25U0.aV7C1Dgzno6sicYvTMslw.Yrlju6dDS',
    '+237690000000',
    'admin',
    '',
    TRUE,
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING;

-- Link admin user to super_admin role in admin_users table
INSERT INTO admin_users (user_id, role_id, is_active, created_at, updated_at)
SELECT
    'a0000000-0000-0000-0000-000000000001',
    'a0000001-0000-0000-0000-000000000001',
    TRUE,
    NOW(),
    NOW()
WHERE EXISTS (
    SELECT 1 FROM users WHERE id = 'a0000000-0000-0000-0000-000000000001'
)
ON CONFLICT (user_id) DO UPDATE SET
    role_id = EXCLUDED.role_id,
    is_active = TRUE,
    updated_at = NOW();

-- ─────────────────────────────────────────────────────────────────
-- 2. SEED: Douala Zone (Second major city)
-- ─────────────────────────────────────────────────────────────────
INSERT INTO zones (id, name, boundary, base_fare, fare_per_km, fare_per_minute, surge_multiplier, created_at) VALUES
(
    'a0000002-0000-0000-0000-000000000002',
    'Douala',
    ST_GeomFromText('POLYGON((9.65 3.90, 9.85 3.90, 9.85 4.10, 9.65 4.10, 9.65 3.90))', 4326),
    500.00, 300.00, 50.00, 1.00, NOW()
),
(
    'a0000002-0000-0000-0000-000000000003',
    'Yaoundé-Nord',
    ST_GeomFromText('POLYGON((11.35 3.90, 11.65 3.90, 11.65 4.05, 11.35 4.05, 11.35 3.90))', 4326),
    500.00, 280.00, 50.00, 1.00, NOW()
),
(
    'a0000002-0000-0000-0000-000000000004',
    'Yaoundé-Sud',
    ST_GeomFromText('POLYGON((11.35 3.70, 11.65 3.70, 11.65 3.85, 11.35 3.85, 11.35 3.70))', 4326),
    500.00, 280.00, 50.00, 1.00, NOW()
),
(
    'a0000002-0000-0000-0000-000000000005',
    'Bafoussam',
    ST_GeomFromText('POLYGON((10.35 5.40, 10.55 5.40, 10.55 5.55, 10.35 5.55, 10.35 5.40))', 4326),
    600.00, 320.00, 60.00, 1.00, NOW()
)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────
-- 3. SEED: Platform Settings (Cameroon configuration)
--    Format: key_name, live_values (JSONB), settings_type, mode, is_active
-- ─────────────────────────────────────────────────────────────────
INSERT INTO settings (key_name, live_values, test_values, settings_type, mode, is_active, additional_data, updated_at) VALUES
(
    'business_settings',
    '{"platform_name":"ZekDrive","platform_currency":"XAF","country_code":"CM","phone_prefix":"+237","commission_rate":15,"min_withdrawal":5000,"max_withdrawal":500000,"driver_min_balance":2000,"support_phone":"+237690000000","support_email":"support@zekdrive.cm","ride_radius_km":5,"review_enabled":true,"surge_enabled":false,"maintenance_mode":false}',
    '{"platform_name":"ZekDrive [TEST]","platform_currency":"XAF","country_code":"CM","phone_prefix":"+237","commission_rate":15,"min_withdrawal":5000,"max_withdrawal":500000,"driver_min_balance":2000,"support_phone":"+237690000000","support_email":"support@zekdrive.cm","ride_radius_km":5,"review_enabled":true,"surge_enabled":false,"maintenance_mode":false}',
    'business',
    'live',
    TRUE,
    '{"timezone":"Africa/Douala","language":"fr","currency_symbol":"FCFA"}',
    NOW()
),
(
    'payment_settings',
    '{"mtn_momo":true,"orange_money":true,"cash":true,"wallet":true,"card":false,"mtn_momo_label":"MTN Mobile Money","orange_money_label":"Orange Money","cash_label":"Espèces"}',
    '{"mtn_momo":true,"orange_money":true,"cash":true,"wallet":true,"card":false,"mtn_momo_label":"MTN Mobile Money","orange_money_label":"Orange Money","cash_label":"Espèces"}',
    'payment',
    'live',
    TRUE,
    NULL,
    NOW()
),
(
    'notification_settings',
    '{"whatsapp":true,"push":true,"email":false,"sms":false}',
    '{"whatsapp":true,"push":true,"email":false,"sms":false}',
    'notification',
    'live',
    TRUE,
    NULL,
    NOW()
),
(
    'map_settings',
    '{"default_lat":3.8480,"default_lng":11.5021,"default_zoom":13,"map_provider":"google","search_radius_km":5}',
    '{"default_lat":3.8480,"default_lng":11.5021,"default_zoom":13,"map_provider":"google","search_radius_km":5}',
    'map',
    'live',
    TRUE,
    '{"city":"Yaoundé","country":"Cameroun"}',
    NOW()
)
ON CONFLICT (key_name) DO UPDATE SET
    live_values = EXCLUDED.live_values,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();


-- ─────────────────────────────────────────────────────────────────
-- 4. SEED: Additional demo riders (Cameroon names)
-- ─────────────────────────────────────────────────────────────────
INSERT INTO users (id, name, email, password, phone, role, pro_profiles, is_phone_verified, created_at) VALUES
('d0000001-0000-0000-0000-000000000004', 'Nkeng Fabrice',    'nkeng@fabrice.cm',   '$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237674567890', 'rider', '', TRUE, NOW() - INTERVAL '20 days'),
('d0000001-0000-0000-0000-000000000005', 'Fosso Brigitte',   'fosso@brigitte.cm',  '$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237675678901', 'rider', '', TRUE, NOW() - INTERVAL '15 days'),
('d0000001-0000-0000-0000-000000000006', 'Mballa Emmanuel',  'mballa@emmanuel.cm', '$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237676789012', 'rider', '', TRUE, NOW() - INTERVAL '10 days'),
('d0000001-0000-0000-0000-000000000007', 'Tsanga Régine',    'tsanga@regine.cm',   '$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237677890123', 'rider', '', TRUE, NOW() - INTERVAL '7 days'),
('d0000001-0000-0000-0000-000000000008', 'Ngono Patrick',    'ngono@patrick.cm',   '$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237678901234', 'rider', '', TRUE, NOW() - INTERVAL '5 days')
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────
-- 5. SEED: Additional Drivers (Douala-based + premium)
-- ─────────────────────────────────────────────────────────────────
INSERT INTO users (id, name, email, password, phone, role, pro_profiles, is_phone_verified, created_at) VALUES
('d0000002-0000-0000-0000-000000000004', 'Kamgang Jules',   'kamgang@jules.cm',  '$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237684567890', 'driver', 'driver', TRUE, NOW() - INTERVAL '25 days'),
('d0000002-0000-0000-0000-000000000005', 'Tabe Christiane', 'tabe@christiane.cm','$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237685678901', 'driver', 'driver', TRUE, NOW() - INTERVAL '20 days'),
('d0000002-0000-0000-0000-000000000006', 'Manga Etienne',   'manga@etienne.cm',  '$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237686789012', 'driver', 'driver', TRUE, NOW() - INTERVAL '15 days')
ON CONFLICT DO NOTHING;

INSERT INTO drivers (id, user_id, license_number, status, rating, location, created_at) VALUES
('e0000001-0000-0000-0000-000000000004', 'd0000002-0000-0000-0000-000000000004', 'LIC-CM-78456', 'online',  4.75, ST_SetSRID(ST_Point(9.7080, 4.0480), 4326), NOW()),
('e0000001-0000-0000-0000-000000000005', 'd0000002-0000-0000-0000-000000000005', 'LIC-CM-78567', 'offline', 4.85, ST_SetSRID(ST_Point(9.7180, 4.0580), 4326), NOW()),
('e0000001-0000-0000-0000-000000000006', 'd0000002-0000-0000-0000-000000000006', 'LIC-CM-78678', 'online',  4.60, ST_SetSRID(ST_Point(9.6980, 4.0380), 4326), NOW())
ON CONFLICT DO NOTHING;

INSERT INTO vehicles (id, driver_id, owner_id, assigned_driver_id, make, model, year, plate_number, color, type, created_at) VALUES
('f0000001-0000-0000-0000-000000000004', 'e0000001-0000-0000-0000-000000000004', 'd0000002-0000-0000-0000-000000000004', 'e0000001-0000-0000-0000-000000000004', 'Mercedes', 'Classe E', 2021, 'DL-001-OU', 'Noir',     'premium', NOW()),
('f0000001-0000-0000-0000-000000000005', 'e0000001-0000-0000-0000-000000000005', 'd0000002-0000-0000-0000-000000000005', 'e0000001-0000-0000-0000-000000000005', 'Honda',    'CB125',   2022, 'DL-002-YA', 'Rouge',    'delivery', NOW()),
('f0000001-0000-0000-0000-000000000006', 'e0000001-0000-0000-0000-000000000006', 'd0000002-0000-0000-0000-000000000006', 'e0000001-0000-0000-0000-000000000006', 'Toyota',   'Camry',   2019, 'DL-003-OU', 'Argent',   'economy', NOW())
ON CONFLICT DO NOTHING;

INSERT INTO driver_wallets (id, driver_id, balance, currency_code, min_balance, is_locked, total_recharged, total_deducted, created_at) VALUES
('f0000002-0000-0000-0000-000000000004', 'e0000001-0000-0000-0000-000000000004', 45000.00, 'XAF', 0.00, FALSE, 50000.00,  5000.00, NOW()),
('f0000002-0000-0000-0000-000000000005', 'e0000001-0000-0000-0000-000000000005',  3500.00, 'XAF', 0.00, FALSE,  5000.00,  1500.00, NOW()),
('f0000002-0000-0000-0000-000000000006', 'e0000001-0000-0000-0000-000000000006', 12000.00, 'XAF', 0.00, FALSE, 15000.00,  3000.00, NOW())
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────
-- 6. SEED: Additional Trips (Recent 7 days — richer dashboard)
-- ─────────────────────────────────────────────────────────────────
INSERT INTO trips (id, rider_id, driver_id, pickup_location, dropoff_location, pickup_address, dropoff_address, status, fare, payment_status, created_at) VALUES
('c0000001-0000-0000-0000-000000000006', 'd0000001-0000-0000-0000-000000000004', 'e0000001-0000-0000-0000-000000000001', ST_SetSRID(ST_Point(11.5021, 3.8480), 4326), ST_SetSRID(ST_Point(11.5189, 3.8620), 4326), 'Marché Central, Yaoundé', 'Nlongkak, Yaoundé',             'completed', 2000.00, 'paid',   NOW() - INTERVAL '6 days'),
('c0000001-0000-0000-0000-000000000007', 'd0000001-0000-0000-0000-000000000005', 'e0000001-0000-0000-0000-000000000002', ST_SetSRID(ST_Point(11.5082, 3.8581), 4326), ST_SetSRID(ST_Point(11.5012, 3.8454), 4326), 'Omnisport, Yaoundé',        'Plateau, Yaoundé',              'completed', 2500.00, 'paid',   NOW() - INTERVAL '4 days'),
('c0000001-0000-0000-0000-000000000008', 'd0000001-0000-0000-0000-000000000006', 'e0000001-0000-0000-0000-000000000004', ST_SetSRID(ST_Point(9.7080, 4.0480), 4326),  ST_SetSRID(ST_Point(9.7280, 4.0680), 4326),  'Akwa, Douala',             'Bonanjo, Douala',               'completed', 3000.00, 'paid',   NOW() - INTERVAL '3 days'),
('c0000001-0000-0000-0000-000000000009', 'd0000001-0000-0000-0000-000000000007', 'e0000001-0000-0000-0000-000000000006', ST_SetSRID(ST_Point(9.6980, 4.0380), 4326),  ST_SetSRID(ST_Point(9.7180, 4.0180), 4326),  'Deïdo, Douala',            'Bassa, Douala',                 'completed', 1800.00, 'paid',   NOW() - INTERVAL '2 days'),
('c0000001-0000-0000-0000-000000000010', 'd0000001-0000-0000-0000-000000000008', 'e0000001-0000-0000-0000-000000000001', ST_SetSRID(ST_Point(11.5021, 3.8480), 4326), ST_SetSRID(ST_Point(11.4821, 3.8680), 4326), 'Poste Centrale, Yaoundé', 'Essos, Yaoundé',                'completed', 1600.00, 'paid',   NOW() - INTERVAL '1 day'),
('c0000001-0000-0000-0000-000000000011', 'd0000001-0000-0000-0000-000000000001', 'e0000001-0000-0000-0000-000000000003', ST_SetSRID(ST_Point(11.5121, 3.8380), 4326), ST_SetSRID(ST_Point(11.5321, 3.8580), 4326), 'Mvog-Mbi, Yaoundé',       'Mendong, Yaoundé',              'cancelled',    0.00, 'failed', NOW() - INTERVAL '12 hours'),
('c0000001-0000-0000-0000-000000000012', 'd0000001-0000-0000-0000-000000000002', 'e0000001-0000-0000-0000-000000000002', ST_SetSRID(ST_Point(11.5021, 3.8480), 4326), ST_SetSRID(ST_Point(11.5121, 3.8580), 4326), 'Nlongkak, Yaoundé',       'Golf Club, Yaoundé',            'requested',  2200.00, 'pending', NOW() - INTERVAL '30 minutes')
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────
-- 7. SEED: More Wallet Transactions (recent)
-- ─────────────────────────────────────────────────────────────────
INSERT INTO wallet_transactions (id, driver_id, trip_id, type, amount, balance_before, balance_after, currency_code, description_fr, description_en, payment_method, reference, status, created_at) VALUES
('b0000002-0000-0000-0000-000000000009',  'e0000001-0000-0000-0000-000000000001', 'c0000001-0000-0000-0000-000000000006', 'commission_deduction', 400.00, 19460.00, 19060.00, 'XAF', 'Commission course Marché Central → Nlongkak',      'Commission trip Marché Central → Nlongkak',      NULL, NULL, 'completed', NOW() - INTERVAL '6 days'),
('b0000002-0000-0000-0000-000000000010',  'e0000001-0000-0000-0000-000000000002', 'c0000001-0000-0000-0000-000000000007', 'commission_deduction', 500.00, 28400.00, 27900.00, 'XAF', 'Commission course Omnisport → Plateau',            'Commission trip Omnisport → Plateau',            NULL, NULL, 'completed', NOW() - INTERVAL '4 days'),
('b0000002-0000-0000-0000-000000000011',  'e0000001-0000-0000-0000-000000000004', NULL,                                    'recharge',            50000.00, 0.00, 50000.00,   'XAF', 'Recharge Orange Money initial',                    'Orange Money initial recharge',                  'orange_money', 'OM-TX-99221', 'completed', NOW() - INTERVAL '26 days'),
('b0000002-0000-0000-0000-000000000012',  'e0000001-0000-0000-0000-000000000004', 'c0000001-0000-0000-0000-000000000008', 'commission_deduction', 600.00, 50000.00, 49400.00, 'XAF', 'Commission course Akwa → Bonanjo',                 'Commission trip Akwa → Bonanjo',                 NULL, NULL, 'completed', NOW() - INTERVAL '3 days'),
('b0000002-0000-0000-0000-000000000013',  'e0000001-0000-0000-0000-000000000006', NULL,                                    'recharge',            15000.00, 0.00, 15000.00,   'XAF', 'Recharge MTN MoMo',                                'MTN MoMo recharge',                              'mtn_momo', 'MTN-TX-33442', 'completed', NOW() - INTERVAL '16 days'),
('b0000002-0000-0000-0000-000000000014',  'e0000001-0000-0000-0000-000000000006', 'c0000001-0000-0000-0000-000000000009', 'commission_deduction', 360.00, 15000.00, 14640.00, 'XAF', 'Commission course Deïdo → Bassa',                  'Commission trip Deïdo → Bassa',                  NULL, NULL, 'completed', NOW() - INTERVAL '2 days'),
('b0000002-0000-0000-0000-000000000015',  'e0000001-0000-0000-0000-000000000001', 'c0000001-0000-0000-0000-000000000010', 'commission_deduction', 320.00, 19060.00, 18740.00, 'XAF', 'Commission course Poste Centrale → Essos',         'Commission trip Poste Centrale → Essos',         NULL, NULL, 'completed', NOW() - INTERVAL '1 day')
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────
-- 8. SEED: More Stores (Restaurant, Pharmacie, Boutique)
-- ─────────────────────────────────────────────────────────────────
INSERT INTO users (id, name, email, password, phone, role, pro_profiles, is_phone_verified, created_at) VALUES
('d0000003-0000-0000-0000-000000000003', 'Guy Minlo',     'guy@minlo.cm',     '$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237663456789', 'store', 'merchant', TRUE, NOW() - INTERVAL '20 days'),
('d0000003-0000-0000-0000-000000000004', 'Flore Ngali',   'flore@ngali.cm',   '$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237664567890', 'store', 'merchant', TRUE, NOW() - INTERVAL '15 days'),
('d0000003-0000-0000-0000-000000000005', 'Roger Abena',   'roger@abena.cm',   '$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237665678901', 'store', 'merchant', TRUE, NOW() - INTERVAL '10 days')
ON CONFLICT DO NOTHING;

INSERT INTO stores (id, user_id, name, description, image_url, location, address, rating, is_active, type, category, created_at) VALUES
('b0000001-0000-0000-0000-000000000003', 'd0000003-0000-0000-0000-000000000003', 'Restaurant Chez Guy',         'Cuisine camerounaise traditionnelle — Ndolé, Eru, Poisson braisé', 'chez_guy.png',    ST_SetSRID(ST_Point(11.5082, 3.8550), 4326), 'Hippodrome, Yaoundé',     4.80, TRUE, 'restaurant', 'Restaurant',   NOW() - INTERVAL '20 days'),
('b0000001-0000-0000-0000-000000000004', 'd0000003-0000-0000-0000-000000000004', 'Pharmacie Centrale Yaoundé',  'Médicaments, parapharmacie et conseils santé',                     'pharmacie.png',   ST_SetSRID(ST_Point(11.5012, 3.8454), 4326), 'Centre-ville, Yaoundé',   4.60, TRUE, 'pharmacy',   'Pharmacie',    NOW() - INTERVAL '15 days'),
('b0000001-0000-0000-0000-000000000005', 'd0000003-0000-0000-0000-000000000005', 'Mode Africa Boutique',        'Vêtements africains modernes, pagnes, bazins et accessoires',     'mode_africa.png', ST_SetSRID(ST_Point(9.7080, 4.0480), 4326),  'Akwa, Douala',            4.40, TRUE, 'fashion',    'Mode',         NOW() - INTERVAL '10 days')
ON CONFLICT DO NOTHING;

INSERT INTO store_schedules (store_id, day_of_week, open_time, close_time, is_closed) VALUES
('b0000001-0000-0000-0000-000000000003', 0, '09:00', '23:00', FALSE),
('b0000001-0000-0000-0000-000000000003', 1, '09:00', '23:00', FALSE),
('b0000001-0000-0000-0000-000000000003', 2, '09:00', '23:00', FALSE),
('b0000001-0000-0000-0000-000000000003', 3, '09:00', '23:00', FALSE),
('b0000001-0000-0000-0000-000000000003', 4, '09:00', '23:00', FALSE),
('b0000001-0000-0000-0000-000000000003', 5, '09:00', '00:00', FALSE),
('b0000001-0000-0000-0000-000000000003', 6, '10:00', '22:00', FALSE),

('b0000001-0000-0000-0000-000000000004', 0, '08:00', '20:00', FALSE),
('b0000001-0000-0000-0000-000000000004', 1, '08:00', '20:00', FALSE),
('b0000001-0000-0000-0000-000000000004', 2, '08:00', '20:00', FALSE),
('b0000001-0000-0000-0000-000000000004', 3, '08:00', '20:00', FALSE),
('b0000001-0000-0000-0000-000000000004', 4, '08:00', '20:00', FALSE),
('b0000001-0000-0000-0000-000000000004', 5, '08:00', '18:00', FALSE),
('b0000001-0000-0000-0000-000000000004', 6, '09:00', '14:00', FALSE),

('b0000001-0000-0000-0000-000000000005', 0, '10:00', '20:00', FALSE),
('b0000001-0000-0000-0000-000000000005', 1, '10:00', '20:00', FALSE),
('b0000001-0000-0000-0000-000000000005', 2, '10:00', '20:00', FALSE),
('b0000001-0000-0000-0000-000000000005', 3, '10:00', '20:00', FALSE),
('b0000001-0000-0000-0000-000000000005', 4, '10:00', '20:00', FALSE),
('b0000001-0000-0000-0000-000000000005', 5, '10:00', '20:00', FALSE),
('b0000001-0000-0000-0000-000000000005', 6, '10:00', '17:00', FALSE)
ON CONFLICT DO NOTHING;

INSERT INTO products (id, store_id, name, description, price, image_url, is_featured, is_deliverable, is_active, created_at) VALUES
-- Restaurant Chez Guy
('a0000003-0000-0000-0000-000000000006', 'b0000001-0000-0000-0000-000000000003', 'Ndolé complet',         'Ndolé aux crevettes avec plantain et riz', 3500.00, 'ndole.png',        TRUE,  TRUE, TRUE, NOW()),
('a0000003-0000-0000-0000-000000000007', 'b0000001-0000-0000-0000-000000000003', 'Eru et Water Fufu',     'Plat traditionnel Camerouno-Nigérian',    4000.00, 'eru.png',          TRUE,  TRUE, TRUE, NOW()),
('a0000003-0000-0000-0000-000000000008', 'b0000001-0000-0000-0000-000000000003', 'Poisson braisé',        'Tilapia braisé sauce tomates et épices',  4500.00, 'poisson.png',      FALSE, TRUE, TRUE, NOW()),
('a0000003-0000-0000-0000-000000000009', 'b0000001-0000-0000-0000-000000000003', 'Jus de gingembre',      'Jus de gingembre frais maison',           800.00,  'gingembre.png',   FALSE, TRUE, TRUE, NOW()),
-- Pharmacie
('a0000003-0000-0000-0000-000000000010', 'b0000001-0000-0000-0000-000000000004', 'Paracétamol 500mg x10', 'Boîte de 10 comprimés paracétamol',       350.00,  'paracetamol.png',  FALSE, TRUE, TRUE, NOW()),
('a0000003-0000-0000-0000-000000000011', 'b0000001-0000-0000-0000-000000000004', 'Ibuprofène 400mg x10', 'Boîte de 10 comprimés ibuprofène',         550.00,  'ibuprofen.png',    FALSE, TRUE, TRUE, NOW()),
-- Boutique
('a0000003-0000-0000-0000-000000000012', 'b0000001-0000-0000-0000-000000000005', 'Pagne Bogolan 6m',      'Tissu bogolan authentique 6 mètres',      8500.00, 'pagne.png',        TRUE,  FALSE, TRUE, NOW()),
('a0000003-0000-0000-0000-000000000013', 'b0000001-0000-0000-0000-000000000005', 'Chemise Bazin Homme',   'Chemise bazin riche brodée',              12000.00,'chemise.png',      TRUE,  FALSE, TRUE, NOW())
ON CONFLICT DO NOTHING;
