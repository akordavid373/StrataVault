#![no_std]
use soroban_sdk::{contract, contractimpl, contracttype, Address, Env, Map, Vec, String, Symbol, BytesN};

// Data structures for RWA Vault
#[contracttype]
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct RWAAsset {
    pub id: u64,
    pub name: String,
    pub symbol: String,
    pub total_supply: u128,
    pub owner: Address,
    pub metadata_hash: BytesN<32>,
    pub compliance_level: u8, // 0-5 compliance levels
    pub is_active: bool,
}

#[contracttype]
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct BatchOperation {
    pub operations: Vec<BatchOp>,
    pub timestamp: u64,
    pub executor: Address,
}

#[contracttype]
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct BatchOp {
    pub op_type: u8, // 0=transfer, 1=mint, 2=burn
    pub asset_id: u64,
    pub from: Address,
    pub to: Address,
    pub amount: u128,
}

#[contracttype]
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct GasMetrics {
    pub total_operations: u64,
    pub gas_saved: u64,
    pub batch_efficiency: u32, // percentage
}

// Contract storage keys
const ADMIN: Symbol = Symbol::short("ADMIN");
const ASSETS: Symbol = Symbol::short("ASSETS");
const ASSET_COUNTER: Symbol = Symbol::short("ASSET_CTR");
const USER_BALANCES: Symbol = Symbol::short("BALANCES");
const BATCH_OPERATIONS: Symbol = Symbol::short("BATCH_OPS");
const GAS_METRICS: Symbol = Symbol::short("GAS_METRICS");
const COMPLIANCE_REGISTRY: Symbol = Symbol::short("COMPLIANCE");

#[contract]
pub struct StrataVault;

#[contractimpl]
impl StrataVault {
    /// Initialize vault with admin address
    pub fn initialize(env: Env, admin: Address) {
        if env.storage().instance().has(&ADMIN) {
            panic!("already initialized");
        }
        
        admin.require_auth();
        env.storage().instance().set(&ADMIN, &admin);
        env.storage().instance().set(&ASSET_COUNTER, &0u64);
        env.storage().instance().set(&GAS_METRICS, &GasMetrics {
            total_operations: 0,
            gas_saved: 0,
            batch_efficiency: 0,
        });
    }

    /// Create a new RWA asset (gas optimized)
    pub fn create_asset(
        env: Env,
        name: String,
        symbol: String,
        initial_supply: u128,
        metadata_hash: BytesN<32>,
        compliance_level: u8,
    ) -> u64 {
        let admin = Self::get_admin(env.clone());
        admin.require_auth();

        let asset_id = Self::get_next_asset_id(env.clone());
        
        let asset = RWAAsset {
            id: asset_id,
            name: name.clone(),
            symbol: symbol.clone(),
            total_supply: initial_supply,
            owner: admin,
            metadata_hash,
            compliance_level,
            is_active: true,
        };

        // Store asset in compressed format
        let mut assets = env.storage().instance().get(&ASSETS).unwrap_or(Map::new(&env));
        assets.set(asset_id, asset);
        env.storage().instance().set(&ASSETS, &assets);

        // Mint initial supply to admin
        if initial_supply > 0 {
            Self::mint_internal(env.clone(), asset_id, admin, initial_supply);
        }

        env.events().publish(
            (Symbol::short("ASSET_CREATED"), asset_id),
            (name, symbol, initial_supply),
        );

        asset_id
    }

    /// Batch process multiple operations (major gas optimization)
    pub fn batch_operations(env: Env, operations: Vec<BatchOp>) -> u64 {
        let caller = env.current_contract_address();
        
        // Calculate gas savings before processing
        let individual_gas_cost = operations.len() as u64 * 10000; // estimated
        let batch_gas_cost = 5000; // estimated batch cost
        let gas_saved = individual_gas_cost.saturating_sub(batch_gas_cost);

        let mut successful_ops = 0u64;
        
        for op in operations.iter() {
            let success = match op.op_type {
                0 => Self::transfer_internal(env.clone(), op.asset_id, op.from, op.to, op.amount),
                1 => Self::mint_internal(env.clone(), op.asset_id, op.to, op.amount),
                2 => Self::burn_internal(env.clone(), op.asset_id, op.from, op.amount),
                _ => false,
            };
            
            if success {
                successful_ops += 1;
            }
        }

        // Update gas metrics
        let mut metrics = Self::get_gas_metrics(env.clone());
        metrics.total_operations += successful_ops;
        metrics.gas_saved += gas_saved;
        metrics.batch_efficiency = ((successful_ops as u32 * 100) / operations.len() as u32).min(100);
        env.storage().instance().set(&GAS_METRICS, &metrics);

        env.events().publish(
            Symbol::short("BATCH_PROCESSED"),
            (successful_ops, gas_saved),
        );

        successful_ops
    }

