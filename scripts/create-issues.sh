#!/bin/bash

# Script to create GitHub issues for StrataVault
echo "🐛 Creating GitHub Issues for StrataVault"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed. Please install it first:"
    echo "   https://cli.github.com/manual/installation"
    exit 1
fi

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a git repository. Please run from StrataVault root."
    exit 1
fi

echo "✅ GitHub CLI found. Creating issues..."

# Backend Issues
echo "📡 Creating Backend Issues..."

# Issue 1: WebSocket Support
gh issue create \
  --title "🔄 Add WebSocket Support for Real-Time Asset Updates" \
  --body "Currently, the backend only supports REST API calls. Users need real-time updates for:
- Asset price changes
- Transaction confirmations  
- Batch operation status
- Gas optimization metrics

**Proposed Solution:**
- Implement WebSocket server using Socket.IO
- Add real-time event broadcasting
- Create client-side connection management
- Add authentication for WebSocket connections

**Acceptance Criteria:**
- [ ] WebSocket server integrated with Express
- [ ] Real-time asset price updates
- [ ] Transaction status notifications
- [ ] Connection authentication
- [ ] Error handling and reconnection logic

**Priority:** High
**Labels:** enhancement,backend,websocket,real-time" \
  --label "enhancement" \
  --label "backend" \
  --label "websocket" \
  --label "real-time" \
  --label "good first issue"

# Issue 2: Enhanced Error Handling
gh issue create \
  --title "🛡️ Improve Error Handling and Add Structured Logging" \
  --body "Current error handling is basic and logging could be more comprehensive for production debugging.

**Current Issues:**
- Generic error messages
- Limited context in logs
- No error categorization
- Missing performance metrics

**Proposed Solution:**
- Implement custom error classes
- Add structured logging with Winston
- Create error monitoring dashboard
- Add performance metrics tracking

**Acceptance Criteria:**
- [ ] Custom error types for different scenarios
- [ ] Structured logging with Winston
- [ ] Error correlation across requests
- [ ] Performance metrics collection
- [ ] Error rate monitoring

**Priority:** Medium
**Labels:** enhancement,backend,logging,monitoring" \
  --label "enhancement" \
  --label "backend" \
  --label "logging" \
  --label "monitoring"

# Issue 3: Database Optimization
gh issue create \
  --title "⚡ Optimize Database Connection Pool for High Load" \
  --body "Current database configuration may not handle high concurrent loads efficiently during peak usage.

**Current Issues:**
- Default connection pool settings
- No connection timeout handling
- Missing health checks
- No query performance monitoring

**Proposed Solution:**
- Optimize pool configuration for production
- Add connection health monitoring
- Implement query performance tracking
- Add circuit breaker pattern

**Acceptance Criteria:**
- [ ] Optimized pool configuration
- [ ] Connection health monitoring
- [ ] Query performance metrics
- [ ] Circuit breaker implementation
- [ ] Load testing results

**Priority:** Medium
**Labels:** performance,backend,database,optimization" \
  --label "performance" \
  --label "backend" \
  --label "database" \
  --label "optimization"

echo "🎨 Creating Frontend Issues..."

# Issue 4: Wallet Connection Management
gh issue create \
  --title "🔐 Enhance Wallet Connection and Multi-Wallet Support" \
  --body "Current wallet connection is basic and only supports single wallet connection. Users need better wallet management.

**Current Issues:**
- Only Freighter wallet supported
- No wallet switching capability
- Connection state not persistent
- No wallet balance auto-refresh

**Proposed Solution:**
- Add multi-wallet support (Freighter, Albedo, Ledger)
- Implement wallet connection persistence
- Add automatic balance refresh
- Create wallet connection UI component

**Acceptance Criteria:**
- [ ] Support for 3+ wallet types
- [ ] Wallet switching functionality
- [ ] Persistent connection state
- [ ] Auto-refresh balances
- [ ] Connection error handling
- [ ] Wallet disconnect functionality

**Priority:** High
**Labels:** enhancement,frontend,wallet,ux" \
  --label "enhancement" \
  --label "frontend" \
  --label "wallet" \
  --label "ux" \
  --label "good first issue"

# Issue 5: Mobile Responsiveness
gh issue create \
  --title "📱 Improve Mobile Experience and Add PWA Support" \
  --body "Current frontend is not fully optimized for mobile devices and lacks PWA capabilities.

**Current Issues:**
- Poor mobile navigation
- No offline functionality
- Missing PWA manifest
- Slow loading on mobile networks

**Proposed Solution:**
- Implement responsive design improvements
- Add PWA manifest and service worker
- Optimize for mobile performance
- Add mobile-specific features

**Acceptance Criteria:**
- [ ] Fully responsive design
- [ ] PWA manifest implementation
- [ ] Service worker for offline support
- [ ] Mobile-optimized navigation
- [ ] Touch-friendly interactions
- [ ] App install prompt

**Priority:** High
**Labels:** enhancement,frontend,mobile,pwa" \
  --label "enhancement" \
  --label "frontend" \
  --label "mobile" \
  --label "pwa"

# Issue 6: Advanced Analytics
gh issue create \
  --title "📊 Add Advanced Analytics and Reporting Features" \
  --body "Current dashboard shows basic metrics. Users need more detailed analytics and reporting capabilities.

**Current Limitations:**
- Basic charts only
- No custom date ranges
- Missing export functionality
- No comparative analysis

**Proposed Solution:**
- Add advanced chart types
- Implement custom date range selection
- Add data export features
- Create comparative analysis tools
- Add predictive analytics

**Acceptance Criteria:**
- [ ] Multiple chart types (candlestick, pie, heatmap)
- [ ] Custom date range picker
- [ ] Export to CSV/PDF functionality
- [ ] Comparative analysis tools
- [ ] Gas optimization predictions
- [ ] Portfolio performance metrics

**Priority:** Medium
**Labels:** enhancement,frontend,analytics,reporting" \
  --label "enhancement" \
  --label "frontend" \
  --label "analytics" \
  --label "reporting"

echo ""
echo "🎉 Successfully created 6 GitHub issues!"
echo "📊 Summary:"
echo "   Backend Issues: 3 (WebSocket, Error Handling, Database)"
echo "   Frontend Issues: 3 (Wallet, Mobile, Analytics)"
echo ""
echo "🔗 View issues at: https://github.com/akordavid373/StrataVault/issues"
echo ""
echo "📝 Issues are ready for community contribution and development planning!"
