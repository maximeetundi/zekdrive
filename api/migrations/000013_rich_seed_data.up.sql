-- Migration 013: Rich seed data for Cameroon (Yaoundé & Douala)
-- Seeds users (riders), drivers, vehicles, wallets, zones, stores, products, historical trips, and transactions.

-- ─────────────────────────────────────────────
-- 1. SEED: Users (Riders, Drivers, Merchants)
-- ─────────────────────────────────────────────
-- Passwords are bcrypt for 'admin123'
INSERT INTO users (id, name, email, password, phone, role, pro_profiles, is_phone_verified, created_at) VALUES
('d0000001-0000-0000-0000-000000000001', 'Amadou Diallo', 'amadou@diallo.com', '$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237671234567', 'rider', '', TRUE, NOW() - INTERVAL '30 days'),
('d0000001-0000-0000-0000-000000000002', 'Mariama Sow', 'mariama@sow.com', '$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237672345678', 'rider', '', TRUE, NOW() - INTERVAL '30 days'),
('d0000001-0000-0000-0000-000000000003', 'Cheikh Bamba', 'cheikh@bamba.com', '$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237673456789', 'rider', '', TRUE, NOW() - INTERVAL '30 days'),

('d0000002-0000-0000-0000-000000000001', 'Ibrahima Ndiaye', 'ibrahima@ndiaye.com', '$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237681234567', 'driver', 'driver', TRUE, NOW() - INTERVAL '30 days'),
('d0000002-0000-0000-0000-000000000002', 'Moussa Diop', 'moussa@diop.com', '$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237682345678', 'driver', 'driver', TRUE, NOW() - INTERVAL '30 days'),
('d0000002-0000-0000-0000-000000000003', 'Fatou Fall', 'fatou@fall.com', '$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237683456789', 'driver', 'driver', TRUE, NOW() - INTERVAL '30 days'),

