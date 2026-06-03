@extends('layouts.admin')

@section('content')
<div class="space-y-8">
    
    <!-- Page Header -->
    <div class="flex items-center justify-between">
        <div>
            <h2 class="text-3xl font-bold text-white tracking-tight">إدارة المنتجات</h2>
            <p class="text-slate-400">إدارة المخزون، الأسعار، وحالة المنتجات في متجرك.</p>
        </div>
        <a href="{{ route('admin.products.create') }}" class="bg-amber-500 hover:bg-amber-600 px-6 py-3 rounded-xl text-sm font-bold flex items-center gap-2 shadow-lg shadow-amber-500/20 transition-all text-white">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
            إضافة منتج جديد
        </a>
    </div>

    <!-- Filters & Search -->
    <div class="glass p-6 rounded-2xl flex flex-wrap gap-4 items-center justify-between">
        <div class="flex flex-wrap gap-4 items-center">
            <div class="relative">
                <input type="text" placeholder="بحث عن منتج..." class="bg-slate-800 border border-white/10 rounded-lg py-2 pr-10 pl-4 text-sm focus:outline-none focus:ring-2 focus:ring-amber-500/50 w-72 text-slate-300">
                <svg class="w-4 h-4 text-slate-500 absolute right-3 top-1/2 -translate-y-1/2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
            </div>
            <select class="bg-slate-800 border border-white/10 rounded-lg py-2 px-4 text-sm focus:outline-none text-slate-300">
                <option>جميع التصنيفات</option>
            </select>
            <select class="bg-slate-800 border border-white/10 rounded-lg py-2 px-4 text-sm focus:outline-none text-slate-300">
                <option>الحالة: الكل</option>
                <option>نشط</option>
                <option>غير نشط</option>
            </select>
        </div>
        <div class="text-slate-500 text-xs font-bold">
            عرض {{ $products->count() }} من إجمالي {{ $products->total() }} منتج
        </div>
    </div>

    <!-- Products Table -->
    <div class="glass overflow-hidden rounded-3xl">
        <table class="w-full text-right">
            <thead class="bg-white/5">
                <tr class="text-slate-500 text-[11px] font-bold uppercase tracking-widest border-b border-white/10">
                    <th class="py-4 pr-8">المنتج</th>
                    <th class="py-4">التصنيف</th>
                    <th class="py-4 text-center">السعر</th>
                    <th class="py-4 text-center">الكمية</th>
                    <th class="py-4 text-center">الحالة</th>
                    <th class="py-4 pl-8 text-left">إجراءات</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-white/5">
                @foreach($products as $product)
                <tr class="hover:bg-white/5 transition-colors group">
                    <td class="py-5 pr-8">
                        <div class="flex items-center gap-4">
                            <div class="w-14 h-14 rounded-2xl bg-slate-800 overflow-hidden border border-white/10 group-hover:border-amber-500/50 transition-colors">
                                <img src="{{ $product->image ? asset('storage/'.$product->image) : 'https://placehold.co/100x100?text=Product' }}" alt="{{ $product->name }}" class="w-full h-full object-cover">
                            </div>
                            <div>
                                <h4 class="text-sm font-bold text-white">{{ $product->name }}</h4>
                                <p class="text-[10px] text-slate-500 mt-0.5">ID: #{{ $product->id }}</p>
                            </div>
                        </div>
                    </td>
                    <td class="py-5">
                        <span class="px-3 py-1 bg-slate-800 rounded-lg text-xs font-medium text-slate-300 border border-white/5">
                            {{ $product->category->name ?? 'D' }}
                        </span>
                    </td>
                    <td class="py-5 text-center">
                        <span class="text-sm font-bold text-white">{{ number_format($product->price) }}</span>
                        <span class="text-[10px] text-slate-500 font-bold block">IQD</span>
                    </td>
                    <td class="py-5 text-center">
                        <div class="flex items-center justify-center gap-1.5">
                            <span class="w-2 h-2 rounded-full {{ $product->quantity > 5 ? 'bg-green-500' : 'bg-red-500' }}"></span>
                            <span class="text-sm font-bold text-slate-200">{{ $product->quantity }}</span>
                        </div>
                    </td>
                    <td class="py-5 text-center">
                        <span class="px-2.5 py-1 rounded-full text-[10px] font-bold {{ $product->is_active ? 'bg-green-500/10 text-green-500' : 'bg-red-500/10 text-red-500' }}">
                            {{ $product->is_active ? 'نشط' : 'معطل' }}
                        </span>
                    </td>
                    <td class="py-5 pl-8 text-left">
                        <div class="flex items-center justify-end gap-2">
                            <button class="w-9 h-9 flex items-center justify-center rounded-lg bg-slate-800 text-slate-400 hover:text-white hover:bg-slate-700 transition-all border border-white/5">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"/></svg>
                            </button>
                            <button class="w-9 h-9 flex items-center justify-center rounded-lg bg-slate-800 text-slate-400 hover:text-red-500 hover:bg-red-500/10 transition-all border border-white/5">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                            </button>
                        </div>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>

        <!-- Pagination -->
        <div class="p-6 bg-white/5 border-t border-white/5">
            {{ $products->links() }}
        </div>
    </div>
</div>
@endsection
