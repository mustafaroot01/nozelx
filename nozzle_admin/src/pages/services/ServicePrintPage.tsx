import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Printer, Download, ChevronRight } from 'lucide-react';
import api from '../../services/api';

export default function ServicePrintPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [printData, setPrintData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchPrintData = async () => {
      try {
        setLoading(true);
        const res = await api.get(`/v1/admin/service-requests/${id}/print-data`);
        setPrintData(res.data.data);
        setError(null);
      } catch (err) {
        console.error(err);
        setError('فشل تحميل بيانات الطباعة.');
      } finally {
        setLoading(false);
      }
    };
    fetchPrintData();
  }, [id]);

  const handlePrint = () => {
    window.print();
  };

  const handlePDF = async () => {
    if (!printData) return;
    const el = document.getElementById('print-area');
    if (!el) return;
    
    // Call html2pdf bundle dynamically
    try {
      window.html2pdf().set({
        margin: 15,
        filename: `NZL-REQUEST-${printData.request_number}.pdf`,
        image: { type: 'jpeg', quality: 0.98 },
        html2canvas: { scale: 2, useCORS: true },
        jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
      }).from(el).save();
    } catch (err) {
      console.error('html2pdf generation failed:', err);
      alert('حدث خطأ أثناء تحميل ملف الـ PDF. جرب استخدام زر الطباعة وحفظ كـ PDF.');
    }
  };

  const formatPrice = (price) => {
    return new Intl.NumberFormat('ar-IQ', { style: 'currency', currency: 'IQD', maximumFractionDigits: 0 }).format(price);
  };

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center h-screen gap-3">
        <div className="w-10 h-10 border-4 border-primary-600 border-t-transparent rounded-full animate-spin"></div>
        <p className="text-sm text-gray-500">جاري تجهيز ورقة الطباعة...</p>
      </div>
    );
  }

  if (error || !printData) {
    return (
      <div className="p-8 text-center bg-red-50 border border-red-200 text-red-700 rounded-xl space-y-4 m-10">
        <p className="font-bold text-lg">{error || 'لم نتمكن من العثور على بيانات الطباعة.'}</p>
        <button onClick={() => navigate(`/services/requests/${id}`)} className="px-4 py-2 bg-red-600 text-white rounded-lg text-sm">
          العودة لتفاصيل الطلب
        </button>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-100 p-6 flex flex-col items-center justify-start gap-6 text-right" dir="rtl">
      
      {/* Styling injection for printing */}
      <style dangerouslySetInnerHTML={{__html: `
        @media print {
          body * {
            visibility: hidden;
          }
          #print-area, #print-area * {
            visibility: visible;
          }
          #print-area {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            width: 100% !important;
            padding: 0 !important;
            margin: 0 !important;
            font-family: 'Cairo', sans-serif !important;
            direction: rtl !important;
            background-color: white !important;
            color: black !important;
          }
          .no-print {
            display: none !important;
          }
          @page {
            margin: 15mm;
            size: A4;
          }
        }
      `}} />

      {/* Action buttons panel (Hidden in print) */}
      <div className="w-full max-w-4xl bg-white p-4 rounded-xl border border-gray-250 flex justify-between items-center shadow-sm no-print">
        <div className="flex items-center gap-2">
          <button
            onClick={() => navigate(`/services/requests/${id}`)}
            className="p-1 hover:bg-gray-100 rounded-full text-gray-400"
          >
            <ChevronRight className="w-6 h-6" />
          </button>
          <span className="font-bold text-gray-800 text-sm">معاينة وإجراءات طباعة الطلب</span>
        </div>

        <div className="flex items-center gap-3">
          <button
            onClick={handlePDF}
            className="flex items-center gap-1.5 px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg text-xs font-semibold shadow-sm transition-colors"
          >
            <Download className="w-4 h-4" />
            <span>تحميل نسخة PDF</span>
          </button>
          <button
            onClick={handlePrint}
            className="flex items-center gap-1.5 px-4 py-2 bg-primary-600 hover:bg-primary-700 text-white rounded-lg text-xs font-semibold shadow-sm transition-colors"
          >
            <Printer className="w-4 h-4" />
            <span>طباعة مباشرة</span>
          </button>
        </div>
      </div>

      {/* Main Print Layout (A4 formatted container) */}
      <div 
        id="print-area" 
        className="w-full max-w-4xl bg-white p-6 md:p-8 rounded-2xl border border-gray-250 shadow-sm flex flex-col justify-between text-black text-sm leading-relaxed"
        style={{ minHeight: 'auto' }}
      >
        <div className="space-y-4">
          
          {/* Header */}
          <div className="flex justify-between items-start border-b-2 border-gray-200 pb-4">
            <div className="flex items-start gap-4 text-right">
              {printData.settings?.invoice_logo && (
                <img 
                  src={printData.settings.invoice_logo.startsWith('http') ? printData.settings.invoice_logo : `${api.defaults.baseURL.replace('/api', '')}${printData.settings.invoice_logo}`} 
                  alt="Store Logo" 
                  className="w-16 h-16 rounded-xl object-contain border border-gray-150 p-1 bg-white shrink-0"
                  onError={(e) => { e.target.style.display = 'none'; }}
                />
              )}
              <div className="space-y-0.5">
                <h2 className="text-xl font-extrabold text-blue-700">
                  {printData.settings?.store_name?.ar || 'نوزل لخدمات السيارات'}
                </h2>
                <p className="text-xs text-gray-500">
                  العنوان: {printData.settings?.store_address?.ar || 'العراق، بغداد'}
                </p>
                <p className="text-xs text-gray-500">
                  الهاتف: {printData.settings?.store_phone || '+9647700000000'} | البريد: {printData.settings?.store_email || 'support@nozzle.com'}
                </p>
              </div>
            </div>
            <div className="text-left space-y-0.5">
              <h3 className="text-lg font-bold text-gray-800">وصل حجز خدمة</h3>
              <p className="text-xs font-semibold">رقم الطلب: <b className="text-blue-700">{printData.request_number}</b></p>
              <p className="text-[10px] text-gray-400">تاريخ الوصل: {printData.created_at}</p>
              <p className="text-xs font-semibold">
                الحالة: {
                  printData.status === 'new' ? 'جديد قيد الانتظار' :
                  printData.status === 'confirmed' ? 'تم التأكيد ✅' :
                  printData.status === 'in_progress' ? 'قيد التنفيذ ⚙️' :
                  printData.status === 'completed' ? 'مكتمل ومغلق 🟢' : 'ملغي 🔴'
                }
              </p>
            </div>
          </div>

          {/* Section 1: Customer Details */}
          <div className="space-y-1.5">
            <h4 className="text-xs font-extrabold text-gray-900 border-r-4 border-blue-600 pr-2">بيانات العميل المستلم</h4>
            <div className="grid grid-cols-2 gap-y-1.5 border border-gray-150 p-3 rounded-lg bg-gray-50/50 text-xs">
              <div>
                <span className="text-[10px] text-gray-450 block">اسم الزبون الكامل</span>
                <span className="font-bold text-gray-800">{printData.customer_name}</span>
              </div>
              <div>
                <span className="text-[10px] text-gray-450 block">رقم هاتف الاتصال</span>
                <span className="font-bold text-gray-800">{printData.customer_phone}</span>
              </div>
              <div className="col-span-2">
                <span className="text-[10px] text-gray-450 block">العنوان والتفاصيل الجغرافية</span>
                <span className="font-bold text-gray-800">{printData.address}</span>
              </div>
            </div>
          </div>

          {/* Section 2: Service & Schedule Details */}
          <div className="space-y-1.5">
            <h4 className="text-xs font-extrabold text-gray-900 border-r-4 border-blue-600 pr-2">تفاصيل الخدمة وجدولة الموعد</h4>
            <div className="grid grid-cols-2 gap-y-2 border border-gray-150 p-3 rounded-lg text-xs">
              <div>
                <span className="text-[10px] text-gray-450 block">الخدمة الأساسية</span>
                <span className="font-bold text-gray-800">{printData.service_name}</span>
              </div>
              <div>
                <span className="text-[10px] text-gray-450 block">الموعد المحدد للحضور</span>
                <span className="font-bold text-gray-800">{printData.scheduled_date} | الساعة {printData.scheduled_time}</span>
              </div>
              <div>
                <span className="text-[10px] text-gray-450 block">الباقة / الخيار الإضافي</span>
                <span className="font-bold text-gray-800">{printData.option_name || 'بدون إضافات'}</span>
              </div>
              <div>
                <span className="text-[10px] text-gray-450 block">المدة المتوقعة للتنفيذ</span>
                <span className="font-bold text-gray-800">{printData.duration_minutes} دقيقة</span>
              </div>
              {printData.assigned_worker && (
                <div className="col-span-2">
                  <span className="text-[10px] text-gray-450 block">المسؤول المعين للتنفيذ</span>
                  <span className="font-bold text-gray-800">
                    {printData.assigned_worker} {printData.worker_phone && `(${printData.worker_phone})`}
                  </span>
                </div>
              )}
            </div>
          </div>

          {/* Section 3: Pricing Summary */}
          <div className="space-y-1.5">
            <h4 className="text-xs font-extrabold text-gray-900 border-r-4 border-blue-600 pr-2">كشف الحساب وتفاصيل الدفع</h4>
            <div className="border border-gray-150 rounded-lg overflow-hidden">
              <table className="w-full text-right text-xs">
                <thead className="bg-gray-50 border-b border-gray-150 text-gray-700 font-bold">
                  <tr>
                    <th className="p-2">تفاصيل البند</th>
                    <th className="p-2 text-left">القيمة المالية</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-150">
                  <tr>
                    <td className="p-2">سعر الخدمة الأساسية ({printData.service_name})</td>
                    <td className="p-2 text-left font-semibold">{formatPrice(printData.base_price)}</td>
                  </tr>
                  {printData.option_name && (
                    <tr>
                      <td className="p-2">سعر الخيار الإضافي ({printData.option_name})</td>
                      <td className="p-2 text-left font-semibold">+ {formatPrice(printData.option_price)}</td>
                    </tr>
                  )}
                  <tr className="bg-blue-50/50 font-bold text-xs">
                    <td className="p-2 text-blue-800">الإجمالي المستحق للدفع</td>
                    <td className="p-2 text-left text-blue-800 font-extrabold">{formatPrice(printData.total_price)}</td>
                  </tr>
                  <tr>
                    <td className="p-2">طريقة الدفع المقررة</td>
                    <td className="p-2 text-left font-semibold">
                      {printData.payment_method === 'cash' ? 'نقد عند الاستلام (كاش)' : printData.payment_method}
                    </td>
                  </tr>
                  <tr>
                    <td className="p-2">حالة الدفع الحالية</td>
                    <td className={`p-2 text-left font-bold ${printData.payment_status === 'paid' ? 'text-green-600' : 'text-red-500'}`}>
                      {printData.payment_status === 'paid' ? 'تم الدفع بالكامل' : 'معلق لم يتم الدفع'}
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          {/* Customer notes */}
          {printData.notes && (
            <div className="space-y-1">
              <span className="text-[10px] text-gray-400 block font-bold">ملاحظات العميل:</span>
              <p className="p-2.5 border border-gray-200 rounded-lg text-xs italic bg-gray-50/50">
                "{printData.notes}"
              </p>
            </div>
          )}

        </div>

        {/* Signature Fields (Strictly bottom-aligned) */}
        <div className="border-t border-gray-200 pt-4 flex justify-between items-center text-xs mt-6">
          <div className="space-y-3 w-1/3 text-center">
            <p className="font-bold text-gray-600">توقيع وموافقة العميل</p>
            <p className="text-[10px] text-gray-400">التاريخ: ____ / ____ / ________</p>
            <div className="h-8 border-b border-dashed border-gray-300 w-full"></div>
          </div>
          
          <div className="space-y-3 w-1/3 text-center">
            <p className="font-bold text-gray-600">توقيع الفني المنفذ</p>
            <p className="text-[10px] text-gray-400">التاريخ: ____ / ____ / ________</p>
            <div className="h-8 border-b border-dashed border-gray-300 w-full"></div>
          </div>
        </div>

      </div>

    </div>
  );
}
