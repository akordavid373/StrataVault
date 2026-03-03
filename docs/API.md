# API Documentation

## StrataVault Backend API

### Base URL
```
Development: http://localhost:3001/api
Production: https://api.stratavault.com/api
```

### Authentication
All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

## Endpoints

### Health Checks

#### GET /health
Check API health status.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "version": "0.1.0",
  "stellar": "connected"
}
```

#### GET /health/db
Check database connection status.

#### GET /health/stellar
Check Stellar network connection status.

### Assets

#### GET /api/assets
Get all RWA assets with pagination.

**Query Parameters:**
- `page` (number): Page number (default: 1)
- `limit` (number): Items per page (default: 10)
- `type` (string): Filter by asset type
- `verified` (boolean): Filter by verification status

**Response:**
```json
{
  "assets": [
    {
      "id": 1,
      "name": "Real Estate Token #1",
      "symbol": "RET1",
      "asset_type": "RealEstate",
      "total_supply": 1000000,
      "owner": "G...",
      "metadata_hash": "0x...",
      "compliance_level": 3,
      "is_verified": true,
      "is_active": true,
      "created_at": "2024-01-01T00:00:00.000Z",
      "holder_count": 25
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 50,
    "pages": 5
  }
}
```

#### GET /api/assets/:id
Get specific asset details including valuation history.

**Response:**
```json
{
  "id": 1,
  "name": "Real Estate Token #1",
  "symbol": "RET1",
  "asset_type": "RealEstate",
  "total_supply": 1000000,
  "owner": "G...",
  "metadata_hash": "0x...",
  "compliance_level": 3,
  "is_verified": true,
  "is_active": true,
  "created_at": "2024-01-01T00:00:00.000Z",
  "holder_count": 25,
  "valuation_history": [
    {
      "id": 1,
      "asset_id": 1,
      "old_value": 1000000,
      "new_value": 1050000,
      "oracle_address": "G...",
      "confidence": 95,
      "timestamp": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

#### POST /api/assets
Create a new RWA asset.

**Request Body:**
```json
{
  "name": "Real Estate Token #1",
  "symbol": "RET1",
  "initialSupply": 1000000,
  "metadataHash": "0x1234567890abcdef...",
  "complianceLevel": 3,
  "assetType": "RealEstate"
}
```

**Response:**
```json
{
  "message": "Asset created successfully",
  "asset": {
    "id": 1,
    "name": "Real Estate Token #1",
    "symbol": "RET1",
    "asset_type": "RealEstate",
    "total_supply": 1000000,
    "owner": "G...",
    "metadata_hash": "0x...",
    "compliance_level": 3,
    "is_verified": false,
    "is_active": true,
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

#### POST /api/assets/batch
Process multiple operations in a single batch for gas optimization.

**Request Body:**
```json
{
  "operations": [
    {
      "opType": 0,
      "assetId": 1,
      "from": "G...",
      "to": "G...",
      "amount": 1000
    },
    {
      "opType": 1,
      "assetId": 1,
      "to": "G...",
      "amount": 500
    }
  ]
}
```

**Response:**
```json
{
  "message": "Batch operations completed",
  "results": [
    {
      "success": true,
      "operation": "transfer"
    },
    {
      "success": true,
      "operation": "mint"
    }
  ],
  "gasSaved": 15000,
  "successCount": 2,
  "totalCount": 2
}
```

### Vault Management

#### GET /api/vault/metrics
Get gas optimization metrics.

#### GET /api/vault/balance/:assetId/:userAddress
Get user balance for specific asset.

#### POST /api/vault/transfer
Transfer tokens between addresses.

#### POST /api/vault/mint
Mint new tokens (admin only).

#### POST /api/vault/burn
Burn tokens.

### Analytics

#### GET /api/analytics/gas-usage
Get gas usage analytics and trends.

#### GET /api/analytics/transaction-volume
Get transaction volume data.

#### GET /api/analytics/asset-performance
Get asset performance metrics.

### Users

#### GET /api/users/profile
Get user profile information.

#### POST /api/users/register
Register new user.

#### POST /api/users/kyc
Submit KYC documentation.

## Error Responses

All endpoints return consistent error responses:

```json
{
  "error": "Error Type",
  "message": "Detailed error message",
  "details": "Additional error details (if available)"
}
```

### Common HTTP Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `404` - Not Found
- `429` - Rate Limited
- `500` - Internal Server Error

## Rate Limiting

API endpoints are rate-limited to prevent abuse:
- 100 requests per minute per IP
- 1000 requests per hour per authenticated user

## WebSocket Support

Real-time updates available via WebSocket connection:
```
ws://localhost:3001/ws
```

Events:
- `asset_created`
- `transfer_completed`
- `batch_processed`
- `valuation_updated`

## SDK Integration

### JavaScript/TypeScript
```javascript
import { StrataVaultAPI } from '@stratavault/sdk';

const api = new StrataVaultAPI({
  baseURL: 'http://localhost:3001/api',
  apiKey: 'your-api-key'
});

const assets = await api.assets.list();
const result = await api.assets.batchTransfer(operations);
```

### Python
```python
from stratavault import StrataVaultAPI

api = StrataVaultAPI(
    base_url='http://localhost:3001/api',
    api_key='your-api-key'
)

assets = api.assets.list()
result = api.assets.batch_transfer(operations)
```
