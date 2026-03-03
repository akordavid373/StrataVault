import React, { useState, useEffect } from 'react';
import { TrendingUp, Database, Zap, Shield, DollarSign, Activity } from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar } from 'recharts';

export const Dashboard: React.FC = () => {
  const [metrics, setMetrics] = useState({
    totalAssets: 0,
    totalValue: 0,
    gasSaved: 0,
    efficiency: 0,
    activeUsers: 0,
    transactions: 0
  });

  const [chartData, setChartData] = useState([
    { name: 'Mon', gas: 4000, transactions: 24 },
    { name: 'Tue', gas: 3000, transactions: 18 },
    { name: 'Wed', gas: 5000, transactions: 29 },
    { name: 'Thu', gas: 2780, transactions: 15 },
    { name: 'Fri', gas: 6890, transactions: 38 },
    { name: 'Sat', gas: 4390, transactions: 25 },
    { name: 'Sun', gas: 3490, transactions: 20 },
  ]);

  useEffect(() => {
    // Simulate fetching dashboard data
    setMetrics({
      totalAssets: 12,
      totalValue: 2847500,
      gasSaved: 847302,
      efficiency: 75,
      activeUsers: 234,
      transactions: 1847
    });
  }, []);

  const StatCard = ({ icon: Icon, title, value, change, color }: any) => (
    <div className="bg-white rounded-xl shadow-md p-6 border border-gray-200">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm font-medium text-gray-600">{title}</p>
          <p className="text-2xl font-bold text-gray-900 mt-1">{value}</p>
          {change && (
            <p className={`text-sm mt-1 ${change >= 0 ? 'text-green-600' : 'text-red-600'}`}>
              {change >= 0 ? '+' : ''}{change}%
            </p>
          )}
        </div>
        <div className={`p-3 rounded-lg ${color}`}>
          <Icon className="h-6 w-6 text-white" />
        </div>
      </div>
    </div>
  );

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">StrataVault Dashboard</h1>
        <p className="text-gray-600 mt-1">Monitor your gas-optimized real-world asset vault</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <StatCard
          icon={Database}
          title="Total Assets"
          value={metrics.totalAssets}
          change={12}
          color="bg-blue-500"
        />
        <StatCard
          icon={DollarSign}
          title="Total Value (USD)"
          value={`$${(metrics.totalValue / 1000000).toFixed(1)}M`}
          change={8}
          color="bg-green-500"
        />
        <StatCard
          icon={Zap}
          title="Gas Saved"
          value={metrics.gasSaved.toLocaleString()}
          change={25}
          color="bg-yellow-500"
        />
        <StatCard
          icon={TrendingUp}
          title="Efficiency"
          value={`${metrics.efficiency}%`}
          change={5}
          color="bg-purple-500"
        />
        <StatCard
          icon={Activity}
          title="Active Users"
          value={metrics.activeUsers}
          change={15}
          color="bg-indigo-500"
        />
        <StatCard
          icon={Shield}
          title="Transactions"
          value={metrics.transactions.toLocaleString()}
          change={18}
          color="bg-red-500"
        />
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-xl shadow-md p-6 border border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Gas Optimization Trend</h3>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Line type="monotone" dataKey="gas" stroke="#3B82F6" strokeWidth={2} />
            </LineChart>
          </ResponsiveContainer>
        </div>

        <div className="bg-white rounded-xl shadow-md p-6 border border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Transaction Volume</h3>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="transactions" fill="#10B981" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Recent Activity */}
      <div className="bg-white rounded-xl shadow-md p-6 border border-gray-200">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Activity</h3>
        <div className="space-y-3">
          {[
            { asset: 'Real Estate Token #1', action: 'Batch Transfer', amount: '10,000', gas: 'Saved 45%' },
            { asset: 'Bond Token #3', action: 'Mint', amount: '50,000', gas: 'Saved 38%' },
            { asset: 'Commodity Token #2', action: 'Burn', amount: '5,000', gas: 'Saved 52%' },
            { asset: 'Real Estate Token #1', action: 'Transfer', amount: '25,000', gas: 'Saved 41%' },
          ].map((activity, index) => (
            <div key={index} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
              <div>
                <p className="font-medium text-gray-900">{activity.asset}</p>
                <p className="text-sm text-gray-600">{activity.action}</p>
              </div>
              <div className="text-right">
                <p className="font-medium text-gray-900">${activity.amount}</p>
                <p className="text-sm text-green-600">{activity.gas}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
