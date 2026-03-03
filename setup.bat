@echo off
REM StrataVault Quick Setup Script for Windows
echo 🚀 Setting up StrataVault - RWA Vault Management System

REM Check prerequisites
echo 📋 Checking prerequisites...

REM Check if Node.js is installed
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Node.js is not installed. Please install Node.js 16+ first.
    pause
    exit /b 1
)

REM Check if Rust is installed
where cargo >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Rust is not installed. Please install Rust first.
    pause
    exit /b 1
)

REM Check if PostgreSQL is installed
where psql >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ PostgreSQL is not installed. Please install PostgreSQL first.
    pause
    exit /b 1
)

echo ✅ All prerequisites are installed!

REM Setup backend
echo 🔧 Setting up backend...
cd backend
call npm install

REM Create environment file
if not exist .env (
    copy .env.example .env
    echo 📝 Created .env file. Please update with your configuration.
)

REM Setup frontend
echo 🎨 Setting up frontend...
cd ..\frontend
call npm install

REM Create environment file
if not exist .env (
    copy .env.example .env
    echo 📝 Created frontend .env file. Please update with your configuration.
)

REM Setup contracts
echo 📜 Setting up smart contracts...
cd ..\contracts
cargo build

echo.
echo 🎉 StrataVault setup complete!
echo.
echo 📖 Next steps:
echo 1. Configure your database connection in backend\.env
echo 2. Update Stellar network configuration
echo 3. Run database schema: psql -d stratavault -f docs\database-schema.sql
echo 4. Start backend: cd backend && npm run dev
echo 5. Start frontend: cd frontend && npm start
echo.
echo 🌐 Access the application at: http://localhost:3000
echo 🔗 Backend API at: http://localhost:3001
echo.
echo 📚 For more information, check the README.md file
pause
