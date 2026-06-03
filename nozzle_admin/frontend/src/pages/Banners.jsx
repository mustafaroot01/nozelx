import React, { useState, useEffect } from 'react';
import api from '../services/api';
import ImageUploader from '../components/ui/ImageUploader';
import { 
  Plus, 
  Edit2, 
  Trash2, 
  Image, 
  Eye, 
  MousePointerClick, 
  Percent, 
  Calendar,
  ExternalLink,
  ChevronDown,
  EyeOff,
  Palette,
  AlignJustify
} from 'lucide-react';

const alignmentOptions = [
  { value: 'top_left', label: 'أعلى اليسار', dotClass: 'top-1 left-1' },
  { value: 'top_center', label: 'أعلى الوسط', dotClass: 'top-1 left-1/2 -translate-x-1/2' },
  { value: 'top_right', label: 'أعلى اليمين', dotClass: 'top-1 right-1' },
  { value: 'center_left', label: 'وسط اليسار', dotClass: 'top-1/2 -translate-y-1/2 left-1' },
  { value: 'center', label: 'الوسط', dotClass: 'top-1/2 -translate-y-1/2 left-1/2 -translate-x-1/2' },
  { value: 'center_right', label: 'وسط اليمين', dotClass: 'top-1/2 -translate-y-1/2 right-1' },
  { value: 'bottom_left', label: 'أسفل اليسار', dotClass: 'bottom-1 left-1' },
  { value: 'bottom_center', label: 'أسفل الوسط', dotClass: 'bottom-1 left-1/2 -translate-x-1/2' },
  { value: 'bottom_right', label: 'أسفل اليمين', dotClass: 'bottom-1 right-1' }
];

const getAlignmentClasses = (align) => {
  switch (align) {
    case 'top_left': return { justify: 'justify-start', items: 'items-start', text: 'text-left' };
    case 'top_center': return { justify: 'justify-start', items: 'items-center', text: 'text-center' };
    case 'top_right': return { justify: 'justify-start', items: 'items-end', text: 'text-right' };
    case 'center_left': return { justify: 'justify-center', items: 'items-start', text: 'text-left' };
    case 'center_right': return { justify: 'justify-center', items: 'items-end', text: 'text-right' };
    case 'bottom_left': return { justify: 'justify-end', items: 'items-start', text: 'text-left' };
    case 'bottom_center': return { justify: 'justify-end', items: 'items-center', text: 'text-center' };
    case 'bottom_right': return { justify: 'justify-end', items: 'items-end', text: 'text-right' };
    case 'center':
    default: return { justify: 'justify-center', items: 'items-center', text: 'text-center' };
  }
};

