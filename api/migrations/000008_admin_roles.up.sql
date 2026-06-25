-- Migration 008: Admin Roles & Permissions System
-- Creates: admin_roles, admin_permissions, admin_role_permissions, admin_users tables

-- ─────────────────────────────────────────────
-- 1. Admin Roles
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS admin_roles (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(50) UNIQUE NOT NULL,  -- 'super_admin', 'admin', 'moderator', 'support', 'finance'
    label       VARCHAR(100) NOT NULL,         -- Human-readable
    description TEXT,
    color       VARCHAR(20) DEFAULT '#6366f1', -- UI badge color
    is_system   BOOLEAN DEFAULT FALSE,         -- System roles cannot be deleted
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────────
-- 2. Permissions
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS admin_permissions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key         VARCHAR(80) UNIQUE NOT NULL,   -- e.g. 'users.view', 'users.edit'
    label       VARCHAR(100) NOT NULL,
    group_name  VARCHAR(50) NOT NULL,          -- e.g. 'users', 'trips', 'stores'
    description TEXT,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────────
-- 3. Role <-> Permission mapping
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS admin_role_permissions (
    role_id       UUID REFERENCES admin_roles(id) ON DELETE CASCADE,
    permission_id UUID REFERENCES admin_permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

-- ─────────────────────────────────────────────
-- 4. Admin users (sub-table referencing users)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS admin_users (
    user_id     UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    role_id     UUID REFERENCES admin_roles(id) ON DELETE SET NULL,
    is_active   BOOLEAN DEFAULT TRUE,
    last_login  TIMESTAMPTZ,
    created_by  UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────────
-- 5. SEED: Roles
-- ─────────────────────────────────────────────
INSERT INTO admin_roles (id, name, label, description, color, is_system) VALUES
(
    'a0000001-0000-0000-0000-000000000001',
    'super_admin',
    'Super Administrateur',
    'Accès complet à toutes les fonctionnalités. Ne peut pas être supprimé.',
    '#ef4444',
    TRUE
),
(
    'a0000001-0000-0000-0000-000000000002',
    'admin',
    'Administrateur',
    'Gestion complète sauf la gestion des administrateurs.',
    '#f97316',
    TRUE
),
(
    'a0000001-0000-0000-0000-000000000003',
    'moderator',
    'Modérateur',
    'Peut voir et modérer les utilisateurs, chauffeurs et commerces.',
    '#8b5cf6',
    TRUE
),
(
    'a0000001-0000-0000-0000-000000000004',
    'support',
    'Support Client',
    'Accès en lecture aux données pour traiter les tickets.',
    '#06b6d4',
    TRUE
),
(
    'a0000001-0000-0000-0000-000000000005',
    'finance',
    'Responsable Finance',
    'Accès aux transactions, promotions et facturation.',
    '#10b981',
    TRUE
)
ON CONFLICT (name) DO NOTHING;

-- ─────────────────────────────────────────────
-- 6. SEED: Permissions
-- ─────────────────────────────────────────────
INSERT INTO admin_permissions (key, label, group_name) VALUES
-- Utilisateurs
('users.view',        'Voir les utilisateurs',         'users'),
('users.edit',        'Modifier les utilisateurs',     'users'),
('users.delete',      'Supprimer des utilisateurs',    'users'),
('users.ban',         'Bannir des utilisateurs',       'users'),
-- Chauffeurs
('drivers.view',      'Voir les chauffeurs',           'drivers'),
('drivers.edit',      'Modifier les chauffeurs',       'drivers'),
('drivers.approve',   'Approuver les chauffeurs',      'drivers'),
('drivers.ban',       'Bannir des chauffeurs',         'drivers'),
-- Courses
('trips.view',        'Voir les courses',              'trips'),
('trips.manage',      'Gérer les courses',             'trips'),
-- Livraisons
('deliveries.view',   'Voir les livraisons',           'deliveries'),
('deliveries.manage', 'Gérer les livraisons',          'deliveries'),
-- Commerces
('stores.view',       'Voir les commerces',            'stores'),
('stores.edit',       'Modifier les commerces',        'stores'),
('stores.approve',    'Approuver les commerces',       'stores'),
('stores.delete',     'Supprimer des commerces',       'stores'),
-- Commandes commerce
('orders.view',       'Voir les commandes',            'orders'),
('orders.manage',     'Gérer les commandes',           'orders'),
-- Véhicules & Flotte
('vehicles.view',     'Voir les véhicules',            'vehicles'),
('vehicles.edit',     'Modifier les véhicules',        'vehicles'),
('fleet.view',        'Voir les parcs automobiles',    'fleet'),
('fleet.manage',      'Gérer les parcs automobiles',   'fleet'),
-- Zones & Tarification
('zones.view',        'Voir les zones',                'zones'),
('zones.edit',        'Modifier les zones',            'zones'),
('pricing.view',      'Voir la tarification',          'pricing'),
('pricing.edit',      'Modifier la tarification',      'pricing'),
-- Promotions
('promotions.view',   'Voir les promotions',           'promotions'),
('promotions.edit',   'Gérer les promotions',          'promotions'),
-- Finance
('transactions.view', 'Voir les transactions',         'finance'),
('transactions.export','Exporter les transactions',    'finance'),
-- Analytiques
('analytics.view',    'Voir les statistiques',         'analytics'),
-- Paramètres
('settings.view',     'Voir les paramètres',           'settings'),
('settings.edit',     'Modifier les paramètres',       'settings'),
-- Administration
('admins.view',       'Voir les administrateurs',      'admins'),
('admins.manage',     'Gérer les administrateurs',     'admins')
ON CONFLICT (key) DO NOTHING;

-- ─────────────────────────────────────────────
-- 7. SEED: Role → Permissions mapping
-- ─────────────────────────────────────────────

-- SUPER_ADMIN: toutes les permissions
INSERT INTO admin_role_permissions (role_id, permission_id)
SELECT 'a0000001-0000-0000-0000-000000000001', id FROM admin_permissions
ON CONFLICT DO NOTHING;

-- ADMIN: tout sauf admins.manage
INSERT INTO admin_role_permissions (role_id, permission_id)
SELECT 'a0000001-0000-0000-0000-000000000002', id
FROM admin_permissions
WHERE key NOT IN ('admins.manage')
ON CONFLICT DO NOTHING;

-- MODERATOR: vue + modération utilisateurs/chauffeurs/commerces/courses
INSERT INTO admin_role_permissions (role_id, permission_id)
SELECT 'a0000001-0000-0000-0000-000000000003', id
FROM admin_permissions
WHERE key IN (
    'users.view','users.edit','users.ban',
    'drivers.view','drivers.edit','drivers.approve','drivers.ban',
    'trips.view','trips.manage',
    'deliveries.view','deliveries.manage',
    'stores.view','stores.edit','stores.approve',
    'orders.view','orders.manage',
    'vehicles.view',
    'analytics.view'
)
ON CONFLICT DO NOTHING;

-- SUPPORT: lecture seule principalement
INSERT INTO admin_role_permissions (role_id, permission_id)
SELECT 'a0000001-0000-0000-0000-000000000004', id
FROM admin_permissions
WHERE key IN (
    'users.view',
    'drivers.view',
    'trips.view',
    'deliveries.view',
    'stores.view',
    'orders.view',
    'vehicles.view',
    'analytics.view',
    'transactions.view'
)
ON CONFLICT DO NOTHING;

-- FINANCE: finance + analytics + promotions
INSERT INTO admin_role_permissions (role_id, permission_id)
SELECT 'a0000001-0000-0000-0000-000000000005', id
FROM admin_permissions
WHERE key IN (
    'transactions.view','transactions.export',
    'promotions.view','promotions.edit',
    'pricing.view','pricing.edit',
    'analytics.view',
    'users.view',
    'drivers.view',
    'stores.view'
)
ON CONFLICT DO NOTHING;
