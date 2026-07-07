INSERT INTO zones (id, name, boundary, base_fare, fare_per_km, fare_per_minute, surge_multiplier, created_at) VALUES
('a0000002-0000-0000-0000-000000000003', 'Douala', ST_GeomFromText('POLYGON((9.60 3.95, 9.90 3.95, 9.90 4.15, 9.60 4.15, 9.60 3.95))', 4326), 500.00, 300.00, 50.00, 1.00, NOW())
ON CONFLICT (id) DO UPDATE SET boundary = EXCLUDED.boundary, base_fare = EXCLUDED.base_fare, fare_per_km = EXCLUDED.fare_per_km;
