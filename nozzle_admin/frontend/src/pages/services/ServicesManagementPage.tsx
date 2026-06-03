import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  Wrench, 
  Calendar, 
  Clock, 
  DollarSign, 
  Activity, 
  Plus, 
  Search, 
  Edit, 
  Trash, 
  ArrowUp, 
  ArrowDown, 
  Printer, 
  FileText, 
  ChevronRight, 
  Filter, 
  RefreshCw,
  TrendingUp
} from 'lucide-react';
import api from '../../services/api';
import ServiceFormModal from '../../components/services/ServiceFormModal';

export default function ServicesManagementPage() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState('catalog'); // catalog, bookings
  const [services, setServices] = useState([]);
  const [requests, setRequests] = useState([]);
  const [stats, setStats] = useState({
    total_services: 0,
    active_services: 0,
    total_requests: 0,
    today_requests: 0,
    pending_requests: 0,
    this_month_revenue: 0,
    requests_by_status: { new: 0, confirmed: 0, in_progress: 0, completed: 0, cancelled: 0 },
    top_services: []
  });
  
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [serviceFilter, setServiceFilter] = useState('all');
  const [dateFrom, setDateFrom] = useState('');
  const [dateTo, setDateTo] = useState('');
  const [modalOpen, setModalOpen] = useState(false);
  const [editingService, setEditingService] = useState(null);

  // Fetch all initial data
  const fetchData = async () => {
    try {
      setLoading(true);
      const [servicesRes, statsRes] = await Promise.all([
        api.get('/v1/admin/services'),
        api.get('/v1/admin/services/stats')
      ]);

      setServices(servicesRes.data.data);
      setStats(statsRes.data.data);
      
      // Fetch bookings requests
      await fetchRequests();
    } catch (err) {
      console.error('Error fetching services details:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchRequests = async () => {
    try {
      const params = {};
      if (statusFilter !== 'all') params.status = statusFilter;
      if (serviceFilter !== 'all') params.service_id = serviceFilter;
      if (searchQuery) params.search = searchQuery;
      if (dateFrom) params.date_from = dateFrom;
      if (dateTo) params.date_to = dateTo;

      const requestsRes = await api.get('/v1/admin/service-requests', { params });
      setRequests(requestsRes.data.data);
      if (requestsRes.data.meta && requestsRes.data.meta.stats) {
        setStats(prev => ({
          ...prev,
          requests_by_status: requestsRes.data.meta.stats
        }));
      }
    } catch (err) {
      console.error('Error fetching requests:', err);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  useEffect(() => {
    fetchRequests();
  }, [statusFilter, serviceFilter, searchQuery, dateFrom, dateTo]);

  // Reordering hander
  const handleMove = async (index, direction) => {
    const newServices = [...services];
    const targetIndex = direction === 'up' ? index - 1 : index + 1;
    
    if (targetIndex < 0 || targetIndex >= services.length) return;
    
    // Swap
    const temp = newServices[index];
    newServices[index] = newServices[targetIndex];
    newServices[targetIndex] = temp;
    
    setServices(newServices);

    try {
      const ids = newServices.map(s => s.id);
      await api.put('/v1/admin/services/reorder', { ids });
    } catch (err) {
      console.error('Error updating order:', err);
    }
  };

  // Toggle availability helper
  const handleToggleAvailability = async (service) => {
    try {
      const updatedAvailable = !service.is_available;
      const res = await api.put(`/v1/admin/services/${service.id}`, {
        ...service,
        is_available: updatedAvailable
      });
      setServices(prev => prev.map(s => s.id === service.id ? res.data.data : s));
      fetchData();
    } catch (err) {
      console.error('Failed to toggle availability:', err);
    }
  };

  const handleDeleteService = async (id) => {
    if (!window.confirm('هل أنت متأكد من حذف هذه الخدمة؟')) return;
    try {
      await api.delete(`/v1/admin/services/${id}`);
      fetchData();
    } catch (err) {
      console.error('Failed to delete service:', err);
    }
  };

  const handleStatusChange = async (requestId, newStatus) => {
    try {
      await api.put(`/v1/admin/service-requests/${requestId}/status`, {
        status: newStatus,
        notify_customer: true
      });
      fetchRequests();
    } catch (err) {
      console.error('Failed to update request status:', err);
    }
  };

  const formatPrice = (price) => {
    return new Intl.NumberFormat('ar-IQ', { style: 'currency', currency: 'IQD', maximumFractionDigits: 0 }).format(price);
  };

  const getStatusBadge = (status) => {
    switch (status) {
      case 'new': return <span className="px-3 py-1 text-xs font-semibold bg-yellow-100 text-yellow-800 rounded-full dark:bg-yellow-900/30 dark:text-yellow-400">جديد 🟡</span>;
      case 'confirmed': return <span className="px-3 py-1 text-xs font-semibold bg-blue-100 text-blue-800 rounded-full dark:bg-blue-900/30 dark:text-blue-400">مؤكد 🔵</span>;
      case 'in_progress': return <span className="px-3 py-1 text-xs font-semibold bg-orange-100 text-orange-800 rounded-full dark:bg-orange-900/30 dark:text-orange-400">قيد التنفيذ 🟠</span>;
      case 'completed': return <span className="px-3 py-1 text-xs font-semibold bg-green-100 text-green-800 rounded-full dark:bg-green-900/30 dark:text-green-400">مكتمل 🟢</span>;
      case 'cancelled': return <span className="px-3 py-1 text-xs font-semibold bg-red-100 text-red-800 rounded-full dark:bg-red-900/30 dark:text-red-400">ملغي 🔴</span>;
      default: return <span className="px-3 py-1 text-xs font-semibold bg-gray-100 text-gray-800 rounded-full">{status}</span>;
    }
  };

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-gray-900 dark:text-white">إدارة الخدمات والحجوزات</h1>
          <p className="text-gray-500 dark:text-dark-300">تحكم بالخدمات المتاحة للزبائن واستعرض طلبات الحجز المباشرة.</p>
        </div>
        <button
          onClick={() => {
            setEditingService(null);
            setModalOpen(true);
          }}
          className="flex items-center gap-2 px-4 py-2 bg-primary-600 hover:bg-primary-700 text-white rounded-lg transition-colors font-medium text-sm"
        >
          <Plus className="w-5 h-5" />
          <span>إضافة خدمة جديدة</span>
        </button>
      </div>

      {/* Quick Statistics (4 cards) */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-white dark:bg-dark-900 rounded-xl p-6 shadow-sm border border-gray-100 dark:border-dark-800 flex items-center gap-4">
          <div className="p-3 bg-blue-50 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400 rounded-lg">
            <Wrench className="w-6 h-6" />
          </div>
          <div>
            <p className="text-sm text-gray-500 dark:text-dark-400">الخدمات الكلية</p>
            <h3 className="text-2xl font-bold text-gray-900 dark:text-white">{stats.total_services}</h3>
            <p className="text-xs text-green-600 font-semibold">({stats.active_services} نشطة)</p>
          </div>
        </div>

        <div className="bg-white dark:bg-dark-900 rounded-xl p-6 shadow-sm border border-gray-100 dark:border-dark-800 flex items-center gap-4">
          <div className="p-3 bg-yellow-50 dark:bg-yellow-900/20 text-yellow-600 dark:text-yellow-400 rounded-lg">
            <Calendar className="w-6 h-6" />
          </div>
          <div>
            <p className="text-sm text-gray-500 dark:text-dark-400">طلبات اليوم</p>
            <h3 className="text-2xl font-bold text-gray-900 dark:text-white">{stats.today_requests}</h3>
            <p className="text-xs text-yellow-600 font-semibold">+{stats.pending_requests} جديد</p>
          </div>
        </div>

        <div className="bg-white dark:bg-dark-900 rounded-xl p-6 shadow-sm border border-gray-100 dark:border-dark-800 flex items-center gap-4">
          <div className="p-3 bg-orange-50 dark:bg-orange-900/20 text-orange-600 dark:text-orange-400 rounded-lg">
            <Activity className="w-6 h-6" />
          </div>
          <div>
            <p className="text-sm text-gray-500 dark:text-dark-400">قيد التنفيذ</p>
            <h3 className="text-2xl font-bold text-gray-900 dark:text-white">{stats.requests_by_status.in_progress}</h3>
            <p className="text-xs text-orange-600 font-semibold">🟠 عاجل</p>
          </div>
        </div>

        <div className="bg-white dark:bg-dark-900 rounded-xl p-6 shadow-sm border border-gray-100 dark:border-dark-800 flex items-center gap-4">
          <div className="p-3 bg-green-50 dark:bg-green-900/20 text-green-600 dark:text-green-400 rounded-lg">
            <DollarSign className="w-6 h-6" />
          </div>
          <div>
            <p className="text-sm text-gray-500 dark:text-dark-400">إيراد الشهر الحالي</p>
            <h3 className="text-2xl font-bold text-gray-900 dark:text-white">{formatPrice(stats.this_month_revenue)}</h3>
            <p className="text-xs text-green-600 font-semibold flex items-center gap-1">
              <TrendingUp className="w-3.5 h-3.5" />
              <span>د.ع مكتملة</span>
            </p>
          </div>
        </div>
      </div>

      {/* Navigation Tabs */}
      <div className="flex border-b border-gray-200 dark:border-dark-800">
        <button
          onClick={() => setActiveTab('catalog')}
          className={`px-6 py-3 font-semibold text-sm border-b-2 transition-colors ${
            activeTab === 'catalog'
              ? 'border-primary-600 text-primary-600 dark:text-primary-400'
              : 'border-transparent text-gray-500 hover:text-gray-700 dark:text-dark-400'
          }`}
        >
          🔧 إدارة الخدمات والتسعير
        </button>
        <button
          onClick={() => setActiveTab('bookings')}
          className={`px-6 py-3 font-semibold text-sm border-b-2 transition-colors flex items-center gap-2 ${
            activeTab === 'bookings'
              ? 'border-primary-600 text-primary-600 dark:text-primary-400'
              : 'border-transparent text-gray-500 hover:text-gray-700 dark:text-dark-400'
          }`}
        >
          <span>📋 طلبات الخدمات</span>
          {stats.pending_requests > 0 && (
            <span className="px-2 py-0.5 text-xs font-bold bg-red-500 text-white rounded-full">
              {stats.pending_requests}
            </span>
          )}
        </button>
      </div>

      {/* Loading Shimmer */}
      {loading ? (
        <div className="flex items-center justify-center h-64">
          <RefreshCw className="w-8 h-8 text-primary-600 animate-spin" />
        </div>
      ) : (
        <div>
          {/* TAB 1: SERVICES CATALOG */}
          {activeTab === 'catalog' && (
            <div className="bg-white dark:bg-dark-900 shadow-sm rounded-xl overflow-hidden border border-gray-100 dark:border-dark-800">
              <div className="p-6 border-b border-gray-100 dark:border-dark-800 flex justify-between items-center flex-wrap gap-4">
                <h3 className="font-bold text-lg text-gray-900 dark:text-white">قائمة خدمات نوزل</h3>
                <span className="text-sm text-gray-500 dark:text-dark-400">يمكنك استخدام الأسهم لإعادة الترتيب في شاشات التطبيق</span>
              </div>
              <div className="overflow-x-auto">
                <table className="w-full text-right text-gray-500 dark:text-dark-300">
                  <thead className="text-xs text-gray-700 dark:text-dark-200 uppercase bg-gray-50 dark:bg-dark-950">
                    <tr>
                      <th className="px-6 py-4">الترتيب</th>
                      <th className="px-6 py-4">الصورة</th>
                      <th className="px-6 py-4">الاسم</th>
                      <th className="px-6 py-4">الفئة</th>
                      <th className="px-6 py-4">السعر الأساسي</th>
                      <th className="px-6 py-4">الطلبات</th>
                      <th className="px-6 py-4">التقييم</th>
                      <th className="px-6 py-4">الحالة</th>
                      <th className="px-6 py-4 text-left">إجراءات</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100 dark:divide-dark-800">
                    {services.map((service, index) => (
                      <tr key={service.id} className="hover:bg-gray-50/50 dark:hover:bg-dark-950/50">
                        <td className="px-6 py-4">
                          <div className="flex items-center gap-1">
                            <button
                              disabled={index === 0}
                              onClick={() => handleMove(index, 'up')}
                              className="p-1 hover:bg-gray-100 dark:hover:bg-dark-800 text-gray-400 disabled:opacity-30 rounded"
                            >
                              <ArrowUp className="w-4 h-4" />
                            </button>
                            <button
                              disabled={index === services.length - 1}
                              onClick={() => handleMove(index, 'down')}
                              className="p-1 hover:bg-gray-100 dark:hover:bg-dark-800 text-gray-400 disabled:opacity-30 rounded"
                            >
                              <ArrowDown className="w-4 h-4" />
                            </button>
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <img
                            src={service.image_url ? (service.image_url.startsWith('http') ? service.image_url : `${api.defaults.baseURL.replace('/api', '')}${service.image_url}`) : '/placeholder-image.jpg'}
                            alt={service.name}
                            className="w-12 h-9 rounded object-cover border border-gray-100"
                            onError={(e) => { e.target.src = 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=500&auto=format&fit=crop'; }}
                          />
                        </td>
                        <td className="px-6 py-4 font-bold text-gray-900 dark:text-white">
                          <div className="flex items-center gap-2">
                            <span>{service.icon_emoji}</span>
                            <span>{service.name}</span>
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <span className="px-2 py-1 text-xs font-semibold bg-gray-100 text-gray-700 dark:bg-dark-850 dark:text-dark-200 rounded">
                            {service.category || 'أخرى'}
                          </span>
                        </td>
                        <td className="px-6 py-4 text-green-600 dark:text-green-400 font-bold">
                          {service.price_type === 'from' && 'يبدأ من '}
                          {formatPrice(service.base_price)}
                        </td>
                        <td className="px-6 py-4">{service.total_bookings} طلب</td>
                        <td className="px-6 py-4">⭐ {service.rating} ({service.reviews_count})</td>
                        <td className="px-6 py-4">
                          <label className="relative inline-flex items-center cursor-pointer">
                            <input
                              type="checkbox"
                              checked={service.is_available}
                              onChange={() => handleToggleAvailability(service)}
                              className="sr-only peer"
                            />
                            <div className="w-9 h-5 bg-gray-200 peer-focus:outline-none rounded-full peer dark:bg-dark-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-350 after:border after:rounded-full after:h-4 after:w-4 after:transition-all dark:border-dark-600 peer-checked:bg-primary-600"></div>
                          </label>
                        </td>
                        <td className="px-6 py-4 text-left">
                          <div className="flex items-center justify-end gap-2">
                            <button
                              onClick={() => {
                                setEditingService(service);
                                setModalOpen(true);
                              }}
                              className="p-1 text-blue-600 hover:bg-blue-50 dark:hover:bg-blue-900/20 rounded"
                              title="تعديل الخدمة"
                            >
                              <Edit className="w-5 h-5" />
                            </button>
                            <button
                              onClick={() => handleDeleteService(service.id)}
                              className="p-1 text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 rounded"
                              title="حذف الخدمة"
                            >
                              <Trash className="w-5 h-5" />
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* TAB 2: BOOKING REQUESTS */}
          {activeTab === 'bookings' && (
            <div className="space-y-4">
              {/* Filter controls */}
              <div className="bg-white dark:bg-dark-900 p-6 rounded-xl shadow-sm border border-gray-100 dark:border-dark-800 space-y-4">
                {/* Status Quick Filters (clickable badges) */}
                <div className="flex items-center flex-wrap gap-2">
                  <span className="text-sm font-semibold text-gray-500 dark:text-dark-300 ml-2">تصنيف الحالات:</span>
                  {[
                    { id: 'all', label: 'الكل', count: stats.requests_by_status.all, color: 'bg-gray-100 text-gray-800 dark:bg-dark-850 dark:text-dark-200' },
                    { id: 'new', label: 'جديد 🟡', count: stats.requests_by_status.new, color: 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/20 dark:text-yellow-400' },
                    { id: 'confirmed', label: 'مؤكد 🔵', count: stats.requests_by_status.confirmed, color: 'bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-400' },
                    { id: 'in_progress', label: 'قيد التنفيذ 🟠', count: stats.requests_by_status.in_progress, color: 'bg-orange-100 text-orange-800 dark:bg-orange-900/20 dark:text-orange-400' },
                    { id: 'completed', label: 'مكتمل 🟢', count: stats.requests_by_status.completed, color: 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400' },
                    { id: 'cancelled', label: 'ملغى 🔴', count: stats.requests_by_status.cancelled, color: 'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400' },
                  ].map(badge => (
                    <button
                      key={badge.id}
                      onClick={() => setStatusFilter(badge.id)}
                      className={`px-3 py-1.5 rounded-full text-xs font-bold transition-all ${
                        statusFilter === badge.id 
                          ? 'ring-2 ring-primary-600 scale-105 shadow-sm'
                          : 'opacity-70 hover:opacity-100'
                      } ${badge.color}`}
                    >
                      {badge.label} ({badge.count})
                    </button>
                  ))}
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                  {/* Search query input */}
                  <div className="relative">
                    <Search className="absolute right-3 top-2.5 w-5 h-5 text-gray-400" />
                    <input
                      type="text"
                      placeholder="بحث بالاسم أو الهاتف أو رقم الطلب..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="w-full pr-10 pl-3 py-2 text-sm border border-gray-200 dark:border-dark-800 rounded-lg bg-gray-50 dark:bg-dark-950 focus:outline-none focus:ring-1 focus:ring-primary-600 focus:border-primary-600"
                    />
                  </div>

                  {/* Service selector */}
                  <div className="relative">
                    <select
                      value={serviceFilter}
                      onChange={(e) => setServiceFilter(e.target.value)}
                      className="w-full px-3 py-2 text-sm border border-gray-200 dark:border-dark-800 rounded-lg bg-gray-50 dark:bg-dark-950 focus:outline-none focus:ring-1 focus:ring-primary-600 focus:border-primary-600"
                    >
                      <option value="all">كل الخدمات</option>
                      {services.map(s => (
                        <option key={s.id} value={s.id}>{s.name}</option>
                      ))}
                    </select>
                  </div>

                  {/* Scheduled date from */}
                  <div className="flex gap-2 items-center">
                    <span className="text-xs text-gray-500 whitespace-nowrap">من:</span>
                    <input
                      type="date"
                      value={dateFrom}
                      onChange={(e) => setDateFrom(e.target.value)}
                      className="w-full px-3 py-2 text-sm border border-gray-200 dark:border-dark-800 rounded-lg bg-gray-50 dark:bg-dark-950 focus:outline-none focus:ring-1 focus:ring-primary-600"
                    />
                  </div>

                  {/* Scheduled date to */}
                  <div className="flex gap-2 items-center">
                    <span className="text-xs text-gray-500 whitespace-nowrap">إلى:</span>
                    <input
                      type="date"
                      value={dateTo}
                      onChange={(e) => setDateTo(e.target.value)}
                      className="w-full px-3 py-2 text-sm border border-gray-200 dark:border-dark-800 rounded-lg bg-gray-50 dark:bg-dark-950 focus:outline-none focus:ring-1 focus:ring-primary-600"
                    />
                  </div>
                </div>
              </div>

              {/* Bookings List Table */}
              <div className="bg-white dark:bg-dark-900 shadow-sm rounded-xl overflow-hidden border border-gray-100 dark:border-dark-800">
                <div className="overflow-x-auto">
                  <table className="w-full text-right text-gray-500 dark:text-dark-300">
                    <thead className="text-xs text-gray-700 dark:text-dark-200 uppercase bg-gray-50 dark:bg-dark-950">
                      <tr>
                        <th className="px-6 py-4">رقم الطلب</th>
                        <th className="px-6 py-4">الزبون</th>
                        <th className="px-6 py-4">الخدمة المطلوبة</th>
                        <th className="px-6 py-4">الموعد المحدد</th>
                        <th className="px-6 py-4">السعر الكلي</th>
                        <th className="px-6 py-4">الحالة</th>
                        <th className="px-6 py-4 text-left">إجراءات</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100 dark:divide-dark-800">
                      {requests.length === 0 ? (
                        <tr>
                          <td colSpan="7" className="px-6 py-12 text-center text-gray-400">
                            لا توجد طلبات حجز مطابقة لخيارات الفلترة.
                          </td>
                        </tr>
                      ) : (
                        requests.map(req => (
                          <tr key={req.id} className="hover:bg-gray-50/50 dark:hover:bg-dark-950/50">
                            <td className="px-6 py-4 font-bold text-gray-900 dark:text-white">
                              {req.request_number}
                            </td>
                            <td className="px-6 py-4">
                              <div>
                                <p className="font-semibold text-gray-900 dark:text-white">{req.customer_name}</p>
                                <p className="text-xs text-gray-400">{req.customer_phone}</p>
                              </div>
                            </td>
                            <td className="px-6 py-4 font-semibold text-gray-800 dark:text-dark-100">
                              {req.service ? req.service.name : 'خدمة غير معروفة'}
                              {req.option && <span className="text-xs text-primary-600 block">({req.option.name})</span>}
                            </td>
                            <td className="px-6 py-4">
                              <div className="flex flex-col">
                                <span className="font-medium">{req.scheduled_date}</span>
                                <span className="text-xs text-gray-400">{req.scheduled_time}</span>
                              </div>
                            </td>
                            <td className="px-6 py-4 font-bold text-green-600 dark:text-green-400">
                              {formatPrice(req.total_price)}
                            </td>
                            <td className="px-6 py-4">
                              {getStatusBadge(req.status)}
                            </td>
                            <td className="px-6 py-4 text-left">
                              <div className="flex items-center justify-end gap-2">
                                <button
                                  onClick={() => navigate(`/services/requests/${req.id}`)}
                                  className="px-2.5 py-1 text-xs font-semibold bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-dark-850 dark:text-dark-200 rounded"
                                >
                                  تفاصيل
                                </button>
                                <select
                                  value={req.status}
                                  onChange={(e) => handleStatusChange(req.id, e.target.value)}
                                  className="px-2 py-1 text-xs border border-gray-200 dark:border-dark-800 rounded bg-white dark:bg-dark-950 font-medium focus:outline-none"
                                >
                                  <option value="new">جديد</option>
                                  <option value="confirmed">مؤكد</option>
                                  <option value="in_progress">قيد التنفيذ</option>
                                  <option value="completed">مكتمل</option>
                                  <option value="cancelled">ملغي</option>
                                </select>
                                <button
                                  onClick={() => navigate(`/services/requests/${req.id}/print`)}
                                  className="p-1 hover:bg-gray-100 dark:hover:bg-dark-800 text-gray-500 rounded"
                                  title="طباعة الطلب"
                                >
                                  <Printer className="w-4 h-4" />
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))
                      )}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}
        </div>
      )}

      {/* Service Add/Edit Modal */}
      {modalOpen && (
        <ServiceFormModal
          service={editingService}
          onClose={() => setModalOpen(false)}
          onSave={() => {
            setModalOpen(false);
            fetchData();
          }}
        />
      )}
    </div>
  );
}
