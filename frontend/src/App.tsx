import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Navbar } from './components/Navbar';
import { Dashboard } from './pages/Dashboard';
import { VaultManager } from './pages/VaultManager';
import { AssetManager } from './pages/AssetManager';
import { GasAnalytics } from './pages/GasAnalytics';
import { Compliance } from './pages/Compliance';
import { WalletConnect } from './components/WalletConnect';

function App() {
  const [isConnected, setIsConnected] = useState(false);
  const [walletAddress, setWalletAddress] = useState('');

  return (
    <Router>
      <div className="min-h-screen bg-gray-50">
        <Navbar 
          isConnected={isConnected}
          walletAddress={walletAddress}
        />
        
        <main className="container mx-auto px-4 py-8">
          {!isConnected ? (
            <WalletConnect 
              onConnect={(address) => {
                setIsConnected(true);
                setWalletAddress(address);
              }}
            />
          ) : (
            <Routes>
              <Route path="/" element={<Dashboard />} />
              <Route path="/vault" element={<VaultManager />} />
              <Route path="/assets" element={<AssetManager />} />
              <Route path="/analytics" element={<GasAnalytics />} />
              <Route path="/compliance" element={<Compliance />} />
            </Routes>
          )}
        </main>
      </div>
    </Router>
  );
}

export default App;
