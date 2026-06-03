import React, { useState } from 'react';
import { X, CheckCircle, Clock, ShoppingCart } from 'lucide-react';
import api from '../services/api';

export default function OrderModal({ isOpen, onClose, order, onUpdateStatus }) {
  const [status, setStatus] = useState('');
  const [submitting, setSubmitting] = useState(false);

  React.useEffect(() => {
    if (order) {
      setStatus(order.status || 'pending');
    }
  }, [order, isOpen]);

  if (!isOpen || !order) return null;

  const handleStatusChange = async (e) => {
    const newStatus = e.target.value;
    setStatus(newStatus);
  };

  const handleSaveStatus = async () => {
    setSubmitting(true);
    try {
      await api.put(`/orders/${order.id}/status`, { status });
      onUpdateStatus();
      onClose();
    } catch (error) {
      console.error('Failed to update order status:', error);
    } finally {
      setSubmitting(false);
    }
  };

  const statusColors = {
    pending: 'bg-orange-50 border-orange-200 text-orange-700 dark:bg-orange-950/20 dark:border-orange-900 dark:text-orange-400',
    processing: 'bg-blue-50 border-blue-200 text-blue-700 dark:bg-blue-950/20 dark:border-blue-900 dark:text-blue-400',
    completed: 'bg-emerald-50 border-emerald-200 text-emerald-700 dark:bg-emerald-950/20 dark:border-emerald-900 dark:text-emerald-400',
    cancelled: 'bg-red-50 border-red-200 text-red-700 dark:bg-red-950/20 dark:border-red-900 dark:text-red-400',
  };

  const statusLabels = {
    pending: 'معلق',
    processing: 'قيد التجهيز',
    completed: 'مكتمل',
    cancelled: 'ملغي',
  };

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto flex items-center justify-center p-4">
      {/* Overlay */}
      <div className="fixed inset-0 bg-black/55 backdrop-blur-sm" onClick={onClose}></div>

      {/* Container */}
      <div className="bg-white dark:bg-dark-900 border border-gray-100 dark:border-dark-800 rounded-3xl shadow-2xl w-full max-w-xl z-10 overflow-hidden relative animate-in fade-in zoom-in-95 duration-200">
        
        {/* Header */}
        <div className="px-6 py-4 border-b border-gray-100 dark:border-dark-800 flex justify-between items-center">
          <div className="flex items-center gap-2">
            <ShoppingCart size={18} className="text-primary-500" />
            <h3 className="font-extrabold text-base text-gray-800 dark:text-dark-100">
              تفاصيل الطلب رقم #{order.id}
            </h3>
          </div>
          <button onClick={onClose} className="p-1 hover:bg-gray-100 dark:hover:bg-dark-850 rounded-lg transition-colors cursor-pointer text-gray-400">
            <X size={18} />
          </button>
        </div>

        {/* Content Body */}
        <div className="p-6 space-y-6">
          
          {/* Customer Metadata */}
          <div className="grid grid-cols-2 gap-4 bg-gray-50/50 dark:bg-dark-950/20 p-4 rounded-2xl border border-gray-100 dark:border-dark-800 text-xs">
            <div className="space-y-1">
              <span className="text-gray-400 block font-medium">اسم العميل</span>
              <span className="font-bold text-gray-800 dark:text-dark-200">{order.customer_name}</span>
            </div>
            <div className="space-y-1">
              <span className="text-gray-400 block font-medium">البريد الإلكتروني</span>
              <span className="font-bold text-gray-800 dark:text-dark-200 truncate block">{order.customer_email}</span>
            </div>
            <div className="space-y-1">
              <span className="text-gray-400 block font-medium">تاريخ الإنشاء</span>
              <span className="font-bold text-gray-800 dark:text-dark-200">
                {new Date(order.created_at).toLocaleString('ar-SA')}
              </span>
            </div>
            <div className="space-y-1">
              <span className="text-gray-400 block font-medium">حالة الطلب الحالية</span>
              <span className={`inline-flex px-2.5 py-0.5 rounded-full border text-[10px] font-bold ${statusColors[order.status]}`}>
                {statusLabels[order.status]}
              </span>
            </div>
          </div>

          {/* Line items list */}
          <div className="space-y-3">
            <h4 className="font-bold text-xs text-gray-600 dark:text-dark-300">مكونات الطلب</h4>
            <div className="border border-gray-100 dark:border-dark-800 rounded-2xl overflow-hidden divide-y divide-gray-100 dark:divide-dark-800">
              {order.items?.map((item) => (
                <div key={item.id} className="p-3.5 flex justify-between items-center text-xs">
                  <div className="space-y-1">
                    <span className="font-bold text-gray-800 dark:text-dark-200">
                      {item.product?.name || `منتج رقم #${item.product_id}`}
                    </span>
                    <span className="text-gray-400 block">
                      {item.quantity} × {Number(item.price).toLocaleString()} د.ع
                    </span>
                  </div>
                  <span className="font-bold text-gray-800 dark:text-dark-200">
                    {Number(item.quantity * item.price).toLocaleString()} د.ع
                  </span>
                </div>
              ))}
            </div>
            <div className="flex justify-between items-center px-2">
              <span className="text-sm font-bold text-gray-700 dark:text-dark-300">الإجمالي الكلي:</span>
              <span className="text-xl font-extrabold text-primary-600 dark:text-primary-400">
                {Number(order.total_amount).toLocaleString()} د.ع
              </span>
            </div>
          </div>

          {/* Change Order Status */}
          <div className="pt-4 border-t border-gray-100 dark:border-dark-800 space-y-3">
            <label className="text-xs font-bold text-gray-600 dark:text-dark-300">تحديث حالة الطلب</label>
            <div className="flex items-center gap-3">
              <select
                value={status}
                onChange={handleStatusChange}
                className="flex-1 px-4 py-2 rounded-xl border border-gray-200 focus:border-primary-400 focus:outline-none text-sm dark:bg-dark-950 dark:border-dark-800"
              >
                <option value="pending">معلق</option>
                <option value="processing">قيد التجهيز</option>
                <option value="completed">مكتمل</option>
                <option value="cancelled">ملغي</option>
              </select>
              <button
                type="button"
                onClick={handleSaveStatus}
                disabled={submitting}
                className="px-5 py-2.5 rounded-xl bg-primary-600 hover:bg-primary-700 text-white text-xs font-bold shadow-md disabled:opacity-50 transition-colors cursor-pointer"
              >
                {submitting ? 'جاري التحديث...' : 'تحديث الحالة'}
              </button>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}
