import React, { useState, useEffect } from 'react';
import { Sun, Moon, Bell, Search, ShieldCheck } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';

export default function Header() {
  const { theme, toggleTheme } = useTheme();
  const { user } = useAuth();
  const [showNotifications, setShowNotifications] = useState(false);
  const [alerts, setAlerts] = useState([]);
  const [loading, setLoading] = useState(false);

  const fetchAlerts = async () => {
    try {
      setLoading(true);
      const res = await api.get('/inventory/dashboard');
      if (res.data && res.data.status === 'success') {
        const { low_stock_items } = res.data.data;
        const dynamicAlerts = low_stock_items.map((item, idx) => {
          let title = 'مخزون منخفض';
          let body = `المنتج "${item.name}" شارف على الانتهاء (متبقي ${item.stock} قطع)`;
          if (item.stock <= 0) {
            title = 'نفذت الكمية';
            body = `المنتج "${item.name}" غير متوفر حالياً بالمخزن (0 قطع)`;
          } else if (item.status === 'critical') {
            title = 'مخزون حرج جداً';
            body = `المنتج "${item.name}" في مستوى حرج (متبقي ${item.stock} قطع)`;
          }
          return {
            id: `stock-${item.id}-${idx}`,
            title,
            body,
            time: 'تنبيه مخزني'
          };
        });
        setAlerts(dynamicAlerts.slice(0, 5)); // Show top 5 warnings
      }
    } catch (err) {
      console.error('Error fetching header inventory alerts:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (user) {
      fetchAlerts();
      // Poll every 60 seconds to keep it fresh
      const interval = setInterval(fetchAlerts, 60000);
      return () => clearInterval(interval);
    }
  }, [user]);

  return (
    <header className="h-20 bg-white dark:bg-dark-900 border-b border-gray-200 dark:border-dark-800 px-8 flex items-center justify-between relative z-10">
      {/* Search Bar */}
      <div className="relative w-96 hidden md:block">
        <span className="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none text-gray-400">
          <Search size={18} />
        </span>
        <input
          type="text"
          placeholder="ابحث هنا عن منتجات، طلبات، فواتير..."
          className="w-full pr-10 pl-4 py-2 rounded-xl bg-gray-50 border border-gray-200 focus:border-primary-400 focus:bg-white focus:outline-none dark:bg-dark-950 dark:border-dark-800 dark:focus:border-primary-600 transition-colors text-sm"
        />
      </div>

      {/* Action Controls */}
      <div className="flex items-center gap-4 mr-auto md:mr-0">
        
        {/* Dark Mode Switcher */}
        <button
          onClick={toggleTheme}
          className="p-2.5 rounded-xl border border-gray-200 dark:border-dark-800 hover:bg-gray-50 dark:hover:bg-dark-800 text-gray-600 dark:text-dark-300 cursor-pointer transition-colors"
          aria-label="Toggle Theme"
        >
          {theme === 'dark' ? <Sun size={20} /> : <Moon size={20} />}
        </button>

        {/* Notifications Icon and Dropdown */}
        <div className="relative">
          <button
            onClick={() => setShowNotifications(!showNotifications)}
            className="p-2.5 rounded-xl border border-gray-200 dark:border-dark-800 hover:bg-gray-50 dark:hover:bg-dark-800 text-gray-600 dark:text-dark-300 cursor-pointer transition-colors relative"
            aria-label="View Notifications"
          >
            <Bell size={20} />
            {alerts.length > 0 && (
              <span className="absolute top-1 left-1 w-2.5 h-2.5 bg-red-500 rounded-full border-2 border-white dark:border-dark-900 animate-ping"></span>
            )}
          </button>

          {showNotifications && (
            <>
              {/* Overlay background for closing */}
              <div 
                className="fixed inset-0 z-30" 
                onClick={() => setShowNotifications(false)}
              ></div>
              
              {/* Dropdown Menu */}
              <div className="absolute left-0 mt-2 w-80 bg-white dark:bg-dark-900 border border-gray-200 dark:border-dark-800 rounded-2xl shadow-xl z-40 py-2 animate-in fade-in-50 slide-in-from-top-2 duration-200">
                <div className="px-4 py-2 border-b border-gray-100 dark:border-dark-800 flex justify-between items-center">
                  <h3 className="font-bold text-sm text-gray-800 dark:text-dark-100 font-cairo">الإشعارات والتنبيهات</h3>
                  {alerts.length > 0 && (
                    <span className="text-xs bg-red-100 text-red-700 px-2 py-0.5 rounded-full font-bold">
                      {alerts.length} تنبيهات
                    </span>
                  )}
                </div>
                <div className="divide-y divide-gray-100 dark:divide-dark-800 max-h-72 overflow-y-auto font-cairo text-right">
                  {alerts.length === 0 ? (
                    <div className="p-6 text-center text-gray-400 text-xs font-bold">
                      لا توجد تنبيهات نشطة حالياً. المخزون مستقر.
                    </div>
                  ) : (
                    alerts.map((item) => (
                      <div key={item.id} className="p-4 hover:bg-gray-50 dark:hover:bg-dark-800/40 cursor-pointer transition-colors">
                        <div className="flex justify-between items-start gap-2">
                          <span className="text-[10px] text-gray-400 whitespace-nowrap">{item.time}</span>
                          <h4 className="text-xs font-black text-red-600">{item.title}</h4>
                        </div>
                        <p className="text-xs text-gray-500 mt-1 leading-relaxed">{item.body}</p>
                      </div>
                    ))
                  )}
                </div>
                <div className="p-2 border-t border-gray-100 dark:border-dark-800 text-center">
                  <button 
                    onClick={() => { setShowNotifications(false); window.location.href = '/inventory'; }}
                    className="text-xs text-primary-600 font-bold hover:underline font-cairo"
                  >
                    فتح لوحة تحكم المخزون
                  </button>
                </div>
              </div>
            </>
          )}
        </div>

        {/* User Info Capsule */}
        <div className="flex items-center gap-3 border-r border-gray-200 dark:border-dark-800 pr-4">
          <div className="hidden lg:block text-right">
            <div className="flex items-center gap-1">
              <h3 className="text-sm font-bold text-gray-800 dark:text-dark-100">{user?.full_name}</h3>
              <ShieldCheck size={14} className="text-primary-600 dark:text-primary-400" />
            </div>
            <p className="text-xs text-gray-400">{user?.role === 'superadmin' ? 'المدير العام' : 'مشرف النظام'}</p>
          </div>
          <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-primary-500 to-indigo-500 text-white font-extrabold flex items-center justify-center shadow-md">
            {user?.full_name?.charAt(0) || 'أ'}
          </div>
        </div>

      </div>
    </header>
  );
}
