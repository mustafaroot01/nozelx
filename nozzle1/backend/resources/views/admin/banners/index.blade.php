@extends('layouts.admin')

@section('content')
<div class="space-y-8">
    <!-- Header -->
    <div class="flex items-center justify-between">
        <div>
            <h2 class="text-3xl font-bold text-white tracking-tight">إدارة البانرات الإعلانية</h2>
            <p class="text-slate-400 text-sm mt-1">التحكم في الصور المتحركة في أعلى الصفحة الرئيسية للتطبيق.</p>
        </div>
        <a href="{{ route('admin.banners.create') }}" class="bg-amber-500 hover:bg-amber-600 px-6 py-3 rounded-xl text-sm font-bold shadow-lg shadow-amber-500/20 transition-all text-white flex items-center gap-2 group">
            <svg class="w-5 h-5 group-hover:rotate-90 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
            إضافة بانر جديد
        </a>
    </div>

    <!-- Stats/Advice -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="glass p-6 rounded-3xl border border-white/5 flex items-center gap-4">
            <div class="w-12 h-12 bg-blue-500/10 rounded-2xl flex items-center justify-center text-blue-500">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
            </div>
            <div>
                <p class="text-xs font-bold text-slate-500 uppercase tracking-wider">المقاس المثالي</p>
                <p class="text-lg font-bold text-white">1200 × 600 px</p>
            </div>
        </div>
        <div class="glass p-6 rounded-3xl border border-white/5 flex items-center gap-4">
            <div class="w-12 h-12 bg-amber-500/10 rounded-2xl flex items-center justify-center text-amber-500">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>
            </div>
            <div>
                <p class="text-xs font-bold text-slate-500 uppercase tracking-wider">البانرات النشطة</p>
                <p class="text-lg font-bold text-white">{{ $banners->where('is_active', true)->count() }} بانر</p>
            </div>
        </div>
        <div class="glass p-6 rounded-3xl border border-white/5 flex items-center gap-4">
            <div class="w-12 h-12 bg-purple-500/10 rounded-2xl flex items-center justify-center text-purple-500">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
            </div>
            <div>
                <p class="text-xs font-bold text-slate-500 uppercase tracking-wider">نصيحة التصميم</p>
                <p class="text-[10px] font-bold text-slate-400 leading-tight">تجنب وضع نصوص مهمة في حواف الصورة لتجنب القص.</p>
            </div>
        </div>
    </div>

    <!-- Banners Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
        @forelse($banners as $banner)
        <div class="glass group rounded-[2.5rem] overflow-hidden border border-white/5 shadow-2xl transition-all hover:scale-[1.02]">
            <div class="aspect-[2/1] relative overflow-hidden">
                <img src="{{ asset('storage/' . $banner->image) }}" class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110">
                <div class="absolute inset-0 bg-gradient-to-t from-slate-950 via-transparent to-transparent opacity-60"></div>
                
                <!-- Status Badge -->
                <div class="absolute top-6 right-6">
                    @if($banner->is_active)
                    <span class="bg-green-500 text-white text-[10px] font-bold px-3 py-1 rounded-full shadow-lg shadow-green-500/20">نشط الآن</span>
                    @else
                    <span class="bg-slate-700 text-slate-400 text-[10px] font-bold px-3 py-1 rounded-full border border-white/5">متوقف</span>
                    @endif
                </div>

                <!-- Actions Overlay -->
                <div class="absolute bottom-6 left-6 right-6 flex items-center justify-between">
                    <div class="space-y-1">
                        <h4 class="text-white font-bold text-lg">{{ $banner->title }}</h4>
                        <p class="text-slate-300 text-xs">{{ $banner->subtitle }}</p>
                    </div>
                    <div class="flex items-center gap-2">
                        @if($banner->link)
                            <div class="px-3 py-1 bg-white/10 rounded-lg text-[10px] text-white backdrop-blur">
                                <span class="text-slate-400">توجيه: </span>
                                {{ Str::title(explode('/', $banner->link)[0] ?? 'رابط') }}
                            </div>
                        @endif
                        <a href="{{ route('admin.banners.edit', $banner) }}" class="p-3 glass rounded-2xl text-white hover:bg-indigo-500 transition-all" title="تعديل">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                        </a>
                        <form action="{{ route('admin.banners.toggle', $banner) }}" method="POST">
                            @csrf
                            @method('PATCH')
                            <button type="submit" class="p-3 glass rounded-2xl text-white hover:bg-amber-500 transition-all" title="تغيير الحالة">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"/></svg>
                            </button>
                        </form>
                        <form action="{{ route('admin.banners.destroy', $banner) }}" method="POST" onsubmit="return confirm('هل أنت متأكد من الحذف؟')">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="p-3 glass rounded-2xl text-red-500 hover:bg-red-500 hover:text-white transition-all">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
        @empty
        <div class="md:col-span-2 glass p-20 rounded-[3rem] border border-white/5 text-center space-y-4">
            <div class="w-20 h-20 bg-slate-900 rounded-[2rem] flex items-center justify-center mx-auto text-slate-700">
                <svg class="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
            </div>
            <h3 class="text-xl font-bold text-white">لا يوجد بانرات حالياً</h3>
            <p class="text-slate-500 max-w-xs mx-auto">ابدأ بإضافة أول بانر إعلاني ليظهر في التطبيق لزبائنك.</p>
        </div>
        @endforelse
    </div>
</div>
@endsection
