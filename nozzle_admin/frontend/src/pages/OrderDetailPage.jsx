import React, { useState, useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { 
  ArrowRight, 
  Printer, 
  FileText, 
  MessageSquare, 
  Phone, 
  MapPin, 
  Calendar, 
  User, 
  ShoppingBag,
  Clock,
  CheckCircle,
  AlertCircle,
  ChevronLeft,
  Bell,
  Check,
  Save,
  MessageCircle,
  Percent
} from 'lucide-react';
import api from '../services/api';
import Toast from '../components/Toast';
import { generateInvoicePDF } from '../services/invoicePdf.service';

const statusColors = {
  new: 'bg-blue-50 text-blue-700 border-blue-200 dark:bg-blue-950/20 dark:text-blue-400 dark:border-blue-800',
  pending: 'bg-amber-50 text-amber-700 border-amber-200 dark:bg-amber-950/20 dark:text-amber-400 dark:border-amber-800',
  confirmed: 'bg-indigo-50 text-indigo-700 border-indigo-200 dark:bg-indigo-950/20 dark:text-indigo-400 dark:border-indigo-800',
  processing: 'bg-purple-50 text-purple-700 border-purple-200 dark:bg-purple-950/20 dark:text-purple-400 dark:border-purple-800',
  shipped: 'bg-cyan-50 text-cyan-700 border-cyan-200 dark:bg-cyan-950/20 dark:text-cyan-400 dark:border-cyan-800',
  on_the_way: 'bg-orange-50 text-orange-700 border-orange-200 dark:bg-orange-950/20 dark:text-orange-400 dark:border-orange-800',
  delivered: 'bg-emerald-50 text-emerald-700 border-emerald-200 dark:bg-emerald-950/20 dark:text-emerald-400 dark:border-emerald-800',
  completed: 'bg-emerald-100 text-emerald-800 border-emerald-300 dark:bg-emerald-950/30 dark:text-emerald-400 dark:border-emerald-800',
  cancelled: 'bg-rose-50 text-rose-700 border-rose-200 dark:bg-rose-950/20 dark:text-rose-400 dark:border-rose-800'
};

const statusLabels = {
  new: 'جديد',
  pending: 'معلق',
  confirmed: 'مؤكد',
  processing: 'جاري التحضير',
  shipped: 'تم الشحن',
  on_the_way: 'في الطريق',
  delivered: 'تم التسليم',
  completed: 'مكتمل',
  cancelled: 'ملغي'
};

// Timeline steps mapping
const timelineSteps = [
  { key: 'new', label: 'جديد' },
  { key: 'confirmed', label: 'مؤكد' },
  { key: 'processing', label: 'جاري التحضير' },
  { key: 'on_the_way', label: 'في الطريق' },
  { key: 'delivered', label: 'تم التسليم' }
];

export default function OrderDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);
  
  // Status edit states
  const [status, setStatus] = useState('');
  const [note, setNote] = useState('');
  const [sendNotification, setSendNotification] = useState(true);
  const [savingStatus, setSavingStatus] = useState(false);
  
  // Toast feedback states
  const [toastMessage, setToastMessage] = useState('');
  const [toastType, setToastType] = useState('success');

  const fetchOrderDetail = async () => {
    setLoading(true);
    try {
      const response = await api.get(`/v1/orders/${id}/detail`);
      if (response.data && response.data.success) {
        const orderData = response.data.data;
        setOrder(orderData);
        setStatus(orderData.status);
      } else {
        showToast('فشل تحميل تفاصيل الطلب', 'error');
      }
    } catch (error) {
      console.error('Failed to load order details:', error);
      showToast('خطأ في الاتصال بالخادم لمشاهدة تفاصيل الطلب', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrderDetail();
  }, [id]);

  const showToast = (message, type = 'success') => {
    setToastMessage(message);
    setToastType(type);
  };

  const handleUpdateStatus = async (e) => {
    e.preventDefault();
    setSavingStatus(true);
    try {
      const response = await api.put(`/v1/orders/${id}/status`, {
        status,
        note,
        send_notification: sendNotification
      });
      if (response.data && response.data.success) {
        showToast('تم تحديث حالة الطلب وحفظها بنجاح', 'success');
        setNote('');
        fetchOrderDetail(); // reload order detail
      } else {
        showToast('فشل تحديث حالة الطلب', 'error');
      }
    } catch (error) {
      console.error('Failed to update status:', error);
      showToast('خطأ أثناء إرسال تحديث الحالة', 'error');
    } finally {
      setSavingStatus(false);
    }
  };

  // Helper: format dates nicely
  const formatDateTime = (dateStr) => {
    if (!dateStr) return '';
    try {
      const d = new Date(dateStr);
      return d.toLocaleDateString('ar-IQ', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch (e) {
      return dateStr;
    }
  };

  // Generate dynamic whatsapp message share link
  const getWhatsAppLink = () => {
    if (!order) return '';
    const phone = order.customer?.phone || order.customer_phone || '';
    // Format Iraqi phone numbers if necessary (remove leading 0 and add +964)
    let formattedPhone = phone.trim();
    if (formattedPhone.startsWith('07')) {
      formattedPhone = '964' + formattedPhone.substring(1);
    } else if (formattedPhone.startsWith('7')) {
      formattedPhone = '964' + formattedPhone;
    }
    
    // Construct message body
    const orderItems = order.items.map(item => 
      `- ${item.product?.name} (الكمية: ${item.quantity} | السعر: ${Number(item.price).toLocaleString()} د.ع)`
    ).join('\n');

    const messageText = `مرحباً ${order.customer?.name || order.customer_name}،
يسعدنا إبلاغك بآخر تحديثات طلبك رقم #${order.id} من متجر نوزل.

حالة الطلب الحالية: *${statusLabels[order.status]}*

*تفاصيل المنتجات:*
${orderItems}

*ملخص الفاتورة:*
- المجموع الفرعي: ${Number(order.subtotal).toLocaleString()} د.ع
- رسوم التوصيل: ${Number(order.delivery_fee).toLocaleString()} د.ع
${order.coupon_discount > 0 ? `- خصم الكوبون: -${Number(order.coupon_discount).toLocaleString()} د.ع\n` : ''}- *الإجمالي النهائي: ${Number(order.total).toLocaleString()} د.ع*

عنوان التوصيل: ${order.address}
شكرًا لتسوّقك معنا! ❤️`;

    return `https://wa.me/${formattedPhone}?text=${encodeURIComponent(messageText)}`;
  };

  // Check if timeline step is completed or active
  const getStepStatus = (stepKey) => {
    if (!order) return 'todo';
    const statusOrder = [
      'new',
      'confirmed',
      'processing',
      'on_the_way',
      'delivered',
      'completed'
    ];
    
    const currentIdx = statusOrder.indexOf(order.status);
    const stepIdx = statusOrder.indexOf(stepKey);

    // Handle completed, active, todo states
    if (order.status === 'cancelled') return 'cancelled';
    if (stepKey === order.status) return 'active';
    if (stepIdx !== -1 && currentIdx !== -1 && stepIdx < currentIdx) return 'completed';
    return 'todo';
  };

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[400px] space-y-4">
        <div className="w-12 h-12 border-4 border-primary-600 border-t-transparent rounded-full animate-spin"></div>
        <p className="text-gray-400 text-sm font-bold">جاري تحميل تفاصيل الطلب من الخادم...</p>
      </div>
    );
  }

  if (!order) {
    return (
      <div className="bg-white dark:bg-dark-900 border border-gray-200 dark:border-dark-800 rounded-2xl p-8 text-center space-y-4">
        <AlertCircle className="w-12 h-12 text-rose-500 mx-auto" />
        <h3 className="font-bold text-lg text-gray-800 dark:text-dark-100">الطلب غير موجود</h3>
        <p className="text-gray-400 text-sm">عذرًا، لم يتم العثور على الطلب المطلوب أو أنه قد تم حذفه.</p>
        <Link 
          to="/orders"
          className="inline-flex items-center gap-2 px-5 py-2.5 bg-primary-600 hover:bg-primary-700 text-white rounded-xl text-sm font-bold shadow-sm"
        >
          <ArrowRight size={16} />
          العودة للطلبات
        </Link>
      </div>
    );
  }

  return (
    <div className="space-y-6 pb-12 text-right" dir="rtl">
      {/* Breadcrumbs & Back Link */}
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-2 text-sm">
          <Link to="/orders" className="text-primary-600 hover:underline font-bold">إدارة الطلبات</Link>
          <ChevronLeft size={16} className="text-gray-400" />
          <span className="text-gray-500 dark:text-dark-400 font-semibold">تفاصيل الطلب #{order.id}</span>
        </div>
        
        <Link 
          to="/orders" 
          className="flex items-center gap-2 px-4 py-2 border border-gray-200 dark:border-dark-800 rounded-xl hover:bg-gray-50 dark:hover:bg-dark-800/40 text-gray-600 dark:text-dark-300 font-bold text-sm"
        >
          <ArrowRight size={16} />
          <span>العودة للطلبيات</span>
        </Link>
      </div>

      {/* Main Header Card */}
      <div className="bg-white dark:bg-dark-900 border border-gray-200 dark:border-dark-800 rounded-2xl p-6 shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div className="space-y-2">
          <div className="flex flex-wrap items-center gap-3">
            <h1 className="text-xl md:text-2xl font-black text-gray-800 dark:text-dark-50">
              تفاصيل الطلب <span className="text-primary-600 font-mono">#{order.id}</span>
            </h1>
            <span className={`px-3 py-1 rounded-full border text-xs font-bold ${statusColors[order.status]}`}>
              {statusLabels[order.status]}
            </span>
          </div>
          
          <div className="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-gray-400 font-semibold">
            <span className="flex items-center gap-1">
              <Calendar size={14} />
              <span>تاريخ الطلب: {formatDateTime(order.created_at)}</span>
            </span>
            <span className="flex items-center gap-1 font-mono">
              <FileText size={14} />
              <span>رقم الفاتورة: {order.invoice_number}</span>
            </span>
            <span className="flex items-center gap-1">
              <Percent size={14} className="text-emerald-500" />
              <span>كود الخصم: {order.coupon_code ? <strong className="text-emerald-600 dark:text-emerald-400 font-bold bg-emerald-50 dark:bg-emerald-950/20 px-2 py-0.5 rounded-lg border border-emerald-100 dark:border-emerald-900/50">{order.coupon_code}</strong> : 'لا يوجد'}</span>
            </span>
          </div>
        </div>

        {/* Header Action Buttons */}
        <div className="flex flex-wrap items-center gap-3">
          <button
            onClick={() => generateInvoicePDF(order)}
            className="flex items-center gap-2 px-4 py-2.5 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 dark:bg-indigo-950/20 dark:text-indigo-400 dark:hover:bg-indigo-950/30 rounded-xl text-sm font-bold border border-indigo-100 dark:border-indigo-900/50 cursor-pointer"
          >
            <FileText size={16} />
            <span>تنزيل PDF</span>
          </button>
          
          <Link
            to={`/orders/${order.id}/invoice`}
            target="_blank"
            className="flex items-center gap-2 px-4 py-2.5 bg-slate-50 hover:bg-slate-100 text-slate-700 dark:bg-dark-800 dark:text-dark-200 dark:hover:bg-dark-700 rounded-xl text-sm font-bold border border-slate-200 dark:border-dark-700 cursor-pointer"
          >
            <Printer size={16} />
            <span>طباعة الفاتورة</span>
          </Link>
          
          <a
            href={getWhatsAppLink()}
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-2 px-4 py-2.5 bg-emerald-50 hover:bg-emerald-100 text-emerald-700 dark:bg-emerald-950/20 dark:text-emerald-400 dark:hover:bg-emerald-950/30 rounded-xl text-sm font-bold border border-emerald-200 dark:border-emerald-900/30 cursor-pointer"
          >
            <MessageCircle size={16} />
            <span>مشاركة واتساب</span>
          </a>
        </div>
      </div>

      {/* Visual Status Timeline Progress Bar */}
      <div className="bg-white dark:bg-dark-900 border border-gray-200 dark:border-dark-800 rounded-2xl p-6 shadow-sm overflow-hidden">
        <h3 className="font-extrabold text-sm text-gray-500 mb-6 uppercase tracking-wider">مراحل وتاريخ حالة الطلب</h3>
        
        {order.status === 'cancelled' ? (
          <div className="flex items-center gap-3 p-4 bg-rose-50 border border-rose-150 text-rose-800 rounded-xl text-sm font-bold">
            <AlertCircle className="w-5 h-5 text-rose-600" />
            <span>تم إلغاء هذا الطلب نهائياً. يمكنك الاطلاع على تفاصيل سجل العمليات بالأسفل.</span>
          </div>
        ) : (
          <div className="relative flex flex-col md:flex-row md:items-center justify-between gap-6 md:gap-4 mt-2">
            {/* Step Nodes */}
            {timelineSteps.map((step, idx) => {
              const stepStatus = getStepStatus(step.key);
              
              // Timeline connector line
              const showLine = idx < timelineSteps.length - 1;
              let lineClass = 'bg-gray-200 dark:bg-dark-800';
              if (stepStatus === 'completed' || stepStatus === 'active') {
                lineClass = 'bg-primary-600';
              }

              // Get actual timestamp for the step if exists in history
              const historyItem = order.status_history?.find(h => h.status === step.key);
              
              return (
                <div key={step.key} className="flex-1 relative flex md:flex-col items-center gap-4 md:gap-2 text-right md:text-center">
                  
                  {/* Connector Line (Desktop only) */}
                  {showLine && (
                    <div className={`hidden md:block absolute top-5 right-1/2 left-0 h-0.5 z-0 ${lineClass}`} />
                  )}

                  {/* Node Circle */}
                  <div className={`w-10 h-10 rounded-full flex items-center justify-center z-15 border-2 transition-all duration-300 ${
                    stepStatus === 'completed' 
                      ? 'bg-primary-600 border-primary-600 text-white'
                      : stepStatus === 'active'
                        ? 'bg-white border-primary-600 text-primary-600 dark:bg-dark-950 dark:border-primary-500 dark:text-primary-400 font-black ring-4 ring-primary-100 dark:ring-primary-950/40'
                        : 'bg-white border-gray-200 text-gray-400 dark:bg-dark-900 dark:border-dark-800'
                  }`}>
                    {stepStatus === 'completed' ? (
                      <Check size={16} strokeWidth={3} />
                    ) : (
                      <span className="text-xs font-bold">{idx + 1}</span>
                    )}
                  </div>

                  {/* Step Metadata */}
                  <div className="space-y-0.5">
                    <p className={`text-sm font-bold ${
                      stepStatus === 'active' ? 'text-primary-600 dark:text-primary-400' : 'text-gray-700 dark:text-dark-200'
                    }`}>
                      {step.label}
                    </p>
                    {historyItem ? (
                      <p className="text-[10px] text-gray-400 font-semibold font-mono">
                        {new Date(historyItem.timestamp).toLocaleTimeString('ar-IQ', { hour: '2-digit', minute: '2-digit' })}
                      </p>
                    ) : (
                      <p className="text-[10px] text-gray-300 dark:text-dark-700 font-medium">غير مكتمل</p>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Two Column Content Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        {/* Left Column: Products List & Payments (Spans 2 cols) */}
        <div className="lg:col-span-2 space-y-6">
          
          {/* Products Table Card */}
          <div className="bg-white dark:bg-dark-900 border border-gray-200 dark:border-dark-800 rounded-2xl shadow-sm overflow-hidden">
            <div className="p-5 border-b border-gray-150 dark:border-dark-850 flex items-center gap-3">
              <ShoppingBag className="text-primary-500" size={20} />
              <h3 className="font-extrabold text-base text-gray-800 dark:text-dark-100">محتويات وعناصر السلة</h3>
            </div>
            
            <div className="overflow-x-auto">
              <table className="w-full border-collapse">
                <thead>
                  <tr className="bg-gray-50/50 dark:bg-dark-950/20 text-gray-500 dark:text-dark-400 text-xs border-b border-gray-150 dark:border-dark-850">
                    <th className="p-4 text-center font-bold w-16">الصورة</th>
                    <th className="p-4 text-right font-bold">اسم المنتج / المواصفات</th>
                    <th className="p-4 text-center font-bold">المقاس / اللون</th>
                    <th className="p-4 text-center font-bold">الكمية</th>
                    <th className="p-4 text-center font-bold">سعر الوحدة</th>
                    <th className="p-4 text-center font-bold">الإجمالي</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100 dark:divide-dark-850 text-sm">
                  {order.items.map((item) => (
                    <tr key={item.id} className="hover:bg-slate-50/30 dark:hover:bg-dark-900/50">
                      <td className="p-4">
                        <div className="w-12 h-12 rounded-xl border border-gray-200 dark:border-dark-800 bg-gray-50 dark:bg-dark-950/30 overflow-hidden flex items-center justify-center p-0.5">
                          {item.product?.image_url ? (
                            <img 
                              src={item.product.image_url} 
                              alt={item.product.name} 
                              className="w-full h-full object-contain"
                            />
                          ) : (
                            <ShoppingBag className="text-gray-300" size={20} />
                          )}
                        </div>
                      </td>
                      <td className="p-4">
                        <div className="space-y-0.5">
                          <p className="font-bold text-gray-800 dark:text-dark-100">{item.product?.name || 'منتج محذوف'}</p>
                          {item.product?.sku && (
                            <p className="text-xs text-gray-400 font-mono">SKU: {item.product.sku}</p>
                          )}
                        </div>
                      </td>
                      <td className="p-4 text-center font-semibold text-gray-600 dark:text-dark-300">
                        {item.selected_size || item.selected_color ? (
                          <div className="space-y-0.5">
                            {item.selected_size && <div>المقاس: <span className="font-bold text-primary-600 dark:text-primary-400">{item.selected_size}</span></div>}
                            {item.selected_color && <div>اللون: <span className="font-bold text-slate-500">{item.selected_color}</span></div>}
                          </div>
                        ) : (
                          <span className="text-gray-300">—</span>
                        )}
                      </td>
                      <td className="p-4 text-center font-bold text-gray-700 dark:text-dark-200">
                        {item.quantity}
                      </td>
                      <td className="p-4 text-center font-semibold text-gray-600 dark:text-dark-300">
                        {Number(item.price).toLocaleString()} د.ع
                      </td>
                      <td className="p-4 text-center font-bold text-primary-600 dark:text-primary-400">
                        {Number(item.price * item.quantity).toLocaleString()} د.ع
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Money Breakdown Summary */}
            <div className="p-6 bg-slate-50/50 dark:bg-dark-900/50 border-t border-gray-150 dark:border-dark-850 flex justify-end">
              <div className="w-full sm:w-80 space-y-3 text-xs sm:text-sm font-semibold text-gray-600 dark:text-dark-300">
                <div className="flex justify-between items-center">
                  <span>المجموع الفرعي:</span>
                  <span className="text-gray-800 dark:text-dark-100 font-bold">{Number(order.subtotal).toLocaleString()} د.ع</span>
                </div>
                
                <div className="flex justify-between items-center">
                  <span>رسوم الشحن والتوصيل:</span>
                  <span className="text-gray-800 dark:text-dark-100 font-bold">{Number(order.delivery_fee).toLocaleString()} د.ع</span>
                </div>

                {order.coupon_discount > 0 && (
                  <div className="flex justify-between items-center text-rose-600 dark:text-rose-400">
                    <span>كود الخصم ({order.coupon_code}):</span>
                    <span className="font-bold">-{Number(order.coupon_discount).toLocaleString()} د.ع</span>
                  </div>
                )}
                
                <div className="h-px bg-gray-200 dark:bg-dark-800 my-2" />

                <div className="flex justify-between items-center text-base font-black">
                  <span className="text-gray-900 dark:text-dark-50">الإجمالي النهائي:</span>
                  <span className="text-primary-600 dark:text-primary-400 font-black">{Number(order.total).toLocaleString()} د.ع</span>
                </div>
              </div>
            </div>
          </div>

          {/* Status History Trail Audit logs */}
          <div className="bg-white dark:bg-dark-900 border border-gray-200 dark:border-dark-800 rounded-2xl shadow-sm overflow-hidden">
            <div className="p-5 border-b border-gray-150 dark:border-dark-850 flex items-center gap-3">
              <Clock className="text-primary-500" size={20} />
              <h3 className="font-extrabold text-base text-gray-800 dark:text-dark-100">سجل عمليات وحالات الطلب</h3>
            </div>
            
            <div className="p-6">
              <div className="relative border-r-2 border-gray-150 dark:border-dark-850 mr-4 pr-6 space-y-6">
                {order.status_history?.map((hist, idx) => (
                  <div key={idx} className="relative">
                    {/* Node Pointer */}
                    <div className="absolute -right-[31px] top-1.5 w-4 h-4 rounded-full bg-indigo-100 text-indigo-600 dark:bg-indigo-950 dark:text-indigo-400 flex items-center justify-center ring-4 ring-white dark:ring-dark-900">
                      <div className="w-1.5 h-1.5 rounded-full bg-indigo-500" />
                    </div>
                    
                    <div className="space-y-1">
                      <div className="flex items-center gap-3">
                        <span className="font-bold text-sm text-gray-800 dark:text-dark-100">
                          تغيير الحالة إلى: <span className="text-indigo-600 dark:text-indigo-400">{statusLabels[hist.status] || hist.status}</span>
                        </span>
                        <span className="text-[10px] text-gray-400 font-mono font-bold bg-gray-50 dark:bg-dark-950 px-2 py-0.5 rounded-md">
                          {formatDateTime(hist.timestamp)}
                        </span>
                      </div>
                      {hist.note && (
                        <p className="text-xs text-gray-500 dark:text-dark-400 bg-slate-50 dark:bg-dark-950/30 p-2.5 rounded-xl border border-gray-150 dark:border-dark-850">
                          {hist.note}
                        </p>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Right Column: Customer Details & Form controls (Spans 1 col) */}
        <div className="space-y-6">
          
          {/* Customer Metadata Card */}
          <div className="bg-white dark:bg-dark-900 border border-gray-200 dark:border-dark-800 rounded-2xl shadow-sm overflow-hidden p-6 space-y-4">
            <h3 className="font-extrabold text-sm text-gray-500 uppercase tracking-wider border-b border-gray-100 dark:border-dark-800 pb-3 flex items-center gap-2">
              <User className="text-primary-500" size={18} />
              بيانات العميل
            </h3>
            
            <div className="space-y-3.5">
              <div>
                <p className="text-xs text-gray-400 font-bold">اسم العميل:</p>
                <p className="font-bold text-gray-800 dark:text-dark-100 text-sm mt-0.5">
                  {order.customer?.name || order.customer_name}
                </p>
              </div>

              <div>
                <p className="text-xs text-gray-400 font-bold">رقم الهاتف:</p>
                <div className="flex items-center justify-between gap-4 mt-1">
                  <span className="font-mono font-bold text-gray-800 dark:text-dark-100 text-sm">
                    {order.customer?.phone || order.customer_phone}
                  </span>
                  
                  <div className="flex gap-2">
                    <a 
                      href={`tel:${order.customer?.phone || order.customer_phone}`}
                      className="p-1.5 bg-slate-100 text-slate-700 hover:bg-slate-200 dark:bg-dark-800 dark:text-dark-200 rounded-lg shadow-sm transition-transform active:scale-95 cursor-pointer"
                      title="اتصال هاتف"
                    >
                      <Phone size={14} />
                    </a>
                    
                    <a 
                      href={`https://wa.me/${order.customer?.phone || order.customer_phone}`}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="p-1.5 bg-emerald-50 text-emerald-600 hover:bg-emerald-100 dark:bg-emerald-950/20 dark:text-emerald-400 rounded-lg shadow-sm transition-transform active:scale-95 cursor-pointer"
                      title="مراسلة واتساب"
                    >
                      <MessageSquare size={14} />
                    </a>
                  </div>
                </div>
              </div>

              <div>
                <p className="text-xs text-gray-400 font-bold">عنوان التوصيل:</p>
                <div className="flex items-start gap-1.5 mt-1 text-sm text-gray-700 dark:text-dark-200 leading-relaxed font-semibold">
                  <MapPin size={16} className="text-rose-500 shrink-0 mt-0.5" />
                  <span>{order.address || 'لا يوجد عنوان مسجل للطلب'}</span>
                </div>
              </div>

              {order.notes && (
                <div className="p-3 bg-amber-50 dark:bg-amber-950/10 border border-amber-200 dark:border-amber-900/30 rounded-xl space-y-1">
                  <p className="text-xs text-amber-800 dark:text-amber-400 font-bold">ملاحظات العميل:</p>
                  <p className="text-xs text-amber-900 dark:text-amber-300 font-semibold leading-relaxed">
                    {order.notes}
                  </p>
                </div>
              )}
            </div>

            {/* Quick Customer Profile stats */}
            {order.customer && (
              <div className="bg-slate-50 dark:bg-dark-950/50 p-4 border border-gray-150 dark:border-dark-850 rounded-xl space-y-2 text-xs font-semibold text-gray-500 dark:text-dark-400">
                <div className="flex justify-between">
                  <span>إجمالي الطلبيات:</span>
                  <span className="font-bold text-gray-800 dark:text-dark-100">{order.customer.total_orders} طلبيات</span>
                </div>
                <div className="flex justify-between">
                  <span>إجمالي الإنفاق:</span>
                  <span className="font-bold text-primary-600 dark:text-primary-400">{Number(order.customer.total_spent).toLocaleString()} د.ع</span>
                </div>
              </div>
            )}
          </div>

          {/* Status Changer Form */}
          <div className="bg-white dark:bg-dark-900 border border-gray-200 dark:border-dark-800 rounded-2xl shadow-sm overflow-hidden p-6 space-y-4">
            <h3 className="font-extrabold text-sm text-gray-500 uppercase tracking-wider border-b border-gray-100 dark:border-dark-800 pb-3 flex items-center gap-2">
              <Bell className="text-primary-500" size={18} />
              تحديث حالة الطلبية
            </h3>
            
            <form onSubmit={handleUpdateStatus} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-gray-500 mb-1.5">الحالة الجديدة:</label>
                <select
                  value={status}
                  onChange={(e) => setStatus(e.target.value)}
                  className="w-full p-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent text-sm dark:text-dark-100 focus:border-primary-500 focus:outline-none font-bold"
                >
                  <option value="new">جديد (New)</option>
                  <option value="pending">معلق (Pending)</option>
                  <option value="confirmed">مؤكد (Confirmed)</option>
                  <option value="processing">جاري التحضير (Processing)</option>
                  <option value="shipped">تم الشحن (Shipped)</option>
                  <option value="on_the_way">في الطريق (On the Way)</option>
                  <option value="delivered">تم التسليم (Delivered)</option>
                  <option value="completed">مكتمل (Completed)</option>
                  <option value="cancelled">ملغي (Cancelled)</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-bold text-gray-500 mb-1.5">ملاحظة التحديث:</label>
                <textarea
                  value={note}
                  onChange={(e) => setNote(e.target.value)}
                  placeholder="أدخل أي ملاحظات حول التحديث الحالي للطلب..."
                  rows={3}
                  className="w-full p-3 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent text-xs dark:text-dark-100 focus:border-primary-500 focus:outline-none"
                />
              </div>

              <div className="flex items-center gap-2">
                <input 
                  type="checkbox"
                  id="sendNotification"
                  checked={sendNotification}
                  onChange={(e) => setSendNotification(e.target.checked)}
                  className="w-4.5 h-4.5 accent-primary-600 rounded cursor-pointer"
                />
                <label htmlFor="sendNotification" className="text-xs text-gray-600 dark:text-dark-300 font-bold select-none cursor-pointer">
                  إرسال إشعار فوري وتنبيه للعميل
                </label>
              </div>

              <button
                type="submit"
                disabled={savingStatus}
                className="w-full py-2.5 rounded-xl bg-primary-600 hover:bg-primary-700 disabled:bg-primary-400 text-white font-bold text-sm shadow-md active:scale-98 transition-all flex items-center justify-center gap-2 cursor-pointer"
              >
                <Save size={16} />
                {savingStatus ? 'جاري التحديث...' : 'تحديث حالة الطلب'}
              </button>
            </form>
          </div>
        </div>
      </div>

      {/* Toast message popups */}
      <Toast 
        message={toastMessage} 
        type={toastType} 
        onClose={() => setToastMessage('')} 
      />
    </div>
  );
}
