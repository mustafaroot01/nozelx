@extends('layouts.admin')

@section('content')
<div class="space-y-8">
    
    <!-- Page Header -->
    <div class="flex items-center justify-between">
        <div>
            <h2 class="text-3xl font-bold text-white tracking-tight">التصنيفات</h2>
            <p class="text-slate-400">تنظيم المنتجات في مجموعات لتسهيل عملية التسوق والبحث.</p>
        </div>
        <a href="{{ route('admin.categories.create') }}" class="bg-amber-500 hover:bg-amber-600 px-6 py-3 rounded-xl text-sm font-bold flex items-center gap-2 shadow-lg shadow-amber-500/20 transition-all text-white">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
            إضافة تصنيف جديد
        </a>
    </div>

    <!-- Categories Grid/Table -->
    <div class="glass overflow-hidden rounded-3xl">
        <table class="w-full text-right">
            <thead class="bg-white/5">
                <tr class="text-slate-500 text-[11px] font-bold uppercase tracking-widest border-b border-white/10">
                    <th class="py-4 pr-8">التصنيف</th>
                    <th class="py-4">المنتجات</th>
                    <th class="py-4 text-left">عدد الأقسام الفرعية</th>
                    <th class="py-4 pl-8 text-left">إجراءات</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-white/5">
                @foreach($categories as $parent)
                    <!-- Parent Category -->
                    <tr class="hover:bg-white/5 transition-colors group">
                        <td class="py-5 pr-8">
                            <div class="flex items-center gap-4">
                                <div class="w-12 h-12 rounded-2xl bg-slate-800 overflow-hidden border border-white/10 group-hover:border-amber-500/50 transition-colors">
                                    <img src="{{ $parent->image ? asset('storage/'.$parent->image) : 'https://placehold.co/100x100?text='.$parent->name }}" alt="{{ $parent->name }}" class="w-full h-full object-cover">
                                </div>
                                <div>
                                    <h4 class="text-sm font-bold text-white">{{ $parent->name_ar ?? $parent->name }}</h4>
                                    <p class="text-[10px] text-slate-500 tracking-wider font-mono">/{{ $parent->slug }}</p>
                                </div>
                            </div>
                        </td>
                        <td class="py-5">
                            <div class="flex items-center gap-2">
                                <div class="bg-indigo-500/10 text-indigo-400 px-2 py-0.5 rounded text-[10px] font-bold border border-indigo-500/20">
                                    {{ $parent->products_count }} منتج
                                </div>
                            </div>
                        </td>
                        <td class="py-5 text-left">
                            <span class="bg-amber-500/10 text-amber-500 px-3 py-1 rounded-full text-[10px] font-bold border border-amber-500/20">
                                {{ $parent->sub_categories_count }} قسم فرعي
                            </span>
                        </td>
                        <td class="py-5 pl-8 text-left">
                            <div class="flex items-center justify-end gap-2">
                                <!-- Toggle Status -->
                                <form action="{{ route('admin.categories.toggle', $parent) }}" method="POST">
                                    @csrf
                                    @method('PATCH')
                                    <button type="submit" class="w-9 h-9 flex items-center justify-center rounded-lg {{ $parent->is_active ? 'bg-green-500/10 text-green-500' : 'bg-slate-800 text-slate-500' }} hover:bg-green-500 hover:text-white transition-all border border-white/5" title="{{ $parent->is_active ? 'تعطيل' : 'تفعيل' }}">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                                    </button>
                                </form>

                                <a href="{{ route('admin.categories.edit', $parent) }}" class="w-9 h-9 flex items-center justify-center rounded-lg bg-slate-800 text-slate-400 hover:text-white hover:bg-slate-700 transition-all border border-white/5">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"/></svg>
                                </a>
                                <form action="{{ route('admin.categories.destroy', $parent) }}" method="POST" onsubmit="return confirm('هل أنت متأكد من الحذف؟')">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="w-9 h-9 flex items-center justify-center rounded-lg bg-slate-800 text-slate-400 hover:text-red-500 hover:bg-red-500/10 transition-all border border-white/5">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>

                    <!-- Child Categories -->
                    @foreach($parent->subCategories as $child)
                    <tr class="bg-white/[0.02] hover:bg-white/5 transition-colors group">
                        <td class="py-4 pr-16">
                            <div class="flex items-center gap-3">
                                <div class="w-2 h-2 rounded-full bg-amber-500/30 group-hover:bg-amber-500 transition-colors"></div>
                                <div class="w-8 h-8 rounded-xl bg-slate-900 overflow-hidden border border-white/5">
                                    <img src="{{ $child->image ? asset('storage/'.$child->image) : 'https://placehold.co/100x100?text='.$child->name }}" alt="{{ $child->name }}" class="w-full h-full object-cover opacity-60">
                                </div>
                                <div>
                                    <h4 class="text-xs font-bold text-slate-300 group-hover:text-white transition-colors">{{ $child->name_ar ?? $child->name }}</h4>
                                    <p class="text-[9px] text-slate-600 tracking-wider">فرعي لـ {{ $parent->name }}</p>
                                </div>
                            </div>
                        </td>
                        <td class="py-4">
                            <div class="text-[9px] text-slate-500 font-bold px-2 py-0.5 rounded bg-slate-800 w-fit">
                                {{ $child->products()->count() }} منتج
                            </div>
                        </td>
                        <td class="py-4 text-left text-slate-600 text-[10px] italic">
                            قسم نهائي
                        </td>
                        <td class="py-4 pl-8 text-left">
                            <div class="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-all">
                                <!-- Toggle Status -->
                                <form action="{{ route('admin.categories.toggle', $child) }}" method="POST">
                                    @csrf
                                    @method('PATCH')
                                    <button type="submit" class="w-7 h-7 flex items-center justify-center rounded-lg {{ $child->is_active ? 'bg-green-500/10 text-green-500' : 'bg-slate-800 text-slate-500' }} hover:bg-green-500 hover:text-white transition-all border border-white/5" title="{{ $child->is_active ? 'تعطيل' : 'تفعيل' }}">
                                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                                    </button>
                                </form>

                                <a href="{{ route('admin.categories.edit', $child) }}" class="w-7 h-7 flex items-center justify-center rounded-lg bg-slate-800 text-slate-500 hover:text-white hover:bg-indigo-500 transition-all">
                                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"/></svg>
                                </a>
                                <form action="{{ route('admin.categories.destroy', $child) }}" method="POST" onsubmit="return confirm('هل أنت متأكد من الحذف؟')">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="w-7 h-7 flex items-center justify-center rounded-lg bg-slate-800 text-slate-500 hover:text-white hover:bg-red-500 transition-all">
                                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    @endforeach
                @endforeach
            </tbody>
        </table>

        <!-- Pagination -->
        <div class="p-6 bg-white/5 border-t border-white/5">
            {{ $categories->links() }}
        </div>
    </div>
</div>
@endsection