    /// Transfer RWA tokens (gas optimized)
    pub fn transfer(env: Env, asset_id: u64, to: Address, amount: u128) {
        let from = env.current_contract_address();
        Self::transfer_internal(env, asset_id, from, to, amount);
    }

    /// Mint new RWA tokens
    pub fn mint(env: Env, asset_id: u64, to: Address, amount: u128) {
        let admin = Self::get_admin(env.clone());
        admin.require_auth();
        Self::mint_internal(env, asset_id, to, amount);
    }

    /// Burn RWA tokens
    pub fn burn(env: Env, asset_id: u64, from: Address, amount: u128) {
        from.require_auth();
        Self::burn_internal(env, asset_id, from, amount);
    }

    /// Get asset information
    pub fn get_asset(env: Env, asset_id: u64) -> Option<RWAAsset> {
        let assets = env.storage().instance().get(&ASSETS).unwrap_or(Map::new(&env));
        assets.get(asset_id)
    }

    /// Get user balance
    pub fn get_balance(env: Env, asset_id: u64, user: Address) -> u128 {
        let key = (asset_id, user);
        env.storage().instance().get(&key).unwrap_or(0u128)
    }

    /// Get gas optimization metrics
    pub fn get_gas_metrics(env: Env) -> GasMetrics {
        env.storage().instance().get(&GAS_METRICS).unwrap_or(GasMetrics {
            total_operations: 0,
            gas_saved: 0,
            batch_efficiency: 0,
        })
    }

    /// Get all assets for a user (gas optimized)
    pub fn get_user_assets(env: Env, user: Address) -> Vec<u64> {
        let assets = env.storage().instance().get(&ASSETS).unwrap_or(Map::new(&env));
        let mut user_assets = Vec::new(&env);
        
        for (asset_id, _) in assets.iter() {
            let balance = Self::get_balance(env.clone(), asset_id, user);
            if balance > 0 {
                user_assets.push_back(asset_id);
            }
        }
        
        user_assets
    }

    // Internal helper functions
    fn get_admin(env: Env) -> Address {
        env.storage().instance().get(&ADMIN).unwrap()
    }

    fn get_next_asset_id(env: Env) -> u64 {
        let counter = env.storage().instance().get(&ASSET_COUNTER).unwrap_or(0u64);
        env.storage().instance().set(&ASSET_COUNTER, &(counter + 1));
        counter + 1
    }

    fn get_gas_metrics(env: Env) -> GasMetrics {
        env.storage().instance().get(&GAS_METRICS).unwrap_or(GasMetrics {
            total_operations: 0,
            gas_saved: 0,
            batch_efficiency: 0,
        })
    }

    fn transfer_internal(env: Env, asset_id: u64, from: Address, to: Address, amount: u128) -> bool {
        if amount == 0 {
            return false;
        }

        let from_balance = Self::get_balance(env.clone(), asset_id, from);
        if from_balance < amount {
            return false;
        }

        // Update balances
        let from_key = (asset_id, from);
        let to_key = (asset_id, to);
        
        env.storage().instance().set(&from_key, &(from_balance - amount));
        let to_balance = Self::get_balance(env.clone(), asset_id, to);
        env.storage().instance().set(&to_key, &(to_balance + amount));

        env.events().publish(
            (Symbol::short("TRANSFER"), asset_id),
            (from, to, amount),
        );

        true
    }

    fn mint_internal(env: Env, asset_id: u64, to: Address, amount: u128) -> bool {
        if amount == 0 {
            return false;
        }

        // Update asset total supply
        let mut assets = env.storage().instance().get(&ASSETS).unwrap_or(Map::new(&env));
        if let Some(mut asset) = assets.get(asset_id) {
            asset.total_supply += amount;
            assets.set(asset_id, asset);
            env.storage().instance().set(&ASSETS, &assets);
        } else {
            return false;
        }

        // Update user balance
        let key = (asset_id, to);
        let current_balance = Self::get_balance(env.clone(), asset_id, to);
        env.storage().instance().set(&key, &(current_balance + amount));

        env.events().publish(
            (Symbol::short("MINT"), asset_id),
            (to, amount),
        );

        true
    }

    fn burn_internal(env: Env, asset_id: u64, from: Address, amount: u128) -> bool {
        if amount == 0 {
            return false;
        }

        let from_balance = Self::get_balance(env.clone(), asset_id, from);
        if from_balance < amount {
            return false;
        }

        // Update asset total supply
        let mut assets = env.storage().instance().get(&ASSETS).unwrap_or(Map::new(&env));
        if let Some(mut asset) = assets.get(asset_id) {
            if asset.total_supply < amount {
                return false;
            }
            asset.total_supply -= amount;
            assets.set(asset_id, asset);
            env.storage().instance().set(&ASSETS, &assets);
        } else {
            return false;
        }

        // Update user balance
        let key = (asset_id, from);
        env.storage().instance().set(&key, &(from_balance - amount));

        env.events().publish(
            (Symbol::short("BURN"), asset_id),
            (from, amount),
        );

        true
    }
}
