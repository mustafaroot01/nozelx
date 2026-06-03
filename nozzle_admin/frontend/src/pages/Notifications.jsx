import React, { useState, useEffect } from 'react';
import api from '../services/api';
import { 
  Bell, 
  Send, 
  Trash2, 
  Search, 
  Calendar, 
  Clock, 
  Sparkles,
  Smartphone,
  Eye,
  CheckCircle,
  AlertCircle
} from 'lucide-react';

export default function Notifications() {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [modalOpen, setModalOpen] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  // Form states
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [imageUrl, setImageUrl] = useState('');
  const [targetType, setTargetType] = useState('all'); // all, product, category, external
  const [targetId, setTargetId] = useState('');
  const [isScheduled, setIsScheduled] = useState(false);
  const [scheduleTime, setScheduleTime] = useState('');

  useEffect(() => {
    fetchNotifications();
  }, []);

  const fetchNotifications = async () => {
    try {
      setLoading(true);
      const res = await api.get('/notifications');
      setNotifications(res.data);
    } catch (err) {
      console.error('Error fetching notifications:', err);
    } finally {
      setLoading(false);
    }
  };

  const openSendModal = () => {
    setTitle('');
    setBody('');
    setImageUrl('');
    setTargetType('all');
    setTargetId('');
    setIsScheduled(false);
    setScheduleTime('');
    setErrorMessage('');
    setSuccessMessage('');
    setModalOpen(true);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMessage('');
    setSuccessMessage('');

    if (!title || !body) {
      setErrorMessage('عنوان الإشعار ومحتواه مطلوبان');
      return;
    }

    const payload = {
      title,
      body,
      image_url: imageUrl || null,
      target_type: targetType,
      target_id: targetId || null,
      status: isScheduled ? 'scheduled' : 'sent',
      scheduled_at: isScheduled && scheduleTime ? new Date(scheduleTime).toISOString() : null
    };

    try {
      await api.post('/notifications', payload);
      setSuccessMessage(isScheduled ? 'تم جدولة الإشعار بنجاح!' : 'تم إرسال الإشعار بنجاح للعملاء!');
      setTimeout(() => {
        setModalOpen(false);
        fetchNotifications();
      }, 1500);
    } catch (err) {
      const msg = err.response?.data?.detail || 'حدث خطأ أثناء إرسال الإشعار';
      setErrorMessage(msg);
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('هل أنت متأكد من حذف هذا السجل؟')) return;
    try {
      await api.delete(`/notifications/${id}`);
      fetchNotifications();
    } catch (err) {
      alert('حدث خطأ أثناء حذف الإشعار');
    }
  };

  const getStatusBadge = (status) => {
    switch (status) {
      case 'sent':
        return (
          <span className="bg-emerald-50 text-emerald-600 dark:bg-emerald-950/20 dark:text-emerald-400 text-xs px-2.5 py-1 rounded-full border border-emerald-200 dark:border-emerald-900/30 font-bold flex items-center gap-1 w-fit">
            <CheckCircle size={12} /> تم الإرسال
          </span>
        );
      case 'scheduled':
        return (
          <span className="bg-blue-50 text-blue-600 dark:bg-blue-950/20 dark:text-blue-400 text-xs px-2.5 py-1 rounded-full border border-blue-200 dark:border-blue-900/30 font-bold flex items-center gap-1 w-fit">
            <Clock size={12} /> مجدول
          </span>
        );
      default:
        return (
          <span className="bg-rose-50 text-rose-600 dark:bg-rose-950/20 dark:text-rose-400 text-xs px-2.5 py-1 rounded-full border border-rose-200 dark:border-rose-900/30 font-bold flex items-center gap-1 w-fit">
            <AlertCircle size={12} /> فشل الإرسال
          </span>
        );
    }
  };

  const getTargetText = (type, id) => {
    switch (type) {
      case 'all':
        return 'جميع المستخدمين';
      case 'product':
        return `منتج معين (ID: ${id})`;
      case 'category':
        return `قسم معين (ID: ${id})`;
      case 'external':
        return `رابط خارجي (${id})`;
      default:
        return 'عام';
    }
  };

  const filteredNotifications = notifications.filter(notif => 
    notif.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
    notif.body.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="space-y-6">
      {/* Page Title */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-black text-gray-800 dark:text-dark-50">إشعارات الـ Push</h1>
          <p className="text-sm text-gray-400 mt-1">أرسل وجدول الإشعارات الفورية لجميع العملاء عبر Firebase Cloud Messaging.</p>
        </div>
        <button 
          onClick={openSendModal}
          className="bg-primary-600 hover:bg-primary-700 text-white font-bold px-4 py-2.5 rounded-xl flex items-center gap-2 shadow-lg shadow-primary-600/20 transition-all active:scale-95 cursor-pointer"
        >
          <Send size={18} />
          إرسال إشعار جديد
        </button>
      </div>

      {/* Main Container */}
      <div className="bg-white dark:bg-dark-900 rounded-2xl border border-gray-200 dark:border-dark-800 shadow-sm overflow-hidden p-6">
        {/* Search & Actions */}
        <div className="flex items-center gap-4 mb-6">
          <div className="relative flex-1 max-w-md">
            <Search className="absolute right-3.5 top-3.5 text-gray-400" size={18} />
            <input 
              type="text"
              placeholder="البحث في الإشعارات المرسلة..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-4 pr-10 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none text-sm"
            />
          </div>
        </div>

        {loading ? (
          <div className="space-y-4 py-6">
            {[1, 2, 3].map(n => (
              <div key={n} className="h-16 bg-gray-150 dark:bg-dark-800 rounded-xl animate-pulse w-full"></div>
            ))}
          </div>
        ) : filteredNotifications.length === 0 ? (
          <div className="text-center py-16">
            <div className="w-16 h-16 bg-gray-50 dark:bg-dark-800/40 text-gray-400 rounded-full flex items-center justify-center mx-auto mb-4">
              <Bell size={28} />
            </div>
            <h3 className="font-bold text-gray-700 dark:text-dark-300">سجل الإشعارات فارغ</h3>
            <p className="text-sm text-gray-400 mt-1">اضغط على زر "إرسال إشعار جديد" في الأعلى للتواصل مع عملائك.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-right border-collapse">
              <thead>
                <tr className="border-b border-gray-100 dark:border-dark-800 text-gray-400 text-sm font-bold">
                  <th className="pb-3 text-right">الإشعار</th>
                  <th className="pb-3 text-right">الجمهور المستهدف</th>
                  <th className="pb-3 text-right">الحالة</th>
                  <th className="pb-3 text-right">تاريخ الإرسال</th>
                  <th className="pb-3"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-dark-800/60">
                {filteredNotifications.map((notif) => (
                  <tr key={notif.id} className="hover:bg-gray-50/50 dark:hover:bg-dark-800/30 transition-colors">
                    <td className="py-4">
                      <div className="flex items-start gap-3 max-w-lg">
                        {notif.image_url ? (
                          <img 
                            src={notif.image_url} 
                            alt="" 
                            className="w-12 h-12 rounded-lg object-cover flex-shrink-0 border border-gray-100 dark:border-dark-800"
                            onError={(e) => { e.target.style.display = 'none'; }}
                          />
                        ) : (
                          <div className="w-12 h-12 rounded-lg bg-gray-100 dark:bg-dark-850 flex items-center justify-center text-gray-400 flex-shrink-0">
                            <Smartphone size={20} />
                          </div>
                        )}
                        <div>
                          <h4 className="font-bold text-gray-800 dark:text-dark-100 flex items-center gap-1.5">
                            {notif.title}
                          </h4>
                          <p className="text-sm text-gray-400 mt-0.5 line-clamp-2">{notif.body}</p>
                        </div>
                      </div>
                    </td>
                    <td className="py-4">
                      <span className="text-sm font-semibold text-gray-600 dark:text-dark-300">
                        {getTargetText(notif.target_type, notif.target_id)}
                      </span>
                    </td>
                    <td className="py-4">
                      {getStatusBadge(notif.status)}
                    </td>
                    <td className="py-4 text-sm font-semibold text-gray-500">
                      {notif.status === 'scheduled' && notif.scheduled_at ? (
                        <span className="flex items-center gap-1 text-blue-500 font-bold">
                          <Calendar size={14} />
                          {new Date(notif.scheduled_at).toLocaleString('ar-EG')}
                        </span>
                      ) : (
                        new Date(notif.created_at).toLocaleString('ar-EG')
                      )}
                    </td>
                    <td className="py-4 text-left">
                      <button
                        onClick={() => handleDelete(notif.id)}
                        className="p-2 text-gray-400 hover:text-red-600 dark:hover:text-red-400 rounded-lg transition-colors cursor-pointer"
                        title="حذف السجل"
                      >
                        <Trash2 size={16} />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Send Notification Modal */}
      {modalOpen && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4 backdrop-blur-sm">
          <div className="bg-white dark:bg-dark-900 rounded-2xl w-full max-w-lg overflow-hidden shadow-2xl border border-gray-100 dark:border-dark-800 flex flex-col max-h-[90vh]">
            <div className="p-6 border-b border-gray-100 dark:border-dark-800 flex justify-between items-center bg-gray-50/50 dark:bg-dark-900/50">
              <h3 className="font-extrabold text-lg text-gray-800 dark:text-dark-100 flex items-center gap-2">
                <Sparkles className="text-primary-500" size={20} />
                إرسال إشعار جديد للعملاء
              </h3>
              <button 
                onClick={() => setModalOpen(false)}
                className="text-gray-400 hover:text-gray-600 dark:hover:text-dark-200 cursor-pointer"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleSubmit} className="p-6 space-y-4 overflow-y-auto flex-1">
              {errorMessage && (
                <div className="bg-red-50 text-red-500 border border-red-200 p-3 rounded-lg text-sm font-bold">
                  {errorMessage}
                </div>
              )}

              {successMessage && (
                <div className="bg-emerald-50 text-emerald-600 border border-emerald-200 p-3 rounded-lg text-sm font-bold">
                  {successMessage}
                </div>
              )}

              {/* Title */}
              <div>
                <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">عنوان الإشعار</label>
                <input 
                  type="text"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none"
                  placeholder="مثال: خصم 20% لفترة محدودة! 🔥"
                  required
                />
              </div>

              {/* Body */}
              <div>
                <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">محتوى الرسالة</label>
                <textarea 
                  value={body}
                  onChange={(e) => setBody(e.target.value)}
                  className="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none h-24"
                  placeholder="اكتب تفاصيل الإشعار الذي سيظهر للعميل على شاشة هاتفه..."
                  required
                />
              </div>

              {/* Image URL */}
              <div>
                <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">رابط الصورة (اختياري)</label>
                <input 
                  type="text"
                  value={imageUrl}
                  onChange={(e) => setImageUrl(e.target.value)}
                  className="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none text-left"
                  placeholder="https://example.com/banner.jpg"
                />
              </div>

              {/* Target Type */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">الجمهور المستهدف</label>
                  <select
                    value={targetType}
                    onChange={(e) => setTargetType(e.target.value)}
                    className="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none"
                  >
                    <option value="all">كل المشتركين</option>
                    <option value="product">تحويل لمنتج معين</option>
                    <option value="category">تحويل لقسم معين</option>
                    <option value="external">رابط إنترنت خارجي</option>
                  </select>
                </div>

                {targetType !== 'all' && (
                  <div>
                    <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">
                      {targetType === 'external' ? 'الرابط الكامل URL' : 'رقم المعرف ID'}
                    </label>
                    <input 
                      type="text"
                      value={targetId}
                      onChange={(e) => setTargetId(e.target.value)}
                      className="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none text-left"
                      placeholder={targetType === 'external' ? 'https://...' : 'مثال: 5'}
                      required
                    />
                  </div>
                )}
              </div>

              {/* Scheduling Options */}
              <div className="border-t border-gray-150 dark:border-dark-800 pt-4 space-y-4">
                <div className="flex items-center gap-3">
                  <input 
                    type="checkbox" 
                    id="isScheduled"
                    checked={isScheduled}
                    onChange={(e) => setIsScheduled(e.target.checked)}
                    className="w-5 h-5 accent-primary-600 rounded cursor-pointer"
                  />
                  <label htmlFor="isScheduled" className="text-sm font-bold text-gray-700 dark:text-dark-300 cursor-pointer flex items-center gap-1.5">
                    <Clock size={16} className="text-gray-400" /> جدولة إرسال هذا الإشعار لاحقاً
                  </label>
                </div>

                {isScheduled && (
                  <div>
                    <label className="block text-xs font-bold mb-1.5 text-gray-700 dark:text-dark-300">تاريخ ووقت الإرسال</label>
                    <input 
                      type="datetime-local"
                      value={scheduleTime}
                      onChange={(e) => setScheduleTime(e.target.value)}
                      className="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none text-left"
                      required
                    />
                  </div>
                )}
              </div>

              {/* Buttons */}
              <div className="flex gap-3 justify-end pt-4 border-t border-gray-100 dark:border-dark-800">
                <button
                  type="button"
                  onClick={() => setModalOpen(false)}
                  className="px-5 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 text-gray-700 dark:text-dark-300 font-bold hover:bg-gray-50 dark:hover:bg-dark-800/40 cursor-pointer"
                >
                  إلغاء
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 rounded-xl bg-primary-600 hover:bg-primary-700 text-white font-bold shadow-lg shadow-primary-600/10 active:scale-95 cursor-pointer flex items-center gap-2"
                >
                  <Send size={16} />
                  {isScheduled ? 'جدولة الآن' : 'إرسال الإشعار فوراً'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
