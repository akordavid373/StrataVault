#!/bin/bash

# StrataVault Quick Setup Script
echo "🚀 Setting up StrataVault - RWA Vault Management System"

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 16+ first."
    exit 1
fi

# Check if Rust is installed
if ! command -v cargo &> /dev/null; then
    echo "❌ Rust is not installed. Please install Rust first."
    exit 1
fi

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL is not installed. Please install PostgreSQL first."
    exit 1
fi

echo "✅ All prerequisites are installed!"

# Setup backend
echo "🔧 Setting up backend..."
cd backend
npm install

# Create environment file
if [ ! -f .env ]; then
    cp .env.example .env
    echo "📝 Created .env file. Please update with your configuration."
fi

# Setup frontend
echo "🎨 Setting up frontend..."
cd ../frontend
npm install

# Create environment file
if [ ! -f .env ]; then
    cp .env.example .env
    echo "📝 Created frontend .env file. Please update with your configuration."
fi

# Setup contracts
echo "📜 Setting up smart contracts..."
cd ../contracts
cargo build

# Database setup
echo "🗄️  Database setup..."
cd ../docs
echo "Please run the following SQL commands to set up your database:"
echo "1. createdb stratavault"
echo "2. psql -d stratavault -f database-schema.sql"

echo ""
echo "🎉 StrataVault setup complete!"
echo ""
echo "📖 Next steps:"
echo "1. Configure your database connection in backend/.env"
echo "2. Update Stellar network configuration"
echo "3. Run database schema: psql -d stratavault -f docs/database-schema.sql"
echo "4. Start backend: cd backend && npm run dev"
echo "5. Start frontend: cd frontend && npm start"
echo ""
echo "🌐 Access the application at: http://localhost:3000"
echo "🔗 Backend API at: http://localhost:3001"
echo ""
echo "📚 For more information, check the README.md file"
