import React from 'react';
import { Info, HelpCircle } from 'lucide-react';

export default function ImageSpecsTable() {
  const specs = [
    { section: 'صورة المنتج الرئيسية', dimensions: '800 × 800', ratio: '1:1 (مربعة)', size: '2MB', formats: 'JPG, PNG, WebP' },
    { section: 'معرض صور المنتج', dimensions: '1200 × 1200', ratio: '1:1 (مربعة)', size: '2MB', formats: 'JPG, PNG, WebP' },
    { section: 'بنر الموبايل', dimensions: '1080 × 480', ratio: '9:4', size: '3MB', formats: 'JPG, PNG, WebP' },
    { section: 'بنر الويب', dimensions: '1920 × 600', ratio: '16:5', size: '4MB', formats: 'JPG, PNG, WebP' },
    { section: 'أيقونة القسم الرئيسي', dimensions: '200 × 200', ratio: '1:1 (مربعة)', size: '1MB', formats: 'JPG, PNG, SVG' },
    { section: 'صورة غلاف القسم', dimensions: '800 × 400', ratio: '2:1', size: '2MB', formats: 'JPG, PNG, WebP' },
    { section: 'أيقونة القسم الفرعي', dimensions: '200 × 200', ratio: '1:1 (مربعة)', size: '1MB', formats: 'JPG, PNG, SVG' },
    { section: 'شعار التطبيق', dimensions: '500 × 500', ratio: '1:1 (مربعة)', size: '1MB', formats: 'PNG, SVG, WebP' },
    { section: 'صورة Splash للتطبيق', dimensions: '1080 × 1920', ratio: '9:16', size: '3MB', formats: 'JPG, PNG, WebP' },
    { section: 'صورة الحساب الشخصي', dimensions: '400 × 400', ratio: '1:1 (مربعة)', size: '1MB', formats: 'JPG, PNG, WebP' },
  ];

  return (
    <div className="w-full bg-white border border-slate-200 rounded-2xl overflow-hidden shadow-sm text-right" dir="rtl">
      <div className="p-4 bg-slate-50 border-b border-slate-100 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Info className="w-5 h-5 text-indigo-500" />
          <h3 className="font-bold text-slate-800 text-sm sm:text-base">الجدول المرجعي لقياسات الصور المقبولة</h3>
        </div>
        <span className="text-xs text-slate-400 font-semibold">موصى بها لأفضل أداء للموقع والتطبيق</span>
      </div>
      
      <div className="overflow-x-auto">
        <table className="w-full border-collapse text-xs sm:text-sm">
          <thead>
            <tr className="bg-slate-100/50 text-slate-600 border-b border-slate-100">
              <th className="p-3 text-right font-bold">القسم</th>
              <th className="p-3 text-right font-bold">الأبعاد (عرض × ارتفاع)</th>
              <th className="p-3 text-right font-bold">نسبة الارتفاع</th>
              <th className="p-3 text-right font-bold">الحجم الأقصى</th>
              <th className="p-3 text-right font-bold">الصيغ المدعومة</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-slate-700">
            {specs.map((item, idx) => (
              <tr 
                key={idx} 
                className="hover:bg-slate-50/50 transition-colors duration-150"
              >
                <td className="p-3 font-bold text-slate-900">{item.section}</td>
                <td className="p-3 font-semibold text-slate-600">{item.dimensions} بكسل</td>
                <td className="p-3">
                  <span className="px-2 py-0.5 bg-indigo-50 text-indigo-700 rounded-md font-bold text-xs">
                    {item.ratio}
                  </span>
                </td>
                <td className="p-3 font-semibold text-amber-600">{item.size}</td>
                <td className="p-3 font-mono text-slate-500 text-xs">{item.formats}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      
      <div className="p-3 bg-amber-50/50 border-t border-slate-100 text-amber-800 text-xs flex items-center gap-2">
        <HelpCircle className="w-4 h-4 shrink-0 text-amber-600" />
        <span><b>ملاحظة:</b> يقوم نظام الرفع الموحد بضغط وتغيير حجم الصور تلقائياً إلى هذه الأبعاد الموصى بها قبل رفعها لتوفير مساحة التخزين وسرعة تحميل التطبيق.</span>
      </div>
    </div>
  );
}