('d0000003-0000-0000-0000-000000000001', 'Babacar Sall', 'babacar@royale.com', '$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237661234567', 'store', 'merchant', TRUE, NOW() - INTERVAL '30 days'),
('d0000003-0000-0000-0000-000000000002', 'Aida Kane', 'aida@excellence.com', '$2a$10$7zB3cW02G99.F7zYvK6iDeG25xW4l5VwF3/6lU1Dug7v2/u5U2jBq', '+237662345678', 'store', 'merchant', TRUE, NOW() - INTERVAL '30 days')
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────
-- 2. SEED: Drivers
-- ─────────────────────────────────────────────
INSERT INTO drivers (id, user_id, license_number, status, rating, location, created_at) VALUES
('e0000001-0000-0000-0000-000000000001', 'd0000002-0000-0000-0000-000000000001', 'LIC-CM-78123', 'online', 4.80, ST_SetSRID(ST_Point(11.5021, 3.8480), 4326), NOW()),
('e0000001-0000-0000-0000-000000000002', 'd0000002-0000-0000-0000-000000000002', 'LIC-CM-78234', 'online', 4.90, ST_SetSRID(ST_Point(11.5121, 3.8580), 4326), NOW()),
('e0000001-0000-0000-0000-000000000003', 'd0000002-0000-0000-0000-000000000003', 'LIC-CM-78345', 'online', 4.70, ST_SetSRID(ST_Point(11.4921, 3.8380), 4326), NOW())
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────
-- 3. SEED: Vehicles
-- ─────────────────────────────────────────────
INSERT INTO vehicles (id, driver_id, owner_id, assigned_driver_id, make, model, year, plate_number, color, type, created_at) VALUES
('f0000001-0000-0000-0000-000000000001', 'e0000001-0000-0000-0000-000000000001', 'd0000002-0000-0000-0000-000000000001', 'e0000001-0000-0000-0000-000000000001', 'Toyota', 'Corolla', 2018, 'LT-123-YA', 'Jaune', 'economy', NOW()),
('f0000001-0000-0000-0000-000000000002', 'e0000001-0000-0000-0000-000000000002', 'd0000002-0000-0000-0000-000000000002', 'e0000001-0000-0000-0000-000000000002', 'Toyota', 'Prado', 2020, 'CE-456-OU', 'Noir', 'premium', NOW()),
('f0000001-0000-0000-0000-000000000003', 'e0000001-0000-0000-0000-000000000003', 'd0000002-0000-0000-0000-000000000003', 'e0000001-0000-0000-0000-000000000003', 'Yamaha', 'Crypton', 2021, 'LT-789-CM', 'Rouge', 'delivery', NOW())
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────
-- 4. SEED: Wallets
-- ─────────────────────────────────────────────
INSERT INTO driver_wallets (id, driver_id, balance, currency_code, min_balance, is_locked, total_recharged, total_deducted, created_at) VALUES
('f0000002-0000-0000-0000-000000000001', 'e0000001-0000-0000-0000-000000000001', 15000.00, 'XAF', 0.00, FALSE, 20000.00, 5000.00, NOW()),
('f0000002-0000-0000-0000-000000000002', 'e0000001-0000-0000-0000-000000000002', 25000.00, 'XAF', 0.00, FALSE, 30000.00, 5000.00, NOW()),
('f0000002-0000-0000-0000-000000000003', 'e0000001-0000-0000-0000-000000000003', 8000.00, 'XAF', 0.00, FALSE, 10000.00, 2000.00, NOW())
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────
-- 5. SEED: Yaoundé Zone (Default Zone 1)
-- ─────────────────────────────────────────────
INSERT INTO zones (id, name, boundary, base_fare, fare_per_km, fare_per_minute, surge_multiplier, created_at) VALUES
('a0000002-0000-0000-0000-000000000001', 'Yaoundé', ST_GeomFromText('POLYGON((11.35 3.75, 11.65 3.75, 11.65 3.95, 11.35 3.95, 11.35 3.75))', 4326), 500.00, 300.00, 50.00, 1.00, NOW())
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────
-- 6. SEED: Historical Completed Trips (Last 30 Days)
-- ─────────────────────────────────────────────
INSERT INTO trips (id, rider_id, driver_id, pickup_location, dropoff_location, pickup_address, dropoff_address, status, fare, payment_status, created_at) VALUES
('c0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001', 'e0000001-0000-0000-0000-000000000001', ST_SetSRID(ST_Point(11.5012, 3.8454), 4326), ST_SetSRID(ST_Point(11.5189, 3.8502), 4326), 'Avenue de l''Indépendance, Yaoundé', 'Bastos, Yaoundé', 'completed', 1500.00, 'paid', NOW() - INTERVAL '15 days'),
('c0000001-0000-0000-0000-000000000002', 'd0000001-0000-0000-0000-000000000002', 'e0000001-0000-0000-0000-000000000002', ST_SetSRID(ST_Point(11.5031, 3.8424), 4326), ST_SetSRID(ST_Point(11.5211, 3.8711), 4326), 'Poste Centrale, Yaoundé', 'Golf Club, Yaoundé', 'completed', 3500.00, 'paid', NOW() - INTERVAL '10 days'),
('c0000001-0000-0000-0000-000000000003', 'd0000001-0000-0000-0000-000000000003', 'e0000001-0000-0000-0000-000000000001', ST_SetSRID(ST_Point(11.4921, 3.8312), 4326), ST_SetSRID(ST_Point(11.5021, 3.8412), 4326), 'Mvan, Yaoundé', 'Centre Ville, Yaoundé', 'completed', 1200.00, 'paid', NOW() - INTERVAL '8 days'),
('c0000001-0000-0000-0000-000000000004', 'd0000001-0000-0000-0000-000000000002', 'e0000001-0000-0000-0000-000000000003', ST_SetSRID(ST_Point(11.5121, 3.8580), 4326), ST_SetSRID(ST_Point(11.5021, 3.8480), 4326), 'Emana, Yaoundé', 'Bastos, Yaoundé', 'completed', 1800.00, 'paid', NOW() - INTERVAL '5 days'),
('c0000001-0000-0000-0000-000000000005', 'd0000001-0000-0000-0000-000000000001', 'e0000001-0000-0000-0000-000000000002', ST_SetSRID(ST_Point(11.5211, 3.8711), 4326), ST_SetSRID(ST_Point(11.5012, 3.8454), 4326), 'Golf, Yaoundé', 'Avenue de l''Indépendance, Yaoundé', 'completed', 4500.00, 'paid', NOW() - INTERVAL '2 days')
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────
-- 7. SEED: Wallet Transactions
-- ─────────────────────────────────────────────
INSERT INTO wallet_transactions (id, driver_id, trip_id, type, amount, balance_before, balance_after, currency_code, description_fr, description_en, payment_method, reference, status, created_at) VALUES
('b0000002-0000-0000-0000-000000000001', 'e0000001-0000-0000-0000-000000000001', NULL, 'recharge', 20000.00, 0.00, 20000.00, 'XAF', 'Recharge de compte MTN Mobile Money', 'MTN MoMo Recharge', 'mtn_momo', 'MTN-TX-99881', 'completed', NOW() - INTERVAL '20 days'),
('b0000002-0000-0000-0000-000000000002', 'e0000001-0000-0000-0000-000000000001', 'c0000001-0000-0000-0000-000000000001', 'commission_deduction', 300.00, 20000.00, 19700.00, 'XAF', 'Déduction commission course #c0000001', 'Commission deduction trip #c0000001', NULL, NULL, 'completed', NOW() - INTERVAL '15 days'),
('b0000002-0000-0000-0000-000000000003', 'e0000001-0000-0000-0000-000000000001', 'c0000001-0000-0000-0000-000000000003', 'commission_deduction', 240.00, 19700.00, 19460.00, 'XAF', 'Déduction commission course #c0000003', 'Commission deduction trip #c0000003', NULL, NULL, 'completed', NOW() - INTERVAL '8 days'),

