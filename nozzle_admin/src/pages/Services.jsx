import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Wrench, 
  Calendar, 
  Clock, 
  User, 
  Car, 
  FileText, 
  Check, 
  X, 
  Plus, 
  Edit2, 
  Trash2, 
  Search, 
  DollarSign, 
  Activity,
  Phone,
  MapPin,
  RefreshCw,
  CheckCircle2,
  XCircle,
  AlertCircle,
  Printer,
  ChevronLeft
} from 'lucide-react';
import api from '../services/api';
import ImageUploader from '../components/ui/ImageUploader';

export default function Services() {
  const [activeTab, setActiveTab] = useState('bookings'); // bookings, catalog
  const [loading, setLoading] = useState(true);
  const [services, setServices] = useState([]);
  const [bookings, setBookings] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');

  // Modals state
  const [serviceModal, setServiceModal] = useState({
    open: false,
    service: null, // null for add
    name: '',
    name_en: '',
    description: '',
    icon: 'build',
    image: '',
    price: '',
    duration_minutes: '30',
    is_active: true
  });

  const [selectedBooking, setSelectedBooking] = useState(null); // Detailed view

  const [successMessage, setSuccessMessage] = useState('');
  const [errorMessage, setErrorMessage] = useState('');

  const showSuccess = (msg) => {
    setSuccessMessage(msg);
    setTimeout(() => setSuccessMessage(''), 4000);
  };

  const showError = (msg) => {
    setErrorMessage(msg);
    setTimeout(() => setErrorMessage(''), 4000);
  };

  // Fetch Services & Bookings
  const fetchServicesAndBookings = async () => {
    try {
      setLoading(true);
      const [servicesRes, bookingsRes] = await Promise.all([
        api.get('/services'),
        api.get('/services/bookings/all')
      ]);

      if (servicesRes.data && servicesRes.data.status === 'success') {
        setServices(servicesRes.data.data);
      }
      
      if (bookingsRes.data && bookingsRes.data.status === 'success') {
        setBookings(bookingsRes.data.data);
      }
    } catch (err) {
      console.error('Error fetching services/bookings:', err);
      showError('فشل تحميل بيانات الخدمات والحجوزات.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchServicesAndBookings();
  }, []);

  // Handle Booking Status Update
  const handleUpdateStatus = async (bookingId, newStatus) => {
    try {
      const res = await api.put(`/services/bookings/${bookingId}/status`, { status: newStatus });
      if (res.data && res.data.status === 'success') {
        showSuccess('تم تحديث حالة الحجز بنجاح!');
        // Update selectedBooking state in GUI if open
        if (selectedBooking && selectedBooking.id === bookingId) {
          setSelectedBooking(prev => ({ ...prev, status: newStatus }));
        }
        fetchServicesAndBookings();
      }
    } catch (err) {
      console.error('Error updating booking status:', err);
      showError('فشل تحديث حالة الحجز.');
    }
  };

  // Handle Service Submit (Create/Update)
  const handleServiceSubmit = async (e) => {
    e.preventDefault();
    try {
      const payload = {
        name: serviceModal.name,
        name_en: serviceModal.name_en || null,
        description: serviceModal.description || null,
        icon: serviceModal.icon,
        image: serviceModal.image || null,
        price: parseFloat(serviceModal.price),
        duration_minutes: parseInt(serviceModal.duration_minutes),
        is_active: serviceModal.is_active
      };

      let res;
      if (serviceModal.service) {
        res = await api.put(`/services/${serviceModal.service.id}`, payload);
      } else {
        res = await api.post('/services', payload);
      }

      if (res.data && res.data.status === 'success') {
        showSuccess(serviceModal.service ? 'تم تعديل الخدمة بنجاح!' : 'تم إضافة الخدمة بنجاح!');
        setServiceModal({ open: false, service: null, name: '', name_en: '', description: '', icon: 'build', image: '', price: '', duration_minutes: '30', is_active: true });
        fetchServicesAndBookings();
      }
    } catch (err) {
      console.error('Error saving service:', err);
      showError('فشل حفظ الخدمة بالخادم.');
    }
  };

  // Open Edit Service Modal
  const openEditService = (service) => {
    setServiceModal({
      open: true,
      service,
      name: service.title_ar || service.name || '',
      name_en: service.title || service.name_en || '',
      description: service.description || '',
      icon: service.icon || 'build',
      image: service.image || '',
      price: service.price || '',
      duration_minutes: String(service.duration_minutes || '30'),
      is_active: service.is_active !== false
    });
  };

  // Handle Service Delete
  const handleDeleteService = async (serviceId) => {
    if (!window.confirm('هل أنت متأكد من رغبتك في إيقاف/حذف هذه الخدمة؟')) return;
    try {
      const res = await api.delete(`/services/${serviceId}`);
      if (res.data && res.data.status === 'success') {
        showSuccess('تم إيقاف الخدمة بنجاح!');
        fetchServicesAndBookings();
      }
    } catch (err) {
      console.error('Error deleting service:', err);
      showError('فشل حذف الخدمة.');
    }
  };

  // Receipt Printing Feature
  const handlePrintBooking = (booking) => {
    const printWindow = window.open('', '_blank');
    const invoiceHTML = `
      <html>
        <head>
          <title>وصل حجز موعد الخدمة #${booking.id}</title>
          <style>
            @import url('https://fonts.googleapis.com/css2?family=Cairo:wght@400;700;900&display=swap');
            body {
              font-family: 'Cairo', sans-serif;
              direction: rtl;
              text-align: right;
              padding: 40px;
              color: #1e293b;
              background: #fff;
            }
            .header {
              display: flex;
              justify-content: space-between;
              align-items: center;
              border-bottom: 2px solid #e2e8f0;
              padding-bottom: 20px;
              margin-bottom: 30px;
            }
            .logo {
              font-size: 24px;
              font-weight: 900;
              color: #1e4db7;
            }
            .invoice-title {
              font-size: 20px;
              font-weight: 700;
              color: #0f172a;
            }
            .info-grid {
              display: grid;
              grid-template-columns: 1fr 1fr;
              gap: 20px;
              margin-bottom: 40px;
            }
            .info-card {
              background: #f8fafc;
              padding: 20px;
              border-radius: 12px;
              border: 1px solid #f1f5f9;
            }
            .info-card h3 {
              margin-top: 0;
              margin-bottom: 15px;
              font-size: 15px;
              color: #475569;
              border-bottom: 1px solid #cbd5e1;
              padding-bottom: 8px;
            }
            .info-row {
              display: flex;
              justify-content: space-between;
              margin-bottom: 8px;
              font-size: 14px;
            }
            .info-label {
              color: #64748b;
              font-weight: 700;
            }
            .info-value {
              font-weight: 900;
              color: #0f172a;
            }
            .table-container {
              margin-bottom: 40px;
            }
            table {
              width: 100%;
              border-collapse: collapse;
              margin-top: 15px;
            }
            th, td {
              padding: 12px;
              border-bottom: 1px solid #e2e8f0;
              text-align: right;
            }
            th {
              background: #f1f5f9;
              color: #475569;
              font-weight: 700;
            }
            td {
              color: #0f172a;
            }
            .total-section {
              text-align: left;
              font-size: 18px;
              font-weight: 900;
              margin-top: 20px;
              padding-top: 15px;
              border-top: 2px solid #e2e8f0;
              color: #1e4db7;
            }
            .footer {
              text-align: center;
              margin-top: 60px;
              font-size: 12px;
              color: #94a3b8;
              border-top: 1px dashed #cbd5e1;
              padding-top: 20px;
            }
            @media print {
              body { padding: 0; }
            }
          </style>
        </head>
        <body>
          <div class="header">
            <div class="logo">مركز نوزل للصيانة</div>
            <div class="invoice-title">تفاصيل موعد حجز #${booking.id}</div>
          </div>
          
          <div class="info-grid">
            <div class="info-card">
              <h3>معلومات العميل</h3>
              <div class="info-row">
                <span class="info-label">الاسم الكامل:</span>
                <span class="info-value">${booking.customer_name || 'غير معروف'}</span>
              </div>
              <div class="info-row">
                <span class="info-label">رقم الهاتف:</span>
                <span class="info-value">${booking.customer_phone || '-'}</span>
              </div>
              <div class="info-row">
                <span class="info-label">المنطقة / القضاء:</span>
                <span class="info-value">${booking.customer_district || '-'}</span>
              </div>
            </div>
            
            <div class="info-card">
              <h3>معلومات السيارة والموعد</h3>
              <div class="info-row">
                <span class="info-label">نوع وموديل السيارة:</span>
                <span class="info-value">${booking.car_model || '-'}</span>
              </div>
              <div class="info-row">
                <span class="info-label">رقم لوحة السيارة:</span>
                <span class="info-value">${booking.car_number || '-'}</span>
              </div>
              <div class="info-row">
                <span class="info-label">التاريخ والوقت:</span>
                <span class="info-value">${booking.preferred_date} - ${booking.preferred_time}</span>
              </div>
            </div>
          </div>
          
          <div class="table-container">
            <h3>الخدمة المطلوبة</h3>
            <table>
              <thead>
                <tr>
                  <th>الخدمة</th>
                  <th>المدة التقديرية</th>
                  <th>السعر التقديري</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td><strong>${booking.service_name}</strong></td>
                  <td>${booking.duration_minutes || 30} دقيقة</td>
                  <td>${(booking.price || 0).toLocaleString()} د.ع</td>
                </tr>
              </tbody>
            </table>
            
            <div class="total-section">
              التكلفة الإجمالية الكلية: ${(booking.price || 0).toLocaleString()} د.ع
            </div>
          </div>
          
          ${booking.notes ? `
          <div class="info-card" style="margin-top: 20px;">
            <h3>ملاحظات وتفاصيل الحجز</h3>
            <p style="font-size: 14px; margin: 0; line-height: 1.6;">${booking.notes}</p>
          </div>
          ` : ''}
          
          <div class="footer">
            شكراً لاختياركم مركز نوزل للصيانة • تم إنشاء هذا التقرير تلقائياً بواسطة لوحة التحكم
          </div>
          
          <script>
            window.onload = function() {
              window.print();
              setTimeout(function() { window.close(); }, 500);
            };
          </script>
        </body>
      </html>
    `;
    printWindow.document.write(invoiceHTML);
    printWindow.document.close();
  };

  // Filter Bookings
  const filteredBookings = bookings.filter(b => {
    const query = searchTerm.toLowerCase();
    const matchesSearch = 
      (b.customer_name && b.customer_name.toLowerCase().includes(query)) ||
      (b.customer_phone && b.customer_phone.toLowerCase().includes(query)) ||
      (b.service_name && b.service_name.toLowerCase().includes(query)) ||
      (b.car_model && b.car_model.toLowerCase().includes(query));

    const matchesStatus = statusFilter === 'all' || b.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const getStatusBadgeClass = (status) => {
    switch (status) {
      case 'pending': return 'bg-orange-100 text-orange-800 border-orange-200';
      case 'confirmed': return 'bg-blue-100 text-blue-800 border-blue-200';
      case 'completed': return 'bg-emerald-100 text-emerald-800 border-emerald-200';
      case 'cancelled': return 'bg-red-100 text-red-800 border-red-200';
      default: return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const getStatusLabel = (status) => {
    switch (status) {
      case 'pending': return 'معلق';
      case 'confirmed': return 'مؤكد';
      case 'completed': return 'مكتمل';
      case 'cancelled': return 'ملغي';
      default: return status;
    }
  };

  return (
    <div className="space-y-8 font-cairo text-right" dir="rtl">
      {/* Top Banner Alert */}
      <AnimatePresence>
        {successMessage && (
          <motion.div 
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="fixed top-6 left-6 right-6 md:left-auto md:w-96 bg-emerald-50 border-r-4 border-emerald-500 p-4 rounded-xl shadow-lg z-50 flex items-center gap-3"
          >
            <CheckCircle2 className="text-emerald-500 flex-shrink-0" size={24} />
            <span className="text-sm font-bold text-emerald-800">{successMessage}</span>
          </motion.div>
        )}
        {errorMessage && (
          <motion.div 
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="fixed top-6 left-6 right-6 md:left-auto md:w-96 bg-red-50 border-r-4 border-red-500 p-4 rounded-xl shadow-lg z-50 flex items-center gap-3"
          >
            <XCircle className="text-red-500 flex-shrink-0" size={24} />
            <span className="text-sm font-bold text-red-800">{errorMessage}</span>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight flex items-center gap-3">
            <Wrench className="text-primary-600" size={32} />
            <span>نظام الخدمات والحجوزات</span>
          </h1>
          <p className="text-gray-500 mt-1.5 text-sm">
            إدارة قائمة الخدمات المتوفرة بالتطبيق وتتبع طلبات حجوزات صيانة السيارات ومواعيدها.
          </p>
        </div>
        {activeTab === 'catalog' && (
          <button
            onClick={() => setServiceModal({
              open: true,
              service: null,
              name: '',
              name_en: '',
              description: '',
              icon: 'build',
              image: '',
              price: '',
              duration_minutes: '30',
              is_active: true
            })}
            className="px-4 py-2.5 rounded-xl bg-primary-600 hover:bg-primary-700 text-white font-bold text-sm shadow-md transition-all flex items-center gap-2 self-start md:self-auto"
          >
            <Plus size={18} />
            <span>إضافة خدمة جديدة</span>
          </button>
        )}
      </div>

      {/* Tabs */}
      <div className="flex border-b border-gray-200">
        <button
          onClick={() => setActiveTab('bookings')}
          className={`flex items-center gap-2 px-6 py-4 font-bold text-sm border-b-2 transition-all ${
            activeTab === 'bookings'
              ? 'border-primary-600 text-primary-600'
              : 'border-transparent text-gray-500 hover:text-gray-800'
          }`}
        >
          <Calendar size={18} />
          <span>طلبات الحجوزات</span>
        </button>
        <button
          onClick={() => setActiveTab('catalog')}
          className={`flex items-center gap-2 px-6 py-4 font-bold text-sm border-b-2 transition-all ${
            activeTab === 'catalog'
              ? 'border-primary-600 text-primary-600'
              : 'border-transparent text-gray-500 hover:text-gray-800'
          }`}
        >
          <Wrench size={18} />
          <span>دليل الخدمات</span>
        </button>
      </div>

      {/* TAB CONTENT: BOOKINGS */}
      {activeTab === 'bookings' && (
        <div className="space-y-6">
          {/* Filters */}
          <div className="bg-white p-5 rounded-3xl border border-gray-100 shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div className="relative flex-grow max-w-md">
              <Search className="absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
              <input
                type="text"
                placeholder="ابحث باسم الزبون، الهاتف، السيارة أو الخدمة..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-4 pr-10 py-3 rounded-2xl bg-gray-50 border-0 focus:ring-2 focus:ring-primary-600 focus:bg-white text-sm outline-none transition-all"
              />
            </div>

            <div className="flex items-center gap-2">
              <span className="text-xs font-bold text-gray-400">حالة الحجز:</span>
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="bg-gray-50 border-0 rounded-xl px-4 py-2.5 text-sm font-bold text-gray-700 outline-none focus:ring-2 focus:ring-primary-600"
              >
                <option value="all">كل الحجوزات</option>
                <option value="pending">معلق</option>
                <option value="confirmed">مؤكد</option>
                <option value="completed">مكتمل</option>
                <option value="cancelled">ملغي</option>
              </select>
            </div>
          </div>

          {/* Bookings Table */}
          <div className="bg-white rounded-3xl border border-gray-100 shadow-sm overflow-hidden">
            {loading ? (
              <div className="p-12 text-center">
                <div className="w-10 h-10 border-4 border-primary-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
                <p className="text-gray-500 font-bold text-sm">جاري تحميل طلبات الحجوزات...</p>
              </div>
            ) : filteredBookings.length === 0 ? (
              <div className="p-12 text-center text-gray-400">
                <Calendar size={48} className="mx-auto mb-3 opacity-55" />
                <p className="font-bold">لا توجد حجوزات مسجلة حالياً.</p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-right border-collapse">
                  <thead>
                    <tr className="bg-gray-50 border-b border-gray-100 text-gray-500 text-xs font-bold uppercase">
                      <th className="px-6 py-4.5">رقم الحجز</th>
                      <th className="px-6 py-4.5">الزبون</th>
                      <th className="px-6 py-4.5">الخدمة المطلوبة</th>
                      <th className="px-6 py-4.5">السيارة</th>
                      <th className="px-6 py-4.5">التاريخ والوقت</th>
                      <th className="px-6 py-4.5">الحالة</th>
                      <th className="px-6 py-4.5 text-left">الإجراءات</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100 text-sm">
                    {filteredBookings.map((b) => (
                      <tr 
                        key={b.id} 
                        className="hover:bg-gray-50/50 cursor-pointer transition-colors"
                        onClick={() => setSelectedBooking(b)}
                      >
                        <td className="px-6 py-4 font-mono font-bold text-gray-400">
                          #{b.id}
                        </td>
                        <td className="px-6 py-4">
                          <div>
                            <h4 className="font-bold text-gray-950 flex items-center gap-1">
                              <User size={14} className="text-gray-400" />
                              {b.customer_name || 'زبون غير معروف'}
                            </h4>
                            <span className="text-xs text-gray-400 flex items-center gap-1 mt-0.5">
                              <Phone size={12} className="text-gray-300" />
                              {b.customer_phone || '-'}
                            </span>
                            {b.customer_district && (
                              <span className="text-[10px] bg-gray-100 text-gray-600 px-1.5 py-0.5 rounded font-bold mt-1 block w-fit">
                                <MapPin size={10} className="inline mr-1" />
                                {b.customer_district}
                              </span>
                            )}
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <div>
                            <span className="font-extrabold text-primary-700">{b.service_name}</span>
                            <span className="text-xs text-gray-400 block mt-0.5">السعر: {(b.price || 0).toLocaleString()} د.ع</span>
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <span className="font-bold text-gray-600 flex items-center gap-1">
                            <Car size={14} className="text-gray-400" />
                            {b.car_model || '-'} {b.car_number ? `(${b.car_number})` : ''}
                          </span>
                        </td>
                        <td className="px-6 py-4">
                          <div>
                            <span className="font-extrabold text-gray-800">{b.preferred_date}</span>
                            <span className="text-xs text-gray-400 block mt-0.5 flex items-center gap-1">
                              <Clock size={12} className="text-gray-300" />
                              {b.preferred_time}
                            </span>
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <span className={`px-2.5 py-1 rounded-full text-xs font-bold border ${getStatusBadgeClass(b.status)}`}>
                            {getStatusLabel(b.status)}
                          </span>
                        </td>
                        <td className="px-6 py-4 text-left" onClick={(e) => e.stopPropagation()}>
                          <div className="flex items-center justify-end gap-1.5">
                            <button
                              onClick={() => handlePrintBooking(b)}
                              className="p-1.5 rounded-lg bg-gray-100 text-gray-600 hover:bg-gray-200 transition-all"
                              title="طباعة الوصل"
                            >
                              <Printer size={14} />
                            </button>
                            {b.status === 'pending' && (
                              <button
                                onClick={() => handleUpdateStatus(b.id, 'confirmed')}
                                className="px-2.5 py-1.5 rounded-lg bg-blue-50 text-blue-700 hover:bg-blue-100 text-xs font-bold transition-all flex items-center gap-1"
                              >
                                <Check size={14} />
                                <span>تأكيد</span>
                              </button>
                            )}
                            {b.status === 'confirmed' && (
                              <button
                                onClick={() => handleUpdateStatus(b.id, 'completed')}
                                className="px-2.5 py-1.5 rounded-lg bg-emerald-50 text-emerald-700 hover:bg-emerald-100 text-xs font-bold transition-all flex items-center gap-1"
                              >
                                <CheckCircle2 size={14} />
                                <span>إكمال</span>
                              </button>
                            )}
                            {b.status !== 'completed' && b.status !== 'cancelled' && (
                              <button
                                onClick={() => handleUpdateStatus(b.id, 'cancelled')}
                                className="p-1.5 rounded-lg bg-red-50 text-red-600 hover:bg-red-100 transition-all"
                                title="إلغاء الموعد"
                              >
                                <X size={14} />
                              </button>
                            )}
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>
      )}

      {/* TAB CONTENT: CATALOG */}
      {activeTab === 'catalog' && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {loading ? (
            <div className="col-span-full p-12 text-center">
              <div className="w-10 h-10 border-4 border-primary-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
              <p className="text-gray-500 font-bold text-sm">جاري تحميل الخدمات...</p>
            </div>
          ) : services.length === 0 ? (
            <div className="col-span-full p-12 text-center text-gray-400">
              <Wrench size={48} className="mx-auto mb-3 opacity-55" />
              <p className="font-bold">لا توجد أي خدمات معرّفة حالياً.</p>
            </div>
          ) : (
            services.map((s) => (
              <div key={s.id} className="bg-white rounded-3xl border border-gray-100 shadow-sm p-6 space-y-4 hover:shadow-md transition-all flex flex-col justify-between">
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    {s.image ? (
                      <img src={s.image} alt={s.name} className="w-12 h-12 rounded-2xl object-cover border border-gray-100 shadow-sm" />
                    ) : (
                      <div className="w-12 h-12 rounded-2xl bg-primary-50 text-primary-600 flex items-center justify-center font-bold">
                        <Wrench size={24} />
                      </div>
                    )}
                    <span className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                      s.is_active ? 'bg-emerald-100 text-emerald-800' : 'bg-gray-100 text-gray-500'
                    }`}>
                      {s.is_active ? 'نشطة بالتطبيق' : 'مخفية'}
                    </span>
                  </div>

                  <div>
                    <h3 className="text-lg font-black text-gray-900">{s.title_ar || s.name}</h3>
                    <p className="text-xs text-gray-400 font-bold font-mono mt-0.5">{s.title || s.name_en}</p>
                    <p className="text-xs text-gray-500 mt-2 leading-relaxed h-12 overflow-hidden">{s.description || 'لا يوجد وصف للخدمة.'}</p>
                  </div>

                  <div className="grid grid-cols-2 gap-2 bg-gray-50 p-2.5 rounded-2xl">
                    <div className="text-center border-l border-gray-100">
                      <span className="text-[10px] font-bold text-gray-400 block">السعر التقديري</span>
                      <span className="text-sm font-extrabold text-gray-800">{(s.price || 0).toLocaleString()} د.ع</span>
                    </div>
                    <div className="text-center">
                      <span className="text-[10px] font-bold text-gray-400 block">المدة التقديرية</span>
                      <span className="text-sm font-extrabold text-gray-800">{s.duration_minutes} دقيقة</span>
                    </div>
                  </div>
                </div>

                <div className="pt-4 border-t border-gray-100 grid grid-cols-2 gap-2">
                  <button
                    onClick={() => openEditService(s)}
                    className="w-full bg-gray-50 hover:bg-gray-100 text-gray-700 py-2.5 rounded-xl font-bold text-xs transition-all flex items-center justify-center gap-1.5"
                  >
                    <Edit2 size={12} />
                    <span>تعديل</span>
                  </button>
                  <button
                    onClick={() => handleDeleteService(s.id)}
                    className="w-full bg-red-50 hover:bg-red-100 text-red-600 py-2.5 rounded-xl font-bold text-xs transition-all flex items-center justify-center gap-1.5"
                  >
                    <Trash2 size={12} />
                    <span>تعطيل / حذف</span>
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      )}

      {/* CREATE/EDIT SERVICE MODAL */}
      <AnimatePresence>
        {serviceModal.open && (
          <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4 font-cairo text-right" dir="rtl">
            <motion.div 
              initial={{ scale: 0.95, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.95, opacity: 0 }}
              className="bg-white rounded-3xl shadow-xl w-full max-w-md overflow-hidden max-h-[90vh] flex flex-col"
            >
              <div className="p-6 border-b border-gray-100 flex items-center justify-between">
                <h3 className="font-extrabold text-lg text-gray-800">
                  {serviceModal.service ? 'تعديل بيانات الخدمة' : 'إضافة خدمة جديدة'}
                </h3>
                <button 
                  type="button"
                  onClick={() => setServiceModal({ open: false, service: null, name: '', name_en: '', description: '', icon: 'build', image: '', price: '', duration_minutes: '30', is_active: true })}
                  className="p-1 rounded-lg hover:bg-gray-100 text-gray-400"
                >
                  <XCircle size={20} />
                </button>
              </div>

              <form onSubmit={handleServiceSubmit} className="p-6 space-y-4 overflow-y-auto flex-grow">
                <div>
                  <label className="block text-xs font-bold text-gray-500 mb-1.5">اسم الخدمة (بالعربية) *</label>
                  <input
                    type="text"
                    required
                    placeholder="مثال: غسيل وتلميع بخاري"
                    value={serviceModal.name}
                    onChange={(e) => setServiceModal(prev => ({ ...prev, name: e.target.value }))}
                    className="w-full bg-gray-50 border-0 rounded-xl px-4 py-2.5 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-primary-600 font-bold"
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold text-gray-500 mb-1.5">اسم الخدمة (بالإنجليزية) - اختياري</label>
                  <input
                    type="text"
                    placeholder="مثال: Steam Wash & Polish"
                    value={serviceModal.name_en}
                    onChange={(e) => setServiceModal(prev => ({ ...prev, name_en: e.target.value }))}
                    className="w-full bg-gray-50 border-0 rounded-xl px-4 py-2.5 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-primary-600 text-left font-sans"
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-bold text-gray-500 mb-1.5">السعر التقديري (IQD) *</label>
                    <input
                      type="number"
                      required
                      placeholder="15000"
                      value={serviceModal.price}
                      onChange={(e) => setServiceModal(prev => ({ ...prev, price: e.target.value }))}
                      className="w-full bg-gray-50 border-0 rounded-xl px-4 py-2.5 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-primary-600 font-bold"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-bold text-gray-500 mb-1.5">المدة التقديرية (دقائق) *</label>
                    <input
                      type="number"
                      required
                      placeholder="30"
                      value={serviceModal.duration_minutes}
                      onChange={(e) => setServiceModal(prev => ({ ...prev, duration_minutes: e.target.value }))}
                      className="w-full bg-gray-50 border-0 rounded-xl px-4 py-2.5 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-primary-600 font-bold"
                    />
                  </div>
                </div>

                {/* Device Image Uploader */}
                <div>
                  <ImageUploader
                    configKey="service_image"
                    folder="services"
                    value={serviceModal.image}
                    onChange={(url) => setServiceModal(prev => ({ ...prev, image: url }))}
                    label="صورة غلاف الخدمة"
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold text-gray-500 mb-1.5">وصف الخدمة بالتفصيل</label>
                  <textarea
                    rows="3"
                    placeholder="اكتب مواصفات وتفاصيل الخدمة وما تقدمه للسيارة..."
                    value={serviceModal.description}
                    onChange={(e) => setServiceModal(prev => ({ ...prev, description: e.target.value }))}
                    className="w-full bg-gray-50 border-0 rounded-xl px-4 py-2.5 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-primary-600 resize-none"
                  ></textarea>
                </div>

                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    id="is_active"
                    checked={serviceModal.is_active}
                    onChange={(e) => setServiceModal(prev => ({ ...prev, is_active: e.target.checked }))}
                    className="w-4.5 h-4.5 text-primary-600 bg-gray-100 border-gray-300 rounded-lg focus:ring-primary-500"
                  />
                  <label htmlFor="is_active" className="text-xs font-bold text-gray-600 cursor-pointer">عرض الخدمة وتفعيلها فوراً بالتطبيق</label>
                </div>

                <div className="pt-4 grid grid-cols-2 gap-3">
                  <button
                    type="submit"
                    className="w-full bg-primary-600 text-white py-3 rounded-2xl font-bold text-sm hover:bg-primary-700 shadow-md shadow-primary-600/10 hover:shadow-lg transition-all"
                  >
                    حفظ الخدمة
                  </button>
                  <button
                    type="button"
                    onClick={() => setServiceModal({ open: false, service: null, name: '', name_en: '', description: '', icon: 'build', image: '', price: '', duration_minutes: '30', is_active: true })}
                    className="w-full bg-gray-100 hover:bg-gray-200 text-gray-600 py-3 rounded-2xl font-bold text-sm transition-all"
                  >
                    إلغاء
                  </button>
                </div>
              </form>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* DETAILED BOOKING MODAL */}
      <AnimatePresence>
        {selectedBooking && (
          <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4 font-cairo text-right" dir="rtl">
            <motion.div
              initial={{ scale: 0.95, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.95, opacity: 0 }}
              className="bg-white rounded-3xl shadow-xl w-full max-w-2xl overflow-hidden max-h-[90vh] flex flex-col"
            >
              <div className="p-6 border-b border-gray-100 flex items-center justify-between bg-gray-50/50">
                <div>
                  <h3 className="font-extrabold text-lg text-gray-900">تفاصيل طلب الحجز #{selectedBooking.id}</h3>
                  <p className="text-xs text-gray-400 mt-0.5">تاريخ الإرسال: {selectedBooking.created_at ? new Date(selectedBooking.created_at).toLocaleString('ar-EG') : '-'}</p>
                </div>
                <button
                  type="button"
                  onClick={() => setSelectedBooking(null)}
                  className="p-1.5 rounded-xl hover:bg-gray-200 text-gray-400 transition-colors"
                >
                  <XCircle size={22} />
                </button>
              </div>

              <div className="p-6 overflow-y-auto flex-grow space-y-6">
                {/* Info Grid */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {/* Client Card */}
                  <div className="bg-slate-50 border border-slate-100 p-4 rounded-2xl space-y-3">
                    <h4 className="text-xs font-bold text-gray-400 border-b border-slate-200 pb-2 flex items-center gap-1.5">
                      <User size={14} className="text-primary-600" />
                      <span>معلومات العميل والاتصال</span>
                    </h4>
                    <div className="space-y-2 text-sm">
                      <div className="flex justify-between">
                        <span className="text-gray-500">الاسم:</span>
                        <span className="font-extrabold text-gray-900">{selectedBooking.customer_name || 'غير معروف'}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-500">رقم الهاتف:</span>
                        <span className="font-bold text-gray-900 font-sans" dir="ltr">{selectedBooking.customer_phone || '-'}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-500">المنطقة / القضاء:</span>
                        <span className="font-extrabold text-gray-900">{selectedBooking.customer_district || '-'}</span>
                      </div>
                    </div>
                  </div>

                  {/* Vehicle Card */}
                  <div className="bg-slate-50 border border-slate-100 p-4 rounded-2xl space-y-3">
                    <h4 className="text-xs font-bold text-gray-400 border-b border-slate-200 pb-2 flex items-center gap-1.5">
                      <Car size={14} className="text-primary-600" />
                      <span>بيانات السيارة والموعد</span>
                    </h4>
                    <div className="space-y-2 text-sm">
                      <div className="flex justify-between">
                        <span className="text-gray-500">نوع وموديل السيارة:</span>
                        <span className="font-extrabold text-gray-900">{selectedBooking.car_model || '-'}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-500">رقم لوحة الترخيص:</span>
                        <span className="font-extrabold text-gray-900">{selectedBooking.car_number || '-'}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-500">الموعد المحدد:</span>
                        <span className="font-extrabold text-gray-900">{selectedBooking.preferred_date} ({selectedBooking.preferred_time})</span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Service Box */}
                <div className="bg-primary-50/30 border border-primary-100 p-4 rounded-2xl flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-primary-100 text-primary-600 flex items-center justify-center">
                      <Wrench size={20} />
                    </div>
                    <div>
                      <h4 className="font-extrabold text-gray-950 text-sm">{selectedBooking.service_name}</h4>
                      <span className="text-xs text-gray-400 font-bold block mt-0.5">المدة المقدرة: {selectedBooking.duration_minutes || 30} دقيقة</span>
                    </div>
                  </div>
                  <div className="text-left">
                    <span className="text-xs text-gray-400 block font-bold">التكلفة التقديرية</span>
                    <span className="text-lg font-black text-primary-700">{(selectedBooking.price || 0).toLocaleString()} د.ع</span>
                  </div>
                </div>

                {/* Client Notes */}
                {selectedBooking.notes && (
                  <div className="bg-amber-50/40 border border-amber-100 p-4 rounded-2xl space-y-2">
                    <h4 className="text-xs font-bold text-amber-800">ملاحظات وطلبات خاصة من العميل:</h4>
                    <p className="text-sm text-gray-700 leading-relaxed font-bold">{selectedBooking.notes}</p>
                  </div>
                )}

                {/* Status Timeline History */}
                <div className="border border-gray-100 rounded-2xl p-4 space-y-4">
                  <h4 className="text-xs font-bold text-gray-400">حالة الطلب الحالية والتاريخ</h4>
                  <div className="flex items-center gap-3">
                    <span className={`px-3 py-1.5 rounded-full text-xs font-bold border ${getStatusBadgeClass(selectedBooking.status)}`}>
                      {getStatusLabel(selectedBooking.status)}
                    </span>
                    <span className="text-xs text-gray-400 font-semibold">تعديل حالة الحجز فوراً:</span>
                  </div>

                  <div className="flex flex-wrap gap-2 pt-2">
                    {selectedBooking.status === 'pending' && (
                      <button
                        onClick={() => handleUpdateStatus(selectedBooking.id, 'confirmed')}
                        className="px-3.5 py-2 rounded-xl bg-blue-600 text-white hover:bg-blue-700 text-xs font-bold shadow transition-all flex items-center gap-1.5"
                      >
                        <Check size={14} />
                        <span>تأكيد وحجز موعد</span>
                      </button>
                    )}
                    {selectedBooking.status === 'confirmed' && (
                      <button
                        onClick={() => handleUpdateStatus(selectedBooking.id, 'completed')}
                        className="px-3.5 py-2 rounded-xl bg-emerald-600 text-white hover:bg-emerald-700 text-xs font-bold shadow transition-all flex items-center gap-1.5"
                      >
                        <CheckCircle2 size={14} />
                        <span>إكمال الخدمة بنجاح</span>
                      </button>
                    )}
                    {selectedBooking.status !== 'completed' && selectedBooking.status !== 'cancelled' && (
                      <button
                        onClick={() => handleUpdateStatus(selectedBooking.id, 'cancelled')}
                        className="px-3.5 py-2 rounded-xl bg-red-50 text-red-600 hover:bg-red-100 text-xs font-bold border border-red-200 transition-all flex items-center gap-1.5"
                      >
                        <XCircle size={14} />
                        <span>إلغاء الطلب</span>
                      </button>
                    )}
                  </div>
                </div>
              </div>

              {/* Modal Footer Actions */}
              <div className="p-6 border-t border-gray-100 bg-gray-50/50 flex items-center justify-between">
                <button
                  onClick={() => handlePrintBooking(selectedBooking)}
                  className="px-5 py-2.5 rounded-2xl bg-primary-600 text-white hover:bg-primary-700 text-sm font-bold shadow-md shadow-primary-600/10 hover:shadow-lg transition-all flex items-center gap-2"
                >
                  <Printer size={16} />
                  <span>طباعة وصل الحجز</span>
                </button>
                <button
                  onClick={() => setSelectedBooking(null)}
                  className="px-5 py-2.5 rounded-2xl bg-gray-200 hover:bg-gray-300 text-gray-700 text-sm font-bold transition-all"
                >
                  إغلاق النافذة
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
