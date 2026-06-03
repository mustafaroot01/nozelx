@extends('layouts.admin')

@section('content')
<div class="max-w-6xl mx-auto space-y-8 pb-20">
    
    <!-- Page Header -->
    <div class="flex items-center justify-between">
        <div>
            <h2 class="text-3xl font-bold text-white tracking-tight">إضافة منتج احترافي</h2>
            <p class="text-slate-400">تحكم بكل تفاصيل المنتج لضمان عرض مثالي في التطبيق.</p>
        </div>
        <div class="flex gap-4">
            <a href="{{ route('admin.products.index') }}" class="glass px-5 py-2.5 rounded-xl text-sm font-semibold flex items-center gap-2 hover:bg-white/10 transition-all text-white">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
                العودة للقائمة
            </a>
        </div>
    </div>

    <form action="{{ route('admin.products.store') }}" method="POST" enctype="multipart/form-data" class="space-y-8">
        @csrf
        
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-8">
            
            <!-- Left Column: Main Content (8 cols) -->
            <div class="lg:col-span-8 space-y-8">
                
                <!-- General Information (Bilingual) -->
                <div class="glass p-8 rounded-[2rem] space-y-8 border border-white/5">
                    <div class="flex items-center gap-3 border-b border-white/5 pb-5">
                        <div class="w-10 h-10 bg-amber-500/10 rounded-xl flex items-center justify-center text-amber-500">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                        </div>
                        <h3 class="text-xl font-bold text-white">المعلومات الأساسية</h3>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div class="space-y-2">
                            <label class="text-xs font-bold text-slate-400 uppercase tracking-wider mr-1">Product Name (EN) <span class="text-red-500">*</span></label>
                            <input type="text" name="name" required placeholder="e.g. Motul 7100 10W40" class="w-full bg-slate-900/50 border border-white/10 rounded-2xl py-4 px-5 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all">
                        </div>
                        <div class="space-y-2">
                            <label class="text-xs font-bold text-slate-400 uppercase tracking-wider mr-1">اسم المنتج (العربي) <span class="text-red-500">*</span></label>
                            <input type="text" name="name_ar" required placeholder="مثلاً: زيت موتول 7100" class="w-full bg-slate-900/50 border border-white/10 rounded-2xl py-4 px-5 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all text-right">
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div class="space-y-2">
                            <label class="text-xs font-bold text-slate-400 uppercase tracking-wider mr-1">Description (EN)</label>
                            <textarea name="description" rows="4" placeholder="Full technical description..." class="w-full bg-slate-900/50 border border-white/10 rounded-2xl py-4 px-5 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all"></textarea>
                        </div>
                        <div class="space-y-2">
                            <label class="text-xs font-bold text-slate-400 uppercase tracking-wider mr-1">الوصف (العربي)</label>
                            <textarea name="description_ar" rows="4" placeholder="وصف كامل للمنتج يظهر للزبون..." class="w-full bg-slate-900/50 border border-white/10 rounded-2xl py-4 px-5 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all text-right"></textarea>
                        </div>
                    </div>
                </div>

                <!-- Features & Specs (Enhanced) -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                    <!-- Features Section -->
                    <div class="glass p-8 rounded-[2rem] space-y-6 border border-white/5">
                        <div class="flex items-center justify-between border-b border-white/5 pb-4">
                            <h3 class="text-lg font-bold text-white">مميزات المنتج</h3>
                            <button type="button" onclick="addFeature()" class="p-2 bg-amber-500/10 text-amber-500 rounded-lg hover:bg-amber-500 hover:text-white transition-all">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
                            </button>
                        </div>
                        <div id="features-container" class="space-y-3">
                            <div class="flex gap-2">
                                <input type="text" name="features[]" placeholder="مثلاً: يخدم لـ 5000 كم" class="flex-1 bg-slate-900/50 border border-white/10 rounded-xl py-3 px-4 text-white text-sm focus:outline-none focus:ring-1 focus:ring-amber-500/30 transition-all">
                                <button type="button" onclick="this.parentElement.remove()" class="p-3 text-slate-500 hover:text-red-500 transition-colors">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                                </button>
                            </div>
                        </div>
                        <p class="text-[10px] text-slate-500 font-medium">سيتم عرضها كنقاط في صفحة تفاصيل المنتج.</p>
                    </div>

                    <!-- Specifications Section -->
                    <div class="glass p-8 rounded-[2rem] space-y-6 border border-white/5">
                        <div class="flex items-center justify-between border-b border-white/5 pb-4">
                            <h3 class="text-lg font-bold text-white">المواصفات الفنية</h3>
                            <button type="button" onclick="addSpec()" class="p-2 bg-blue-500/10 text-blue-500 rounded-lg hover:bg-blue-500 hover:text-white transition-all text-blue-500">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
                            </button>
                        </div>
                        <div id="specs-container" class="space-y-3">
                            <div class="flex gap-2">
                                <input type="text" name="spec_keys[]" placeholder="الخاصية (مثلاً: اللزوجة)" class="w-1/2 bg-slate-900/50 border border-white/10 rounded-xl py-3 px-4 text-white text-sm focus:outline-none focus:ring-1 focus:ring-blue-500/30 transition-all">
                                <input type="text" name="spec_values[]" placeholder="القيمة (مثلاً: 10W40)" class="w-1/2 bg-slate-900/50 border border-white/10 rounded-xl py-3 px-4 text-white text-sm focus:outline-none focus:ring-1 focus:ring-blue-500/30 transition-all">
                                <button type="button" onclick="this.parentElement.remove()" class="p-3 text-slate-500 hover:text-red-500 transition-colors">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
                                </button>
                            </div>
                        </div>
                        <p class="text-[10px] text-slate-500 font-medium">ستظهر كجدول مواصفات في التطبيق.</p>
                    </div>
                </div>
            </div>

            <!-- Right Column: Sidebar (4 cols) -->
            <div class="lg:col-span-4 space-y-8">
                
                <!-- Image Section -->
                <div class="glass p-8 rounded-[2rem] border border-white/5 space-y-6">
                    <h3 class="text-lg font-bold text-white uppercase tracking-tighter">صورة المنتج</h3>
                    <div class="relative group cursor-pointer">
                        <div id="image-preview" class="aspect-square border-2 border-dashed border-white/10 rounded-3xl p-4 text-center hover:border-amber-500/50 transition-all overflow-hidden relative flex flex-col items-center justify-center bg-slate-900/30">
                            <div class="w-16 h-16 bg-amber-500/10 rounded-2xl flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform">
                                <svg class="w-8 h-8 text-amber-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
                            </div>
                            <p class="text-white text-sm font-bold">صورة المنتج الأساسية</p>
                            <p class="text-slate-500 text-[10px] mt-2">يفضل استخدام خلفية بيضاء</p>
                        </div>
                        <input type="file" name="image" required class="absolute inset-0 opacity-0 cursor-pointer" onchange="previewImage(this)">
                    </div>
                </div>

                <!-- Pricing & Stock -->
                <div class="glass p-8 rounded-[2rem] border border-white/5 space-y-6">
                    <h3 class="text-lg font-bold text-white border-b border-white/5 pb-4">الأسعار والمخزون</h3>
                    <div class="grid grid-cols-2 gap-4">
                        <div class="space-y-2">
                            <label class="text-xs font-bold text-slate-400">السعر الحالي</label>
                            <input type="number" name="price" required placeholder="0" class="w-full bg-slate-900/50 border border-white/10 rounded-xl py-3 px-4 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all font-mono">
                        </div>
                        <div class="space-y-2">
                            <label class="text-xs font-bold text-slate-400">السعر الأصلي</label>
                            <input type="number" name="old_price" placeholder="0" class="w-full bg-slate-900/50 border border-white/10 rounded-xl py-3 px-4 text-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all font-mono">
                        </div>
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                        <div class="space-y-2">
                            <label class="text-xs font-bold text-slate-400">الكمية المتوفرة</label>
                            <input type="number" name="quantity" required value="10" class="w-full bg-slate-900/50 border border-white/10 rounded-xl py-3 px-4 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all font-mono">
                        </div>
                        <div class="space-y-2">
                            <label class="text-xs font-bold text-slate-400">تنبيه المخزون</label>
                            <input type="number" name="low_stock_threshold" value="5" class="w-full bg-slate-900/50 border border-white/10 rounded-xl py-3 px-4 text-amber-500 focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all font-mono">
                        </div>
                    </div>
                </div>

                <!-- Organization & Placement -->
                <div class="glass p-8 rounded-[2rem] border border-white/5 space-y-6">
                    <h3 class="text-lg font-bold text-white border-b border-white/5 pb-4">التنظيم والعرض</h3>
                    
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-400">التصنيف</label>
                        <select name="category_id" required class="w-full bg-slate-900 border border-white/10 rounded-xl py-3 px-4 text-white focus:outline-none appearance-none">
                            @foreach($categories as $category)
                                <option value="{{ $category->id }}">{{ $category->name_ar ?? $category->name }}</option>
                            @endforeach
                        </select>
                    </div>

                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-400">ماركة المنتج</label>
                        <select name="brand_id" class="w-full bg-slate-900 border border-white/10 rounded-xl py-3 px-4 text-white focus:outline-none appearance-none">
                            <option value="">غير محدد</option>
                            @foreach($brands as $brand)
                                <option value="{{ $brand->id }}">{{ $brand->name }}</option>
                            @endforeach
                        </select>
                    </div>

                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-400">مكان الظهور في الرئيسية</label>
                        <select name="home_section" class="w-full bg-slate-900 border border-amber-500/30 rounded-xl py-3 px-4 text-amber-500 focus:outline-none appearance-none font-bold">
                            <option value="none">بدون قسم خاص</option>
                            <option value="featured">المنتجات المميزة</option>
                            <option value="best_seller">الأكثر مبيعاً</option>
                            <option value="new_arrival">وصل حديثاً</option>
                        </select>
                    </div>

                    <div class="flex items-center justify-between p-4 bg-white/5 rounded-2xl border border-white/5">
                        <div class="space-y-0.5">
                            <p class="text-sm font-bold text-white">تفعيل المنتج</p>
                            <p class="text-[10px] text-slate-500">متاح للطلب الآن</p>
                        </div>
                        <label class="relative inline-flex items-center cursor-pointer">
                            <input type="checkbox" name="is_available" value="1" checked class="sr-only peer">
                            <div class="w-11 h-6 bg-slate-700 rounded-full peer peer-checked:after:-translate-x-full rtl:peer-checked:after:translate-x-full peer-checked:bg-amber-500 transition-all after:content-[''] after:absolute after:top-[2px] after:right-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all"></div>
                        </label>
                    </div>
                </div>

            </div>
        </div>

        <!-- Sticky Bottom Toolbar -->
        <div class="fixed bottom-0 left-0 right-0 p-6 bg-slate-950/80 backdrop-blur-xl border-t border-white/10 shadow-2xl z-[100] transform transition-transform duration-300">
            <div class="max-w-6xl mx-auto flex items-center justify-between">
                <div class="flex items-center gap-3">
                    <div class="flex -space-x-2">
                        <div class="w-8 h-8 rounded-full border-2 border-slate-950 bg-amber-500 flex items-center justify-center text-[10px] font-bold text-white">1</div>
                        <div class="w-8 h-8 rounded-full border-2 border-slate-950 bg-slate-800 flex items-center justify-center text-[10px] font-bold text-slate-400">2</div>
                        <div class="w-8 h-8 rounded-full border-2 border-slate-950 bg-slate-800 flex items-center justify-center text-[10px] font-bold text-slate-400">3</div>
                    </div>
                    <span class="text-xs font-bold text-slate-400 uppercase tracking-widest ml-4">Ready to Publish</span>
                </div>
                <div class="flex items-center gap-4">
                    <a href="{{ route('admin.products.index') }}" class="px-6 py-3 rounded-xl text-sm font-bold text-slate-400 hover:text-white transition-colors">إلغاء</a>
                    <button type="submit" class="bg-amber-500 hover:bg-amber-600 px-10 py-3 rounded-2xl text-sm font-bold shadow-xl shadow-amber-500/20 transition-all text-white active:scale-95">نشر المنتج في التطبيق</button>
                </div>
            </div>
        </div>
    </form>
