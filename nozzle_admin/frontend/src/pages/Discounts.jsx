import React, { useState, useEffect } from 'react';
import api from '../services/api';
import { 
  Plus, 
  Edit2, 
  Trash2, 
  Ticket, 
  Calendar, 
  Check, 
  Percent, 
  DollarSign, 
  AlertCircle,
  EyeOff
} from 'lucide-react';

export default function Discounts() {
  const [coupons, setCoupons] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [editingCoupon, setEditingCoupon] = useState(null);
  const [errorMessage, setErrorMessage] = useState('');
  
  // Scopes lists
  const [productList, setProductList] = useState([]);
  const [categoryList, setCategoryList] = useState([]);

  // Form states
  const [code, setCode] = useState('');
  const [discountType, setDiscountType] = useState('percentage'); // percentage, fixed, buy_x_get_y
  const [value, setValue] = useState(0);
  const [minOrderValue, setMinOrderValue] = useState('');
  const [maxDiscountValue, setMaxDiscountValue] = useState('');
  const [usageLimit, setUsageLimit] = useState('');
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const [selectedProductIds, setSelectedProductIds] = useState([]);
  const [selectedCategoryIds, setSelectedCategoryIds] = useState([]);
  const [buyX, setBuyX] = useState('');
  const [getY, setGetY] = useState('');
  const [getYDiscount, setGetYDiscount] = useState(100);
  const [isActive, setIsActive] = useState(true);

  useEffect(() => {
    fetchCoupons();
    fetchOptions();
  }, []);

  const fetchCoupons = async () => {
    try {
      setLoading(true);
      const res = await api.get('/coupons');
      if (res.data && res.data.status === 'success') {
        setCoupons(res.data.data);
      }
    } catch (err) {
      console.error('Error fetching coupons:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchOptions = async () => {
    try {
      const catRes = await api.get('/categories?parent_only=true');
      if (catRes.data && catRes.data.status === 'success') {
        setCategoryList(catRes.data.data);
      }
      const prodRes = await api.get('/products?limit=100');
      if (prodRes.data && prodRes.data.status === 'success') {
        setProductList(prodRes.data.data);
      }
    } catch (err) {
      console.error('Error fetching options list:', err);
    }
  };

  const openAddModal = () => {
    setEditingCoupon(null);
    setCode('');
    setDiscountType('percentage');
    setValue(0);
    setMinOrderValue('');
    setMaxDiscountValue('');
    setUsageLimit('');
    setStartDate('');
    setEndDate('');
    setSelectedProductIds([]);
    setSelectedCategoryIds([]);
    setBuyX('');
    setGetY('');
    setGetYDiscount(100);
    setIsActive(true);
    setErrorMessage('');
    setModalOpen(true);
  };

  const openEditModal = (c) => {
    setEditingCoupon(c);
    setCode(c.code || '');
    setDiscountType(c.discount_type || 'percentage');
    setValue(c.value || 0);
    setMinOrderValue(c.min_order_value ? String(c.min_order_value) : '');
    setMaxDiscountValue(c.max_discount_value ? String(c.max_discount_value) : '');
    setUsageLimit(c.usage_limit ? String(c.usage_limit) : '');
    setStartDate(c.start_date ? c.start_date.substring(0, 16) : '');
    setEndDate(c.end_date ? c.end_date.substring(0, 16) : '');
    setSelectedProductIds(c.product_ids || []);
    setSelectedCategoryIds(c.category_ids || []);
    setBuyX(c.buy_x ? String(c.buy_x) : '');
    setGetY(c.get_y ? String(c.get_y) : '');
    setGetYDiscount(c.get_y_discount || 100);
    setIsActive(c.is_active !== false);
    setErrorMessage('');
    setModalOpen(true);
  };

  const handleProductToggle = (id) => {
    setSelectedProductIds(prev => 
      prev.includes(id) ? prev.filter(item => item !== id) : [...prev, id]
    );
  };

  const handleCategoryToggle = (id) => {
    setSelectedCategoryIds(prev => 
      prev.includes(id) ? prev.filter(item => item !== id) : [...prev, id]
    );
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMessage('');

    if (!code) {
      setErrorMessage('كود الكوبون مطلوب');
      return;
    }

    const payload = {
      code: code.trim().toUpperCase(),
      discount_type: discountType,
      value: discountType === 'buy_x_get_y' ? 0 : parseFloat(value) || 0,
      min_order_value: minOrderValue ? parseFloat(minOrderValue) : null,
      max_discount_value: maxDiscountValue ? parseFloat(maxDiscountValue) : null,
      usage_limit: usageLimit ? parseInt(usageLimit) : null,
      start_date: startDate ? new Date(startDate).toISOString() : null,
      end_date: endDate ? new Date(endDate).toISOString() : null,
      product_ids: selectedProductIds,
      category_ids: selectedCategoryIds,
      buy_x: discountType === 'buy_x_get_y' && buyX ? parseInt(buyX) : null,
      get_y: discountType === 'buy_x_get_y' && getY ? parseInt(getY) : null,
      get_y_discount: discountType === 'buy_x_get_y' ? parseFloat(getYDiscount) : 100.0,
      is_active: isActive
    };

    try {
      if (editingCoupon) {
        await api.put(`/coupons/${editingCoupon.id}`, payload);
      } else {
        await api.post('/coupons', payload);
      }
      setModalOpen(false);
      fetchCoupons();
    } catch (err) {
      setErrorMessage(err.response?.data?.detail || 'حدث خطأ أثناء حفظ الكوبون');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('هل أنت متأكد من حذف هذا الكوبون الخصم؟')) return;
    try {
      await api.delete(`/coupons/${id}`);
      fetchCoupons();
    } catch (err) {
      alert('حدث خطأ أثناء حذف الكوبون');
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-black text-gray-800 dark:text-dark-50">الخصومات والكوبونات</h1>
          <p className="text-sm text-gray-400 mt-1">إنشاء كوبونات الخصم للعملاء وتحديد شروط وقواعد الاستخدام.</p>
        </div>
        <button 
          onClick={openAddModal}
          className="bg-primary-600 hover:bg-primary-700 text-white font-bold px-4 py-2.5 rounded-xl flex items-center gap-2 shadow-lg shadow-primary-600/20 transition-all active:scale-95"
        >
          <Plus size={18} />
          إنشاء كوبون جديد
        </button>
      </div>

      {/* Main coupons list table */}
      <div className="bg-white dark:bg-dark-900 border border-gray-200 dark:border-dark-800 rounded-2xl shadow-sm overflow-hidden">
        {loading ? (
          <div className="space-y-4 p-6 animate-pulse">
            {[1, 2, 3].map(n => (
              <div key={n} className="h-12 bg-gray-100 dark:bg-dark-850 rounded-xl w-full"></div>
            ))}
          </div>
        ) : coupons.length === 0 ? (
          <div className="text-center py-12">
            <div className="w-16 h-16 bg-gray-50 dark:bg-dark-800/40 text-gray-400 rounded-full flex items-center justify-center mx-auto mb-4">
              <Ticket size={28} />
            </div>
            <h3 className="font-bold text-gray-700 dark:text-dark-300">لا توجد كوبونات خصم</h3>
            <p className="text-sm text-gray-400 mt-1">ابدأ بإنشاء أول كوبون لجذب العملاء وتنشيط المبيعات.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-right border-collapse">
              <thead>
                <tr className="bg-gray-50 dark:bg-dark-800/40 border-b border-gray-200 dark:border-dark-800 text-xs font-bold text-gray-500 uppercase">
                  <th className="py-4 px-6">كود الكوبون</th>
                  <th className="py-4 px-6">نوع الخصم</th>
                  <th className="py-4 px-6">القيمة</th>
                  <th className="py-4 px-6">شروط الاستخدام</th>
                  <th className="py-4 px-6">معدل الاستخدام</th>
                  <th className="py-4 px-6">حالة الكوبون</th>
                  <th className="py-4 px-6 text-left">خيارات</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-dark-800 text-sm">
                {coupons.map((c) => {
                  const now = new Date();
                  const isExpired = c.end_date && new Date(c.end_date) < now;
                  
                  return (
                    <tr key={c.id} className="hover:bg-gray-50/50 dark:hover:bg-dark-800/20">
                      {/* Code */}
                      <td className="py-4 px-6 font-mono font-bold text-gray-900 dark:text-dark-100">
                        <span className="bg-primary-50 text-primary-600 dark:bg-primary-950/20 px-2.5 py-1 rounded-lg border border-primary-100 dark:border-primary-900/40">
                          {c.code}
                        </span>
                      </td>

                      {/* Discount type */}
                      <td className="py-4 px-6">
                        {c.discount_type === 'percentage' ? (
                          <span className="flex items-center gap-1.5 text-indigo-600 dark:text-indigo-400">
                            <Percent size={14} /> نسبة مئوية
                          </span>
                        ) : c.discount_type === 'fixed' ? (
                          <span className="flex items-center gap-1.5 text-green-600 dark:text-green-400">
                            <DollarSign size={14} /> مبلغ ثابت
                          </span>
                        ) : (
                          <span className="bg-yellow-50 text-yellow-600 dark:bg-yellow-950/20 px-2 py-0.5 rounded text-xs font-bold">
                            اشترِ X واحصل على Y
                          </span>
                        )}
                      </td>

                      {/* Value */}
                      <td className="py-4 px-6 font-bold text-gray-800 dark:text-dark-200">
                        {c.discount_type === 'percentage' ? (
                          `${c.value}%`
                        ) : c.discount_type === 'fixed' ? (
                          `${Number(c.value).toLocaleString()} د.ع`
                        ) : (
                          `اشترِ ${c.buy_x} واحصل على ${c.get_y} بخصم ${c.get_y_discount}%`
                        )}
                      </td>

                      {/* Restrictions */}
                      <td className="py-4 px-6 text-xs text-gray-500 space-y-1">
                        {c.min_order_value && <div>الحد الأدنى: {Number(c.min_order_value).toLocaleString()} د.ع</div>}
                        {(c.product_ids.length > 0 || c.category_ids.length > 0) && (
                          <div className="text-primary-600 font-bold">مشمول بمنتجات/أقسام محددة</div>
                        )}
                        {(!c.min_order_value && c.product_ids.length === 0 && c.category_ids.length === 0) && (
                          <div className="text-gray-400">لا توجد قيود</div>
                        )}
                      </td>

                      {/* Usage */}
                      <td className="py-4 px-6">
                        <div className="flex items-center gap-1.5 font-mono text-xs">
                          <span className="font-bold text-gray-800 dark:text-dark-200">{c.usage_count}</span>
                          <span className="text-gray-400">/</span>
                          <span className="text-gray-400">{c.usage_limit || '∞'}</span>
                        </div>
                      </td>

                      {/* Status */}
                      <td className="py-4 px-6">
                        {isExpired ? (
                          <span className="bg-red-50 text-red-500 border border-red-100 text-[10px] px-2 py-0.5 rounded-full font-bold">
                            منتهي الصلاحية
                          </span>
                        ) : c.is_active ? (
                          <span className="bg-green-50 text-green-500 border border-green-100 text-[10px] px-2 py-0.5 rounded-full font-bold">
                            نشط
                          </span>
                        ) : (
                          <span className="bg-gray-100 text-gray-500 text-[10px] px-2 py-0.5 rounded-full font-bold flex items-center gap-0.5 w-max">
                            <EyeOff size={10} /> معطل
                          </span>
                        )}
                      </td>

                      {/* Actions */}
                      <td className="py-4 px-6 text-left">
                        <div className="flex items-center gap-1 justify-end">
                          <button
                            onClick={() => openEditModal(c)}
                            className="p-1.5 hover:bg-blue-50 hover:text-blue-600 dark:hover:bg-blue-950/20 text-gray-400 rounded-lg"
                          >
                            <Edit2 size={15} />
                          </button>
                          <button
                            onClick={() => handleDelete(c.id)}
                            className="p-1.5 hover:bg-red-50 hover:text-red-600 dark:hover:bg-red-950/20 text-gray-400 rounded-lg"
                          >
                            <Trash2 size={15} />
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

      {/* Coupon Add/Edit Modal */}
      {modalOpen && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4 backdrop-blur-sm">
          <div className="bg-white dark:bg-dark-900 rounded-2xl w-full max-w-xl overflow-hidden shadow-2xl border border-gray-100 dark:border-dark-800 flex flex-col max-h-[90vh]">
            <div className="p-6 border-b border-gray-100 dark:border-dark-800 flex justify-between items-center bg-gray-50/50 dark:bg-dark-900/50">
              <h3 className="font-extrabold text-lg text-gray-800 dark:text-dark-100">
                {editingCoupon ? 'تعديل كوبون الخصم' : 'إنشاء كوبون خصم جديد'}
              </h3>
              <button 
                onClick={() => setModalOpen(false)}
                className="text-gray-400 hover:text-gray-600 dark:hover:text-dark-200"
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

              {/* Code */}
              <div>
                <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">كود الكوبون</label>
                <input 
                  type="text"
                  value={code}
                  onChange={(e) => setCode(e.target.value)}
                  className="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none font-mono text-left uppercase font-bold"
                  placeholder="NOZZLE20"
                  required
                />
              </div>

              {/* Discount Type */}
              <div className="grid grid-cols-3 gap-3 p-1.5 bg-gray-100 dark:bg-dark-850 rounded-xl">
                {[
                  { type: 'percentage', label: 'نسبة مئوية' },
                  { type: 'fixed', label: 'مبلغ ثابت' },
                  { type: 'buy_x_get_y', label: 'اشترِ X واحصل على Y' }
                ].map(opt => (
                  <button
                    key={opt.type}
                    type="button"
                    onClick={() => setDiscountType(opt.type)}
                    className={`py-2 rounded-lg text-xs font-bold transition-all ${discountType === opt.type ? 'bg-white dark:bg-dark-900 text-primary-600 dark:text-primary-400 shadow-sm' : 'text-gray-500 hover:text-gray-700'}`}
                  >
                    {opt.label}
                  </button>
                ))}
              </div>

              {/* Value Fields depending on Type */}
              {discountType !== 'buy_x_get_y' ? (
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">
                      {discountType === 'percentage' ? 'نسبة الخصم (%)' : 'قيمة الخصم (د.ع)'}
                    </label>
                    <input 
                      type="number"
                      value={value}
                      onChange={(e) => setValue(e.target.value)}
                      className="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none"
                      min="0"
                      max={discountType === 'percentage' ? '100' : '9999'}
                      required
                    />
                  </div>

                  {discountType === 'percentage' && (
                    <div>
                      <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">الحد الأقصى للخصم (اختياري)</label>
                      <input 
                        type="number"
                        value={maxDiscountValue}
                        onChange={(e) => setMaxDiscountValue(e.target.value)}
                        className="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none"
                        placeholder="لا يوجد سقف"
                      />
                    </div>
                  )}
                </div>
              ) : (
                <div className="grid grid-cols-3 gap-3 p-4 bg-yellow-50/50 dark:bg-yellow-950/10 border border-yellow-100 dark:border-yellow-900/30 rounded-2xl">
                  <div>
                    <label className="block text-xs font-bold mb-1 text-yellow-800 dark:text-yellow-400">اشترِ (X)</label>
                    <input 
                      type="number"
                      value={buyX}
                      onChange={(e) => setBuyX(e.target.value)}
                      className="w-full px-3 py-1.5 rounded-lg border border-yellow-200 dark:border-yellow-900 bg-white dark:bg-dark-900 text-sm focus:outline-none"
                      placeholder="3"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold mb-1 text-yellow-800 dark:text-yellow-400">احصل على (Y)</label>
                    <input 
                      type="number"
                      value={getY}
                      onChange={(e) => setGetY(e.target.value)}
                      className="w-full px-3 py-1.5 rounded-lg border border-yellow-200 dark:border-yellow-900 bg-white dark:bg-dark-900 text-sm focus:outline-none"
                      placeholder="1"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold mb-1 text-yellow-800 dark:text-yellow-400">بخصم Y (%)</label>
                    <input 
                      type="number"
                      value={getYDiscount}
                      onChange={(e) => setGetYDiscount(e.target.value)}
                      className="w-full px-3 py-1.5 rounded-lg border border-yellow-200 dark:border-yellow-900 bg-white dark:bg-dark-900 text-sm focus:outline-none"
                      placeholder="100 (مجاني)"
                      min="0"
                      max="100"
                    />
                  </div>
                </div>
              )}

              {/* Usage thresholds limits */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">الحد الأدنى لقيمة الطلب</label>
                  <input 
                    type="number"
                    value={minOrderValue}
                    onChange={(e) => setMinOrderValue(e.target.value)}
                    className="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none"
                    placeholder="بدون حد أدنى"
                  />
                </div>
                <div>
                  <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">الحد الأقصى لمرات الاستخدام</label>
                  <input 
                    type="number"
                    value={usageLimit}
                    onChange={(e) => setUsageLimit(e.target.value)}
                    className="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none"
                    placeholder="غير محدود"
                  />
                </div>
              </div>

              {/* Target scopes selection */}
              <div className="border border-gray-150 dark:border-dark-800 rounded-xl p-4 space-y-4">
                <h4 className="font-extrabold text-sm text-gray-500">تقييد استخدام الكوبون (اختياري)</h4>
                
                {/* Category scoping select */}
                <div>
                  <label className="block text-xs font-bold text-gray-700 dark:text-dark-300 mb-2">تحديد أقسام معينة مشمولة</label>
                  <div className="flex flex-wrap gap-2 max-h-24 overflow-y-auto p-1">
                    {categoryList.map(c => {
                      const isSelected = selectedCategoryIds.includes(c.id);
                      return (
                        <button
                          key={c.id}
                          type="button"
                          onClick={() => handleCategoryToggle(c.id)}
                          className={`text-xs px-2.5 py-1 rounded-full border transition-all ${isSelected ? 'bg-indigo-50 border-indigo-300 text-indigo-600 dark:bg-indigo-950/20' : 'bg-transparent border-gray-200 text-gray-500'}`}
                        >
                          {c.name}
                        </button>
                      );
                    })}
                  </div>
                </div>

                {/* Product scoping select */}
                <div>
                  <label className="block text-xs font-bold text-gray-700 dark:text-dark-300 mb-2">تحديد منتجات معينة مشمولة</label>
                  <div className="flex flex-wrap gap-2 max-h-28 overflow-y-auto p-1">
                    {productList.map(p => {
                      const isSelected = selectedProductIds.includes(p.id);
                      return (
                        <button
                          key={p.id}
                          type="button"
                          onClick={() => handleProductToggle(p.id)}
                          className={`text-xs px-2.5 py-1 rounded-full border transition-all ${isSelected ? 'bg-primary-50 border-primary-300 text-primary-600 dark:bg-primary-950/20' : 'bg-transparent border-gray-200 text-gray-500'}`}
                        >
                          {p.name}
                        </button>
                      );
                    })}
                  </div>
                </div>
              </div>

              {/* Schedule Dates */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">تاريخ بدء الصلاحية</label>
                  <input 
                    type="datetime-local"
                    value={startDate}
                    onChange={(e) => setStartDate(e.target.value)}
                    className="w-full px-4 py-2 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none text-sm text-left"
                  />
                </div>
                <div>
                  <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">تاريخ انتهاء الصلاحية</label>
                  <input 
                    type="datetime-local"
                    value={endDate}
                    onChange={(e) => setEndDate(e.target.value)}
                    className="w-full px-4 py-2 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none text-sm text-left"
                  />
                </div>
              </div>

              {/* Active Toggle */}
              <div className="flex items-center gap-3 border-t border-gray-150 dark:border-dark-800 pt-4">
                <input 
                  type="checkbox" 
                  id="isActive"
                  checked={isActive}
                  onChange={(e) => setIsActive(e.target.checked)}
                  className="w-5 h-5 accent-primary-600 rounded cursor-pointer"
                />
                <label htmlFor="isActive" className="text-sm font-bold text-gray-700 dark:text-dark-300 cursor-pointer">
                  تفعيل الكوبون (عرضه وصلاحيته فورياً للعملاء)
                </label>
              </div>

              {/* Submit Buttons */}
              <div className="flex gap-3 justify-end pt-4 border-t border-gray-100 dark:border-dark-800">
                <button
                  type="button"
                  onClick={() => setModalOpen(false)}
                  className="px-5 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 text-gray-700 dark:text-dark-300 font-bold hover:bg-gray-50 dark:hover:bg-dark-800/40"
                >
                  إلغاء
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 rounded-xl bg-primary-600 hover:bg-primary-700 text-white font-bold shadow-lg shadow-primary-600/10 active:scale-95"
                >
                  حفظ الكوبون
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