('b0000002-0000-0000-0000-000000000004', 'e0000001-0000-0000-0000-000000000002', NULL, 'recharge', 30000.00, 0.00, 30000.00, 'XAF', 'Recharge de compte Orange Money', 'Orange Money Recharge', 'orange_money', 'OM-TX-44331', 'completed', NOW() - INTERVAL '12 days'),
('b0000002-0000-0000-0000-000000000005', 'e0000001-0000-0000-0000-000000000002', 'c0000001-0000-0000-0000-000000000002', 'commission_deduction', 700.00, 30000.00, 29300.00, 'XAF', 'Déduction commission course #c0000002', 'Commission deduction trip #c0000002', NULL, NULL, 'completed', NOW() - INTERVAL '10 days'),
('b0000002-0000-0000-0000-000000000006', 'e0000001-0000-0000-0000-000000000002', 'c0000001-0000-0000-0000-000000000005', 'commission_deduction', 900.00, 29300.00, 28400.00, 'XAF', 'Déduction commission course #c0000005', 'Commission deduction trip #c0000005', NULL, NULL, 'completed', NOW() - INTERVAL '2 days'),

('b0000002-0000-0000-0000-000000000007', 'e0000001-0000-0000-0000-000000000003', NULL, 'recharge', 10000.00, 0.00, 10000.00, 'XAF', 'Recharge de compte MTN Mobile Money', 'MTN MoMo Recharge', 'mtn_momo', 'MTN-TX-99885', 'completed', NOW() - INTERVAL '6 days'),
('b0000002-0000-0000-0000-000000000008', 'e0000001-0000-0000-0000-000000000003', 'c0000001-0000-0000-0000-000000000004', 'commission_deduction', 360.00, 10000.00, 9640.00, 'XAF', 'Déduction commission course #c0000004', 'Commission deduction trip #c0000004', NULL, NULL, 'completed', NOW() - INTERVAL '5 days')
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────
-- 8. SEED: Stores
-- ─────────────────────────────────────────────
INSERT INTO stores (id, user_id, name, description, image_url, location, address, rating, is_active, type, category, created_at) VALUES
('b0000001-0000-0000-0000-000000000001', 'd0000003-0000-0000-0000-000000000001', 'Pâtisserie Boulangerie Bastos', 'Boulangerie & Pâtisserie de luxe au coeur de Bastos', 'royale.png', ST_SetSRID(ST_Point(11.5031, 3.8424), 4326), 'Avenue Bastos, Yaoundé', 4.70, TRUE, 'bakery', 'Boulangerie', NOW() - INTERVAL '30 days'),
('b0000001-0000-0000-0000-000000000002', 'd0000003-0000-0000-0000-000000000002', 'Supermarché Bastos', 'Alimentation générale, fruits et légumes frais', 'excellence.png', ST_SetSRID(ST_Point(11.5082, 3.8481), 4326), 'Rue Bastos, Yaoundé', 4.50, TRUE, 'grocery', 'Alimentation', NOW() - INTERVAL '30 days')
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────
-- 9. SEED: Store Schedules
-- ─────────────────────────────────────────────
INSERT INTO store_schedules (store_id, day_of_week, open_time, close_time, is_closed) VALUES
('b0000001-0000-0000-0000-000000000001', 0, '07:00', '22:00', FALSE),
('b0000001-0000-0000-0000-000000000001', 1, '07:00', '22:00', FALSE),
('b0000001-0000-0000-0000-000000000001', 2, '07:00', '22:00', FALSE),
('b0000001-0000-0000-0000-000000000001', 3, '07:00', '22:00', FALSE),
('b0000001-0000-0000-0000-000000000001', 4, '07:00', '22:00', FALSE),
('b0000001-0000-0000-0000-000000000001', 5, '07:00', '23:00', FALSE),
('b0000001-0000-0000-0000-000000000001', 6, '07:00', '23:00', FALSE),