</div>

<script>
function previewImage(input) {
    const preview = document.getElementById('image-preview');
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function(e) {
            preview.innerHTML = `<img src="${e.target.result}" class="w-full h-full object-contain">`;
        }
        reader.readAsDataURL(input.files[0]);
    }
}

function addFeature() {
    const container = document.getElementById('features-container');
    const div = document.createElement('div');
    div.className = 'flex gap-2 animate-fadeIn mb-3';
    div.innerHTML = `
        <input type="text" name="features[]" placeholder="ميزة إضافية..." class="flex-1 bg-slate-900/50 border border-white/10 rounded-xl py-3 px-4 text-white text-sm focus:outline-none focus:ring-1 focus:ring-amber-500/30 transition-all">
        <button type="button" onclick="this.parentElement.remove()" class="p-3 text-slate-500 hover:text-red-500 transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
        </button>
    `;
    container.appendChild(div);
}

function addSpec() {
    const container = document.getElementById('specs-container');
    const div = document.createElement('div');
    div.className = 'flex gap-2 animate-fadeIn mb-3';
    div.innerHTML = `
        <input type="text" name="spec_keys[]" placeholder="الخاصية" class="w-1/2 bg-slate-900/50 border border-white/10 rounded-xl py-3 px-4 text-white text-sm focus:outline-none focus:ring-1 focus:ring-blue-500/30 transition-all">
        <input type="text" name="spec_values[]" placeholder="القيمة" class="w-1/2 bg-slate-900/50 border border-white/10 rounded-xl py-3 px-4 text-white text-sm focus:outline-none focus:ring-1 focus:ring-blue-500/30 transition-all">
        <button type="button" onclick="this.parentElement.remove()" class="p-3 text-slate-500 hover:text-red-500 transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
        </button>
    `;
    container.appendChild(div);
}
</script>

<style>
@keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
}
.animate-fadeIn {
    animation: fadeIn 0.3s ease-out forwards;
}
</style>
@endsection
