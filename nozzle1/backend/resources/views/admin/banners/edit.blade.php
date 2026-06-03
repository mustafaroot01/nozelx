@extends('layouts.admin')

@section('content')
<div class="max-w-4xl mx-auto space-y-8">
    <!-- Header -->
    <div class="flex items-center justify-between border-b border-white/10 pb-6">
        <div>
            <h2 class="text-3xl font-bold text-white tracking-tight">تعديل البانر</h2>
            <p class="text-slate-400">تحديث معلومات البانر الإعلاني رقم #{{ $banner->id }}</p>
        </div>
        <a href="{{ route('admin.banners.index') }}" class="group flex items-center gap-2 text-slate-400 hover:text-white transition-colors">
            <svg class="w-5 h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5l7 7-7 7M5 5l7 7-7 7"/></svg>
            العودة للمقاييس
        </a>
    </div>

    <!-- Edit Form -->
    <form action="{{ route('admin.banners.update', $banner) }}" method="POST" enctype="multipart/form-data" class="space-y-8">
        @csrf
        @method('PUT')
        
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <!-- Left: Inputs -->
            <div class="md:col-span-2 space-y-6">
                <!-- Advice Box -->
                <div class="p-6 rounded-[2rem] bg-indigo-500/10 border border-indigo-500/20 space-y-3 relative overflow-hidden group">
                    <div class="absolute -right-4 -top-4 w-24 h-24 bg-indigo-500/10 rounded-full blur-3xl group-hover:bg-indigo-500/20 transition-all"></div>
                    <div class="flex items-center gap-3 text-indigo-400">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        <h4 class="font-bold text-sm tracking-widest uppercase">Size Guidance | نصيحة المقاس</h4>
                    </div>
                    <p class="text-white text-lg font-bold leading-relaxed">
                        1200x600 بكسل هو المقاس الذهبي.
                    </p>
                </div>

                <div class="glass p-8 rounded-[2.5rem] shadow-2xl border border-white/5 space-y-6">
                    <div>
                        <label class="block text-sm font-bold text-slate-400 mb-2 mr-1">العنوان الرئيسي</label>
                        <input type="text" name="title" value="{{ old('title', $banner->title) }}" required 
                            class="w-full bg-slate-900 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all">
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-slate-400 mb-2 mr-1">العنوان الفرعي (اختياري)</label>
                        <input type="text" name="subtitle" value="{{ old('subtitle', $banner->subtitle) }}" 
                            class="w-full bg-slate-900 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all">
                    </div>
                    
                    <div class="space-y-4">
                        <label class="block text-sm font-bold text-slate-400 mb-2 mr-1">نوع التوجيه (الرابط)</label>
                        @php
                            $link = $banner->link;
                            $linkType = 'none';
                            $linkVal = '';
                            if ($link) {
                                if (strpos($link, 'products/') === 0) {
                                    $linkType = 'product';
                                    $linkVal = str_replace('products/', '', $link);
                                } elseif (strpos($link, 'categories/') === 0) {
                                    $linkType = 'category';
                                    $linkVal = str_replace('categories/', '', $link);
                                } else {
                                    $linkType = 'custom';
                                    $linkVal = $link;
                                }
                            }
                        @endphp
                        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                            <label class="cursor-pointer group">
                                <input type="radio" name="link_type" value="none" {{ $linkType == 'none' ? 'checked' : '' }} class="peer sr-only" onchange="toggleLinkInputs('none')">
                                <div class="p-4 bg-slate-900 border border-white/5 rounded-2xl text-center group-hover:border-amber-500/30 peer-checked:border-amber-500 peer-checked:bg-amber-500/10 transition-all">
                                    <span class="block text-xs font-bold text-slate-300 peer-checked:text-amber-500">لا يوجد</span>
                                </div>
                            </label>
                            <label class="cursor-pointer group">
                                <input type="radio" name="link_type" value="product" {{ $linkType == 'product' ? 'checked' : '' }} class="peer sr-only" onchange="toggleLinkInputs('product')">
                                <div class="p-4 bg-slate-900 border border-white/5 rounded-2xl text-center group-hover:border-amber-500/30 peer-checked:border-amber-500 peer-checked:bg-amber-500/10 transition-all">
                                    <span class="block text-xs font-bold text-slate-300 peer-checked:text-amber-500">منتج</span>
                                </div>
                            </label>
                            <label class="cursor-pointer group">
                                <input type="radio" name="link_type" value="category" {{ $linkType == 'category' ? 'checked' : '' }} class="peer sr-only" onchange="toggleLinkInputs('category')">
                                <div class="p-4 bg-slate-900 border border-white/5 rounded-2xl text-center group-hover:border-amber-500/30 peer-checked:border-amber-500 peer-checked:bg-amber-500/10 transition-all">
                                    <span class="block text-xs font-bold text-slate-300 peer-checked:text-amber-500">قسم</span>
                                </div>
                            </label>
                            <label class="cursor-pointer group">
                                <input type="radio" name="link_type" value="custom" {{ $linkType == 'custom' ? 'checked' : '' }} class="peer sr-only" onchange="toggleLinkInputs('custom')">
                                <div class="p-4 bg-slate-900 border border-white/5 rounded-2xl text-center group-hover:border-amber-500/30 peer-checked:border-amber-500 peer-checked:bg-amber-500/10 transition-all">
                                    <span class="block text-xs font-bold text-slate-300 peer-checked:text-amber-500">رابط خارجي</span>
                                </div>
                            </label>
                        </div>

                        <!-- Product Selector -->
                        <div id="product-selector" class="{{ $linkType == 'product' ? '' : 'hidden' }} animate-in fade-in slide-in-from-top-2">
                            <label class="block text-xs font-bold text-slate-500 mb-2 mr-1">اختر المنتج</label>
                            <select id="product_id" class="w-full bg-slate-900 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all">
                                <option value="">-- اختر منتجاً --</option>
                                @foreach($products as $product)
                                    <option value="{{ $product->id }}" {{ ($linkType == 'product' && $linkVal == $product->id) ? 'selected' : '' }}>{{ $product->name_ar ?? $product->name }}</option>
                                @endforeach
                            </select>
                        </div>

                        <!-- Category Selector -->
                        <div id="category-selector" class="{{ $linkType == 'category' ? '' : 'hidden' }} animate-in fade-in slide-in-from-top-2">
                            <label class="block text-xs font-bold text-slate-500 mb-2 mr-1">اختر القسم</label>
                            <select id="category_id" class="w-full bg-slate-900 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all">
                                <option value="">-- اختر قسماً --</option>
                                @foreach($categories as $category)
                                    <option value="{{ $category->id }}" {{ ($linkType == 'category' && $linkVal == $category->id) ? 'selected' : '' }}>{{ $category->name_ar ?? $category->name }}</option>
                                @endforeach
                            </select>
                        </div>

                        <!-- Custom URL -->
                        <div id="custom-url" class="{{ $linkType == 'custom' ? '' : 'hidden' }} animate-in fade-in slide-in-from-top-2">
                            <label class="block text-xs font-bold text-slate-500 mb-2 mr-1">أدخل الرابط</label>
                            <input type="text" id="custom_link" value="{{ $linkType == 'custom' ? $linkVal : '' }}" placeholder="https://example.com" 
                                class="w-full bg-slate-900 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all">
                        </div>

                        <!-- Hidden Real Input for backend -->
                        <input type="hidden" name="link" id="final-link-value" value="{{ $banner->link }}">
                    </div>
                </div>
            </div>

            <!-- Right: Image Preview -->
            <div class="space-y-6">
                <div class="glass p-8 rounded-[2.5rem] shadow-2xl border border-white/5">
                    <label class="block text-sm font-bold text-slate-400 mb-4 mr-1">صورة البانر</label>
                    <div class="relative group cursor-pointer">
                        <div id="image-preview" class="aspect-[2/1] rounded-2xl bg-slate-900/50 border-2 border-dashed border-white/10 flex flex-col items-center justify-center p-4 group-hover:border-amber-500/50 transition-all overflow-hidden relative">
                            @if($banner->image)
                                <img src="{{ asset('storage/' . $banner->image) }}" class="w-full h-full object-cover">
                            @else
                                <div class="text-center p-6 space-y-2">
                                    <svg class="w-10 h-10 text-slate-600 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
                                    <p class="text-[10px] text-slate-500 font-bold uppercase tracking-widest text-center">انقر للتغيير</p>
                                </div>
                            @endif
                        </div>
                        <input type="file" name="image" class="absolute inset-0 opacity-0 cursor-pointer" accept="image/*" onchange="previewImage(this)">
                    </div>
                    <p class="text-center text-[10px] text-slate-500 mt-4 italic">كحد أقصى 2MB</p>
                </div>

                <div class="glass p-8 rounded-[2.5rem] border border-white/5">
                    <label class="flex items-center justify-between cursor-pointer group">
                        <div class="ml-4">
                            <span class="block text-sm font-bold text-white mr-1">تفعيل البانر</span>
                            <span class="block text-[10px] text-slate-500 mt-1 mr-1">يظهر للزبائن فور الحفظ</span>
                        </div>
                        <div class="relative inline-flex items-center cursor-pointer">
                            <input type="checkbox" name="is_active" class="sr-only peer" {{ $banner->is_active ? 'checked' : '' }} value="1">
                            <div class="w-14 h-8 bg-slate-800 rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:bg-amber-500 transition-all after:content-[''] after:absolute after:top-[4px] after:start-[4px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all"></div>
                        </div>
                    </label>
                </div>

                <button type="submit" class="w-full bg-amber-500 hover:bg-amber-600 px-8 py-5 rounded-2xl text-sm font-bold shadow-lg shadow-amber-500/20 transition-all text-white flex items-center justify-center gap-2 group">
                    تحديث البانر النشط
                    <svg class="w-5 h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
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

document.getElementById('product_id').addEventListener('change', updateFinalLink);
document.getElementById('category_id').addEventListener('change', updateFinalLink);
document.getElementById('custom_link').addEventListener('input', updateFinalLink);
</script>
@endsection
