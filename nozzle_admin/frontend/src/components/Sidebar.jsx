import React, { useState } from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { 
  LayoutDashboard, 
  ShoppingBag, 
  ShoppingCart, 
  Users, 
  LogOut, 
  ChevronRight, 
  ChevronLeft,
  Settings,
  Car,
  Folder,
  FolderOpen,
  Image,
  Percent,
  Bell,
  Package,
  Wrench,
  ShieldCheck
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export default function Sidebar() {
  const [isCollapsed, setIsCollapsed] = useState(false);
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const navItems = [
    { name: 'الرئيسية', path: '/', icon: LayoutDashboard },
    { name: 'الأقسام', path: '/categories', icon: Folder },
    { name: 'تصنيفات المنتجات', path: '/product-tags', icon: FolderOpen },
    { name: 'المنتجات', path: '/products', icon: ShoppingBag },
    { name: 'المخزون', path: '/inventory', icon: Package },
    { name: 'الخدمات والحجوزات', path: '/services', icon: Wrench },
    { name: 'الطلبات', path: '/orders', icon: ShoppingCart },
    { name: 'حسابات المستخدمين', path: '/customers', icon: Users },
    { name: 'البنرات الإعلانية', path: '/banners', icon: Image },
    { name: 'كوبونات الخصم', path: '/discounts', icon: Percent },
    { name: 'إشعارات الـ Push', path: '/notifications', icon: Bell },
  ];

  // Only show users & settings option for superadmins
  if (user?.role === 'superadmin') {
    navItems.push({ name: 'المشرفين', path: '/users', icon: ShieldCheck });
    navItems.push({ name: 'الإعدادات', path: '/settings', icon: Settings });
  }

  return (
    <aside 
      className={`h-screen bg-white dark:bg-dark-900 border-l border-gray-200 dark:border-dark-800 transition-all duration-300 flex flex-col relative z-20 shadow-sm ${
        isCollapsed ? 'w-20' : 'w-64'
      }`}
    >
      {/* Brand logo header */}
      <div className="p-5 flex items-center gap-3 border-b border-gray-100 dark:border-dark-800">
        <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-primary-600 to-indigo-500 flex items-center justify-center text-white font-extrabold shadow-md flex-shrink-0">
          <Car size={22} className="animate-pulse" />
        </div>
        {!isCollapsed && (
          <span className="font-extrabold text-xl bg-gradient-to-r from-primary-600 to-indigo-500 bg-clip-text text-transparent">
            نوزل برو
          </span>
        )}
      </div>

      {/* Navigation links */}
      <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
        {navItems.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            className={({ isActive }) =>
              `flex items-center gap-4 px-4 py-3.5 rounded-xl transition-all duration-200 group relative ${
                isActive
                  ? 'bg-primary-50 text-primary-600 dark:bg-primary-950/30 dark:text-primary-400 font-bold'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900 dark:text-dark-400 dark:hover:bg-dark-800/50 dark:hover:text-dark-100'
              }`
            }
          >
            <item.icon size={20} className="flex-shrink-0" />
            {!isCollapsed && <span className="text-sm">{item.name}</span>}
            
            {/* Tooltip on hover if collapsed */}
            {isCollapsed && (
              <span className="absolute right-full mr-2 px-2 py-1 bg-gray-900 text-white text-xs rounded opacity-0 group-hover:opacity-100 pointer-events-none transition-opacity duration-200 whitespace-nowrap z-50">
                {item.name}
              </span>
            )}
          </NavLink>
        ))}
      </nav>

      {/* Collapse button */}
      <button
        onClick={() => setIsCollapsed(!isCollapsed)}
        className="absolute bottom-24 -left-3.5 bg-white dark:bg-dark-800 border border-gray-200 dark:border-dark-700 w-7 h-7 rounded-full flex items-center justify-center text-gray-500 dark:text-dark-400 hover:text-primary-600 dark:hover:text-primary-400 shadow-md cursor-pointer transition-transform hover:scale-115"
        aria-label="Toggle Sidebar"
      >
        {isCollapsed ? <ChevronLeft size={16} /> : <ChevronRight size={16} />}
      </button>

      {/* Footer Profile & Logout */}
      <div className="p-4 border-t border-gray-100 dark:border-dark-800 space-y-3 bg-gray-50/50 dark:bg-dark-900/50">
        {!isCollapsed && (
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-full bg-primary-100 dark:bg-primary-900/50 flex items-center justify-center font-bold text-primary-600 dark:text-primary-300">
              {user?.full_name?.charAt(0) || 'أ'}
            </div>
            <div className="overflow-hidden">
              <h4 className="text-sm font-bold text-gray-800 dark:text-dark-100 truncate">{user?.full_name}</h4>
              <p className="text-xs text-gray-400 truncate">{user?.role === 'superadmin' ? 'مدير عام' : 'مشرف'}</p>
            </div>
          </div>
        )}
        
        <button
          onClick={handleLogout}
          className={`w-full flex items-center gap-4 px-4 py-3 rounded-xl text-red-600 hover:bg-red-50 dark:hover:bg-red-950/20 transition-colors duration-200 font-bold group relative ${
            isCollapsed ? 'justify-center' : ''
          }`}
        >
          <LogOut size={20} className="flex-shrink-0" />
          {!isCollapsed && <span className="text-sm">تسجيل الخروج</span>}
          {isCollapsed && (
            <span className="absolute right-full mr-2 px-2 py-1 bg-red-600 text-white text-xs rounded opacity-0 group-hover:opacity-100 pointer-events-none transition-opacity duration-200 whitespace-nowrap z-50">
              تسجيل الخروج
            </span>
          )}
        </button>
      </div>
    </aside>
  );
}
