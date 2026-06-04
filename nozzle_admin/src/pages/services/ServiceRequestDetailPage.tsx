import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { 
  Printer, 
  ChevronRight, 
  User, 
  Phone, 
  MapPin, 
  Calendar, 
  Clock, 
  DollarSign, 
  MessageSquare,
  Wrench,
  CheckCircle,
  HelpCircle,
  Truck,
  ShieldCheck,
  AlertTriangle,
  UserCheck,
  Send
} from 'lucide-react';
import api from '../../services/api';

export default function ServiceRequestDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [request, setRequest] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Status changer state
  const [status, setStatus] = useState('new');
  const [worker, setWorker] = useState('');
  const [workerPhone, setWorkerPhone] = useState('');
  const [note, setNote] = useState('');
  const [notifyCustomer, setNotifyCustomer] = useState(true);
  const [savingStatus, setSavingStatus] = useState(false);

  // Internal Notes state
  const [internalNote, setInternalNote] = useState('');
  const [savingNote, setSavingNote] = useState(false);

  const fetchRequestDetails = async () => {
    try {
      setLoading(true);
      const res = await api.get(`/v1/admin/service-requests/${id}`);
      const data = res.data.data;
      setRequest(data);
      
      // Sync form state
      setStatus(data.status);
      setWorker(data.assigned_worker || '');
      setWorkerPhone(data.worker_phone || '');
      setInternalNote(data.admin_notes || '');
      setError(null);
    } catch (err) {
      console.error(err);
      setError('فشل تحميل تفاصيل طلب الخدمة.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRequestDetails();
  }, [id]);

  const handleUpdateStatus = async (e) => {
    e.preventDefault();
    setSavingStatus(true);
    try {
      await api.put(`/v1/admin/service-requests/${id}/status`, {
        status,
        note: note.trim() || undefined,
        assigned_worker: worker.trim() || undefined,
        worker_phone: workerPhone.trim() || undefined,
        notify_customer: notifyCustomer
      });
      setNote('');
      fetchRequestDetails();
      alert('تم تحديث حالة الطلب بنجاح وتوثيق التغيير في التايملاين!');
    } catch (err) {
      console.error(err);
      alert('فشل تحديث حالة الحجز.');
    } finally {
      setSavingStatus(false);
    }
  };

  const handleSaveInternalNote = async (e) => {
    e.preventDefault();
    setSavingNote(true);
    try {
      // Modify admin notes directly
      await api.put(`/v1/admin/service-requests/${id}/status`, {
        status: request.status,
        note: `[ملاحظة داخلية]: ${internalNote.trim()}`,
        notify_customer: false
      });
      fetchRequestDetails();
      alert('تم حفظ الملاحظة الداخلية الموثقة بنجاح!');
    } catch (err) {
      console.error(err);
      alert('فشل حفظ الملاحظة.');
    } finally {
      setSavingNote(false);
    }
  };

  const formatPrice = (price) => {
    return new Intl.NumberFormat('ar-IQ', { style: 'currency', currency: 'IQD', maximumFractionDigits: 0 }).format(price);
  };

  const getStatusText = (st) => {
    switch (st) {
      case 'new': return 'جديد قيد الانتظار';
      case 'confirmed': return 'مؤكد ومثبت';
      case 'in_progress': return 'قيد العمل الفني';
      case 'completed': return 'مكتمل بنجاح';
      case 'cancelled': return 'ملغي';
      default: return st;
    }
  };

  const getStatusIcon = (st) => {
    switch (st) {
      case 'new': return <HelpCircle className="w-5 h-5 text-yellow-500" />;
      case 'confirmed': return <ShieldCheck className="w-5 h-5 text-blue-500" />;
      case 'in_progress': return <Truck className="w-5 h-5 text-orange-500" />;
      case 'completed': return <CheckCircle className="w-5 h-5 text-green-500" />;
      case 'cancelled': return <AlertTriangle className="w-5 h-5 text-red-500" />;
      default: return <HelpCircle className="w-5 h-5 text-gray-500" />;
    }
  };

  const getTimelineBadgeColor = (st) => {
    switch (st) {
      case 'new': return 'border-yellow-500 bg-yellow-50 text-yellow-700';
      case 'confirmed': return 'border-blue-500 bg-blue-50 text-blue-700';
      case 'in_progress': return 'border-orange-500 bg-orange-50 text-orange-700';
      case 'completed': return 'border-green-500 bg-green-50 text-green-700';
      case 'cancelled': return 'border-red-500 bg-red-50 text-red-700';
      default: return 'border-gray-500 bg-gray-50';
    }
  };

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center h-96 gap-3">
        <div className="w-10 h-10 border-4 border-primary-600 border-t-transparent rounded-full animate-spin"></div>
        <p className="text-sm text-gray-500">جاري تحميل تفاصيل طلب الخدمة...</p>
      </div>
    );
  }

  if (error || !request) {
    return (
      <div className="p-8 text-center bg-red-50 border border-red-200 text-red-700 rounded-xl space-y-4">
        <p className="font-bold text-lg">{error || 'لم يتم العثور على طلب الخدمة.'}</p>
        <button onClick={() => navigate('/services')} className="px-4 py-2 bg-red-600 text-white rounded-lg text-sm">
          العودة لإدارة الخدمات
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-6 text-right" dir="rtl">
      
      {/* Header section */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white dark:bg-dark-900 p-6 rounded-2xl border border-gray-100 dark:border-dark-800 shadow-sm">
        <div className="space-y-1">
          <div className="flex items-center gap-2 flex-wrap">
            <button
              onClick={() => navigate('/services')}
              className="p-1 hover:bg-gray-100 dark:hover:bg-dark-800 rounded-full text-gray-400"
            >
              <ChevronRight className="w-6 h-6" />
            </button>
            <h1 className="text-2xl font-extrabold text-gray-900 dark:text-white">
              طلب حجز خدمة رقم {request.request_number}
            </h1>
            <div className="flex items-center gap-1.5 mr-2">
              {getStatusIcon(request.status)}
              <span className="text-sm font-bold text-gray-700 dark:text-dark-200">{getStatusText(request.status)}</span>
            </div>
          </div>
          <p className="text-xs text-gray-500 mr-8">
            تاريخ تسجيل الطلب: {new Date(request.created_at).toLocaleString('ar-IQ')}
          </p>
        </div>
        
        <div className="flex items-center gap-2 mr-8 md:mr-0">
          <button
            onClick={() => navigate(`/services/requests/${id}/print`)}
            className="flex items-center gap-1.5 px-4 py-2 bg-gray-100 hover:bg-gray-200 dark:bg-dark-800 dark:hover:bg-dark-700 text-gray-700 dark:text-dark-100 rounded-lg text-sm font-semibold transition-colors"
          >
            <Printer className="w-4 h-4" />
            <span>طباعة وتصدير PDF</span>
          </button>
        </div>
      </div>

      {/* 4 Summary Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-white dark:bg-dark-900 p-5 rounded-xl border border-gray-100 dark:border-dark-800 shadow-sm flex items-center gap-4">
          <div className="p-2.5 bg-blue-50 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400 rounded-lg">
            <Calendar className="w-5 h-5" />
          </div>
          <div>
            <p className="text-xs text-gray-400">تاريخ الطلب</p>
            <p className="font-bold text-sm text-gray-800 dark:text-white">
              {new Date(request.created_at).toLocaleDateString('ar-IQ')}
            </p>
          </div>
        </div>

        <div className="bg-white dark:bg-dark-900 p-5 rounded-xl border border-gray-100 dark:border-dark-800 shadow-sm flex items-center gap-4">
          <div className="p-2.5 bg-yellow-50 dark:bg-yellow-900/20 text-yellow-600 dark:text-yellow-400 rounded-lg">
            <Clock className="w-5 h-5" />
          </div>
          <div>
            <p className="text-xs text-gray-400">الموعد المحدد للعمل</p>
            <p className="font-bold text-sm text-gray-800 dark:text-white">
              {request.scheduled_date} | {request.scheduled_time}
            </p>
          </div>
        </div>

        <div className="bg-white dark:bg-dark-900 p-5 rounded-xl border border-gray-100 dark:border-dark-800 shadow-sm flex items-center gap-4">
          <div className="p-2.5 bg-green-50 dark:bg-green-900/20 text-green-600 dark:text-green-400 rounded-lg">
            <DollarSign className="w-5 h-5" />
          </div>
          <div>
            <p className="text-xs text-gray-400">المبلغ الكلي المستحق</p>
            <p className="font-extrabold text-sm text-green-600 dark:text-green-400">
              {formatPrice(request.total_price)}
            </p>
          </div>
        </div>

        <div className="bg-white dark:bg-dark-900 p-5 rounded-xl border border-gray-100 dark:border-dark-800 shadow-sm flex items-center gap-4">
          <div className="p-2.5 bg-purple-50 dark:bg-purple-900/20 text-purple-600 dark:text-purple-400 rounded-lg">
            <ShieldCheck className="w-5 h-5" />
          </div>
          <div>
            <p className="text-xs text-gray-400">طريقة وحالة الدفع</p>
            <p className="font-bold text-sm text-gray-800 dark:text-white">
              {request.payment_method === 'cash' ? 'كاش عند الحضور' : request.payment_method} |{' '}
              <span className={request.payment_status === 'paid' ? 'text-green-600' : 'text-red-500'}>
                {request.payment_status === 'paid' ? 'تم الدفع ✅' : 'معلق ⏳'}
              </span>
            </p>
          </div>
        </div>
      </div>

      {/* Main Content Grid (2 columns) */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
        
        {/* Left Column (Customer Details, Service details, notes) */}
        <div className="lg:col-span-2 space-y-6">
          
          {/* Customer details card */}
          <div className="bg-white dark:bg-dark-900 p-6 rounded-xl border border-gray-100 dark:border-dark-800 shadow-sm space-y-4">
            <h3 className="text-lg font-bold text-gray-900 dark:text-white flex items-center gap-2 border-b border-gray-100 dark:border-dark-800 pb-3">
              <User className="w-5 h-5 text-primary-600" />
              <span>👤 بيانات العميل وبيانات الاتصال</span>
            </h3>
            
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
              <div className="flex flex-col gap-1">
                <span className="text-gray-400 text-xs">الاسم الكامل</span>
                <span className="font-semibold text-gray-900 dark:text-white">{request.customer_name}</span>
              </div>

              <div className="flex flex-col gap-1">
                <span className="text-gray-400 text-xs">رقم الهاتف</span>
                <span className="font-semibold text-gray-900 dark:text-white flex items-center gap-2">
                  <span>{request.customer_phone}</span>
                  <a
                    href={`tel:${request.customer_phone}`}
                    className="px-2 py-0.5 bg-blue-50 hover:bg-blue-100 text-blue-600 dark:bg-blue-900/20 dark:text-blue-400 rounded text-xs"
                  >
                    اتصال
                  </a>
                  <a
                    href={`https://wa.me/${request.customer_phone.replace(/^0/, '964')}`}
                    target="_blank"
                    rel="noreferrer"
                    className="px-2 py-0.5 bg-green-50 hover:bg-green-100 text-green-600 dark:bg-green-900/20 dark:text-green-400 rounded text-xs"
                  >
                    واتساب
                  </a>
                </span>
              </div>

              <div className="flex flex-col gap-1 sm:col-span-2">
                <span className="text-gray-400 text-xs">العنوان الجغرافي المحدد</span>
                <span className="font-semibold text-gray-950 dark:text-white flex items-center gap-1.5">
                  <MapPin className="w-4 h-4 text-red-500 shrink-0" />
                  <span>{request.address}</span>
                  {request.latitude && request.longitude && (
                    <a
                      href={`https://www.google.com/maps/search/?api=1&query=${request.latitude},${request.longitude}`}
                      target="_blank"
                      rel="noreferrer"
                      className="px-2.5 py-0.5 bg-red-50 text-red-600 text-xs rounded font-bold mr-2 hover:bg-red-100"
                    >
                      موقع خرائط Google
                    </a>
                  )}
                </span>
              </div>
            </div>
          </div>

          {/* Service details card */}
          <div className="bg-white dark:bg-dark-900 p-6 rounded-xl border border-gray-100 dark:border-dark-800 shadow-sm space-y-4">
            <h3 className="text-lg font-bold text-gray-900 dark:text-white flex items-center gap-2 border-b border-gray-100 dark:border-dark-800 pb-3">
              <Wrench className="w-5 h-5 text-primary-600" />
              <span>🔧 تفاصيل الخدمة والخيارات التابعة</span>
            </h3>

            {request.service && (
              <div className="flex gap-4 items-center">
                <img
                  src={request.service.image_url ? (request.service.image_url.startsWith('http') ? request.service.image_url : `${api.defaults.baseURL.replace('/api', '')}${request.service.image_url}`) : '/placeholder-image.jpg'}
                  alt={request.service.name}
                  className="w-20 h-16 rounded object-cover border border-gray-100 shrink-0"
                  onError={(e) => { e.target.src = 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=500&auto=format&fit=crop'; }}
                />
                <div className="space-y-1">
                  <h4 className="font-bold text-gray-900 dark:text-white">
                    {request.service.icon_emoji} {request.service.name}
                  </h4>
                  <p className="text-xs text-gray-500">الفئة التابعة: {request.service.category || 'صيانة وتأهيل'}</p>
                  
                  {request.option && (
                    <div className="text-xs text-primary-600 dark:text-primary-400 font-bold bg-primary-50 dark:bg-primary-950/20 px-2 py-0.5 rounded inline-block">
                      الخيار المضاف: {request.option.name} (+ {formatPrice(request.option.extra_price)})
                    </div>
                  )}
                </div>
              </div>
            )}

            <div className="grid grid-cols-2 gap-4 border-t border-gray-100 dark:border-dark-800 pt-4 text-xs">
              <div>
                <p className="text-gray-400">سعر الخدمة الأساسي</p>
                <p className="font-bold text-gray-900 dark:text-white">
                  {request.service ? formatPrice(request.service.base_price) : formatPrice(0)}
                </p>
              </div>
              <div>
                <p className="text-gray-400">إضافي الباقة المحددة</p>
                <p className="font-bold text-gray-900 dark:text-white">
                  {request.option ? formatPrice(request.option.extra_price) : formatPrice(0)}
                </p>
              </div>
            </div>
          </div>

          {/* Customer notes card */}
          {request.notes && (
            <div className="bg-white dark:bg-dark-900 p-6 rounded-xl border border-gray-100 dark:border-dark-800 shadow-sm space-y-3">
              <h3 className="text-sm font-bold text-gray-900 dark:text-white flex items-center gap-1.5">
                <MessageSquare className="w-4 h-4 text-primary-600" />
                <span>📝 ملاحظات وتوجيهات العميل</span>
              </h3>
              <p className="text-sm text-gray-600 dark:text-dark-200 bg-gray-50 dark:bg-dark-950 p-4 rounded-lg leading-relaxed border border-gray-100 dark:border-dark-850">
                {request.notes}
              </p>
            </div>
          )}

          {/* Booking Request Logs Timeline */}
          <div className="bg-white dark:bg-dark-900 p-6 rounded-xl border border-gray-100 dark:border-dark-800 shadow-sm space-y-6">
            <h3 className="text-lg font-bold text-gray-900 dark:text-white flex items-center gap-2 border-b border-gray-100 dark:border-dark-800 pb-3">
              <Clock className="w-5 h-5 text-primary-600" />
              <span>📊 سجل حركة الحالات والتايملاين</span>
            </h3>

            <div className="relative border-r-2 border-gray-200 dark:border-dark-800 mr-4 pl-0 pr-6 space-y-6">
              {request.status_history.map((log) => (
                <div key={log.id} className="relative">
                  {/* Dot indicator */}
                  <span className={`absolute -right-[31px] top-1.5 w-4 h-4 rounded-full border-2 bg-white dark:bg-dark-900 ${
                    log.new_status === 'completed' ? 'border-green-500' :
                    log.new_status === 'cancelled' ? 'border-red-500' :
                    log.new_status === 'in_progress' ? 'border-orange-500' :
                    log.new_status === 'confirmed' ? 'border-blue-500' : 'border-yellow-500'
                  }`} />
                  
                  <div className="space-y-1">
                    <div className="flex items-center gap-2 flex-wrap">
                      <span className={`px-2 py-0.5 rounded text-[10px] font-bold border ${getTimelineBadgeColor(log.new_status)}`}>
                        {getStatusText(log.new_status)}
                      </span>
                      <span className="text-xs text-gray-400">
                        {new Date(log.created_at).toLocaleString('ar-IQ')}
                      </span>
                      {log.changed_by && (
                        <span className="text-xs text-gray-500 dark:text-dark-300">
                          بواسطة: <b>{log.changed_by}</b>
                        </span>
                      )}
                    </div>
                    {log.note && (
                      <p className="text-xs text-gray-600 dark:text-dark-200 mt-1 pl-2">
                        {log.note}
                      </p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>

        </div>

        {/* Right Column (Change status controls, Internal Notes) */}
        <div className="space-y-6">
          
          {/* Change Status Card */}
          <div className="bg-white dark:bg-dark-900 p-6 rounded-xl border border-gray-100 dark:border-dark-800 shadow-sm space-y-4">
            <h3 className="text-md font-bold text-gray-900 dark:text-white flex items-center gap-2 border-b border-gray-100 dark:border-dark-800 pb-3">
              <UserCheck className="w-5 h-5 text-primary-600" />
              <span>📊 تغيير حالة الطلب وتعيين الفريق</span>
            </h3>

            <form onSubmit={handleUpdateStatus} className="space-y-4 text-xs font-semibold">
              <div className="space-y-1">
                <label className="text-gray-400">تحديث الحالة إلى</label>
                <select
                  value={status}
                  onChange={(e) => setStatus(e.target.value)}
                  className="w-full px-3 py-2 text-sm border border-gray-200 dark:border-dark-800 rounded-lg dark:bg-dark-950 focus:outline-none"
                >
                  <option value="new">جديد قيد الانتظار</option>
                  <option value="confirmed">تأكيد الموعد</option>
                  <option value="in_progress">قيد التنفيذ والعمل</option>
                  <option value="completed">مكتمل بنجاح</option>
                  <option value="cancelled">ملغي</option>
                </select>
              </div>

              <div className="space-y-1">
                <label className="text-gray-400">المسؤول المعين للمهمة</label>
                <input
                  type="text"
                  value={worker}
                  onChange={(e) => setWorker(e.target.value)}
                  placeholder="مثال: أحمد محمد"
                  className="w-full px-3 py-2 text-sm border border-gray-200 dark:border-dark-800 rounded-lg dark:bg-dark-950 focus:outline-none"
                />
              </div>

              <div className="space-y-1">
                <label className="text-gray-400">رقم هاتف المنفذ</label>
                <input
                  type="text"
                  value={workerPhone}
                  onChange={(e) => setWorkerPhone(e.target.value)}
                  placeholder="مثال: 0790XXXXXXX"
                  className="w-full px-3 py-2 text-sm border border-gray-200 dark:border-dark-800 rounded-lg dark:bg-dark-950 focus:outline-none"
                />
              </div>

              <div className="space-y-1">
                <label className="text-gray-400">ملاحظة التغيير (تظهر للعميل كشرح للتايملاين)</label>
                <textarea
                  rows="2"
                  value={note}
                  onChange={(e) => setNote(e.target.value)}
                  placeholder="مثال: تم التوجيه والتحرك من الفريق الميداني..."
                  className="w-full px-3 py-2 text-sm border border-gray-200 dark:border-dark-800 rounded-lg dark:bg-dark-950 focus:outline-none"
                />
              </div>

              <div className="space-y-2 pt-2">
                <label className="flex items-center gap-2 cursor-pointer text-xs font-semibold text-gray-500">
                  <input
                    type="checkbox"
                    checked={notifyCustomer}
                    onChange={(e) => setNotifyCustomer(e.target.checked)}
                    className="rounded text-primary-600 focus:ring-primary-600 h-4 w-4"
                  />
                  <span>إرسال إشعار فوري للعميل بالتطبيق</span>
                </label>
              </div>

              <button
                type="submit"
                disabled={savingStatus}
                className="w-full py-2.5 bg-primary-600 hover:bg-primary-700 text-white rounded-lg font-bold text-sm transition-colors flex items-center justify-center gap-1.5 disabled:opacity-50"
              >
                {savingStatus && <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>}
                <span>حفظ التغيير وتعيين المنفّذ</span>
              </button>
            </form>
          </div>

          {/* Internal Admin Notes Card */}
          <div className="bg-white dark:bg-dark-900 p-6 rounded-xl border border-gray-100 dark:border-dark-800 shadow-sm space-y-4">
            <h3 className="text-md font-bold text-gray-900 dark:text-white flex items-center gap-2 border-b border-gray-100 dark:border-dark-800 pb-3">
              <MessageSquare className="w-5 h-5 text-primary-600" />
              <span>📋 ملاحظات داخلية (الإدارة فقط)</span>
            </h3>

            <form onSubmit={handleSaveInternalNote} className="space-y-4">
              <textarea
                rows="4"
                value={internalNote}
                onChange={(e) => setInternalNote(e.target.value)}
                placeholder="اكتب ملاحظات داخلية سرية لا تظهر للزبون..."
                className="w-full p-3 text-sm border border-gray-200 dark:border-dark-800 rounded-lg dark:bg-dark-950 focus:outline-none focus:ring-1 focus:ring-primary-600"
              />
              <button
                type="submit"
                disabled={savingNote}
                className="w-full py-2 bg-gray-100 hover:bg-gray-200 dark:bg-dark-800 dark:hover:bg-dark-700 text-gray-700 dark:text-dark-100 rounded-lg font-bold text-sm transition-colors flex items-center justify-center gap-1"
              >
                {savingNote && <div className="w-4 h-4 border-2 border-gray-700 dark:border-dark-100 border-t-transparent rounded-full animate-spin"></div>}
                <Send className="w-4 h-4" />
                <span>حفظ الملاحظة السرية</span>
              </button>
            </form>
          </div>

        </div>

      </div>
    </div>
  );
}
