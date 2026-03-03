-- StrataVault Database Schema
-- RWA Vault Management System

-- Assets table
CREATE TABLE rwa_assets (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    symbol VARCHAR(10) NOT NULL,
    asset_type VARCHAR(50) NOT NULL,
    total_supply DECIMAL(38,0) NOT NULL DEFAULT 0,
    owner VARCHAR(56) NOT NULL,
    metadata_hash VARCHAR(64) NOT NULL,
    compliance_level INTEGER NOT NULL DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Asset balances
CREATE TABLE asset_balances (
    asset_id INTEGER REFERENCES rwa_assets(id) ON DELETE CASCADE,
    user_address VARCHAR(56) NOT NULL,
    balance DECIMAL(38,0) NOT NULL DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (asset_id, user_address)
);

-- Asset transfers
CREATE TABLE asset_transfers (
    id SERIAL PRIMARY KEY,
    asset_id INTEGER REFERENCES rwa_assets(id) ON DELETE CASCADE,
    from_address VARCHAR(56) NOT NULL,
    to_address VARCHAR(56) NOT NULL,
    amount DECIMAL(38,0) NOT NULL,
    gas_used INTEGER,
    transaction_hash VARCHAR(64),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Asset valuations
CREATE TABLE asset_valuations (
    id SERIAL PRIMARY KEY,
    asset_id INTEGER REFERENCES rwa_assets(id) ON DELETE CASCADE,
    old_value DECIMAL(38,0),
    new_value DECIMAL(38,0) NOT NULL,
    oracle_address VARCHAR(56),
    confidence INTEGER,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Asset logs for audit trail
CREATE TABLE asset_logs (
    id SERIAL PRIMARY KEY,
    asset_id INTEGER REFERENCES rwa_assets(id) ON DELETE CASCADE,
    action VARCHAR(50) NOT NULL,
    performed_by VARCHAR(56),
    details JSONB,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users table
CREATE TABLE users (
    address VARCHAR(56) PRIMARY KEY,
    email VARCHAR(255),
    kyc_status VARCHAR(20) DEFAULT 'pending',
    compliance_score INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Batch operations
CREATE TABLE batch_operations (
    id SERIAL PRIMARY KEY,
    operation_count INTEGER NOT NULL,
    successful_operations INTEGER NOT NULL,
    gas_saved INTEGER,
    executor_address VARCHAR(56),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Gas metrics
CREATE TABLE gas_metrics (
    id SERIAL PRIMARY KEY,
    total_operations INTEGER DEFAULT 0,
    total_gas_saved INTEGER DEFAULT 0,
    batch_efficiency INTEGER DEFAULT 0,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_assets_type ON rwa_assets(asset_type);
CREATE INDEX idx_assets_owner ON rwa_assets(owner);
CREATE INDEX idx_assets_created ON rwa_assets(created_at);
CREATE INDEX idx_balances_user ON asset_balances(user_address);
CREATE INDEX idx_transfers_asset ON asset_transfers(asset_id);
CREATE INDEX idx_transfers_timestamp ON asset_transfers(timestamp);
CREATE INDEX idx_logs_asset ON asset_logs(asset_id);
CREATE INDEX idx_logs_timestamp ON asset_logs(timestamp);

-- Triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_rwa_assets_updated_at BEFORE UPDATE ON rwa_assets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_asset_balances_updated_at BEFORE UPDATE ON asset_balances
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
