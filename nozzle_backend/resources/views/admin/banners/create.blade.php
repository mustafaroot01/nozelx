@extends('layouts.admin')

@section('content')
<div class="max-w-4xl mx-auto space-y-8">
    <!-- Header -->
    <div class="flex items-center justify-between border-b border-white/10 pb-6">
        <div>
            <h2 class="text-3xl font-bold text-white tracking-tight">إضافة بانر إعلاني</h2>
            <p class="text-slate-400">تحميل الصور الترويجية التي ستظهر في أعلى التطبيق.</p>
        </div>
        <a href="{{ route('admin.banners.index') }}" class="group flex items-center gap-2 text-slate-400 hover:text-white transition-colors">
            <svg class="w-5 h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5l7 7-7 7M5 5l7 7-7 7"/></svg>
            العودة للمقاييس
        </a>
    </div>

    <!-- Create Form -->
    <form action="{{ route('admin.banners.store') }}" method="POST" enctype="multipart/form-data" class="space-y-8">
        @csrf
        
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <!-- Left: Inputs -->
            <div class="md:col-span-2 space-y-6">
                <!-- Advice Box (USER REQUESTED) -->
                <div class="p-6 rounded-[2rem] bg-indigo-500/10 border border-indigo-500/20 space-y-3 relative overflow-hidden group">
                    <div class="absolute -right-4 -top-4 w-24 h-24 bg-indigo-500/10 rounded-full blur-3xl group-hover:bg-indigo-500/20 transition-all"></div>
                    <div class="flex items-center gap-3 text-indigo-400">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        <h4 class="font-bold text-sm tracking-widest uppercase">Size Guidance | نصيحة المقاس</h4>
                    </div>
                    <p class="text-white text-lg font-bold leading-relaxed">
                        يرجى استخدام صور بعرض <span class="text-indigo-400">1200 بكسل</span> وارتفاع <span class="text-indigo-400">600 بكسل</span>.
                    </p>
                    <p class="text-indigo-300/60 text-[10px] font-medium leading-relaxed">
                        هذا المقاس يضمن ظهور البانر بشكل كامل واحترافي على جميع شاشات الهواتف (iPhone & Android) دون قص الأطراف.
                    </p>
                </div>

                <div class="glass p-8 rounded-[2.5rem] shadow-2xl border border-white/5 space-y-6">
                    <div>
                        <label class="block text-sm font-bold text-slate-400 mb-2 mr-1">العنوان الرئيسي</label>
                        <input type="text" name="title" required placeholder="مثلاً: خصومات العيد، زيوت موتول..." 
                            class="w-full bg-slate-900 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all">
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-slate-400 mb-2 mr-1">العنوان الفرعي (اختياري)</label>
                        <input type="text" name="subtitle" placeholder="مثلاً: بأسعار تنافسية لفترة محدودة" 
                            class="w-full bg-slate-900 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all">
                    </div>
                    <div class="space-y-4">
                        <label class="block text-sm font-bold text-slate-400 mb-2 mr-1">نوع التوجيه (الرابط)</label>
                        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                            <label class="cursor-pointer group">
                                <input type="radio" name="link_type" value="none" checked class="peer sr-only" onchange="toggleLinkInputs('none')">
                                <div class="p-4 bg-slate-900 border border-white/5 rounded-2xl text-center group-hover:border-amber-500/30 peer-checked:border-amber-500 peer-checked:bg-amber-500/10 transition-all">
                                    <span class="block text-xs font-bold text-slate-300 peer-checked:text-amber-500">لا يوجد</span>
                                </div>
                            </label>
                            <label class="cursor-pointer group">
                                <input type="radio" name="link_type" value="product" class="peer sr-only" onchange="toggleLinkInputs('product')">
                                <div class="p-4 bg-slate-900 border border-white/5 rounded-2xl text-center group-hover:border-amber-500/30 peer-checked:border-amber-500 peer-checked:bg-amber-500/10 transition-all">
                                    <span class="block text-xs font-bold text-slate-300 peer-checked:text-amber-500">منتج</span>
                                </div>
                            </label>
                            <label class="cursor-pointer group">
                                <input type="radio" name="link_type" value="category" class="peer sr-only" onchange="toggleLinkInputs('category')">
                                <div class="p-4 bg-slate-900 border border-white/5 rounded-2xl text-center group-hover:border-amber-500/30 peer-checked:border-amber-500 peer-checked:bg-amber-500/10 transition-all">
                                    <span class="block text-xs font-bold text-slate-300 peer-checked:text-amber-500">قسم</span>
                                </div>
                            </label>
                            <label class="cursor-pointer group">
                                <input type="radio" name="link_type" value="custom" class="peer sr-only" onchange="toggleLinkInputs('custom')">
                                <div class="p-4 bg-slate-900 border border-white/5 rounded-2xl text-center group-hover:border-amber-500/30 peer-checked:border-amber-500 peer-checked:bg-amber-500/10 transition-all">
                                    <span class="block text-xs font-bold text-slate-300 peer-checked:text-amber-500">رابط خارجي</span>
                                </div>
                            </label>
                        </div>

                        <!-- Product Selector -->
                        <div id="product-selector" class="hidden animate-in fade-in slide-in-from-top-2">
                            <label class="block text-xs font-bold text-slate-500 mb-2 mr-1">اختر المنتج</label>
                            <select id="product_id" class="w-full bg-slate-900 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all">
                                <option value="">-- اختر منتجاً --</option>
                                @foreach($products as $product)
                                    <option value="{{ $product->id }}">{{ $product->name_ar ?? $product->name }}</option>
                                @endforeach
                            </select>
                        </div>

                        <!-- Category Selector -->
                        <div id="category-selector" class="hidden animate-in fade-in slide-in-from-top-2">
                            <label class="block text-xs font-bold text-slate-500 mb-2 mr-1">اختر القسم</label>
                            <select id="category_id" class="w-full bg-slate-900 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all">
                                <option value="">-- اختر قسماً --</option>
                                @foreach($categories as $category)
                                    <option value="{{ $category->id }}">{{ $category->name_ar ?? $category->name }}</option>
                                @endforeach
                            </select>
                        </div>

                        <!-- Custom URL -->
                        <div id="custom-url" class="hidden animate-in fade-in slide-in-from-top-2">
                            <label class="block text-xs font-bold text-slate-500 mb-2 mr-1">أدخل الرابط</label>
                            <input type="text" id="custom_link" placeholder="https://example.com" 
                                class="w-full bg-slate-900 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all">
                        </div>

                        <!-- Hidden Real Input for backend -->
                        <input type="hidden" name="link" id="final-link-value">
                    </div>
                </div>
            </div>

            <!-- Right: Image Preview -->
            <div class="space-y-6">
                <div class="glass p-8 rounded-[2.5rem] shadow-2xl border border-white/5">
                    <label class="block text-sm font-bold text-slate-400 mb-4 mr-1">صورة البانر</label>
                    <div class="relative group cursor-pointer">
                        <div id="image-preview" class="aspect-[2/1] rounded-2xl bg-slate-900/50 border-2 border-dashed border-white/10 flex flex-col items-center justify-center p-4 group-hover:border-amber-500/50 transition-all overflow-hidden relative">
                            <div class="text-center p-6 space-y-2">
                                <svg class="w-10 h-10 text-slate-600 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
                                <p class="text-[10px] text-slate-500 font-bold uppercase tracking-widest text-center">انقر للتحميل</p>
                            </div>
                        </div>
                        <input type="file" name="image" required class="absolute inset-0 opacity-0 cursor-pointer" accept="image/*" onchange="previewImage(this)">
                    </div>
                </div>

                <div class="glass p-8 rounded-[2.5rem] border border-white/5">
                    <label class="flex items-center justify-between cursor-pointer group">
                        <div class="ml-4">
                            <span class="block text-sm font-bold text-white mr-1">تفعيل البانر</span>
                            <span class="block text-[10px] text-slate-500 mt-1 mr-1">يظهر للزبائن فور الحفظ</span>
                        </div>
                        <div class="relative inline-flex items-center cursor-pointer">
                            <input type="checkbox" name="is_active" class="sr-only peer" checked value="1">
                            <div class="w-14 h-8 bg-slate-800 rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:bg-amber-500 transition-all after:content-[''] after:absolute after:top-[4px] after:start-[4px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all"></div>
                        </div>
                    </label>
                </div>

                <button type="submit" class="w-full bg-amber-500 hover:bg-amber-600 px-8 py-5 rounded-2xl text-sm font-bold shadow-lg shadow-amber-500/20 transition-all text-white flex items-center justify-center gap-2 group">
                    حفظ ونشر البانر
                    <svg class="w-5 h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
                </button>
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
            preview.innerHTML = `<img src="${e.target.result}" class="w-full h-full object-cover">`;
        }
        reader.readAsDataURL(input.files[0]);
    }
}

