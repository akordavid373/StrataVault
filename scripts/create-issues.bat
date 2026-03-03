@echo off
REM Script to create GitHub issues for StrataVault (Windows)
echo 🐛 Creating GitHub Issues for StrataVault

REM Check if gh CLI is installed
where gh >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ GitHub CLI (gh) is not installed. Please install it first:
    echo    https://cli.github.com/manual/installation
    pause
    exit /b 1
)

REM Check if we're in a git repo
git rev-parse --git-dir >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Not in a git repository. Please run from StrataVault root.
    pause
    exit /b 1
)

echo ✅ GitHub CLI found. Creating issues...

REM Backend Issues
echo 📡 Creating Backend Issues...

REM Issue 1: WebSocket Support
gh issue create --title "🔄 Add WebSocket Support for Real-Time Asset Updates" --body "Currently, the backend only supports REST API calls. Users need real-time updates for asset price changes, transaction confirmations, batch operation status, and gas optimization metrics.

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

**Priority:** High" --label "enhancement" --label "backend" --label "websocket" --label "real-time" --label "good first issue"

REM Issue 2: Enhanced Error Handling
gh issue create --title "🛡️ Improve Error Handling and Add Structured Logging" --body "Current error handling is basic and logging could be more comprehensive for production debugging.

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

**Priority:** Medium" --label "enhancement" --label "backend" --label "logging" --label "monitoring"

echo 🎨 Creating Frontend Issues...

REM Issue 3: Wallet Connection Management
gh issue create --title "🔐 Enhance Wallet Connection and Multi-Wallet Support" --body "Current wallet connection is basic and only supports single wallet connection. Users need better wallet management.

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

**Priority:** High" --label "enhancement" --label "frontend" --label "wallet" --label "ux" --label "good first issue"

REM Issue 4: Mobile Responsiveness
gh issue create --title "📱 Improve Mobile Experience and Add PWA Support" --body "Current frontend is not fully optimized for mobile devices and lacks PWA capabilities.

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

**Priority:** High" --label "enhancement" --label "frontend" --label "mobile" --label "pwa"

echo.
echo 🎉 Successfully created 4 GitHub issues!
echo 📊 Summary:
echo    Backend Issues: 2 (WebSocket, Error Handling)
echo    Frontend Issues: 2 (Wallet, Mobile)
echo.
echo 🔗 View issues at: https://github.com/akordavid373/StrataVault/issues
echo.
echo 📝 Issues are ready for community contribution and development planning!
pause
