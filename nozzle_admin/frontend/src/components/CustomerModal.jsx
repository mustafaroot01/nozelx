import React, { useState, useEffect } from 'react';
import { X, Save } from 'lucide-react';
import api from '../services/api';
import ImageUploader from './ui/ImageUploader';

export default function CustomerModal({ isOpen, onClose, customer, onSave }) {
  const [formData, setFormData] = useState({
    full_name: '',
    phone: '',
    email: '',
    password: '', // Not required, but available dynamically
    is_active: true,
    avatar_url: '',
  });
  const [errors, setErrors] = useState({});
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (customer) {
      setFormData({
        full_name: customer.full_name || '',
        phone: customer.phone || '',
        email: customer.email || '',
        password: '',
        is_active: customer.is_active !== false,
        avatar_url: customer.avatar_url || '',
      });
    } else {
      setFormData({
        full_name: '',
        phone: '',
        email: '',
        password: '',
        is_active: true,
        avatar_url: '',
      });
    }
    setErrors({});
  }, [customer, isOpen]);

  if (!isOpen) return null;

  const validate = () => {
    const tempErrors = {};
    if (!formData.full_name.trim()) tempErrors.full_name = 'الاسم الكامل مطلوب';
    
    if (!formData.phone.trim()) {
      tempErrors.phone = 'رقم الهاتف مطلوب';
    } else {
      const cleanPhone = formData.phone.replace(/[^\d]/g, '');
      if (cleanPhone.length < 9) {
        tempErrors.phone = 'رقم الهاتف غير صالح';
      }
    }

    if (formData.email.trim() && !/\S+@\S+\.\S+/.test(formData.email)) {
      tempErrors.email = 'صيغة البريد الإلكتروني غير صالحة';
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
        phone: formData.phone,
        email: formData.email.trim() || null,
        is_active: formData.is_active,
        avatar_url: formData.avatar_url || null,
        role: 'customer'
      };

      // If creating, we must provide a dummy password for schemas.UserCreate
      if (!customer) {
        payload.password = formData.password || '123456';
      } else if (formData.password) {
        payload.password = formData.password;
      }

      if (customer) {
        await api.put(`/customers/${customer.id}`, payload);
      } else {
        await api.post('/customers', payload);
      }
      onSave();
      onClose();
    } catch (error) {
      console.error('Failed to save customer:', error);
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
            {customer ? 'تعديل حساب المستخدم' : 'إضافة حساب مستخدم جديد'}
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
              placeholder="مثال: أحمد علي"
            />
            {errors.full_name && <span className="text-[10px] text-red-500 font-bold">{errors.full_name}</span>}
          </div>

          {/* Phone Number */}
          <div className="space-y-1">
            <label className="text-xs font-bold text-gray-600 dark:text-dark-300">رقم الهاتف *</label>
            <input
              type="text"
              name="phone"
              value={formData.phone}
              onChange={handleChange}
              className={`w-full px-4 py-2.5 rounded-xl border focus:outline-none text-sm dark:bg-dark-950 dark:border-dark-800 ${
                errors.phone ? 'border-red-500' : 'border-gray-200 focus:border-primary-400'
              }`}
              placeholder="077XXXXXXXX"
            />
            {errors.phone && <span className="text-[10px] text-red-500 font-bold">{errors.phone}</span>}
          </div>

          {/* Email (Optional) */}
          <div className="space-y-1">
            <label className="text-xs font-bold text-gray-600 dark:text-dark-300">البريد الإلكتروني (اختياري)</label>
            <input
              type="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              className={`w-full px-4 py-2.5 rounded-xl border focus:outline-none text-sm dark:bg-dark-950 dark:border-dark-800 ${
                errors.email ? 'border-red-500' : 'border-gray-200 focus:border-primary-400'
              }`}
              placeholder="name@example.com"
            />
            {errors.email && <span className="text-[10px] text-red-500 font-bold">{errors.email}</span>}
          </div>

          {/* Password (Optional for edit, default for create) */}
          {customer && (
            <div className="space-y-1">
              <label className="text-xs font-bold text-gray-600 dark:text-dark-300">تعيين كلمة مرور جديدة (اختياري)</label>
              <input
                type="password"
                name="password"
                value={formData.password}
                onChange={handleChange}
                className="w-full px-4 py-2.5 rounded-xl border border-gray-200 focus:border-primary-400 focus:outline-none text-sm dark:bg-dark-950 dark:border-dark-800"
                placeholder="اتركها فارغة للإبقاء على الحالية"
              />
            </div>
          )}

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

          {/* Status Checkbox */}
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
              نشط (السماح للمستخدم بالدخول وحجز الخدمات)
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
              {submitting ? 'جاري الحفظ...' : 'حفظ'}
            </button>
          </div>
        </form>

      </div>
    </div>
  );
}
