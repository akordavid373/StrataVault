import React from 'react';
import { Link } from 'react-router-dom';
import { Wallet, TrendingUp, Database, BarChart3, Shield } from 'lucide-react';

interface NavbarProps {
  isConnected: boolean;
  walletAddress: string;
}

export const Navbar: React.FC<NavbarProps> = ({ isConnected, walletAddress }) => {
  return (
    <nav className="bg-white shadow-lg border-b border-gray-200">
      <div className="container mx-auto px-4">
        <div className="flex justify-between items-center py-4">
          <div className="flex items-center space-x-8">
            <Link to="/" className="flex items-center space-x-2">
              <Database className="h-8 w-8 text-blue-600" />
              <span className="text-xl font-bold text-gray-900">
                StrataVault
              </span>
            </Link>
            
            <div className="hidden md:flex space-x-6">
              <Link
                to="/"
                className="flex items-center space-x-1 text-gray-700 hover:text-blue-600 transition-colors"
              >
                <TrendingUp className="h-4 w-4" />
                <span>Dashboard</span>
              </Link>
              <Link
                to="/vault"
                className="flex items-center space-x-1 text-gray-700 hover:text-blue-600 transition-colors"
              >
                <Database className="h-4 w-4" />
                <span>Vault</span>
              </Link>
              <Link
                to="/assets"
                className="flex items-center space-x-1 text-gray-700 hover:text-blue-600 transition-colors"
              >
                <Shield className="h-4 w-4" />
                <span>Assets</span>
              </Link>
              <Link
                to="/analytics"
                className="flex items-center space-x-1 text-gray-700 hover:text-blue-600 transition-colors"
              >
                <BarChart3 className="h-4 w-4" />
                <span>Analytics</span>
              </Link>
            </div>
          </div>
          
          <div className="flex items-center space-x-4">
            {isConnected && (
              <div className="flex items-center space-x-2 bg-green-100 px-3 py-1 rounded-full">
                <div className="h-2 w-2 bg-green-500 rounded-full"></div>
                <span className="text-sm text-green-800">
                  {walletAddress.slice(0, 6)}...{walletAddress.slice(-4)}
                </span>
              </div>
            )}
            
            <button className="flex items-center space-x-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors">
              <Wallet className="h-4 w-4" />
              <span>{isConnected ? 'Connected' : 'Connect'}</span>
            </button>
          </div>
        </div>
      </div>
    </nav>
  );
};
