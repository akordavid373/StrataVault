# How to Create GitHub Issues for StrataVault

## Quick Method (Recommended)

1. **Get a GitHub Personal Access Token:**
   - Go to https://github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Select "repo" permissions
   - Copy the token

2. **Run the PowerShell Script:**
   ```powershell
   cd C:\Users\USER\CascadeProjects\StrataVault
   .\scripts\create-github-issues.ps1 -GitHubToken "YOUR_TOKEN_HERE"
   ```

## Manual Method (If Script Fails)

1. **Go to GitHub Issues:**
   - Visit: https://github.com/akordavid373/StrataVault/issues/new

2. **Create Each Issue Using These Files:**
   - Copy content from `.github/issues/001-websocket-support.md`
   - Paste as issue body
   - Use title: "🔄 Add WebSocket Support for Real-Time Asset Updates"
   - Add labels: enhancement, backend, websocket, real-time, good first issue

3. **Repeat for All 6 Issues:**
   - Issue files are located in `.github/issues/` folder
   - Each has detailed content ready to copy-paste

## Issues to Create

### Backend Issues (3)
1. **🔄 WebSocket Support** - High Priority
2. **🛡️ Error Handling** - Medium Priority  
3. **⚡ Database Optimization** - Medium Priority

### Frontend Issues (3)
4. **🔐 Wallet Management** - High Priority
5. **📱 Mobile PWA** - High Priority
6. **📊 Advanced Analytics** - Medium Priority

## Verification

After creating issues, visit:
https://github.com/akordavid373/StrataVault/issues

You should see 6 new issues with proper labels and descriptions.

## Troubleshooting

**If PowerShell script fails:**
- Make sure you have a valid GitHub token
- Check that the token has "repo" permissions
- Use the manual method above

**If you don't have a GitHub token:**
- Use the manual copy-paste method
- It's just as effective!
