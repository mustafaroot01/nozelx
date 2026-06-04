import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Mail, Lock, LogIn, AlertCircle, Car } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const { login, token } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    // If already logged in, redirect directly to dashboard
    if (token) {
      navigate('/');
    }
  }, [token, navigate]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    
    if (!email.trim() || !password) {
      setError('يرجى ملء جميع الحقول المطلوبة');
      return;
    }

    setSubmitting(true);
    const result = await login(email, password);
    setSubmitting(false);

    if (result.success) {
      navigate('/');
    } else {
      setError(result.message || 'البريد الإلكتروني أو كلمة المرور غير صحيحة');
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 text-gray-900 dark:bg-dark-950 dark:text-dark-50 flex items-center justify-center p-4 relative overflow-hidden">
      
      {/* Decorative Blur Background Blobs */}
      <div className="absolute top-0 right-0 w-96 h-96 bg-primary-300/20 dark:bg-primary-900/10 rounded-full filter blur-3xl -translate-y-1/2 translate-x-1/2 pointer-events-none"></div>
      <div className="absolute bottom-0 left-0 w-96 h-96 bg-indigo-300/20 dark:bg-indigo-900/10 rounded-full filter blur-3xl translate-y-1/2 -translate-x-1/2 pointer-events-none"></div>

      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.4 }}
        className="w-full max-w-md bg-white dark:bg-dark-900 border border-gray-100 dark:border-dark-800 rounded-3xl p-8 shadow-2xl relative z-10"
      >
        {/* Brand Header */}
        <div className="text-center space-y-3 mb-8">
          <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-primary-600 to-indigo-500 mx-auto flex items-center justify-center text-white shadow-lg shadow-primary-500/20">
            <Car size={32} />
          </div>
          <h2 className="text-2xl font-extrabold text-gray-800 dark:text-dark-100">
            لوحة الإدارة نوزل
          </h2>
          <p className="text-xs text-gray-400">
            سجل الدخول لإدارة المنتجات، الطلبات وإحصائيات المبيعات
          </p>
        </div>

        {/* Error Notification */}
        {error && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className="mb-6 p-4 bg-red-50 border border-red-200 text-red-800 dark:bg-red-950/20 dark:border-red-900 dark:text-red-400 rounded-2xl flex items-center gap-3 text-xs font-bold"
          >
            <AlertCircle size={18} className="flex-shrink-0" />
            <span>{error}</span>
          </motion.div>
        )}

        {/* Login Form */}
        <form onSubmit={handleSubmit} className="space-y-5">
          {/* Email Address */}
          <div className="space-y-1">
            <label className="text-xs font-bold text-gray-600 dark:text-dark-300">البريد الإلكتروني</label>
            <div className="relative">
              <span className="absolute inset-y-0 right-0 flex items-center pr-3.5 pointer-events-none text-gray-400">
                <Mail size={18} />
              </span>
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full pr-11 pl-4 py-3 rounded-xl border border-gray-200 focus:border-primary-400 focus:outline-none text-sm dark:bg-dark-950 dark:border-dark-800 transition-colors"
                placeholder="admin@nozzle.com"
              />
            </div>
          </div>

          {/* Password */}
          <div className="space-y-1">
            <label className="text-xs font-bold text-gray-600 dark:text-dark-300">كلمة المرور</label>
            <div className="relative">
              <span className="absolute inset-y-0 right-0 flex items-center pr-3.5 pointer-events-none text-gray-400">
                <Lock size={18} />
              </span>
              <input
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full pr-11 pl-4 py-3 rounded-xl border border-gray-200 focus:border-primary-400 focus:outline-none text-sm dark:bg-dark-950 dark:border-dark-800 transition-colors"
                placeholder="••••••••"
              />
            </div>
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            disabled={submitting}
            className="w-full py-3.5 mt-2 rounded-xl bg-gradient-to-r from-primary-600 to-indigo-500 hover:from-primary-700 hover:to-indigo-600 text-white text-sm font-bold flex items-center justify-center gap-2.5 shadow-lg shadow-primary-500/25 dark:shadow-none disabled:opacity-50 transition-all cursor-pointer transform hover:scale-[1.01]"
          >
            <LogIn size={18} />
            {submitting ? 'جاري التحقق...' : 'تسجيل الدخول'}
          </button>
        </form>

        {/* Demo Credentials Hint */}
        <div className="mt-8 pt-6 border-t border-gray-100 dark:border-dark-800 text-center">
          <p className="text-[10px] text-gray-400 leading-relaxed">
            بيانات الدخول التجريبية:<br />
            البريد: <span className="font-bold">admin@nozzle.com</span> | كلمة المرور: <span className="font-bold">admin123</span>
          </p>
        </div>
      </motion.div>

    </div>
  );
}
