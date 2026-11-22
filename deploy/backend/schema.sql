-- ==============================================================================
-- BANGLADESH: OPEN WORLD (DTA) — PRODUCTION DATABASE SCHEMA
-- Engine: PostgreSQL 14+
-- Purpose: Persistent accounts, player state, inventory, garages, and missions.
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(32) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(16) NOT NULL DEFAULT 'player',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- 3. PLAYER PROFILES TABLE
CREATE TABLE IF NOT EXISTS player_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    display_name VARCHAR(48) NOT NULL,
    wallet_bdt BIGINT NOT NULL DEFAULT 5000,
    bank_bdt BIGINT NOT NULL DEFAULT 25000,
    wanted_stars INT NOT NULL DEFAULT 0 CHECK (wanted_stars >= 0 AND wanted_stars <= 5),
    current_outfit VARCHAR(64) NOT NULL DEFAULT 'dhaka_casual',
    current_health REAL NOT NULL DEFAULT 100.0 CHECK (current_health >= 0.0),
    current_stamina REAL NOT NULL DEFAULT 100.0 CHECK (current_stamina >= 0.0),
    pos_x REAL NOT NULL DEFAULT 0.0,
    pos_y REAL NOT NULL DEFAULT 0.5,
    pos_z REAL NOT NULL DEFAULT 0.0,
    rot_y REAL NOT NULL DEFAULT 0.0,
    current_region VARCHAR(64) NOT NULL DEFAULT 'region_01_dhaka',
    total_playtime_seconds BIGINT NOT NULL DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. PLAYER INVENTORY TABLE
CREATE TABLE IF NOT EXISTS player_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_id VARCHAR(64) NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    metadata JSONB DEFAULT '{}'::jsonb,
    acquired_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_item UNIQUE (user_id, item_id)
);

CREATE INDEX IF NOT EXISTS idx_inventory_user_id ON player_inventory(user_id);

-- 5. OWNED VEHICLES & GARAGE TABLE
CREATE TABLE IF NOT EXISTS player_vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vehicle_type VARCHAR(48) NOT NULL,
    nickname VARCHAR(64) DEFAULT 'My Vehicle',
    paint_color VARCHAR(32) DEFAULT 'classic_green',
    engine_tune INT NOT NULL DEFAULT 0,
    armor_level INT NOT NULL DEFAULT 0,
    current_health REAL NOT NULL DEFAULT 100.0,
    stored_in_garage VARCHAR(64) DEFAULT 'workshop_buriganga',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_vehicles_user_id ON player_vehicles(user_id);

-- 6. STORY & SIDE MISSIONS PROGRESSION
CREATE TABLE IF NOT EXISTS player_missions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    mission_id VARCHAR(64) NOT NULL,
    status VARCHAR(24) NOT NULL DEFAULT 'NOT_STARTED' CHECK (status IN ('NOT_STARTED', 'IN_PROGRESS', 'COMPLETED', 'FAILED')),
    current_step INT NOT NULL DEFAULT 0,
    completed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT uq_user_mission UNIQUE (user_id, mission_id)
);

CREATE INDEX IF NOT EXISTS idx_missions_user_id ON player_missions(user_id);

-- 7. AUDIT LOG (Anti-Cheat & Transactions)
CREATE TABLE IF NOT EXISTS financial_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    transaction_type VARCHAR(32) NOT NULL,
    amount_bdt BIGINT NOT NULL,
    resulting_balance BIGINT NOT NULL,
    reason VARCHAR(255),
    server_verified BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_audit_user_id ON financial_audit_log(user_id);

-- 8. SUPPORT & BUG REPORTS TABLE
CREATE TABLE IF NOT EXISTS bug_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    player_name VARCHAR(64) NOT NULL,
    email VARCHAR(255),
    category VARCHAR(32) NOT NULL DEFAULT 'GENERAL',
    title VARCHAR(128) NOT NULL,
    description TEXT NOT NULL,
    system_specs TEXT,
    status VARCHAR(24) NOT NULL DEFAULT 'OPEN',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_bug_reports_category ON bug_reports(category);
CREATE INDEX IF NOT EXISTS idx_bug_reports_status ON bug_reports(status);
