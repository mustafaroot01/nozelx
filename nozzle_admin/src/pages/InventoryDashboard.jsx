import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Package, 
  Search, 
  Filter, 
  AlertTriangle, 
  TrendingUp, 
  TrendingDown, 
  Plus, 
  Minus, 
  RefreshCw, 
  Sliders, 
  History, 
  CheckCircle2, 
  XCircle, 
  AlertCircle, 
  ArrowUpDown,
  FileText,
  Settings
} from 'lucide-react';
import api from '../services/api';

export default function InventoryDashboard() {
  // Tabs: 'status', 'history', 'thresholds'
  const [activeTab, setActiveTab] = useState('status');
  const [loading, setLoading] = useState(true);
  const [dashboardData, setDashboardData] = useState({
    total_products: 0,
    out_of_stock_count: 0,
    critical_stock_count: 0,
    low_stock_count: 0,
    low_stock_items: [],
    recent_movements: []
  });
  
  const [products, setProducts] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all'); // all, out, critical, low, normal
  const [categoryFilter, setCategoryFilter] = useState('all');
  const [categories, setCategories] = useState([]);
  const [historyMovements, setHistoryMovements] = useState([]);
  const [loadingHistory, setLoadingHistory] = useState(false);

  // Modals state
  const [updateStockModal, setUpdateStockModal] = useState({
    open: false,
    product: null,
    type: 'in', // in, out, adjustment, audit
    quantity: 1,
    reason: '',
    invoice_number: ''
  });

  const [thresholdModal, setThresholdModal] = useState({
    open: false,
    product: null,
    low_stock_threshold: 10,
    reorder_point: 20,
    max_stock: 100
  });

  const [successMessage, setSuccessMessage] = useState('');
  const [errorMessage, setErrorMessage] = useState('');

  // Fetch data
  const fetchData = async () => {
    try {
      setLoading(true);
      const [dashRes, prodRes, catRes] = await Promise.all([
        api.get('/inventory/dashboard'),
        api.get('/products'),
        api.get('/categories')
      ]);

      if (dashRes.data && dashRes.data.status === 'success') {
        setDashboardData(dashRes.data.data);
      }

      if (prodRes.data) {
        // Handle both format {status: 'success', data: [...]} and raw array
        const prodData = prodRes.data.data || prodRes.data;
        setProducts(prodData);
      }

      if (catRes.data && catRes.data.status === 'success') {
        setCategories(catRes.data.data);
      }
    } catch (err) {
      console.error('Error fetching inventory data:', err);
      showError('فشل تحميل بيانات المخزون. يرجى المحاولة مرة أخرى.');
    } finally {
      setLoading(false);
    }
  };

  const fetchHistory = async () => {
    try {
      setLoadingHistory(true);
      const res = await api.get('/inventory/dashboard'); // Use dashboard's movements or custom history if we want
      if (res.data && res.data.status === 'success') {
        setHistoryMovements(res.data.data.recent_movements || []);
      }
    } catch (err) {
      console.error('Error fetching stock history:', err);
    } finally {
      setLoadingHistory(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  useEffect(() => {
    if (activeTab === 'history') {
      fetchHistory();
    }
  }, [activeTab]);

  const showSuccess = (msg) => {
    setSuccessMessage(msg);
    setTimeout(() => setSuccessMessage(''), 4000);
  };

  const showError = (msg) => {
    setErrorMessage(msg);
    setTimeout(() => setErrorMessage(''), 4000);
  };

  // Stock Update Submit
  const handleStockUpdateSubmit = async (e) => {
    e.preventDefault();
    if (!updateStockModal.product) return;
    
    try {
      const payload = {
        product_id: updateStockModal.product.id,
        type: updateStockModal.type,
        quantity_change: parseInt(updateStockModal.quantity),
        reason: updateStockModal.reason,
        invoice_number: updateStockModal.invoice_number || null
      };

      const res = await api.post('/inventory/stock-update', payload);
      if (res.data && res.data.status === 'success') {
        showSuccess('تم تحديث المخزون بنجاح!');
        setUpdateStockModal({ open: false, product: null, type: 'in', quantity: 1, reason: '', invoice_number: '' });
        fetchData();
      }
    } catch (err) {
      console.error('Error updating stock:', err);
      showError(err.response?.data?.detail || 'فشل تحديث المخزون.');
    }
  };

  // Threshold Update Submit
  const handleThresholdSubmit = async (e) => {
    e.preventDefault();
    if (!thresholdModal.product) return;

    try {
      const payload = {
        low_stock_threshold: parseInt(thresholdModal.low_stock_threshold),
        reorder_point: parseInt(thresholdModal.reorder_point),
        max_stock: parseInt(thresholdModal.max_stock)
      };

      const res = await api.put(`/inventory/thresholds/${thresholdModal.product.id}`, payload);
      if (res.data && res.data.status === 'success') {
        showSuccess('تم تحديث حدود المخزون بنجاح!');
        setThresholdModal({ open: false, product: null, low_stock_threshold: 10, reorder_point: 20, max_stock: 100 });
        fetchData();
      }
    } catch (err) {
      console.error('Error updating thresholds:', err);
      showError(err.response?.data?.detail || 'فشل تحديث حدود المخزون.');
    }
  };

  // Filters
  const filteredProducts = products.filter(p => {
    const matchesSearch = p.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
                          (p.sku && p.sku.toLowerCase().includes(searchTerm.toLowerCase()));
    
    const matchesCategory = categoryFilter === 'all' || String(p.category_id) === String(categoryFilter);
    
    let matchesStatus = true;
    const stock = p.stock_quantity || 0;
    const threshold = p.low_stock_threshold || 10;
    const reorder = p.reorder_point || 20;

    if (statusFilter === 'out') {
      matchesStatus = stock <= 0;
    } else if (statusFilter === 'critical') {
      matchesStatus = stock > 0 && stock <= threshold;
    } else if (statusFilter === 'low') {
      matchesStatus = stock > threshold && stock <= reorder;
    } else if (statusFilter === 'normal') {
      matchesStatus = stock > reorder;
    }

    return matchesSearch && matchesCategory && matchesStatus;
  });

  const getStockBadgeColor = (stock, threshold, reorder) => {
    if (stock <= 0) return 'bg-red-100 text-red-800 border-red-200';
    if (stock <= threshold) return 'bg-orange-100 text-orange-800 border-orange-200';
    if (stock <= reorder) return 'bg-yellow-100 text-yellow-800 border-yellow-200';
    return 'bg-emerald-100 text-emerald-800 border-emerald-200';
  };

  const getStockStatusLabel = (stock, threshold, reorder) => {
    if (stock <= 0) return 'نفذت الكمية';
    if (stock <= threshold) return 'حرج جداً';
    if (stock <= reorder) return 'منخفض';
    return 'مستقر';
  };

  return (
    <div className="space-y-8 font-cairo">
      {/* Top Banner Alert (Success/Error) */}
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
            <Package className="text-primary-600" size={32} />
            <span>نظام المخزون الذكي</span>
          </h1>
          <p className="text-gray-500 mt-1.5 text-sm">
            مراقبة كميات المنتجات وتفاصيل تنبيهات إعادة الطلب وسجل حركات التوريد والصرف بشكل فوري.
          </p>
        </div>
      </div>

      {/* Metric Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm flex items-center justify-between">
          <div>
            <span className="text-xs font-bold text-gray-400">إجمالي المنتجات المراقبة</span>
            <h3 className="text-3xl font-black text-gray-800 mt-1">{dashboardData.total_products}</h3>
          </div>
          <div className="w-12 h-12 rounded-2xl bg-gray-50 flex items-center justify-center text-gray-400">
            <Package size={24} />
          </div>
        </div>

        <div className="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm flex items-center justify-between">
          <div>
            <span className="text-xs font-bold text-red-500">خارج المخزون (نفذت)</span>
            <h3 className="text-3xl font-black text-red-600 mt-1">{dashboardData.out_of_stock_count}</h3>
          </div>
          <div className="w-12 h-12 rounded-2xl bg-red-50 flex items-center justify-center text-red-500">
            <XCircle size={24} />
          </div>
        </div>

        <div className="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm flex items-center justify-between">
          <div>
            <span className="text-xs font-bold text-orange-500">مخزون حرج (مستعجل)</span>
            <h3 className="text-3xl font-black text-orange-600 mt-1">{dashboardData.critical_stock_count}</h3>
          </div>
          <div className="w-12 h-12 rounded-2xl bg-orange-50 flex items-center justify-center text-orange-500">
            <AlertCircle size={24} />
          </div>
        </div>

        <div className="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm flex items-center justify-between">
          <div>
            <span className="text-xs font-bold text-yellow-600">تحت حد إعادة الطلب</span>
            <h3 className="text-3xl font-black text-yellow-600 mt-1">{dashboardData.low_stock_count}</h3>
          </div>
          <div className="w-12 h-12 rounded-2xl bg-yellow-50 flex items-center justify-center text-yellow-600">
            <AlertTriangle size={24} />
          </div>
        </div>
      </div>

      {/* Tabs Menu */}
      <div className="flex border-b border-gray-200">
        <button
          onClick={() => setActiveTab('status')}
          className={`flex items-center gap-2 px-6 py-4 font-bold text-sm border-b-2 transition-all ${
            activeTab === 'status'
              ? 'border-primary-600 text-primary-600'
              : 'border-transparent text-gray-500 hover:text-gray-800'
          }`}
        >
          <Sliders size={18} />
          <span>حالة المخزون الحالية</span>
        </button>
        <button
          onClick={() => setActiveTab('history')}
          className={`flex items-center gap-2 px-6 py-4 font-bold text-sm border-b-2 transition-all ${
            activeTab === 'history'
              ? 'border-primary-600 text-primary-600'
              : 'border-transparent text-gray-500 hover:text-gray-800'
          }`}
        >
          <History size={18} />
          <span>سجل حركات المخزون</span>
        </button>
      </div>

      {/* TAB CONTENT: STATUS */}
      {activeTab === 'status' && (
        <div className="space-y-6">
          {/* Filters Bar */}
          <div className="bg-white p-5 rounded-3xl border border-gray-100 shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div className="relative flex-grow max-w-md">
              <Search className="absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
              <input
                type="text"
                placeholder="ابحث عن طريق اسم المنتج أو الـ SKU..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-4 pr-10 py-3 rounded-2xl bg-gray-50 border-0 focus:ring-2 focus:ring-primary-600 focus:bg-white text-sm outline-none transition-all"
              />
            </div>

            <div className="flex flex-wrap items-center gap-3">
              <div className="flex items-center gap-2">
                <span className="text-xs font-bold text-gray-400 whitespace-nowrap">القسم:</span>
                <select
                  value={categoryFilter}
                  onChange={(e) => setCategoryFilter(e.target.value)}
                  className="bg-gray-50 border-0 rounded-xl px-4 py-2.5 text-sm font-bold text-gray-700 outline-none focus:ring-2 focus:ring-primary-600"
                >
                  <option value="all">كل الأقسام</option>
                  {categories.map(cat => (
                    <option key={cat.id} value={cat.id}>{cat.name}</option>
                  ))}
                </select>
              </div>

              <div className="flex items-center gap-2">
                <span className="text-xs font-bold text-gray-400 whitespace-nowrap">حالة الكمية:</span>
                <select
                  value={statusFilter}
                  onChange={(e) => setStatusFilter(e.target.value)}
                  className="bg-gray-50 border-0 rounded-xl px-4 py-2.5 text-sm font-bold text-gray-700 outline-none focus:ring-2 focus:ring-primary-600"
                >
                  <option value="all">كل الحالات</option>
                  <option value="out">نفذت الكمية</option>
                  <option value="critical">مستوى حرج</option>
                  <option value="low">مستوى منخفض</option>
                  <option value="normal">مستقر</option>
                </select>
              </div>
            </div>
          </div>

          {/* Products List Table */}
          <div className="bg-white rounded-3xl border border-gray-100 shadow-sm overflow-hidden">
            {loading ? (
              <div className="p-12 text-center">
                <div className="w-10 h-10 border-4 border-primary-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
                <p className="text-gray-500 font-bold text-sm">جاري تحميل المنتجات...</p>
              </div>
            ) : filteredProducts.length === 0 ? (
              <div className="p-12 text-center text-gray-400">
                <Package size={48} className="mx-auto mb-3 opacity-55" />
                <p className="font-bold">لم يتم العثور على أي منتجات مطابقة للبحث أو الفلترة.</p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-right border-collapse">
                  <thead>
                    <tr className="bg-gray-50 border-b border-gray-100 text-gray-500 text-xs font-bold uppercase">
                      <th className="px-6 py-4.5">المنتج</th>
                      <th className="px-6 py-4.5">الرمز (SKU)</th>
                      <th className="px-6 py-4.5">الكمية المتوفرة</th>
                      <th className="px-6 py-4.5">حد التنبيه (الحرج)</th>
                      <th className="px-6 py-4.5">حد إعادة الطلب</th>
                      <th className="px-6 py-4.5">الحد الأقصى</th>
                      <th className="px-6 py-4.5">الحالة</th>
                      <th className="px-6 py-4.5 text-left">الإجراءات</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100">
                    {filteredProducts.map((p) => {
                      const stock = p.stock_quantity || 0;
                      const threshold = p.low_stock_threshold || 10;
                      const reorder = p.reorder_point || 20;
                      const maxStock = p.max_stock || 100;
                      
                      return (
                        <tr key={p.id} className="hover:bg-gray-50/50 transition-colors">
                          <td className="px-6 py-4">
                            <div className="flex items-center gap-3">
                              {p.image_url ? (
                                <img src={p.image_url} alt={p.name} className="w-10 h-10 rounded-xl object-cover border" />
                              ) : (
                                <div className="w-10 h-10 rounded-xl bg-gray-50 border flex items-center justify-center text-gray-400">
                                  <Package size={16} />
                                </div>
                              )}
                              <div>
                                <h4 className="text-sm font-bold text-gray-900">{p.name}</h4>
                                <span className="text-xs text-gray-400">السعر: {p.price.toLocaleString()} د.ع</span>
                              </div>
                            </div>
                          </td>
                          <td className="px-6 py-4 text-sm font-semibold text-gray-500">
                            {p.sku || '-'}
                          </td>
                          <td className="px-6 py-4">
                            <span className="text-sm font-extrabold text-gray-900">{stock} وحدة</span>
                          </td>
                          <td className="px-6 py-4 text-sm font-bold text-gray-500">
                            {threshold}
                          </td>
                          <td className="px-6 py-4 text-sm font-bold text-gray-500">
                            {reorder}
                          </td>
                          <td className="px-6 py-4 text-sm font-bold text-gray-500">
                            {maxStock}
                          </td>
                          <td className="px-6 py-4">
                            <span className={`px-3 py-1 rounded-full text-xs font-bold border ${getStockBadgeColor(stock, threshold, reorder)}`}>
                              {getStockStatusLabel(stock, threshold, reorder)}
                            </span>
                          </td>
                          <td className="px-6 py-4 text-left">
                            <div className="flex items-center justify-end gap-2">
                              <button
                                onClick={() => setUpdateStockModal({
                                  open: true,
                                  product: p,
                                  type: 'in',
                                  quantity: 1,
                                  reason: '',
                                  invoice_number: ''
                                })}
                                className="px-3 py-1.5 rounded-xl bg-primary-50 text-primary-600 hover:bg-primary-100 text-xs font-bold transition-colors flex items-center gap-1.5"
                              >
                                <Plus size={14} />
                                <span>تعديل المخزون</span>
                              </button>
                              <button
                                onClick={() => setThresholdModal({
                                  open: true,
                                  product: p,
                                  low_stock_threshold: threshold,
                                  reorder_point: reorder,
                                  max_stock: maxStock
                                })}
                                className="p-2 rounded-xl bg-gray-50 text-gray-500 hover:bg-gray-100 transition-colors"
                                title="إعدادات الحدود"
                              >
                                <Settings size={14} />
                              </button>
                            </div>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>
      )}

      {/* TAB CONTENT: HISTORY */}
      {activeTab === 'history' && (
        <div className="space-y-6">
          <div className="bg-white rounded-3xl border border-gray-100 shadow-sm overflow-hidden">
            <div className="p-5 border-b border-gray-100 flex items-center justify-between">
              <h3 className="font-extrabold text-lg text-gray-800">حركات المخزون الأخيرة</h3>
              <button 
                onClick={fetchHistory}
                className="p-2 rounded-xl hover:bg-gray-100 transition-all text-gray-400 hover:text-gray-700"
              >
                <RefreshCw size={18} />
              </button>
            </div>

            {loadingHistory ? (
              <div className="p-12 text-center">
                <div className="w-10 h-10 border-4 border-primary-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
                <p className="text-gray-500 font-bold text-sm">جاري تحميل سجل الحركات...</p>
              </div>
            ) : historyMovements.length === 0 ? (
              <div className="p-12 text-center text-gray-400">
                <History size={48} className="mx-auto mb-3 opacity-55" />
                <p className="font-bold">لا توجد حركات مخزون مسجلة بعد.</p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-right border-collapse">
                  <thead>
                    <tr className="bg-gray-50 border-b border-gray-100 text-gray-500 text-xs font-bold uppercase">
                      <th className="px-6 py-4.5">المنتج</th>
                      <th className="px-6 py-4.5">نوع الحركة</th>
                      <th className="px-6 py-4.5">التغيير</th>
                      <th className="px-6 py-4.5">الكمية قبل → بعد</th>
                      <th className="px-6 py-4.5">السبب / الملاحظة</th>
                      <th className="px-6 py-4.5">رقم الفاتورة</th>
                      <th className="px-6 py-4.5">المسؤول</th>
                      <th className="px-6 py-4.5">التاريخ والوقت</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100">
                    {historyMovements.map((m) => (
                      <tr key={m.id} className="hover:bg-gray-50/50 transition-colors text-sm">
                        <td className="px-6 py-4 font-bold text-gray-900">
                          {m.product_name}
                        </td>
                        <td className="px-6 py-4">
                          <span className={`px-2.5 py-1 rounded-lg text-xs font-bold flex items-center gap-1.5 w-fit ${
                            m.type === 'in' ? 'bg-emerald-50 text-emerald-700' :
                            m.type === 'out' ? 'bg-red-50 text-red-700' : 'bg-blue-50 text-blue-700'
                          }`}>
                            {m.type === 'in' ? <TrendingUp size={12} /> : 
                             m.type === 'out' ? <TrendingDown size={12} /> : <Sliders size={12} />}
                            {m.type === 'in' ? 'توريد / إدخال' :
                             m.type === 'out' ? 'صرف / بيع' :
                             m.type === 'adjustment' ? 'تعديل مخزني' : 'جرد دوري'}
                          </span>
                        </td>
                        <td className="px-6 py-4 font-extrabold text-gray-900">
                          <span className={m.quantity_change > 0 ? 'text-emerald-600' : 'text-red-600'}>
                            {m.quantity_change > 0 ? `+${m.quantity_change}` : m.quantity_change}
                          </span>
                        </td>
                        <td className="px-6 py-4 text-gray-500 font-semibold">
                          {m.quantity_before} ← <span className="font-extrabold text-gray-900">{m.quantity_after}</span>
                        </td>
                        <td className="px-6 py-4 text-gray-500">
                          {m.reason || '-'}
                        </td>
                        <td className="px-6 py-4 font-mono text-xs font-bold text-indigo-600">
                          {m.invoice_number ? (
                            <span className="flex items-center gap-1">
                              <FileText size={12} />
                              {m.invoice_number}
                            </span>
                          ) : '-'}
                        </td>
                        <td className="px-6 py-4 font-bold text-gray-700">
                          {m.created_by}
                        </td>
                        <td className="px-6 py-4 text-xs text-gray-400 font-semibold">
                          {new Date(m.created_at).toLocaleString('ar-IQ')}
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

      {/* UPDATE STOCK MODAL */}
      <AnimatePresence>
        {updateStockModal.open && (
          <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4 font-cairo">
            <motion.div 
              initial={{ scale: 0.95, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.95, opacity: 0 }}
              className="bg-white rounded-3xl shadow-xl w-full max-w-md overflow-hidden"
            >
              <div className="p-6 border-b border-gray-100 flex items-center justify-between">
                <h3 className="font-extrabold text-lg text-gray-800">تحديث كمية المخزون</h3>
                <button 
                  onClick={() => setUpdateStockModal({ open: false, product: null, type: 'in', quantity: 1, reason: '', invoice_number: '' })}
                  className="p-1 rounded-lg hover:bg-gray-100 text-gray-400"
                >
                  <XCircle size={20} />
                </button>
              </div>

              <form onSubmit={handleStockUpdateSubmit} className="p-6 space-y-4">
                <div className="bg-gray-50 p-3 rounded-2xl border flex items-center gap-3">
                  {updateStockModal.product?.image_url && (
                    <img src={updateStockModal.product.image_url} alt="" className="w-12 h-12 rounded-xl object-cover" />
                  )}
                  <div>
                    <h4 className="text-sm font-bold text-gray-900">{updateStockModal.product?.name}</h4>
                    <p className="text-xs text-gray-400">الكمية الحالية: {updateStockModal.product?.stock_quantity} وحدة</p>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-gray-500 mb-1.5">نوع العملية</label>
                  <div className="grid grid-cols-4 gap-2">
                    {[
                      { key: 'in', label: 'توريد', color: 'peer-checked:bg-emerald-50 peer-checked:text-emerald-700 peer-checked:border-emerald-500' },
                      { key: 'out', label: 'صرف', color: 'peer-checked:bg-red-50 peer-checked:text-red-700 peer-checked:border-red-500' },
                      { key: 'adjustment', label: 'تعديل', color: 'peer-checked:bg-blue-50 peer-checked:text-blue-700 peer-checked:border-blue-500' },
                      { key: 'audit', label: 'جرد', color: 'peer-checked:bg-purple-50 peer-checked:text-purple-700 peer-checked:border-purple-500' }
                    ].map(op => (
                      <label key={op.key} className="cursor-pointer text-center">
                        <input
                          type="radio"
                          name="type"
                          value={op.key}
                          checked={updateStockModal.type === op.key}
                          onChange={(e) => setUpdateStockModal(prev => ({ ...prev, type: e.target.value }))}
                          className="sr-only peer"
                        />
                        <div className={`border rounded-xl py-2 text-xs font-bold text-gray-500 hover:bg-gray-50 transition-all ${op.color}`}>
                          {op.label}
                        </div>
                      </label>
                    ))}
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-gray-500 mb-1.5">الكمية (وحدات)</label>
                  <div className="flex items-center gap-3">
                    <button
                      type="button"
                      onClick={() => setUpdateStockModal(prev => ({ ...prev, quantity: Math.max(1, prev.quantity - 1) }))}
                      className="p-3 bg-gray-50 hover:bg-gray-100 text-gray-600 rounded-xl transition-all"
                    >
                      <Minus size={16} />
                    </button>
                    <input
                      type="number"
                      min="1"
                      required
                      value={updateStockModal.quantity}
                      onChange={(e) => setUpdateStockModal(prev => ({ ...prev, quantity: parseInt(e.target.value) || 1 }))}
                      className="flex-grow text-center py-2.5 bg-gray-50 border-0 rounded-xl font-bold text-gray-900 outline-none"
                    />
                    <button
                      type="button"
                      onClick={() => setUpdateStockModal(prev => ({ ...prev, quantity: prev.quantity + 1 }))}
                      className="p-3 bg-gray-50 hover:bg-gray-100 text-gray-600 rounded-xl transition-all"
                    >
                      <Plus size={16} />
                    </button>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-gray-500 mb-1.5">رقم الفاتورة / المستند (اختياري)</label>
                  <input
                    type="text"
                    placeholder="مثال: INV-1004"
                    value={updateStockModal.invoice_number}
                    onChange={(e) => setUpdateStockModal(prev => ({ ...prev, invoice_number: e.target.value }))}
                    className="w-full bg-gray-50 border-0 rounded-xl px-4 py-2.5 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-primary-600"
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold text-gray-500 mb-1.5">السبب / الملاحظة</label>
                  <textarea
                    rows="3"
                    required
                    placeholder="توضيح سبب الحركة أو الجرد التلقائي..."
                    value={updateStockModal.reason}
                    onChange={(e) => setUpdateStockModal(prev => ({ ...prev, reason: e.target.value }))}
                    className="w-full bg-gray-50 border-0 rounded-xl px-4 py-2.5 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-primary-600 resize-none"
                  ></textarea>
                </div>

                <div className="pt-4 grid grid-cols-2 gap-3">
                  <button
                    type="submit"
                    className="w-full bg-primary-600 text-white py-3 rounded-2xl font-bold text-sm hover:bg-primary-700 shadow-md shadow-primary-600/10 hover:shadow-lg transition-all"
                  >
                    حفظ العملية
                  </button>
                  <button
                    type="button"
                    onClick={() => setUpdateStockModal({ open: false, product: null, type: 'in', quantity: 1, reason: '', invoice_number: '' })}
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

      {/* THRESHOLD CONFIG MODAL */}
      <AnimatePresence>
        {thresholdModal.open && (
          <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4 font-cairo">
            <motion.div 
              initial={{ scale: 0.95, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.95, opacity: 0 }}
              className="bg-white rounded-3xl shadow-xl w-full max-w-md overflow-hidden"
            >
              <div className="p-6 border-b border-gray-100 flex items-center justify-between">
                <h3 className="font-extrabold text-lg text-gray-800">إعدادات حدود المخزون</h3>
                <button 
                  onClick={() => setThresholdModal({ open: false, product: null, low_stock_threshold: 10, reorder_point: 20, max_stock: 100 })}
                  className="p-1 rounded-lg hover:bg-gray-100 text-gray-400"
                >
                  <XCircle size={20} />
                </button>
              </div>

              <form onSubmit={handleThresholdSubmit} className="p-6 space-y-4">
                <div className="bg-gray-50 p-3 rounded-2xl border flex items-center gap-3 mb-2">
                  {thresholdModal.product?.image_url && (
                    <img src={thresholdModal.product.image_url} alt="" className="w-12 h-12 rounded-xl object-cover" />
                  )}
                  <div>
                    <h4 className="text-sm font-bold text-gray-900">{thresholdModal.product?.name}</h4>
                    <p className="text-xs text-gray-400">الكمية الحالية: {thresholdModal.product?.stock_quantity} وحدة</p>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-gray-500 mb-1.5">الحد الحرج (تنبيه فوري باللون الأحمر)</label>
                  <input
                    type="number"
                    min="0"
                    required
                    value={thresholdModal.low_stock_threshold}
                    onChange={(e) => setThresholdModal(prev => ({ ...prev, low_stock_threshold: parseInt(e.target.value) || 0 }))}
                    className="w-full bg-gray-50 border-0 rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:bg-white focus:ring-2 focus:ring-primary-600"
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold text-gray-500 mb-1.5">حد إعادة الطلب (تنبيه باللون الأصفر)</label>
                  <input
                    type="number"
                    min="0"
                    required
                    value={thresholdModal.reorder_point}
                    onChange={(e) => setThresholdModal(prev => ({ ...prev, reorder_point: parseInt(e.target.value) || 0 }))}
                    className="w-full bg-gray-50 border-0 rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:bg-white focus:ring-2 focus:ring-primary-600"
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold text-gray-500 mb-1.5">الحد الأقصى للمخزون (السعة القصوى)</label>
                  <input
                    type="number"
                    min="0"
                    required
                    value={thresholdModal.max_stock}
                    onChange={(e) => setThresholdModal(prev => ({ ...prev, max_stock: parseInt(e.target.value) || 0 }))}
                    className="w-full bg-gray-50 border-0 rounded-xl px-4 py-2.5 text-sm font-bold outline-none focus:bg-white focus:ring-2 focus:ring-primary-600"
                  />
                </div>

                <div className="pt-4 grid grid-cols-2 gap-3">
                  <button
                    type="submit"
                    className="w-full bg-primary-600 text-white py-3 rounded-2xl font-bold text-sm hover:bg-primary-700 shadow-md shadow-primary-600/10 hover:shadow-lg transition-all"
                  >
                    حفظ الحدود
                  </button>
                  <button
                    type="button"
                    onClick={() => setThresholdModal({ open: false, product: null, low_stock_threshold: 10, reorder_point: 20, max_stock: 100 })}
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
    </div>
  );
}
