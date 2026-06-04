import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { 
  ArrowRight, ShoppingBag, DollarSign, 
  Tag, Calendar, Phone, Mail, Clock, Shield, Star, 
  MapPin, Heart, ArrowLeftRight, CheckCircle2, XCircle
} from 'lucide-react';
import api from '../services/api';
import Toast from '../components/Toast';

export default function UserDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  
  const [userData, setUserData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('orders');
  
  // Toast State
  const [toastMessage, setToastMessage] = useState('');
  const [toastType, setToastType] = useState('success');

  const showToast = (msg, type = 'success') => {
    setToastMessage(msg);
    setToastType(type);
  };

  useEffect(() => {
    const fetchUserDetail = async () => {
      setLoading(true);
      try {
        const res = await api.get(`/admin/users/${id}`);
        if (res.data && res.data.success) {
          setUserData(res.data.data);
        } else {
          showToast('فشل تحميل تفاصيل المستخدم', 'error');
        }
      } catch (err) {
        console.error(err);
        showToast('حدث خطأ أثناء تحميل البيانات', 'error');
      } finally {
        setLoading(false);
      }
    };
    fetchUserDetail();
  }, [id]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <div className="w-10 h-10 border-4 border-primary-600 border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  if (!userData) {
    return (
      <div className="text-center py-12">
        <h2 className="text-xl font-bold text-gray-700 dark:text-dark-200">المستخدم غير موجود أو تم حذفه</h2>
        <button 
          onClick={() => navigate('/customers')}
          className="mt-4 px-4 py-2 bg-primary-600 text-white rounded-lg"
        >
          العودة لإدارة المستخدمين
        </button>
      </div>
    );
  }

  // Format currency
  const formatCurrency = (val) => {
    return new Intl.NumberFormat('ar-IQ', { style: 'currency', currency: 'IQD', maximumFractionDigits: 0 }).format(val);
  };

  const formatDate = (dateStr) => {
    if (!dateStr) return '—';
    return new Date(dateStr).toLocaleDateString('ar-SA', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  return (
    <div className="space-y-6">
      {/* Back link */}
      <button 
        onClick={() => navigate('/customers')}
        className="flex items-center gap-2 text-xs font-bold text-gray-500 hover:text-primary-600 transition-colors cursor-pointer"
      >
        <ArrowRight size={16} />
        العودة إلى قائمة حسابات المستخدمين
      </button>

      {/* Header Profile Section */}
      <div className="bg-white dark:bg-dark-900 rounded-3xl p-6 shadow-sm border border-gray-100 dark:border-dark-800 flex flex-col md:flex-row items-center justify-between gap-6">
        <div className="flex flex-col md:flex-row items-center gap-5 text-center md:text-right">
          <div className="w-24 h-24 rounded-full bg-primary-100 dark:bg-primary-950/40 text-primary-600 dark:text-primary-400 flex items-center justify-center font-bold text-3xl overflow-hidden border-4 border-white shadow-md">
            {userData.avatar_url ? (
              <img src={userData.avatar_url} alt={userData.full_name} className="w-full h-full object-cover" />
            ) : (
              (userData.name || userData.full_name || 'م').charAt(0)
            )}
          </div>
          <div className="space-y-1">
            <h1 className="text-2xl font-black text-gray-800 dark:text-dark-100">{userData.name || userData.full_name}</h1>
            <div className="flex flex-wrap items-center justify-center md:justify-start gap-4 text-xs text-gray-400 mt-2">
              <span className="flex items-center gap-1">
                <Phone size={14} className="text-gray-400" />
                <span className="font-mono text-gray-700 dark:text-dark-300">{userData.phone}</span>
              </span>
              <span className="flex items-center gap-1">
                <Calendar size={14} className="text-gray-400" />
                <span>عضو منذ: {formatDate(userData.created_at)}</span>
              </span>
              {userData.last_login_at && (
                <span className="flex items-center gap-1">
                  <Clock size={14} className="text-gray-400" />
                  <span>آخر دخول: {formatDate(userData.last_login_at)}</span>
                </span>
              )}
            </div>
          </div>
        </div>
        
        {/* Status Badge */}
        <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold bg-emerald-50 text-emerald-700 dark:bg-emerald-950/20 dark:text-emerald-400">
          <span className="w-2 h-2 rounded-full bg-emerald-500"></span>
          حساب نشط
        </span>
      </div>

      {/* 4 Stats Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Orders Card */}
        <div className="bg-white dark:bg-dark-900 rounded-3xl p-5 shadow-sm border border-gray-100 dark:border-dark-800 flex items-center justify-between">
          <div className="space-y-1">
            <p className="text-xs text-gray-400 font-bold">إجمالي الطلبات</p>
            <h3 className="text-2xl font-black text-gray-800 dark:text-dark-100">{userData.stats.orders_count}</h3>
            <p className="text-[10px] text-gray-400">
              {userData.stats.completed_orders} مكتمل / {userData.stats.cancelled_orders} ملغي
            </p>
          </div>
          <div className="w-12 h-12 rounded-2xl bg-blue-50 dark:bg-blue-950/40 text-blue-600 dark:text-blue-400 flex items-center justify-center">
            <ShoppingBag size={22} />
          </div>
        </div>

        {/* Spent Card */}
        <div className="bg-white dark:bg-dark-900 rounded-3xl p-5 shadow-sm border border-gray-100 dark:border-dark-800 flex items-center justify-between">
          <div className="space-y-1">
            <p className="text-xs text-gray-400 font-bold">إجمالي الإنفاق</p>
            <h3 className="text-xl font-black text-emerald-600 dark:text-emerald-400">{formatCurrency(userData.total_spent)}</h3>
            <p className="text-[10px] text-gray-400">القيمة الإجمالية لطلبات العميل</p>
          </div>
          <div className="w-12 h-12 rounded-2xl bg-emerald-50 dark:bg-emerald-950/40 text-emerald-600 dark:text-emerald-400 flex items-center justify-center">
            <DollarSign size={22} />
          </div>
        </div>

        {/* Services Card */}
        <div className="bg-white dark:bg-dark-900 rounded-3xl p-5 shadow-sm border border-gray-100 dark:border-dark-800 flex items-center justify-between">
          <div className="space-y-1">
            <p className="text-xs text-gray-400 font-bold">حجوزات الخدمات</p>
            <h3 className="text-2xl font-black text-amber-600 dark:text-amber-400">{userData.stats.service_requests_count}</h3>
            <p className="text-[10px] text-gray-400">حجوزات غسيل وصيانة السيارات</p>
          </div>
          <div className="w-12 h-12 rounded-2xl bg-amber-50 dark:bg-amber-950/40 text-amber-600 dark:text-amber-400 flex items-center justify-center">
            <Star size={22} />
          </div>
        </div>

        {/* Coupons Card */}
        <div className="bg-white dark:bg-dark-900 rounded-3xl p-5 shadow-sm border border-gray-100 dark:border-dark-800 flex items-center justify-between">
          <div className="space-y-1">
            <p className="text-xs text-gray-400 font-bold">الكوبونات المستخدمة</p>
            <h3 className="text-2xl font-black text-purple-600 dark:text-purple-400">{userData.stats.coupons_used_count}</h3>
            <p className="text-[10px] text-purple-500">وفر {formatCurrency(userData.stats.total_savings)}</p>
          </div>
          <div className="w-12 h-12 rounded-2xl bg-purple-50 dark:bg-purple-950/40 text-purple-600 dark:text-purple-400 flex items-center justify-center">
            <Tag size={22} />
          </div>
        </div>
      </div>

      {/* Tabs Container */}
      <div className="bg-white dark:bg-dark-900 rounded-3xl shadow-sm border border-gray-100 dark:border-dark-800 overflow-hidden">
        {/* Navigation Tabs */}
        <div className="flex border-b border-gray-100 dark:border-dark-800 overflow-x-auto">
          <button
            onClick={() => setActiveTab('orders')}
            className={`flex-1 py-4 text-sm font-bold text-center border-b-2 cursor-pointer transition-colors whitespace-nowrap px-6 ${
              activeTab === 'orders' 
                ? 'border-primary-600 text-primary-600' 
                : 'border-transparent text-gray-400 hover:text-gray-600'
            }`}
          >
            الطلبات ({userData.stats.orders_count})
          </button>
          <button
            onClick={() => setActiveTab('services')}
            className={`flex-1 py-4 text-sm font-bold text-center border-b-2 cursor-pointer transition-colors whitespace-nowrap px-6 ${
              activeTab === 'services' 
                ? 'border-primary-600 text-primary-600' 
                : 'border-transparent text-gray-400 hover:text-gray-600'
            }`}
          >
            الخدمات ({userData.stats.service_requests_count})
          </button>
          <button
            onClick={() => setActiveTab('coupons')}
            className={`flex-1 py-4 text-sm font-bold text-center border-b-2 cursor-pointer transition-colors whitespace-nowrap px-6 ${
              activeTab === 'coupons' 
                ? 'border-primary-600 text-primary-600' 
                : 'border-transparent text-gray-400 hover:text-gray-600'
            }`}
          >
            الكوبونات ({userData.stats.coupons_used_count})
          </button>
          <button
            onClick={() => setActiveTab('favorites')}
            className={`flex-1 py-4 text-sm font-bold text-center border-b-2 cursor-pointer transition-colors whitespace-nowrap px-6 ${
              activeTab === 'favorites' 
                ? 'border-primary-600 text-primary-600' 
                : 'border-transparent text-gray-400 hover:text-gray-600'
            }`}
          >
            المفضلة ({userData.favorites_count})
          </button>
        </div>

        {/* Tab Contents */}
        <div className="p-6">
          {activeTab === 'orders' && (
            <div className="overflow-x-auto">
              {userData.recent_orders.length === 0 ? (
                <p className="text-center py-6 text-sm text-gray-400">لا يوجد طلبات سابقة لهذا المستخدم.</p>
              ) : (
                <table className="w-full text-right text-xs">
                  <thead>
                    <tr className="text-gray-400 border-b border-gray-100 dark:border-dark-800 pb-3">
                      <th className="pb-3 font-bold">رقم الطلب</th>
                      <th className="pb-3 font-bold">الحالة</th>
                      <th className="pb-3 font-bold">التاريخ</th>
                      <th className="pb-3 font-bold">عدد المنتجات</th>
                      <th className="pb-3 font-bold">الإجمالي</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100 dark:divide-dark-800">
                    {userData.recent_orders.map((order) => (
                      <tr key={order.id} className="hover:bg-gray-50/50 dark:hover:bg-dark-950/20 transition-colors">
                        <td className="py-4 font-bold text-primary-600 font-mono">{order.order_number}</td>
                        <td className="py-4">
                          <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10px] font-bold ${
                            order.status === 'completed' 
                              ? 'bg-emerald-50 text-emerald-700 dark:bg-emerald-950/20 dark:text-emerald-400' 
                              : order.status === 'cancelled'
                              ? 'bg-red-50 text-red-700 dark:bg-red-950/20 dark:text-red-400'
                              : 'bg-blue-50 text-blue-700 dark:bg-blue-950/20 dark:text-blue-400'
                          }`}>
                            {order.status === 'completed' ? 'مكتمل' : order.status === 'cancelled' ? 'ملغي' : 'قيد المعالجة'}
                          </span>
                        </td>
                        <td className="py-4 text-gray-500">{formatDate(order.created_at)}</td>
                        <td className="py-4 font-bold text-gray-700 dark:text-dark-300">{order.items_count}</td>
                        <td className="py-4 font-bold text-gray-800 dark:text-dark-100">{formatCurrency(order.total)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </div>
          )}

          {activeTab === 'services' && (
            <div className="overflow-x-auto">
              {userData.recent_service_requests.length === 0 ? (
                <p className="text-center py-6 text-sm text-gray-400">لا يوجد حجوزات خدمات سابقة لهذا المستخدم.</p>
              ) : (
                <table className="w-full text-right text-xs">
                  <thead>
                    <tr className="text-gray-400 border-b border-gray-100 dark:border-dark-800 pb-3">
                      <th className="pb-3 font-bold">رقم الحجز</th>
                      <th className="pb-3 font-bold">اسم الخدمة</th>
                      <th className="pb-3 font-bold">الموعد المحجوز</th>
                      <th className="pb-3 font-bold">الحالة</th>
                      <th className="pb-3 font-bold">التكلفة</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100 dark:divide-dark-800">
                    {userData.recent_service_requests.map((sr) => (
                      <tr key={sr.id} className="hover:bg-gray-50/50 dark:hover:bg-dark-950/20 transition-colors">
                        <td className="py-4 font-bold text-amber-600 font-mono">{sr.request_number}</td>
                        <td className="py-4">
                          <div className="flex items-center gap-2">
                            {sr.service_image && (
                              <img src={sr.service_image} alt={sr.service_name} className="w-6 h-6 rounded-lg object-cover" />
                            )}
                            <span className="font-bold text-gray-800 dark:text-dark-200">{sr.service_name}</span>
                          </div>
                        </td>
                        <td className="py-4 text-gray-500 font-mono">{sr.scheduled_at}</td>
                        <td className="py-4">
                          <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10px] font-bold ${
                            sr.status === 'completed' 
                              ? 'bg-emerald-50 text-emerald-700 dark:bg-emerald-950/20 dark:text-emerald-400' 
                              : sr.status === 'cancelled'
                              ? 'bg-red-50 text-red-700 dark:bg-red-950/20 dark:text-red-400'
                              : 'bg-blue-50 text-blue-700 dark:bg-blue-950/20 dark:text-blue-400'
                          }`}>
                            {sr.status === 'completed' ? 'مكتمل' : sr.status === 'cancelled' ? 'ملغي' : 'جديد'}
                          </span>
                        </td>
                        <td className="py-4 font-bold text-gray-800 dark:text-dark-100">{formatCurrency(sr.total_price)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </div>
          )}

          {activeTab === 'coupons' && (
            <div className="overflow-x-auto">
              {userData.coupons_used.length === 0 ? (
                <p className="text-center py-6 text-sm text-gray-400">لم يستخدم أي كوبونات تخفيض حتى الآن.</p>
              ) : (
                <table className="w-full text-right text-xs">
                  <thead>
                    <tr className="text-gray-400 border-b border-gray-100 dark:border-dark-800 pb-3">
                      <th className="pb-3 font-bold">كود الكوبون</th>
                      <th className="pb-3 font-bold">قيمة الخصم</th>
                      <th className="pb-3 font-bold">رقم الطلب المرتبط</th>
                      <th className="pb-3 font-bold">تاريخ الاستخدام</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100 dark:divide-dark-800">
                    {userData.coupons_used.map((coupon, i) => (
                      <tr key={i} className="hover:bg-gray-50/50 dark:hover:bg-dark-950/20 transition-colors">
                        <td className="py-4">
                          <span className="px-2.5 py-1 bg-purple-50 text-purple-700 dark:bg-purple-950/20 dark:text-purple-400 rounded-xl font-bold font-mono">
                            {coupon.coupon_code}
                          </span>
                        </td>
                        <td className="py-4 font-bold text-emerald-600 dark:text-emerald-400">
                          {formatCurrency(coupon.discount_amount)}
                        </td>
                        <td className="py-4 font-mono text-gray-600 dark:text-dark-300">
                          {coupon.order_number || '—'}
                        </td>
                        <td className="py-4 text-gray-500">{formatDate(coupon.used_at)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </div>
          )}

          {activeTab === 'favorites' && (
            <div>
              {/* Fetch real favorites metadata or show placeholder count */}
              <p className="text-center py-6 text-sm text-gray-400">
                لدى المستخدم {userData.favorites_count} منتج في قائمة المفضلة الحالية.
              </p>
            </div>
          )}
        </div>
      </div>

      {/* Toast Popup */}
      <Toast 
        message={toastMessage} 
        type={toastType} 
        onClose={() => setToastMessage('')} 
      />
    </div>
  );
}