export default function Banners() {
  const [banners, setBanners] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [editingBanner, setEditingBanner] = useState(null);
  const [errorMessage, setErrorMessage] = useState('');
  
  // Lists for mapping targets
  const [productList, setProductList] = useState([]);
  const [categoryList, setCategoryList] = useState([]);

  // Form states
  const [title, setTitle] = useState('');
  const [subtitle, setSubtitle] = useState('');
  const [imageUrl, setImageUrl] = useState('');
  const [mobileImageUrl, setMobileImageUrl] = useState('');
  const [linkType, setLinkType] = useState('none'); // product, category, external, none
  const [productId, setProductId] = useState('');
  const [categoryId, setCategoryId] = useState('');
  const [externalUrl, setExternalUrl] = useState('');
  const [textAlignment, setTextAlignment] = useState('center');
  const [textColor, setTextColor] = useState('#ffffff');
  const [overlayColor, setOverlayColor] = useState('#000000');
  const [overlayOpacity, setOverlayOpacity] = useState(0.4);
  const [buttonText, setButtonText] = useState('');
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const [isActive, setIsActive] = useState(true);
  const [sortOrder, setSortOrder] = useState(0);

  useEffect(() => {
    fetchBanners();
    fetchOptions();
  }, []);

  const fetchBanners = async () => {
    try {
      setLoading(true);
      const res = await api.get('/banners/admin');
      if (res.data && res.data.status === 'success') {
        setBanners(res.data.data);
      }
    } catch (err) {
      console.error('Error fetching banners:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchOptions = async () => {
    try {
      // Fetch categories for link target dropdown (includes subcategories now)
      const catRes = await api.get('/categories');
      if (catRes.data && catRes.data.status === 'success') {
        const flattenCategories = (categories) => {
          let flat = [];
          categories.forEach(cat => {
            flat.push(cat);
            const subs = cat.subcategories || cat.sub_categories || [];
            if (subs.length > 0) {
              flat = flat.concat(flattenCategories(subs));
            }
          });
          return flat;
        };
        const flatCategories = flattenCategories(catRes.data.data);
        setCategoryList(flatCategories);
      }

      // Fetch products for link target dropdown
      const prodRes = await api.get('/products?limit=100');
      if (prodRes.data && prodRes.data.status === 'success') {
        setProductList(prodRes.data.data);
      }
    } catch (err) {
      console.error('Error fetching options list:', err);
    }
  };

  const openAddModal = () => {
    setEditingBanner(null);
    setTitle('');
    setSubtitle('');
    setImageUrl('');
    setMobileImageUrl('');
    setLinkType('none');
    setProductId('');
    setCategoryId('');
    setExternalUrl('');
    setTextAlignment('center');
    setTextColor('#ffffff');
    setOverlayColor('#000000');
    setOverlayOpacity(0.4);
    setButtonText('');
    setStartDate('');
    setEndDate('');
    setIsActive(true);
    setSortOrder(0);
    setErrorMessage('');
    setModalOpen(true);
  };

  const openEditModal = (b) => {
    setEditingBanner(b);
    setTitle(b.title || '');
    setSubtitle(b.subtitle || '');
    setImageUrl(b.image_url || '');
    setMobileImageUrl(b.mobile_image_url || '');
    setLinkType(b.link_type || 'none');
    setProductId(b.product_id ? String(b.product_id) : '');
    setCategoryId(b.category_id ? String(b.category_id) : '');
    setExternalUrl(b.external_url || '');
    setTextAlignment(b.text_alignment || 'center');
    setTextColor(b.text_color || '#ffffff');
    setOverlayColor(b.overlay_color || '#000000');
    setOverlayOpacity(b.overlay_opacity !== undefined ? b.overlay_opacity : 0.4);
    setButtonText(b.button_text || '');
    setStartDate(b.start_date ? b.start_date.substring(0, 16) : '');
    setEndDate(b.end_date ? b.end_date.substring(0, 16) : '');
    setIsActive(b.is_active !== false);
    setSortOrder(b.sort_order || 0);
    setErrorMessage('');
    setModalOpen(true);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMessage('');

    if (!imageUrl) {
      setErrorMessage('صورة البنر مطلوبة');
      return;
    }

    const payload = {
      title,
      subtitle: subtitle || null,
      image_url: imageUrl,
      mobile_image_url: mobileImageUrl || null,
      link_type: linkType,
      product_id: linkType === 'product' && productId ? parseInt(productId) : null,
      category_id: linkType === 'category' && categoryId ? parseInt(categoryId) : null,
      external_url: linkType === 'external' && externalUrl ? externalUrl : null,
      text_alignment: textAlignment,
      text_color: textColor,
      overlay_color: overlayColor,
      overlay_opacity: parseFloat(overlayOpacity),
      button_text: buttonText || null,
      sort_order: sortOrder,
      start_date: startDate ? new Date(startDate).toISOString() : null,
      end_date: endDate ? new Date(endDate).toISOString() : null,
      is_active: isActive
    };

    try {
      if (editingBanner) {
        await api.put(`/banners/${editingBanner.id}`, payload);
      } else {
        await api.post('/banners', payload);
      }
      setModalOpen(false);
      fetchBanners();
    } catch (err) {
      setErrorMessage(err.response?.data?.detail || 'حدث خطأ أثناء حفظ البنر');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('هل أنت متأكد من حذف هذا البنر الإعلاني؟')) return;
    try {
      await api.delete(`/banners/${id}`);
      fetchBanners();
    } catch (err) {
      alert('حدث خطأ أثناء حذف البنر');
    }
  };

  const moveOrder = async (index, direction) => {
    const list = [...banners];
    if (direction === 'up' && index === 0) return;
    if (direction === 'down' && index === list.length - 1) return;

    const targetIndex = direction === 'up' ? index - 1 : index + 1;
    const temp = list[index];
    list[index] = list[targetIndex];
    list[targetIndex] = temp;

    const sortPayload = list.map((b, i) => ({
      id: b.id,
      sort_order: i
    }));

    try {
      setBanners(list);
      await api.put('/banners/sort/order', sortPayload);
    } catch (err) {
      console.error('Error sorting banners:', err);
      fetchBanners();
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-black text-gray-800 dark:text-dark-50">البنرات الإعلانية</h1>
          <p className="text-sm text-gray-400 mt-1">إدارة الحملات الإعلانية والبنرات الترويجية ومتابعة أرقام التفاعل (CTR).</p>
        </div>
        <button 
          onClick={openAddModal}
          className="bg-primary-600 hover:bg-primary-700 text-white font-bold px-4 py-2.5 rounded-xl flex items-center gap-2 shadow-lg shadow-primary-600/20 transition-all active:scale-95"
        >
          <Plus size={18} />
          إضافة بنر إعلاني
        </button>
      </div>

      {/* Main banners display container */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {loading ? (
          [1, 2, 3].map(n => (
            <div key={n} className="h-64 bg-gray-100 dark:bg-dark-800 rounded-2xl animate-pulse"></div>
          ))
        ) : banners.length === 0 ? (
          <div className="col-span-full bg-white dark:bg-dark-900 border border-gray-200 dark:border-dark-800 rounded-2xl p-12 text-center shadow-sm">
            <div className="w-16 h-16 bg-gray-50 dark:bg-dark-800/40 text-gray-400 rounded-full flex items-center justify-center mx-auto mb-4">
              <Image size={28} />
            </div>
            <h3 className="font-bold text-gray-700 dark:text-dark-300">لا توجد بنرات إعلانية</h3>
            <p className="text-sm text-gray-400 mt-1">أضف بنرات لعرض الخصومات والعروض الترويجية في الصفحة الرئيسية للتطبيق.</p>
          </div>
        ) : (
          banners.map((b, index) => (
            <div key={b.id} className="bg-white dark:bg-dark-900 border border-gray-200 dark:border-dark-800 rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-shadow flex flex-col">
              {/* Banner image preview */}
              <div className="relative h-40 bg-gray-100 dark:bg-dark-800">
                <img 
                  src={b.image_url} 
                  alt={b.title} 
                  className="w-full h-full object-cover"
                  onError={(e) => { e.target.src = 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=500&auto=format&fit=crop' }}
                />
                
                {/* Active/Inactive badges */}
                <div className="absolute top-3 right-3 flex gap-2">
                  {b.is_active ? (
                    <span className="bg-green-500 text-white text-[10px] px-2 py-0.5 rounded-full font-bold">
                      نشط
                    </span>
                  ) : (
                    <span className="bg-red-500 text-white text-[10px] px-2 py-0.5 rounded-full font-bold flex items-center gap-0.5">
                      <EyeOff size={10} /> معطل
                    </span>
                  )}
                </div>

                {/* Drag sorting sequencing control */}
                <div className="absolute bottom-3 left-3 bg-black/60 backdrop-blur-sm text-white rounded-lg flex items-center p-1">
                  <button 
                    onClick={() => moveOrder(index, 'up')}
                    disabled={index === 0}
                    className="px-1.5 hover:text-primary-400 disabled:opacity-30"
                  >
                    ▲
                  </button>
                  <span className="text-xs px-1 border-r border-l border-white/20">الترتيب</span>
                  <button 
                    onClick={() => moveOrder(index, 'down')}
                    disabled={index === banners.length - 1}
                    className="px-1.5 hover:text-primary-400 disabled:opacity-30"
                  >
                    ▼
                  </button>
                </div>
              </div>

              {/* Banner Details content */}
              <div className="p-5 flex-1 flex flex-col justify-between space-y-4">
                <div>
                  <h3 className="font-extrabold text-gray-800 dark:text-dark-100 text-base line-clamp-1">{b.title || '(بنر بدون كتابة)'}</h3>
                  <div className="flex items-center gap-1.5 mt-1.5 text-xs text-gray-400">
                    <span className="bg-gray-150 dark:bg-dark-800 px-2 py-0.5 rounded-md font-bold text-gray-500">
                      {b.link_type === 'product' ? 'رابط لمنتج' : b.link_type === 'category' ? 'رابط لقسم' : b.link_type === 'external' ? 'رابط خارجي' : 'بدون توجيه'}
                    </span>
                  </div>
                </div>

                {/* CTR and interaction stats panel */}
                <div className="grid grid-cols-3 gap-2 bg-gray-50/50 dark:bg-dark-800/20 p-3 rounded-xl border border-gray-100 dark:border-dark-800/80">
                  <div className="text-center">
                    <span className="text-[10px] text-gray-400 font-bold block">المشاهدات</span>
                    <span className="font-black text-gray-800 dark:text-dark-200 text-sm flex items-center justify-center gap-1">
                      <Eye size={12} className="text-gray-400" /> {b.views}
                    </span>
                  </div>
                  <div className="text-center border-r border-l border-gray-150 dark:border-dark-800">
                    <span className="text-[10px] text-gray-400 font-bold block">النقرات</span>
                    <span className="font-black text-gray-800 dark:text-dark-200 text-sm flex items-center justify-center gap-1">
                      <MousePointerClick size={12} className="text-gray-400" /> {b.clicks}
                    </span>
                  </div>
                  <div className="text-center">
                    <span className="text-[10px] text-gray-400 font-bold block">تفاعل CTR</span>
                    <span className="font-black text-primary-600 dark:text-primary-400 text-sm flex items-center justify-center gap-0.5">
                      {b.ctr}%
                    </span>
                  </div>
                </div>

                {/* Schedule timeline display */}
                {(b.start_date || b.end_date) && (
                  <div className="flex items-center gap-1.5 text-[10px] text-gray-400">
                    <Calendar size={12} />
                    <span>
                      {b.start_date ? new Date(b.start_date).toLocaleDateString('ar-EG') : 'بدون بداية'} ← {b.end_date ? new Date(b.end_date).toLocaleDateString('ar-EG') : 'مفتوح'}
                    </span>
                  </div>
                )}

                {/* Card footer options */}
                <div className="flex gap-2 border-t border-gray-100 dark:border-dark-800/60 pt-3.5">
                  <button
                    onClick={() => openEditModal(b)}
                    className="flex-1 py-2 text-xs border border-gray-200 dark:border-dark-800 rounded-xl hover:bg-gray-50 dark:hover:bg-dark-800/40 text-gray-600 dark:text-dark-300 font-bold flex items-center justify-center gap-1.5"
                  >
                    <Edit2 size={12} /> تعديل
                  </button>
                  <button
                    onClick={() => handleDelete(b.id)}
                    className="py-2 px-3.5 text-xs bg-red-50 hover:bg-red-100/60 dark:bg-red-950/20 dark:hover:bg-red-950/40 rounded-xl text-red-600 dark:text-red-400 font-bold"
                  >
                    <Trash2 size={14} />
                  </button>
                </div>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Banner Add/Edit Modal */}
      {modalOpen && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4 backdrop-blur-sm">
          <div className="bg-white dark:bg-dark-900 rounded-2xl w-full max-w-lg overflow-hidden shadow-2xl border border-gray-100 dark:border-dark-800 flex flex-col max-h-[90vh]">
            <div className="p-6 border-b border-gray-100 dark:border-dark-800 flex justify-between items-center bg-gray-50/50 dark:bg-dark-900/50">
              <h3 className="font-extrabold text-lg text-gray-800 dark:text-dark-100">
                {editingBanner ? 'تعديل بيانات البنر' : 'إضافة بنر إعلاني جديد'}
              </h3>
              <button 
                onClick={() => setModalOpen(false)}
                className="text-gray-400 hover:text-gray-600 dark:hover:text-dark-200"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleSubmit} className="p-6 space-y-5 overflow-y-auto flex-1 bg-gray-50/30">
              {errorMessage && (
                <div className="bg-red-50 text-red-500 border border-red-200 p-3 rounded-lg text-sm font-bold">
                  {errorMessage}
                </div>
              )}

              {/* Live Preview Card */}
              <div className="bg-white dark:bg-dark-850 p-4 rounded-2xl border border-gray-150 dark:border-dark-800 space-y-3">
                <span className="block text-xs font-black text-gray-400 uppercase tracking-wider">معاينة البنر المباشرة (على الموبايل/الويب)</span>
                <div 
                  className="relative w-full h-44 rounded-xl overflow-hidden border border-gray-200 dark:border-dark-800 bg-gray-100 dark:bg-dark-900 flex flex-col transition-all duration-300 shadow-inner"
                  style={{
                    backgroundImage: imageUrl ? `url(${imageUrl})` : 'none',
                    backgroundSize: 'cover',
                    backgroundPosition: 'center',
                  }}
                >
                  {!imageUrl && (
                    <div className="absolute inset-0 bg-gradient-to-r from-gray-100 to-gray-250 dark:from-dark-800 dark:to-dark-850 flex flex-col items-center justify-center text-center p-4">
                      <Image size={24} className="text-gray-300 mb-1" />
                      <span className="text-xs text-gray-400 font-bold">يرجى رفع أو إضافة رابط صورة للمعاينة</span>
                    </div>
                  )}

                  {/* Dark Overlay */}
                  <div 
                    className="absolute inset-0 transition-all duration-300"
                    style={{
                      backgroundColor: overlayColor || '#000000',
                      opacity: imageUrl ? parseFloat(overlayOpacity) : 0.15
                    }}
                  />

                  {/* Banner Content Container */}
                  <div className={`absolute inset-0 p-4 flex flex-col ${getAlignmentClasses(textAlignment).justify} ${getAlignmentClasses(textAlignment).items}`}>
                    <div 
                      className={`max-w-[90%] transition-all duration-300 ${getAlignmentClasses(textAlignment).text}`}
                      style={{ color: textColor || '#ffffff' }}
                    >
                      {title && (
                        <h4 className="font-extrabold text-base md:text-lg leading-tight drop-shadow-md break-words line-clamp-2">
                          {title}
                        </h4>
                      )}
                      {subtitle && (
                        <p className="text-xs mt-1.5 opacity-90 font-bold drop-shadow-md break-words line-clamp-2 leading-relaxed">
                          {subtitle}
                        </p>
                      )}
                      {buttonText && (
                        <button
                          type="button"
                          className="mt-3 px-3 py-1.5 text-[10px] font-black rounded-lg transition-all active:scale-95 shadow-md border-none inline-block pointer-events-none"
                          style={{
                            color: overlayColor || '#000000',
                            backgroundColor: textColor || '#ffffff'
                          }}
                        >
                          {buttonText}
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              </div>

              {/* Title & Subtitle */}
              <div className="space-y-4 bg-white dark:bg-dark-850 p-4 rounded-2xl border border-gray-150 dark:border-dark-800">
                <h4 className="text-xs font-bold text-gray-400 border-b border-gray-100 dark:border-dark-800 pb-2">نصوص البنر</h4>
                
                <div>
                  <label className="block text-xs font-bold mb-1.5 text-gray-600 dark:text-dark-300">العنوان الرئيسي</label>
                  <input 
                    type="text"
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    className="w-full px-4 py-2 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none text-sm font-bold"
                    placeholder="مثال: خصم 20% على فلاتر الزيت (اختياري)"
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold mb-1.5 text-gray-600 dark:text-dark-300">العنوان الفرعي (اختياري)</label>
                  <input 
                    type="text"
                    value={subtitle}
                    onChange={(e) => setSubtitle(e.target.value)}
                    className="w-full px-4 py-2 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none text-sm"
                    placeholder="مثال: العرض ساري حتى نهاية الأسبوع على جميع الموديلات"
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold mb-1.5 text-gray-600 dark:text-dark-300">نص زر التفاعل (اختياري)</label>
                  <input 
                    type="text"
                    value={buttonText}
                    onChange={(e) => setButtonText(e.target.value)}
                    className="w-full px-4 py-2 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none text-sm font-bold"
                    placeholder="مثال: تسوق الآن، احجز موعداً"
                  />
                </div>
              </div>

              {/* Web & Mobile Banner Image Uploader */}
              <div className="bg-white dark:bg-dark-850 p-4 rounded-2xl border border-gray-150 dark:border-dark-800 space-y-4">
                <h4 className="text-xs font-bold text-gray-400 border-b border-gray-100 dark:border-dark-800 pb-2">صور الحملة الإعلانية</h4>
                <div className="space-y-4">
                  <ImageUploader
                    configKey="banner_web"
                    folder="banners"
                    value={imageUrl}
                    onChange={(url) => setImageUrl(url)}
                    label="صورة البنر للويب (الرئيسية)"
                    required={true}
                  />
                  
                  <ImageUploader
                    configKey="banner_mobile"
                    folder="banners"
                    value={mobileImageUrl}
                    onChange={(url) => setMobileImageUrl(url)}
                    label="صورة البنر للموبايل"
                  />
                </div>
              </div>

              {/* Design Customizations */}
              <div className="bg-white dark:bg-dark-850 p-4 rounded-2xl border border-gray-150 dark:border-dark-800 space-y-4">
                <h4 className="text-xs font-bold text-gray-400 border-b border-gray-100 dark:border-dark-800 pb-2">تصميم البنر وموضع النصوص</h4>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {/* Visual 9 grid selector */}
                  <div className="space-y-2">
                    <label className="block text-xs font-bold text-gray-600 dark:text-dark-300">موضع النصوص (محاذاة 9-Grid)</label>
                    <div className="grid grid-cols-3 gap-1.5 w-full max-w-[200px] bg-gray-50 dark:bg-dark-900 p-2 rounded-xl border border-gray-200 dark:border-dark-800">
                      {alignmentOptions.map((opt) => (
                        <button
                          key={opt.value}
                          type="button"
                          onClick={() => setTextAlignment(opt.value)}
                          title={opt.label}
                          className={`relative h-10 border rounded-lg transition-all ${
                            textAlignment === opt.value
                              ? 'bg-primary-600 border-primary-600 text-white shadow-sm'
                              : 'bg-white dark:bg-dark-950 border-gray-200 dark:border-dark-800 hover:bg-gray-100 text-gray-400 hover:text-gray-600'
                          }`}
                        >
                          <span className={`absolute w-2 h-2 rounded-full transition-colors ${
                            textAlignment === opt.value ? 'bg-white' : 'bg-gray-450 dark:bg-gray-600'
                          } ${opt.dotClass}`} />
                        </button>
                      ))}
                    </div>
                  </div>

                  {/* Colors & Opacity */}
                  <div className="space-y-4">
                    <div className="flex gap-4">
                      <div className="flex-1">
                        <label className="block text-xs font-bold mb-1.5 text-gray-600 dark:text-dark-300">لون النصوص</label>
                        <div className="flex gap-2 items-center">
                          <input 
                            type="color"
                            value={textColor}
                            onChange={(e) => setTextColor(e.target.value)}
                            className="w-10 h-10 p-0 border border-gray-200 dark:border-dark-850 rounded-lg cursor-pointer bg-transparent"
                          />
                          <input 
                            type="text"
                            value={textColor}
                            onChange={(e) => setTextColor(e.target.value)}
                            className="w-full px-3 py-2 rounded-lg border border-gray-200 dark:border-dark-800 bg-transparent text-xs font-mono uppercase"
                          />
                        </div>
                      </div>

                      <div className="flex-1">
                        <label className="block text-xs font-bold mb-1.5 text-gray-600 dark:text-dark-300">لون طبقة التباين</label>
                        <div className="flex gap-2 items-center">
                          <input 
                            type="color"
                            value={overlayColor}
                            onChange={(e) => setOverlayColor(e.target.value)}
                            className="w-10 h-10 p-0 border border-gray-200 dark:border-dark-850 rounded-lg cursor-pointer bg-transparent"
                          />
                          <input 
                            type="text"
                            value={overlayColor}
                            onChange={(e) => setOverlayColor(e.target.value)}
                            className="w-full px-3 py-2 rounded-lg border border-gray-200 dark:border-dark-800 bg-transparent text-xs font-mono uppercase"
                          />
                        </div>
                      </div>
                    </div>

                    <div>
                      <div className="flex justify-between text-xs font-bold mb-1.5 text-gray-600 dark:text-dark-300">
                        <span>شفافية طبقة التباين</span>
                        <span className="font-mono">{Math.round(overlayOpacity * 100)}%</span>
                      </div>
                      <input 
                        type="range"
                        min="0"
                        max="1"
                        step="0.05"
                        value={overlayOpacity}
                        onChange={(e) => setOverlayOpacity(parseFloat(e.target.value))}
                        className="w-full h-1.5 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-primary-600"
                      />
                    </div>
                  </div>
                </div>
              </div>

              {/* Link Type and Target */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 bg-white dark:bg-dark-850 p-4 rounded-2xl border border-gray-150 dark:border-dark-800">
                <div>
                  <label className="block text-xs font-bold mb-1.5 text-gray-600 dark:text-dark-300">نوع التوجيه عند النقر</label>
                  <select
                    value={linkType}
                    onChange={(e) => setLinkType(e.target.value)}
                    className="w-full px-3 py-2 rounded-xl border border-gray-200 dark:border-dark-800 bg-white dark:bg-dark-900 dark:text-dark-100 text-sm focus:outline-none"
                  >
                    <option value="none">بدون توجيه (عرض فقط)</option>
                    <option value="product">منتج معين</option>
                    <option value="category">قسم معين</option>
                    <option value="external">رابط خارجي</option>
                  </select>
                </div>

                <div className="flex flex-col justify-end">
                  {linkType === 'product' && (
                    <>
                      <label className="block text-xs font-bold mb-1.5 text-gray-600 dark:text-dark-300">اختر المنتج المستهدف</label>
                      <select
                        value={productId}
                        onChange={(e) => setProductId(e.target.value)}
                        className="w-full px-3 py-2 rounded-xl border border-gray-200 dark:border-dark-800 bg-white dark:bg-dark-900 dark:text-dark-100 text-sm focus:outline-none"
                      >
                        <option value="">-- اختر --</option>
                        {productList.map(p => (
                          <option key={p.id} value={p.id}>{p.name}</option>
                        ))}
                      </select>
                    </>
                  )}

                  {linkType === 'category' && (
                    <>
                      <label className="block text-xs font-bold mb-1.5 text-gray-600 dark:text-dark-300">اختر القسم المستهدف</label>
                      <select
                        value={categoryId}
                        onChange={(e) => setCategoryId(e.target.value)}
                        className="w-full px-3 py-2 rounded-xl border border-gray-200 dark:border-dark-800 bg-white dark:bg-dark-900 dark:text-dark-100 text-sm focus:outline-none"
                      >
                        <option value="">-- اختر --</option>
                        {categoryList.map(c => (
                          <option key={c.id} value={c.id}>
                            {c.parent_id ? '\u00A0\u00A0↳ ' + c.name : c.name}
                          </option>
                        ))}
                      </select>
                    </>
                  )}

                  {linkType === 'external' && (
                    <>
                      <label className="block text-xs font-bold mb-1.5 text-gray-600 dark:text-dark-300">ادخل الرابط الخارجي الكامل</label>
                      <input 
                        type="url"
                        value={externalUrl}
                        onChange={(e) => setExternalUrl(e.target.value)}
                        className="w-full px-3 py-2 rounded-xl border border-gray-200 dark:border-dark-800 bg-white dark:bg-dark-900 dark:text-dark-100 text-sm focus:outline-none text-left"
                        placeholder="https://example.com"
                      />
                    </>
                  )}
                </div>
              </div>

              {/* Schedule Dates */}
              <div className="grid grid-cols-2 gap-4 bg-white dark:bg-dark-850 p-4 rounded-2xl border border-gray-150 dark:border-dark-800">
                <div>
                  <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">تاريخ بدء العرض</label>
                  <input 
                    type="datetime-local"
                    value={startDate}
                    onChange={(e) => setStartDate(e.target.value)}
                    className="w-full px-4 py-2 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none text-sm text-left"
                  />
                </div>
                <div>
                  <label className="block text-sm font-bold mb-1.5 text-gray-700 dark:text-dark-300">تاريخ انتهاء العرض</label>
                  <input 
                    type="datetime-local"
                    value={endDate}
                    onChange={(e) => setEndDate(e.target.value)}
                    className="w-full px-4 py-2 rounded-xl border border-gray-200 dark:border-dark-800 bg-transparent dark:text-dark-100 focus:border-primary-500 focus:outline-none text-sm text-left"
                  />
                </div>
              </div>

              {/* Active Toggle */}
              <div className="flex items-center gap-3 border-t border-gray-150 dark:border-dark-800 pt-4 px-1">
                <input 
                  type="checkbox" 
                  id="isActive"
                  checked={isActive}
                  onChange={(e) => setIsActive(e.target.checked)}
                  className="w-5 h-5 accent-primary-600 rounded cursor-pointer"
                />
                <label htmlFor="isActive" className="text-sm font-bold text-gray-700 dark:text-dark-300 cursor-pointer">
                  تفعيل البنر (عرضه فوراً للمستخدمين في التطبيق)
                </label>
              </div>

              {/* Submit Buttons */}
              <div className="flex gap-3 justify-end pt-4 border-t border-gray-100 dark:border-dark-800 bg-white dark:bg-dark-900 -mx-6 -mb-6 p-6">
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
                  حفظ البنر
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
