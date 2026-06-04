import React, { useState, useEffect } from 'react';
import { X, Save } from 'lucide-react';
import api from '../services/api';
import ImageUploader from './ui/ImageUploader';

export default function UserModal({ isOpen, onClose, user, onSave }) {
  const [formData, setFormData] = useState({
    full_name: '',
    email: '',
    password: '',
    role: 'admin',
    is_active: true,
    avatar_url: '',
  });
  const [errors, setErrors] = useState({});
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (user) {
      setFormData({
        full_name: user.full_name || '',
        email: user.email || '',
        password: '', // Password empty on edit
        role: user.role || 'admin',
        is_active: user.is_active !== false,
        avatar_url: user.avatar_url || '',
      });
    } else {
      setFormData({
        full_name: '',
        email: '',
        password: '',
        role: 'admin',
        is_active: true,
        avatar_url: '',
      });
    }
    setErrors({});
  }, [user, isOpen]);

  if (!isOpen) return null;

  const validate = () => {
    const tempErrors = {};
    if (!formData.full_name.trim()) tempErrors.full_name = 'الاسم الكامل مطلوب';
    if (!formData.email.trim()) {
      tempErrors.email = 'البريد الإلكتروني مطلوب';
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      tempErrors.email = 'صيغة البريد الإلكتروني غير صالحة';
    }
    
    // Password required on create
    if (!user && (!formData.password || formData.password.length < 6)) {
      tempErrors.password = 'كلمة المرور يجب أن تكون 6 خانات على الأقل';
    } else if (user && formData.password && formData.password.length < 6) {
      tempErrors.password = 'كلمة المرور الجديدة يجب أن تكون 6 خانات على الأقل';
    }

    setErrors(tempErrors);
    return Object.keys(tempErrors).length === 0;
  };

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validate()) return;

    setSubmitting(true);
    try {
      const payload = {
        full_name: formData.full_name,
        email: formData.email,
        role: formData.role,
        is_active: formData.is_active,
        avatar_url: formData.avatar_url || null,
      };
      
      if (formData.password) {
        payload.password = formData.password;
      }

      if (user) {
        await api.put(`/users/${user.id}`, payload);
      } else {
        await api.post('/users', payload);
      }
      onSave();
      onClose();
    } catch (error) {
      console.error('Failed to save user:', error);
      const detail = error.response?.data?.detail || 'فشل حفظ البيانات. يرجى التحقق من المدخلات.';
      setErrors({ api: detail });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto flex items-center justify-center p-4">
      {/* Overlay */}
      <div className="fixed inset-0 bg-black/55 backdrop-blur-sm" onClick={onClose}></div>

      {/* Modal Dialog */}
      <div className="bg-white dark:bg-dark-900 border border-gray-100 dark:border-dark-800 rounded-3xl shadow-2xl w-full max-w-md z-10 overflow-hidden relative animate-in fade-in zoom-in-95 duration-200">
        
        {/* Header */}
        <div className="px-6 py-4 border-b border-gray-100 dark:border-dark-800 flex justify-between items-center">
          <h3 className="font-extrabold text-base text-gray-800 dark:text-dark-100">
            {user ? 'تعديل بيانات المشرف' : 'إضافة مشرف جديد'}
          </h3>
          <button onClick={onClose} className="p-1 hover:bg-gray-100 dark:hover:bg-dark-850 rounded-lg transition-colors cursor-pointer text-gray-400">
            <X size={18} />
          </button>
        </div>

        {/* Form Body */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {errors.api && (
            <div className="p-3.5 bg-red-50 border border-red-200 text-red-800 dark:bg-red-950/20 dark:border-red-900 dark:text-red-400 rounded-2xl text-xs font-bold animate-shake">
              {errors.api}
            </div>
          )}

          {/* Full Name */}
          <div className="space-y-1">
            <label className="text-xs font-bold text-gray-600 dark:text-dark-300">الاسم الكامل *</label>
            <input
              type="text"
              name="full_name"
              value={formData.full_name}
              onChange={handleChange}
              className={`w-full px-4 py-2.5 rounded-xl border focus:outline-none text-sm dark:bg-dark-950 dark:border-dark-800 ${
                errors.full_name ? 'border-red-500' : 'border-gray-200 focus:border-primary-400'
              }`}
              placeholder="مثال: خالد محمد"
            />
            {errors.full_name && <span className="text-[10px] text-red-500 font-bold">{errors.full_name}</span>}
          </div>

          {/* Email */}
          <div className="space-y-1">
            <label className="text-xs font-bold text-gray-600 dark:text-dark-300">البريد الإلكتروني *</label>
            <input
              type="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              className={`w-full px-4 py-2.5 rounded-xl border focus:outline-none text-sm dark:bg-dark-950 dark:border-dark-800 ${
                errors.email ? 'border-red-500' : 'border-gray-200 focus:border-primary-400'
              }`}
              placeholder="admin@example.com"
            />
            {errors.email && <span className="text-[10px] text-red-500 font-bold">{errors.email}</span>}
          </div>

          {/* Password */}
          <div className="space-y-1">
            <label className="text-xs font-bold text-gray-600 dark:text-dark-300">
              {user ? 'كلمة المرور الجديدة (اختياري)' : 'كلمة المرور *'}
            </label>
            <input
              type="password"
              name="password"
              value={formData.password}
              onChange={handleChange}
              className={`w-full px-4 py-2.5 rounded-xl border focus:outline-none text-sm dark:bg-dark-950 dark:border-dark-800 ${
                errors.password ? 'border-red-500' : 'border-gray-200 focus:border-primary-400'
              }`}
              placeholder={user ? 'اتركها فارغة للإبقاء على الحالية' : '••••••'}
            />
            {errors.password && <span className="text-[10px] text-red-500 font-bold">{errors.password}</span>}
          </div>

          {/* Role */}
          <div className="space-y-1">
            <label className="text-xs font-bold text-gray-600 dark:text-dark-300">الصلاحية *</label>
            <select
              name="role"
              value={formData.role}
              onChange={handleChange}
              className="w-full px-4 py-2.5 rounded-xl border border-gray-200 focus:border-primary-400 focus:outline-none text-sm dark:bg-dark-950 dark:border-dark-800"
            >
              <option value="admin">مشرف عادي (Admin)</option>
              <option value="superadmin">مدير عام (Super Admin)</option>
            </select>
          </div>

          {/* Avatar Upload */}
          <div className="pt-2">
            <ImageUploader
              configKey="user_avatar"
              folder="avatars"
              value={formData.avatar_url}
              onChange={(url) => setFormData(prev => ({ ...prev, avatar_url: url }))}
              label="صورة الحساب الشخصي (Avatar)"
            />
          </div>

          {/* Account Status */}
          <div className="flex items-center gap-2 pt-2">
            <input
              type="checkbox"
              name="is_active"
              id="is_active"
              checked={formData.is_active}
              onChange={handleChange}
              className="w-4 h-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500"
            />
            <label htmlFor="is_active" className="text-xs font-bold text-gray-700 dark:text-dark-300 select-none">
              الحساب نشط ويسمح له بتسجيل الدخول
            </label>
          </div>

          {/* Footer Actions */}
          <div className="pt-4 border-t border-gray-100 dark:border-dark-800 flex justify-end gap-3">
            <button
              type="button"
              onClick={onClose}
              className="px-5 py-2.5 rounded-xl border border-gray-200 text-gray-600 dark:border-dark-800 dark:text-dark-300 hover:bg-gray-50 dark:hover:bg-dark-850 text-xs font-bold transition-colors cursor-pointer"
            >
              إلغاء
            </button>
            <button
              type="submit"
              disabled={submitting}
              className="px-5 py-2.5 rounded-xl bg-primary-600 hover:bg-primary-700 text-white text-xs font-bold flex items-center gap-2 shadow-md disabled:opacity-50 transition-colors cursor-pointer"
            >
              <Save size={16} />
              {submitting ? 'جاري الحفظ...' : 'حفظ المشرف'}
            </button>
          </div>
        </form>

      </div>
    </div>
  );
}
