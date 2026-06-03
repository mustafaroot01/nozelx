@extends('layouts.admin')

@section('content')
<div class="max-w-4xl mx-auto space-y-8">
    
    <!-- Page Header -->
    <div class="flex items-center justify-between border-b border-white/10 pb-6">
        <div>
            <h2 class="text-3xl font-bold text-white tracking-tight">إضافة تصنيف جديد</h2>
            <p class="text-slate-400">أدخل البيانات المطلوبة لإنشاء قسم جديد للمنتجات.</p>
        </div>
        <a href="{{ route('admin.categories.index') }}" class="group flex items-center gap-2 text-slate-400 hover:text-white transition-colors">
            <svg class="w-5 h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5l7 7-7 7M5 5l7 7-7 7"/></svg>
            العودة للقائمة
        </a>
    </div>

    <!-- Create Form -->
    <form action="{{ route('admin.categories.store') }}" method="POST" enctype="multipart/form-data" class="space-y-6">
        @csrf
        
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <!-- Left Column: Basic Info -->
            <div class="md:col-span-2 space-y-6">
                <div class="glass p-8 rounded-[2.5rem] shadow-2xl border border-white/5 space-y-6">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label for="name" class="block text-sm font-bold text-slate-400 mb-2 mr-1">الاسم (بالإنجليزي)</label>
                            <input type="text" name="name" id="name" required placeholder="مثلاً: Engine Oils" 
                                class="w-full bg-slate-900 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 focus:border-amber-500 transition-all">
                            @error('name') <p class="mt-2 text-red-500 text-xs">{{ $message }}</p> @enderror
                        </div>
                        <div>
                            <label for="name_ar" class="block text-sm font-bold text-slate-400 mb-2 mr-1">الاسم (بالعربي)</label>
                            <input type="text" name="name_ar" id="name_ar" required placeholder="مثلاً: زيوت المحركات" 
                                class="w-full bg-slate-900 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 focus:border-amber-500 transition-all">
                            @error('name_ar') <p class="mt-2 text-red-500 text-xs">{{ $message }}</p> @enderror
                        </div>
                    </div>

                    <div>
                        <label for="parent_id" class="block text-sm font-bold text-slate-400 mb-2 mr-1">التصنيف الرئيسي (اختياري)</label>
                        <select name="parent_id" id="parent_id" 
                            class="w-full bg-slate-900 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 focus:border-amber-500 transition-all appearance-none">
                            <option value="">تحديد كتصنيف رئيسي</option>
                            @foreach($parentCategories as $parent)
                                <option value="{{ $parent->id }}">{{ $parent->name_ar ?? $parent->name }}</option>
                            @endforeach
                        </select>
                        <p class="mt-2 text-[10px] text-slate-500 mr-2 font-medium">إذا اخترت تصنيفاً رئيسياً، فسيعتبر هذا التصنيف فرعياً بداخلة.</p>
                    </div>

                    <div>
                        <label for="description" class="block text-sm font-bold text-slate-400 mb-2 mr-1">وصف القسم (اختياري)</label>
                        <textarea name="description" id="description" rows="4" placeholder="اكتب وصفاً مختصراً لهذا القسم..." 
                            class="w-full bg-slate-900 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 focus:border-amber-500 transition-all"></textarea>
                    </div>
                </div>
            </div>

            <!-- Right Column: Image Upload -->
            <div class="space-y-6">
                <div class="glass p-8 rounded-[2.5rem] shadow-2xl border border-white/5">
                    <label class="block text-sm font-bold text-slate-400 mb-4 mr-1">صورة التصنيف</label>
                    
                    <div class="relative group cursor-pointer">
                        <div id="image-preview" class="aspect-square rounded-3xl bg-slate-900/50 border-2 border-dashed border-white/10 flex flex-col items-center justify-center gap-3 group-hover:border-amber-500/50 transition-all overflow-hidden relative">
                            <div class="text-center p-6 space-y-2">
                                <svg class="w-10 h-10 text-slate-600 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
                                <p class="text-[10px] text-slate-500 font-bold uppercase tracking-widest">تحميل صورة</p>
                            </div>
                        </div>
                        <input type="file" name="image" id="image-input" class="absolute inset-0 opacity-0 cursor-pointer" accept="image/*" onchange="previewImage(this)">
                    </div>
                    @error('image') <p class="mt-2 text-red-500 text-xs">{{ $message }}</p> @enderror

                    <div class="mt-4 p-4 rounded-2xl bg-amber-500/5 border border-amber-500/10">
                        <p class="text-[10px] text-amber-500/80 leading-relaxed font-bold">
                            <svg class="w-3 h-3 inline-block ml-1" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/></svg>
                            يفضل استخدام صور مربعة (1:1) وبحجم لا يتجاوز 2 ميجابايت.
                        </p>
                    </div>
                </div>

                <!-- Status Toggle -->
                <div class="glass p-8 rounded-[2.5rem] shadow-2xl border border-white/5">
                    <label class="flex items-center justify-between cursor-pointer group">
                        <div class="ml-4">
                            <span class="block text-sm font-bold text-slate-400 mr-1">حالة التصنيف</span>
                            <span class="block text-[10px] text-slate-500 mt-1 mr-1">تفعيل أو إيقاف القسم في التطبيق.</span>
                        </div>
                        <div class="relative inline-flex items-center cursor-pointer">
                            <input type="checkbox" name="is_active" class="sr-only peer" checked value="1">
                            <div class="w-14 h-8 bg-slate-800 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[4px] after:start-[4px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-amber-500 transition-all"></div>
                        </div>
                    </label>
                </div>

                <div class="flex flex-col gap-3 pt-6">
                    <button type="submit" class="w-full bg-amber-500 hover:bg-amber-600 px-8 py-5 rounded-2xl text-sm font-bold shadow-lg shadow-amber-500/20 transition-all text-white flex items-center justify-center gap-2 group">
                        حفظ التصنيف الجديد
                        <svg class="w-5 h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
                    </button>
                    <button type="reset" class="w-full border border-white/10 hover:bg-white/5 px-8 py-4 rounded-2xl text-xs font-bold transition-all text-slate-400">
                        إعادة تعيين الحقول
                    </button>
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
            preview.innerHTML = `<img src="${e.target.result}" class="w-full h-full object-cover">`;
        }
        reader.readAsDataURL(input.files[0]);
    }
}
</script>
@endsection