function toggleLinkInputs(type) {
    document.getElementById('product-selector').classList.add('hidden');
    document.getElementById('category-selector').classList.add('hidden');
    document.getElementById('custom-url').classList.add('hidden');
    
    if (type === 'product') document.getElementById('product-selector').classList.remove('hidden');
    if (type === 'category') document.getElementById('category-selector').classList.remove('hidden');
    if (type === 'custom') document.getElementById('custom-url').classList.remove('hidden');
    
    updateFinalLink();
}

function updateFinalLink() {
    const type = document.querySelector('input[name="link_type"]:checked').value;
    const finalInput = document.getElementById('final-link-value');
    
    if (type === 'none') {
        finalInput.value = '';
    } else if (type === 'product') {
        const id = document.getElementById('product_id').value;
        finalInput.value = id ? `products/${id}` : '';
    } else if (type === 'category') {
        const id = document.getElementById('category_id').value;
        finalInput.value = id ? `categories/${id}` : '';
    } else if (type === 'custom') {
        finalInput.value = document.getElementById('custom_link').value;
    }
}

// Add event listeners to update final link on change
document.getElementById('product_id').addEventListener('change', updateFinalLink);
document.getElementById('category_id').addEventListener('change', updateFinalLink);
document.getElementById('custom_link').addEventListener('input', updateFinalLink);
</script>
@endsection
