const express = require('express');
const router = express.Router();
const Joi = require('joi');
const { Pool } = require('pg');
const StellarSdk = require('stellar-sdk');

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// Stellar connection
const server = new StellarSdk.SorobanRpc.Server(
  process.env.STELLAR_RPC_URL || 'https://soroban-testnet.stellar.org'
);

// Validation schemas
const createAssetSchema = Joi.object({
  name: Joi.string().required().min(1).max(100),
  symbol: Joi.string().required().min(1).max(10),
  initialSupply: Joi.number().required().min(0),
  metadataHash: Joi.string().required().hex().length(64),
  complianceLevel: Joi.number().required().min(0).max(5),
  assetType: Joi.string().required().valid('RealEstate', 'Bonds', 'Commodities', 'IP', 'SupplyChain'),
});

const batchOperationSchema = Joi.object({
  operations: Joi.array().items(
    Joi.object({
      opType: Joi.number().required().valid(0, 1, 2), // 0=transfer, 1=mint, 2=burn
      assetId: Joi.number().required(),
      from: Joi.string().required(),
      to: Joi.string().required(),
      amount: Joi.number().required().min(0),
    })
  ).required(),
});

// Get all assets
router.get('/', async (req, res) => {
  try {
    const { page = 1, limit = 10, type, verified } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT id, name, symbol, total_supply, owner, metadata_hash, 
             compliance_level, is_active, created_at, updated_at
      FROM rwa_assets
      WHERE 1=1
    `;
    const params = [];

    if (type) {
      query += ` AND asset_type = $${params.length + 1}`;
      params.push(type);
    }

    if (verified !== undefined) {
      query += ` AND is_verified = $${params.length + 1}`;
      params.push(verified === 'true');
    }

    query += ` ORDER BY created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    // Get total count
    const countQuery = query.split('ORDER BY')[0].replace('SELECT id, name, symbol, total_supply, owner, metadata_hash, compliance_level, is_active, created_at, updated_at', 'SELECT COUNT(*)');
    const countResult = await pool.query(countQuery, params.slice(0, -2));

    res.json({
      assets: result.rows,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: parseInt(countResult.rows[0].count),
        pages: Math.ceil(countResult.rows[0].count / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching assets:', error);
    res.status(500).json({ error: 'Failed to fetch assets' });
  }
});

// Get asset by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await pool.query(
      `SELECT a.*, 
              (SELECT COUNT(*) FROM asset_balances WHERE asset_id = a.id) as holder_count
       FROM rwa_assets a 
       WHERE a.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Asset not found' });
    }

    // Get asset valuation history
    const valuationResult = await pool.query(
      `SELECT * FROM asset_valuations 
       WHERE asset_id = $1 
       ORDER BY timestamp DESC 
       LIMIT 10`,
      [id]
    );

    const asset = {
      ...result.rows[0],
      valuation_history: valuationResult.rows
    };

    res.json(asset);
  } catch (error) {
    console.error('Error fetching asset:', error);
    res.status(500).json({ error: 'Failed to fetch asset' });
  }
});

// Create new asset
router.post('/', async (req, res) => {
  try {
    const { error, value } = createAssetSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ 
        error: 'Validation Error', 
        details: error.details 
      });
    }

    const { name, symbol, initialSupply, metadataHash, complianceLevel, assetType } = value;

    // Insert asset into database
    const result = await pool.query(
      `INSERT INTO rwa_assets 
       (name, symbol, total_supply, metadata_hash, compliance_level, asset_type, owner, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())
       RETURNING *`,
      [name, symbol, initialSupply, metadataHash, complianceLevel, assetType, req.user?.address || 'system']
    );

    // Log the asset creation
    await pool.query(
      `INSERT INTO asset_logs 
       (asset_id, action, performed_by, timestamp, details)
       VALUES ($1, $2, $3, NOW(), $4)`,
      [result.rows[0].id, 'CREATED', req.user?.address || 'system', JSON.stringify(value)]
    );

    res.status(201).json({
      message: 'Asset created successfully',
      asset: result.rows[0]
    });
  } catch (error) {
    console.error('Error creating asset:', error);
    res.status(500).json({ error: 'Failed to create asset' });
  }
});

// Batch operations
router.post('/batch', async (req, res) => {
  try {
    const { error, value } = batchOperationSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ 
        error: 'Validation Error', 
        details: error.details 
      });
    }

    const { operations } = value;
    const results = [];

    // Start transaction
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      for (const op of operations) {
        let result;
        
        switch (op.opType) {
          case 0: // Transfer
            result = await handleTransfer(client, op);
            break;
          case 1: // Mint
            result = await handleMint(client, op);
            break;
          case 2: // Burn
            result = await handleBurn(client, op);
            break;
          default:
            result = { success: false, error: 'Invalid operation type' };
        }
        
        results.push(result);
      }

      await client.query('COMMIT');

      // Calculate gas savings
      const individualCost = operations.length * 10000;
      const batchCost = 5000;
      const gasSaved = individualCost - batchCost;

      res.json({
        message: 'Batch operations completed',
        results,
        gasSaved,
        successCount: results.filter(r => r.success).length,
        totalCount: operations.length
      });

    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Error processing batch operations:', error);
    res.status(500).json({ error: 'Failed to process batch operations' });
  }
});

// Helper functions
async function handleTransfer(client, operation) {
  try {
    // Check sender balance
    const balanceResult = await client.query(
      'SELECT balance FROM asset_balances WHERE asset_id = $1 AND user_address = $2',
      [operation.assetId, operation.from]
    );

    if (balanceResult.rows.length === 0 || balanceResult.rows[0].balance < operation.amount) {
      return { success: false, error: 'Insufficient balance' };
    }

    // Update balances
    await client.query(
      'UPDATE asset_balances SET balance = balance - $1 WHERE asset_id = $2 AND user_address = $3',
      [operation.amount, operation.assetId, operation.from]
    );

    await client.query(
      `INSERT INTO asset_balances (asset_id, user_address, balance, updated_at)
       VALUES ($1, $2, $3, NOW())
       ON CONFLICT (asset_id, user_address) 
       DO UPDATE SET balance = asset_balances.balance + $3, updated_at = NOW()`,
      [operation.assetId, operation.to, operation.amount]
    );

    // Log transfer
    await client.query(
      `INSERT INTO asset_transfers 
       (asset_id, from_address, to_address, amount, timestamp, gas_used)
       VALUES ($1, $2, $3, $4, NOW(), $5)`,
      [operation.assetId, operation.from, operation.to, operation.amount, 5000]
    );

    return { success: true, operation: 'transfer' };
  } catch (error) {
    return { success: false, error: error.message, operation: 'transfer' };
  }
}

async function handleMint(client, operation) {
  try {
    // Update total supply
    await client.query(
      'UPDATE rwa_assets SET total_supply = total_supply + $1, updated_at = NOW() WHERE id = $2',
      [operation.amount, operation.assetId]
    );

    // Add to user balance
    await client.query(
      `INSERT INTO asset_balances (asset_id, user_address, balance, updated_at)
       VALUES ($1, $2, $3, NOW())
       ON CONFLICT (asset_id, user_address) 
       DO UPDATE SET balance = asset_balances.balance + $3, updated_at = NOW()`,
      [operation.assetId, operation.to, operation.amount]
    );

    // Log mint
    await client.query(
      `INSERT INTO asset_logs 
       (asset_id, action, performed_by, timestamp, details)
       VALUES ($1, $2, $3, NOW(), $4)`,
      [operation.assetId, 'MINT', operation.to, JSON.stringify(operation)]
    );

    return { success: true, operation: 'mint' };
  } catch (error) {
    return { success: false, error: error.message, operation: 'mint' };
  }
}

async function handleBurn(client, operation) {
  try {
    // Check user balance
    const balanceResult = await client.query(
      'SELECT balance FROM asset_balances WHERE asset_id = $1 AND user_address = $2',
      [operation.assetId, operation.from]
    );

    if (balanceResult.rows.length === 0 || balanceResult.rows[0].balance < operation.amount) {
      return { success: false, error: 'Insufficient balance' };
    }

    // Update total supply
    await client.query(
      'UPDATE rwa_assets SET total_supply = total_supply - $1, updated_at = NOW() WHERE id = $2',
      [operation.amount, operation.assetId]
    );

    // Update user balance
    await client.query(
      'UPDATE asset_balances SET balance = balance - $1 WHERE asset_id = $2 AND user_address = $3',
      [operation.amount, operation.assetId, operation.from]
    );

    // Log burn
    await client.query(
      `INSERT INTO asset_logs 
       (asset_id, action, performed_by, timestamp, details)
       VALUES ($1, $2, $3, NOW(), $4)`,
      [operation.assetId, 'BURN', operation.from, JSON.stringify(operation)]
    );

    return { success: true, operation: 'burn' };
  } catch (error) {
    return { success: false, error: error.message, operation: 'burn' };
  }
}

module.exports = router;
