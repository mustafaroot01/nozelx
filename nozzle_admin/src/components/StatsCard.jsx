import React from 'react';
import { motion } from 'framer-motion';
import { TrendingUp, TrendingDown } from 'lucide-react';

export default function StatsCard({ title, value, percentage, isPositive = true, icon: Icon, color = 'primary' }) {
  const colorMap = {
    primary: 'from-primary-500 to-indigo-500 text-primary-600 bg-primary-50 dark:bg-primary-950/20 dark:text-primary-400',
    green: 'from-emerald-500 to-teal-500 text-emerald-600 bg-emerald-50 dark:bg-emerald-950/20 dark:text-emerald-400',
    orange: 'from-orange-500 to-amber-500 text-orange-600 bg-orange-50 dark:bg-orange-950/20 dark:text-orange-400',
    purple: 'from-purple-500 to-pink-500 text-purple-600 bg-purple-50 dark:bg-purple-950/20 dark:text-purple-400',
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4 }}
      className="p-6 bg-white dark:bg-dark-900 border border-gray-100 dark:border-dark-800 rounded-3xl shadow-premium flex justify-between items-center relative overflow-hidden group hover:scale-[1.02] transition-transform duration-200"
    >
      <div className="space-y-3 z-10">
        <span className="text-sm text-gray-400 font-medium block">{title}</span>
        <h2 className="text-3xl font-extrabold text-gray-800 dark:text-dark-100 tracking-tight">
          {value}
        </h2>
        
        {percentage && (
          <div className="flex items-center gap-1.5">
            {isPositive ? (
              <span className="flex items-center gap-0.5 text-xs font-bold text-emerald-600 dark:text-emerald-400 bg-emerald-50 dark:bg-emerald-950/30 px-2 py-0.5 rounded-full">
                <TrendingUp size={12} />
                +{percentage}%
              </span>
            ) : (
              <span className="flex items-center gap-0.5 text-xs font-bold text-red-600 dark:text-red-400 bg-red-50 dark:bg-red-950/30 px-2 py-0.5 rounded-full">
                <TrendingDown size={12} />
                -{percentage}%
              </span>
            )}
            <span className="text-xs text-gray-400">مقارنة بالشهر الماضي</span>
          </div>
        )}
      </div>

      <div className={`p-4 rounded-2xl ${colorMap[color].split(' ').slice(2).join(' ')} z-10`}>
        <Icon size={26} className="group-hover:rotate-12 transition-transform duration-300" />
      </div>

      {/* Decorative vector background */}
      <div className="absolute -bottom-10 -left-10 w-32 h-32 bg-gray-50 dark:bg-dark-800/10 rounded-full opacity-30 group-hover:scale-120 transition-transform duration-300 pointer-events-none"></div>
    </motion.div>
  );
}
