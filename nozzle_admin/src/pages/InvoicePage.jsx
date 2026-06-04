import React, { useState, useEffect } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { Printer, ArrowRight, MessageSquare, Download, AlertCircle } from 'lucide-react';
import api from '../services/api';
import { generateInvoicePDF } from '../services/invoicePdf.service';

export default function InvoicePage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchOrder = async () => {
    setLoading(true);
    try {
      const response = await api.get(`/v1/orders/${id}/detail`);
      if (response.data && response.data.success) {
        setOrder(response.data.data);
      }
    } catch (error) {
      console.error('Failed to load order for invoice:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrder();
  }, [id]);

  const handlePrint = () => {
    window.print();
  };

  // Helper: format dates
  const formatDateTime = (dateStr) => {
    if (!dateStr) return '';
    try {
      const d = new Date(dateStr);
      return d.toLocaleDateString('ar-IQ', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      });
    } catch (e) {
      return dateStr;
    }
  };

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen bg-white space-y-4">
        <div className="w-12 h-12 border-4 border-indigo-600 border-t-transparent rounded-full animate-spin"></div>
        <p className="text-gray-500 text-sm font-bold">جاري تجهيز الفاتورة للطباعة...</p>
      </div>
    );
  }

  if (!order) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen bg-slate-50 space-y-4 text-right p-6" dir="rtl">
        <AlertCircle className="w-12 h-12 text-rose-500" />
        <h3 className="font-bold text-lg text-gray-800">عذرًا، لم يتم العثور على تفاصيل الفاتورة</h3>
        <button
          onClick={() => navigate('/orders')}
          className="px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-sm font-bold"
        >
          العودة للطلبات
        </button>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-100 dark:bg-dark-950 py-8 px-4 flex justify-center text-right font-cairo" dir="rtl">
      
      {/* Printable styles */}
      <style>{`
        @media print {
          body {
            background-color: white !important;
            color: black !important;
          }
          .no-print {
            display: none !important;
          }
          .print-area {
            box-shadow: none !important;
            border: none !important;
            padding: 0 !important;
            margin: 0 !important;
            width: 100% !important;
            max-width: 100% !important;
          }
          /* Keep image backgrounds visible when printing in browsers */
          * {
            -webkit-print-color-adjust: exact !important;
            print-color-adjust: exact !important;
          }
        }
      `}</style>

      {/* Floating Action Controls - Hidden in print */}
      <div className="no-print fixed bottom-6 left-1/2 -translate-x-1/2 bg-white/90 dark:bg-dark-900/90 backdrop-blur-md shadow-2xl border border-slate-200 dark:border-dark-800 px-6 py-3.5 rounded-2xl flex items-center gap-4 z-50">
        <button
          onClick={() => navigate(`/orders/${id}`)}
          className="flex items-center gap-2 px-4 py-2 border border-slate-200 dark:border-dark-800 rounded-xl hover:bg-slate-50 dark:hover:bg-dark-800 text-slate-700 dark:text-dark-200 font-bold text-xs sm:text-sm cursor-pointer"
        >
          <ArrowRight size={16} />
          <span>تفاصيل الطلب</span>
        </button>

        <button
          onClick={handlePrint}
          className="flex items-center gap-2 px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl font-bold text-xs sm:text-sm shadow-md active:scale-95 cursor-pointer"
        >
          <Printer size={16} />
          <span>طباعة الفاتورة</span>
        </button>

        <button
          onClick={() => generateInvoicePDF(order)}
          className="flex items-center gap-2 px-4 py-2 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 dark:bg-indigo-950/20 dark:text-indigo-400 rounded-xl font-bold text-xs sm:text-sm border border-indigo-100 dark:border-indigo-900/30 cursor-pointer"
        >
          <Download size={16} />
          <span>تنزيل PDF</span>
        </button>
      </div>

      {/* Printable Invoice Sheet Container */}
      <div className="print-area w-full max-w-3xl bg-white dark:bg-dark-900 p-8 sm:p-12 rounded-2xl border border-slate-200 dark:border-dark-800 shadow-sm space-y-8">
        
        {/* Store Brand / Header Row */}
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-6 border-b border-slate-100 dark:border-dark-850 pb-6">
          <div className="space-y-1">
            <h1 className="text-2xl font-black text-indigo-600 dark:text-indigo-400">متجر نوزل</h1>
            <p className="text-xs text-gray-400 font-semibold leading-relaxed">
              بغداد، الكرادة، شارع المسبح<br />
              هاتف: 07801234567 | support@nozzle.iq
            </p>
          </div>
          
          <div className="text-left sm:text-left self-stretch sm:self-auto space-y-1">
            <div className="bg-indigo-50 dark:bg-indigo-950/20 px-4 py-1.5 rounded-lg inline-block border border-indigo-100 dark:border-indigo-900/30">
              <h2 className="text-indigo-700 dark:text-indigo-400 font-black text-sm uppercase tracking-wider">فاتورة ضريبية مبسطة</h2>
            </div>
            <p className="text-xs text-gray-400 font-mono font-bold pt-1">
              الرقم الضريبي للمتجر: 300456128
            </p>
          </div>
        </div>

        {/* Invoice details & Customer info grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 bg-slate-50 dark:bg-dark-950/20 p-6 rounded-xl border border-slate-100 dark:border-dark-850 text-xs sm:text-sm">
          
          {/* Column 1: Invoice metadata */}
          <div className="space-y-2">
            <h3 className="font-extrabold text-gray-800 dark:text-dark-100 text-xs uppercase tracking-wide text-indigo-600 dark:text-indigo-400">بيانات الفاتورة</h3>
            <div className="space-y-1 text-gray-600 dark:text-dark-300">
              <div className="flex justify-between">
                <span>رقم الفاتورة:</span>
                <span className="font-mono font-bold text-gray-800 dark:text-dark-100">{order.invoice_number}</span>
              </div>
              <div className="flex justify-between">
                <span>رقم الطلب الأصلي:</span>
                <span className="font-mono font-bold text-gray-850 dark:text-dark-150">#{order.id}</span>
              </div>
              <div className="flex justify-between">
                <span>تاريخ الإصدار:</span>
                <span className="font-bold text-gray-800 dark:text-dark-100">{formatDateTime(order.created_at)}</span>
              </div>
              <div className="flex justify-between">
                <span>طريقة الدفع:</span>
                <span className="font-bold text-gray-800 dark:text-dark-100">
                  {order.payment_method === 'cash' ? 'كاش (عند الاستلام)' : 'دفع إلكتروني'}
                </span>
              </div>
            </div>
          </div>

          {/* Column 2: Customer data */}
          <div className="space-y-2">
            <h3 className="font-extrabold text-gray-800 dark:text-dark-100 text-xs uppercase tracking-wide text-indigo-600 dark:text-indigo-400">بيانات العميل</h3>
            <div className="space-y-1 text-gray-600 dark:text-dark-300">
              <div>الاسم: <span className="font-bold text-gray-800 dark:text-dark-100">{order.customer?.name || order.customer_name}</span></div>
              <div>الهاتف: <span className="font-mono font-bold text-gray-800 dark:text-dark-100">{order.customer?.phone || order.customer_phone}</span></div>
              <div className="leading-relaxed">العنوان: <span className="font-semibold text-gray-800 dark:text-dark-100">{order.address}</span></div>
              {order.notes && <div className="text-rose-600 dark:text-rose-400 font-semibold">ملاحظات: {order.notes}</div>}
            </div>
          </div>
        </div>

        {/* Invoice Itemized Products table */}
        <div className="border border-slate-100 dark:border-dark-850 rounded-xl overflow-hidden">
          <table className="w-full border-collapse text-xs sm:text-sm">
            <thead>
              <tr className="bg-slate-50 dark:bg-dark-950/20 text-gray-600 dark:text-dark-400 border-b border-slate-100 dark:border-dark-850">
                <th className="p-3 text-center w-12">الصورة</th>
                <th className="p-3 text-right">المنتج</th>
                <th className="p-3 text-center">المقاس / اللون</th>
                <th className="p-3 text-center w-12">الكمية</th>
                <th className="p-3 text-center">سعر الوحدة</th>
                <th className="p-3 text-center">الإجمالي</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 dark:divide-dark-850 text-gray-700 dark:text-dark-200">
              {order.items.map((item) => (
                <tr key={item.id}>
                  <td className="p-3">
                    <div className="w-10 h-10 border border-slate-100 dark:border-dark-800 bg-slate-50 dark:bg-dark-950 rounded-lg overflow-hidden flex items-center justify-center p-0.5 mx-auto">
                      {item.product?.image_url ? (
                        <img 
                          src={item.product.image_url} 
                          alt={item.product.name} 
                          className="w-full h-full object-contain"
                        />
                      ) : (
                        <div className="w-4 h-4 bg-slate-200 rounded" />
                      )}
                    </div>
                  </td>
                  <td className="p-3">
                    <div className="font-bold text-gray-800 dark:text-dark-100">{item.product?.name || 'منتج غير متوفر'}</div>
                    {item.product?.sku && <div className="text-[10px] text-gray-400 font-mono">SKU: {item.product.sku}</div>}
                  </td>
                  <td className="p-3 text-center font-semibold text-gray-500 dark:text-dark-400">
                    {item.selected_size || item.selected_color ? (
                      <div>
                        {item.selected_size && <span className="ml-2">المقاس: {item.selected_size}</span>}
                        {item.selected_color && <span>اللون: {item.selected_color}</span>}
                      </div>
                    ) : (
                      <span>—</span>
                    )}
                  </td>
                  <td className="p-3 text-center font-bold">{item.quantity}</td>
                  <td className="p-3 text-center font-semibold">{Number(item.price).toLocaleString()} د.ع</td>
                  <td className="p-3 text-center font-bold text-indigo-600 dark:text-indigo-400">
                    {Number(item.price * item.quantity).toLocaleString()} د.ع
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Bottom Pricing Invoice Summary breakdown */}
        <div className="flex justify-end pt-4">
          <div className="w-full sm:w-72 space-y-2.5 text-xs sm:text-sm font-semibold text-gray-500 dark:text-dark-400">
            <div className="flex justify-between items-center">
              <span>المجموع الفرعي:</span>
              <span className="text-gray-800 dark:text-dark-100 font-bold">{Number(order.subtotal).toLocaleString()} د.ع</span>
            </div>
            
            <div className="flex justify-between items-center">
              <span>رسوم التوصيل:</span>
              <span className="text-gray-800 dark:text-dark-100 font-bold">{Number(order.delivery_fee).toLocaleString()} د.ع</span>
            </div>

            {order.coupon_discount > 0 && (
              <div className="flex justify-between items-center text-rose-600 dark:text-rose-450">
                <span>خصم الكوبون ({order.coupon_code}):</span>
                <span className="font-bold">-{Number(order.coupon_discount).toLocaleString()} د.ع</span>
              </div>
            )}
            
            <div className="h-px bg-slate-100 dark:bg-dark-800 my-2" />

            <div className="flex justify-between items-center text-base font-black text-indigo-600 dark:text-indigo-400">
              <span>الإجمالي النهائي:</span>
              <span className="font-black text-lg">{Number(order.total).toLocaleString()} د.ع</span>
            </div>
          </div>
        </div>

        {/* Print Footer terms & message */}
        <div className="border-t border-slate-100 dark:border-dark-850 pt-6 text-center space-y-2 text-[10px] sm:text-xs text-gray-400 font-semibold">
          <p>جميع الأسعار معلنة بالدينار العراقي (IQD) وشاملة للضريبة المطبقة</p>
          <p className="text-indigo-600 dark:text-indigo-400 font-bold text-sm">شكرًا لتعاملكم معنا ونسعد بخدمتكم دائماً ❤️</p>
        </div>
      </div>
    </div>
  );
}
