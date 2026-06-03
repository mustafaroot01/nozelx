import React from 'react';
import { motion } from 'framer-motion';
import { 
  AreaChart, 
  Area, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer, 
  PieChart, 
  Pie, 
  Cell, 
  Legend 
} from 'recharts';

export default function ChartSection({ revenueData = [], categoryData = [] }) {
  // Premium Color palette for pie chart
  const COLORS = ['#5275ff', '#10b981', '#f59e0b', '#8b5cf6', '#ec4899'];

  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
      {/* Area Chart: Revenue Trend */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4, delay: 0.1 }}
        className="lg:col-span-2 p-6 bg-white dark:bg-dark-900 border border-gray-100 dark:border-dark-800 rounded-3xl shadow-premium"
      >
        <div className="flex justify-between items-center mb-6">
          <div>
            <h3 className="font-extrabold text-lg text-gray-800 dark:text-dark-100">المبيعات والإيرادات</h3>
            <p className="text-xs text-gray-400">معدل الإيرادات الشهرية المحصلة من عمليات الشراء المكتملة</p>
          </div>
        </div>

        <div className="h-80 w-full">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={revenueData} margin={{ top: 10, left: -20, right: 10, bottom: 0 }}>
              <defs>
                <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#5275ff" stopOpacity={0.4}/>
                  <stop offset="95%" stopColor="#5275ff" stopOpacity={0}/>
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="rgba(0,0,0,0.03)" />
              <XAxis 
                dataKey="month" 
                tickLine={false} 
                axisLine={false}
                tick={{ fontSize: 11, fill: '#9097aa', fontFamily: 'Cairo' }}
              />
              <YAxis 
                tickLine={false} 
                axisLine={false}
                tick={{ fontSize: 11, fill: '#9097aa' }}
              />
              <Tooltip formatter={(value) => [`${value.toLocaleString()} د.ع`, 'الإيرادات']} />
              <Area 
                type="monotone" 
                dataKey="revenue" 
                stroke="#5275ff" 
                strokeWidth={3}
                fillOpacity={1} 
                fill="url(#colorRevenue)" 
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      </motion.div>

      {/* Pie Chart: Product Distribution */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4, delay: 0.2 }}
        className="p-6 bg-white dark:bg-dark-900 border border-gray-100 dark:border-dark-800 rounded-3xl shadow-premium flex flex-col"
      >
        <div className="mb-6">
          <h3 className="font-extrabold text-lg text-gray-800 dark:text-dark-100">توزيع المنتجات</h3>
          <p className="text-xs text-gray-400">توزيع كميات ونسب المنتجات وفق التصنيف الأساسي</p>
        </div>

        <div className="h-60 w-full flex-1 flex items-center justify-center">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie
                data={categoryData}
                cx="50%"
                cy="50%"
                innerRadius={60}
                outerRadius={80}
                paddingAngle={5}
                dataKey="value"
                nameKey="category"
              >
                {categoryData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip formatter={(value) => [`${value} منتج`, 'العدد']} />
              <Legend 
                verticalAlign="bottom" 
                height={36} 
                iconType="circle"
                wrapperStyle={{ fontSize: '11px', fontFamily: 'Cairo', paddingTop: '10px' }}
              />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </motion.div>
    </div>
  );
}
