import React, { useState, useEffect } from 'react';
import api from '../services/api';
import ImageUploader from '../components/ui/ImageUploader';
import { 
  Settings as SettingsIcon, 
  Store, 
  Percent, 
  Truck, 
  CreditCard, 
  Save, 
  Mail, 
  Phone,
  CheckCircle,
  AlertCircle,
  Globe,
  Image as ImageIcon,
  MessageSquare,
  Key,
  Eye,
  EyeOff
} from 'lucide-react';

export default function Settings() {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [successMessage, setSuccessMessage] = useState('');
  const [errorMessage, setErrorMessage] = useState('');

  // Setting States
  const [storeNameAr, setStoreNameAr] = useState('');
  const [storeNameEn, setStoreNameEn] = useState('');
  const [storeEmail, setStoreEmail] = useState('');
  const [storePhone, setStorePhone] = useState('');
  const [storeAddressAr, setStoreAddressAr] = useState('');
  const [storeAddressEn, setStoreAddressEn] = useState('');
  
  const [taxRate, setTaxRate] = useState(15.0);
  const [shippingFee, setShippingFee] = useState(15.0);
  const [freeShippingThreshold, setFreeShippingThreshold] = useState(150.0);
  
  const [codEnabled, setCodEnabled] = useState(true);
  const [cardEnabled, setCardEnabled] = useState(true);
  const [appLogo, setAppLogo] = useState('');
  const [appSplash, setAppSplash] = useState('');
  const [invoiceLogo, setInvoiceLogo] = useState('');

  // OTP Settings
  const [otpApiKey, setOtpApiKey] = useState('');
  const [otpSenderName, setOtpSenderName] = useState('');
  const [otpProvider, setOtpProvider] = useState('taqnyat');
  const [showOtpKey, setShowOtpKey] = useState(false);

  // Active tab state
  const [activeTab, setActiveTab] = useState('general'); // general, financial, payments, identity

  useEffect(() => {
    fetchSettings();
  }, []);

  const fetchSettings = async () => {
    try {
      setLoading(true);
      const res = await api.get('/settings');
      const data = res.data;
      
      if (data) {
        if (data.store_name) {
          setStoreNameAr(data.store_name.ar || '');
          setStoreNameEn(data.store_name.en || '');
        }
        setStoreEmail(data.store_email || '');
        setStorePhone(data.store_phone || '');
        
        if (data.store_address) {
          setStoreAddressAr(data.store_address.ar || '');
          setStoreAddressEn(data.store_address.en || '');
        } else {
          setStoreAddressAr('');
          setStoreAddressEn('');
        }
        
        setTaxRate(data.tax_rate !== undefined ? data.tax_rate : 15.0);
        setShippingFee(data.shipping_fee !== undefined ? data.shipping_fee : 15.0);
        setFreeShippingThreshold(data.free_shipping_threshold !== undefined ? data.free_shipping_threshold : 150.0);
        
        setCodEnabled(data.cod_enabled !== undefined ? data.cod_enabled : true);
        setCardEnabled(data.card_enabled !== undefined ? data.card_enabled : true);
        
        setAppLogo(data.app_logo || '');
        setAppSplash(data.app_splash || '');
        setInvoiceLogo(data.invoice_logo || '');

        setOtpApiKey(data.otp_api_key || '');
        setOtpSenderName(data.otp_sender_name || '');
        setOtpProvider(data.otp_provider || 'taqnyat');
      }
    } catch (err) {
      console.error('Error loading settings:', err);
      setErrorMessage('حدث خطأ أثناء تحميل الإعدادات من الخادم.');
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async (e) => {
    e.preventDefault();
    setSaving(true);
    setSuccessMessage('');
    setErrorMessage('');

    const payload = {
      store_name: {
        ar: storeNameAr,
        en: storeNameEn
      },
      store_email: storeEmail,
      store_phone: storePhone,
      store_address: {
        ar: storeAddressAr,
        en: storeAddressEn
      },
      tax_rate: parseFloat(taxRate),
      shipping_fee: parseFloat(shippingFee),
      free_shipping_threshold: parseFloat(freeShippingThreshold),
      cod_enabled: codEnabled,
      card_enabled: cardEnabled,
      app_logo: appLogo,
      app_splash: appSplash,
      invoice_logo: invoiceLogo,
      otp_api_key: otpApiKey,
      otp_sender_name: otpSenderName,
      otp_provider: otpProvider
    };

    try {
      await api.post('/settings', payload);
      setSuccessMessage('تم حفظ الإعدادات بنجاح في النظام!');
      setTimeout(() => setSuccessMessage(''), 3000);
    } catch (err) {
      console.error('Error saving settings:', err);
      setErrorMessage('فشل في حفظ التعديلات، يرجى المحاولة لاحقاً.');
    } finally {
      setSaving(false);
    }
  };

  const tabs = [
    { id: 'general', name: 'بيانات المتجر العامة', icon: Store },
    { id: 'financial', name: 'الضرائب والشحن', icon: Truck },
    { id: 'payments', name: 'بوابات الدفع', icon: CreditCard },
    { id: 'identity', name: 'الهوية والشعار', icon: ImageIcon },
    { id: 'otp', name: 'إعدادات OTP / SMS', icon: MessageSquare },
  ];

  return (
    <div className="space-y-6">
      {/* Page Title */}
      <div>
        <h1 className="text-2xl font-black text-gray-800 dark:text-dark-50">إعدادات النظام</h1>
        <p className="text-sm text-gray-400 mt-1">تعديل الملف التعريفي للمتجر، والضرائب وعتبة الشحن المجاني وخيارات الدفع الفعالة.</p>
      </div>

      {loading ? (
        <div className="bg-white dark:bg-dark-900 rounded-2xl border border-gray-200 dark:border-dark-800 shadow-sm p-8 space-y-6">
          <div className="h-6 bg-gray-150 dark:bg-dark-800 rounded animate-pulse w-1/4"></div>
          <div className="grid grid-cols-2 gap-6">
            <div className="h-10 bg-gray-100 dark:bg-dark-800 rounded animate-pulse w-full"></div>
            <div className="h-10 bg-gray-100 dark:bg-dark-800 rounded animate-pulse w-full"></div>
            <div className="h-10 bg-gray-100 dark:bg-dark-800 rounded animate-pulse w-full"></div>
            <div className="h-10 bg-gray-100 dark:bg-dark-800 rounded animate-pulse w-full"></div>
          </div>
        </div>
      ) : (
        <div className="flex flex-col md:flex-row gap-6 items-start">
          {/* Tabs Navigation (Sidebar style) */}
          <div className="w-full md:w-64 bg-white dark:bg-dark-900 rounded-2xl border border-gray-200 dark:border-dark-800 p-4 space-y-1 shadow-sm flex-shrink-0">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl font-bold text-sm transition-colors text-right cursor-pointer ${
                  activeTab === tab.id
                    ? 'bg-primary-50 text-primary-600 dark:bg-primary-950/30 dark:text-primary-400'
                    : 'text-gray-600 dark:text-dark-400 hover:bg-gray-50 dark:hover:bg-dark-800/50 hover:text-gray-900 dark:hover:text-dark-100'
                }`}
              >
                <tab.icon size={18} />
                <span>{tab.name}</span>
              </button>
            ))}
          </div>

          {/* Settings Form Content */}
          <div className="flex-1 w-full bg-white dark:bg-dark-900 rounded-2xl border border-gray-200 dark:border-dark-800 shadow-sm overflow-hidden">
            <form onSubmit={handleSave} className="p-6 space-y-6">
              {successMessage && (
                <div className="bg-emerald-50 text-emerald-600 border border-emerald-200 p-4 rounded-xl text-sm font-bold flex items-center gap-2">
                  <CheckCircle size={18} />
                  <span>{successMessage}</span>
                </div>
              )}

              {errorMessage && (
                <div className="bg-rose-50 text-rose-600 border border-rose-200 p-4 rounded-xl text-sm font-bold flex items-center gap-2">
                  <AlertCircle size={18} />
                  <span>{errorMessage}</span>
                </div>
              )}

              {/* Tab 1: General Settings */}
              {activeTab === 'general' && (
                <div className="space-y-6">
                  <h3 className="font-extrabold text-lg border-b border-gray-100 dark:border-dark-800 pb-3 text-gray-800 dark:text-dark-100 flex items-center gap-2">
                    <Store className="text-primary-500" size={20} />
                    الملف التعريفي العام للمتجر
                  </h3>
                  
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">اسم المتجر (بالعربية)</label>
                      <div className="relative">
                        <Store className="absolute right-3.5 top-3.5 text-gray-400" size={16} />
                        <input 
                          type="text"
                          value={storeNameAr}
                          onChange={(e) => setStoreNameAr(e.target.value)}
                          className="w-full pl-4 pr-11 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none"
                          required
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">اسم المتجر (بالانجليزية)</label>
                      <div className="relative">
                        <Globe className="absolute right-3.5 top-3.5 text-gray-400" size={16} />
                        <input 
                          type="text"
                          value={storeNameEn}
                          onChange={(e) => setStoreNameEn(e.target.value)}
                          className="w-full pl-4 pr-11 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none text-left"
                          required
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">البريد الإلكتروني للدعم</label>
                      <div className="relative">
                        <Mail className="absolute right-3.5 top-3.5 text-gray-400" size={16} />
                        <input 
                          type="email"
                          value={storeEmail}
                          onChange={(e) => setStoreEmail(e.target.value)}
                          className="w-full pl-4 pr-11 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none text-left"
                          required
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">رقم هاتف التواصل</label>
                      <div className="relative">
                        <Phone className="absolute right-3.5 top-3.5 text-gray-400" size={16} />
                        <input 
                          type="text"
                          value={storePhone}
                          onChange={(e) => setStorePhone(e.target.value)}
                          className="w-full pl-4 pr-11 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none text-left"
                          required
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">عنوان المركز (بالعربية)</label>
                      <div className="relative">
                        <Store className="absolute right-3.5 top-3.5 text-gray-400" size={16} />
                        <input 
                          type="text"
                          value={storeAddressAr}
                          onChange={(e) => setStoreAddressAr(e.target.value)}
                          className="w-full pl-4 pr-11 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none"
                          required
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">عنوان المركز (بالانجليزية)</label>
                      <div className="relative">
                        <Globe className="absolute right-3.5 top-3.5 text-gray-400" size={16} />
                        <input 
                          type="text"
                          value={storeAddressEn}
                          onChange={(e) => setStoreAddressEn(e.target.value)}
                          className="w-full pl-4 pr-11 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none text-left"
                          required
                        />
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* Tab 2: Taxes and Shipping */}
              {activeTab === 'financial' && (
                <div className="space-y-6">
                  <h3 className="font-extrabold text-lg border-b border-gray-100 dark:border-dark-800 pb-3 text-gray-800 dark:text-dark-100 flex items-center gap-2">
                    <Truck className="text-primary-500" size={20} />
                    إعدادات الشحن وقيمة الضريبة
                  </h3>

                  <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div>
                      <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">قيمة الضريبة المضافة (%)</label>
                      <div className="relative">
                        <Percent className="absolute right-3.5 top-3.5 text-gray-400" size={16} />
                        <input 
                          type="number"
                          step="0.01"
                          value={taxRate}
                          onChange={(e) => setTaxRate(e.target.value)}
                          className="w-full pl-4 pr-11 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none"
                          required
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">رسوم التوصيل العادية</label>
                      <div className="relative">
                        <span className="absolute right-3.5 top-2.5 text-gray-400 font-bold text-xs">د.ع</span>
                        <input 
                          type="number"
                          step="0.01"
                          value={shippingFee}
                          onChange={(e) => setShippingFee(e.target.value)}
                          className="w-full pl-4 pr-12 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none"
                          required
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">عتبة الحصول على شحن مجاني</label>
                      <div className="relative">
                        <span className="absolute right-3.5 top-2.5 text-gray-400 font-bold text-xs">د.ع</span>
                        <input 
                          type="number"
                          step="0.01"
                          value={freeShippingThreshold}
                          onChange={(e) => setFreeShippingThreshold(e.target.value)}
                          className="w-full pl-4 pr-12 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none"
                          required
                        />
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* Tab 3: Payment Gateways */}
              {activeTab === 'payments' && (
                <div className="space-y-6">
                  <h3 className="font-extrabold text-lg border-b border-gray-100 dark:border-dark-800 pb-3 text-gray-800 dark:text-dark-100 flex items-center gap-2">
                    <CreditCard className="text-primary-500" size={20} />
                    خيارات الدفع وتفعيل البوابات
                  </h3>

                  <div className="space-y-4 max-w-xl">
                    {/* COD Option */}
                    <div className="flex items-center justify-between p-4 rounded-xl border border-gray-150 dark:border-dark-800 bg-gray-50/50 dark:bg-dark-900/50">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-lg bg-indigo-50 text-indigo-500 dark:bg-indigo-950/20 dark:text-indigo-400 flex items-center justify-center">
                          <Truck size={20} />
                        </div>
                        <div>
                          <h4 className="font-bold text-sm text-gray-800 dark:text-dark-100">الدفع عند الاستلام (COD)</h4>
                          <p className="text-xs text-gray-400 mt-0.5">تمكين العملاء من دفع قيمة الطلب نقداً عند وصول السائق.</p>
                        </div>
                      </div>
                      <input 
                        type="checkbox"
                        checked={codEnabled}
                        onChange={(e) => setCodEnabled(e.target.checked)}
                        className="w-5 h-5 accent-primary-600 rounded cursor-pointer"
                      />
                    </div>

                    {/* Card Option */}
                    <div className="flex items-center justify-between p-4 rounded-xl border border-gray-150 dark:border-dark-800 bg-gray-50/50 dark:bg-dark-900/50">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-lg bg-emerald-50 text-emerald-500 dark:bg-emerald-950/20 dark:text-emerald-400 flex items-center justify-center">
                          <CreditCard size={20} />
                        </div>
                        <div>
                          <h4 className="font-bold text-sm text-gray-800 dark:text-dark-100">بوابة الدفع الإلكتروني (مدى، فيزا، ماستر)</h4>
                          <p className="text-xs text-gray-400 mt-0.5">معالجة المدفوعات الفورية عبر بوابة الدفع Moyasar أو Stripe.</p>
                        </div>
                      </div>
                      <input 
                        type="checkbox"
                        checked={cardEnabled}
                        onChange={(e) => setCardEnabled(e.target.checked)}
                        className="w-5 h-5 accent-primary-600 rounded cursor-pointer"
                      />
                    </div>
                  </div>
                </div>
              )}

              {/* Tab 5: OTP Settings */}
              {activeTab === 'otp' && (
                <div className="space-y-6">
                  <h3 className="font-extrabold text-lg border-b border-gray-100 dark:border-dark-800 pb-3 text-gray-800 dark:text-dark-100 flex items-center gap-2">
                    <MessageSquare className="text-primary-500" size={20} />
                    إعدادات رسائل OTP والتحقق برقم الجوال
                  </h3>

                  <div className="bg-blue-50 dark:bg-blue-950/20 border border-blue-200 dark:border-blue-900 rounded-xl p-4 text-sm text-blue-700 dark:text-blue-400">
                    <p className="font-bold mb-1">مزود خدمة الرسائل النصية</p>
                    <p className="text-xs">يتم استخدام هذا المفتاح لإرسال رموز التحقق OTP لتسجيل الدخول عبر رقم الجوال.</p>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6 max-w-2xl">
                    <div>
                      <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">مزود الخدمة</label>
                      <select
                        value={otpProvider}
                        onChange={(e) => setOtpProvider(e.target.value)}
                        className="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none"
                      >
                        <option value="taqnyat">Taqnyat تقنيات</option>
                        <option value="unifonic">Unifonic</option>
                        <option value="msegat">Msegat مسجات</option>
                        <option value="twilio">Twilio</option>
                      </select>
                    </div>

                    <div>
                      <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">اسم المرسل (Sender Name)</label>
                      <div className="relative">
                        <MessageSquare className="absolute right-3.5 top-3.5 text-gray-400" size={16} />
                        <input
                          type="text"
                          value={otpSenderName}
                          onChange={(e) => setOtpSenderName(e.target.value)}
                          placeholder="NozzleApp"
                          className="w-full pl-4 pr-11 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none text-left"
                        />
                      </div>
                    </div>

                    <div className="md:col-span-2">
                      <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">مفتاح API الخاص بالخدمة</label>
                      <div className="relative">
                        <Key className="absolute right-3.5 top-3.5 text-gray-400" size={16} />
                        <input
                          type={showOtpKey ? 'text' : 'password'}
                          value={otpApiKey}
                          onChange={(e) => setOtpApiKey(e.target.value)}
                          placeholder="أدخل مفتاح API الخاص بك هنا..."
                          className="w-full pl-12 pr-11 py-2.5 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none font-mono text-sm text-left"
                        />
                        <button
                          type="button"
                          onClick={() => setShowOtpKey(!showOtpKey)}
                          className="absolute left-3.5 top-3 text-gray-400 hover:text-gray-600 cursor-pointer"
                        >
                          {showOtpKey ? <EyeOff size={16} /> : <Eye size={16} />}
                        </button>
                      </div>
                      <p className="text-xs text-gray-400 mt-1.5">يُحفظ المفتاح بشكل مشفر في قاعدة البيانات ولا يظهر للمستخدمين.</p>
                    </div>
                  </div>
                </div>
              )}

              {/* Tab 4: App Identity */}
              {activeTab === 'identity' && (
                <div className="space-y-6">
                  <h3 className="font-extrabold text-lg border-b border-gray-100 dark:border-dark-800 pb-3 text-gray-800 dark:text-dark-100 flex items-center gap-2">
                    <ImageIcon className="text-primary-500" size={20} />
                    شعار التطبيق وهوية العلامة التجارية
                  </h3>
                  
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    <ImageUploader
                      configKey="app_logo"
                      folder="brand"
                      value={appLogo}
                      onChange={(url) => setAppLogo(url)}
                      label="شعار التطبيق الرئيسي (App Logo)"
                    />
                    
                    <ImageUploader
                      configKey="app_splash"
                      folder="brand"
                      value={appSplash}
                      onChange={(url) => setAppSplash(url)}
                      label="صورة شاشة البداية (Splash Image)"
                    />

                    <ImageUploader
                      configKey="invoice_logo"
                      folder="brand"
                      value={invoiceLogo}
                      onChange={(url) => setInvoiceLogo(url)}
                      label="شعار الفواتير المطبوعة (Invoice Logo)"
                    />
                  </div>
                </div>
              )}

              {/* Submit Section */}
              <div className="flex justify-end pt-4 border-t border-gray-100 dark:border-dark-800">
                <button
                  type="submit"
                  disabled={saving}
                  className="px-6 py-2.5 rounded-xl bg-primary-600 hover:bg-primary-700 disabled:bg-primary-400 text-white font-bold shadow-lg shadow-primary-600/10 active:scale-95 cursor-pointer flex items-center gap-2"
                >
                  <Save size={16} />
                  {saving ? 'جاري الحفظ...' : 'حفظ التغييرات'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