('b0000001-0000-0000-0000-000000000002', 0, '08:00', '21:00', FALSE),
('b0000001-0000-0000-0000-000000000002', 1, '08:00', '21:00', FALSE),
('b0000001-0000-0000-0000-000000000002', 2, '08:00', '21:00', FALSE),
('b0000001-0000-0000-0000-000000000002', 3, '08:00', '21:00', FALSE),
('b0000001-0000-0000-0000-000000000002', 4, '08:00', '21:00', FALSE),
('b0000001-0000-0000-0000-000000000002', 5, '08:00', '22:00', FALSE),
('b0000001-0000-0000-0000-000000000002', 6, '08:00', '15:00', FALSE)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────
-- 10. SEED: Products
-- ─────────────────────────────────────────────
INSERT INTO products (id, store_id, name, description, price, image_url, is_featured, is_deliverable, is_active, created_at) VALUES
('a0000003-0000-0000-0000-000000000001', 'b0000001-0000-0000-0000-000000000001', 'Croissant au Beurre', 'Vrai croissant feuilleté pur beurre', 500.00, 'croissant.png', TRUE, TRUE, TRUE, NOW()),
('a0000003-0000-0000-0000-000000000002', 'b0000001-0000-0000-0000-000000000001', 'Pain au Chocolat', 'Pain au chocolat fondant traditionnel', 600.00, 'chocolat.png', TRUE, TRUE, TRUE, NOW()),
('a0000003-0000-0000-0000-000000000003', 'b0000001-0000-0000-0000-000000000001', 'Baguette Tradition', 'Baguette de tradition française croustillante', 300.00, 'baguette.png', FALSE, TRUE, TRUE, NOW()),

('a0000003-0000-0000-0000-000000000004', 'b0000001-0000-0000-0000-000000000002', 'Lait local CM 1L', 'Lait frais pasteurisé d''origine Cameroun', 1200.00, 'lait.png', TRUE, TRUE, TRUE, NOW()),
('a0000003-0000-0000-0000-000000000005', 'b0000001-0000-0000-0000-000000000002', 'Café Bastos Moulu 500g', 'Café traditionnel moulu de Bastos', 2500.00, 'cafe.png', TRUE, TRUE, TRUE, NOW())
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────
-- 11. SEED: Historical Store Orders (Last 30 Days)
-- ─────────────────────────────────────────────
INSERT INTO store_orders (id, customer_id, store_id, driver_id, status, delivery_type, delivery_address, delivery_location, delivery_fare, items_total, total_fare, payment_status, pickup_otp, created_at) VALUES
('e0000002-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001', 'b0000001-0000-0000-0000-000000000001', 'e0000001-0000-0000-0000-000000000003', 'completed', 'delivery', 'Bastos, Yaoundé', ST_SetSRID(ST_Point(11.5031, 3.8424), 4326), 500.00, 2200.00, 2700.00, 'paid', '123456', NOW() - INTERVAL '15 days'),
('e0000002-0000-0000-0000-000000000002', 'd0000001-0000-0000-0000-000000000002', 'b0000001-0000-0000-0000-000000000002', 'e0000001-0000-0000-0000-000000000003', 'completed', 'delivery', 'Golf, Yaoundé', ST_SetSRID(ST_Point(11.5211, 3.8711), 4326), 400.00, 4900.00, 5300.00, 'paid', '789012', NOW() - INTERVAL '10 days'),
('e0000002-0000-0000-0000-000000000003', 'd0000001-0000-0000-0000-000000000003', 'b0000001-0000-0000-0000-000000000001', NULL, 'cancelled', 'pickup', 'Poste Centrale, Yaoundé', ST_SetSRID(ST_Point(11.5012, 3.8454), 4326), 0.00, 1800.00, 1800.00, 'failed', '345678', NOW() - INTERVAL '5 days')
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────
-- 12. SEED: Store Order Items
-- ─────────────────────────────────────────────
INSERT INTO store_order_items (id, order_id, product_id, quantity, price) VALUES
('10000001-0000-0000-0000-000000000001', 'e0000002-0000-0000-0000-000000000001', 'a0000003-0000-0000-0000-000000000001', 2, 500.00), -- 2 croissants
('10000001-0000-0000-0000-000000000002', 'e0000002-0000-0000-0000-000000000001', 'a0000003-0000-0000-0000-000000000002', 2, 600.00), -- 2 pain choc

('10000001-0000-0000-0000-000000000003', 'e0000002-0000-0000-0000-000000000002', 'a0000003-0000-0000-0000-000000000004', 2, 1200.00), -- 2 laits
('10000001-0000-0000-0000-000000000004', 'e0000002-0000-0000-0000-000000000002', 'a0000003-0000-0000-0000-000000000005', 1, 2500.00), -- 1 café

('10000001-0000-0000-0000-000000000005', 'e0000002-0000-0000-0000-000000000003', 'a0000003-0000-0000-0000-000000000002', 3, 600.00) -- 3 pain choc (cancelled)
ON CONFLICT DO NOTHING;
