@extends('layouts.admin')

@section('content')
<div class="max-w-6xl mx-auto space-y-8 pb-12">
    
    <!-- Page Header -->
    <div class="flex items-center justify-between">
        <div class="flex items-center gap-4">
            <a href="{{ route('admin.orders.index') }}" class="glass w-10 h-10 rounded-xl flex items-center justify-center hover:bg-white/10 transition-colors">
                <svg class="w-5 h-5 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
            </a>
            <div>
                <h2 class="text-3xl font-bold text-white tracking-tight flex items-center gap-3">
                    تفاصيل الطلب <span class="text-amber-500">#{{ $order->order_number ?? rand(10000, 99999) }}</span>
                </h2>
                <p class="text-slate-400">تاريخ الطلب: {{ $order->created_at->translatedFormat('j F Y - h:i a') }}</p>
            </div>
        </div>
        
        <div class="flex gap-4">
            <button class="glass px-4 py-2 rounded-xl text-sm font-semibold flex items-center gap-2 hover:bg-white/10 transition-colors">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/></svg>
                طباعة الفاتورة
            </button>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        <!-- Main Content (Items Table) -->
        <div class="lg:col-span-2 space-y-8">
            <div class="glass rounded-3xl overflow-hidden">
                <div class="p-6 border-b border-white/5 flex items-center justify-between">
                    <h3 class="text-lg font-bold text-white">العناصر المطلوبة</h3>
                    <span class="text-xs font-bold text-slate-500 uppercase tracking-widest">{{ $order->orderItems->count() }} منتج</span>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-right">
                        <thead>
                            <tr class="text-slate-500 text-[11px] font-bold uppercase tracking-widest border-b border-white/5">
                                <th class="py-4 pr-8">المنتج</th>
                                <th class="py-4 text-center">السعر</th>
                                <th class="py-4 text-center">الكمية</th>
                                <th class="py-4 pl-8 text-left">المجموع</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-white/5">
                            @foreach($order->orderItems as $item)
                            <tr class="group">
                                <td class="py-4 pr-8">
                                    <div class="flex items-center gap-4">
                                        <div class="w-12 h-12 rounded-xl bg-slate-800 overflow-hidden border border-white/10 group-hover:border-amber-500/30 transition-colors">
                                            <img src="{{ $item->product && $item->product->image ? asset('storage/'.$item->product->image) : 'https://placehold.co/100x100?text=P' }}" class="w-full h-full object-cover">
                                        </div>
                                        <div>
                                            <h4 class="text-sm font-bold text-white">{{ $item->product->name ?? 'منتج غير متوفر' }}</h4>
                                            <p class="text-[10px] text-slate-500">ID: #{{ $item->product_id }}</p>
                                        </div>
                                    </div>
                                </td>
                                <td class="py-4 text-center text-sm font-medium text-slate-300">
                                    {{ number_format($item->price) }} <span class="text-[10px] text-slate-500">IQD</span>
                                </td>
                                <td class="py-4 text-center text-sm font-bold text-white">
                                    × {{ $item->quantity }}
                                </td>
                                <td class="py-4 pl-8 text-left text-sm font-bold text-amber-500">
                                    {{ number_format($item->price * $item->quantity) }} <span class="text-[10px] font-normal uppercase">IQD</span>
                                </td>
                            </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Order Timeline / Notes -->
            <div class="glass p-8 rounded-3xl space-y-6">
                <h3 class="text-lg font-bold text-white border-b border-white/5 pb-4">ملاحظات الطلب</h3>
                <div class="p-4 bg-slate-900/50 rounded-xl border border-white/5">
                    <p class="text-sm text-slate-400 italic">
                        {{ $order->notes ?? 'لا توجد ملاحظات إضافية من الزبون لهذا الطلب.' }}
                    </p>
                </div>
            </div>
        </div>

        <!-- Sidebar (Customer & Status) -->
        <div class="space-y-8">
            
            <!-- Status Update Section -->
            <div class="glass p-8 rounded-3xl space-y-6">
                <h3 class="text-lg font-bold text-white border-b border-white/5 pb-4">حالة الطلب</h3>
                
                <form action="{{ route('admin.orders.updateStatus', $order) }}" method="POST" class="space-y-4">
                    @csrf
                    @method('PATCH')
                    <div class="space-y-2">
                        <label class="text-[11px] font-bold text-slate-500 uppercase tracking-widest">تحديث الحالة</label>
                        <select name="status" class="w-full bg-slate-900 border border-white/10 rounded-xl py-3 px-4 text-white focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all text-sm">
                            <option value="pending" {{ $order->status == 'pending' ? 'selected' : '' }}>قيد الانتظار</option>
                            <option value="processing" {{ $order->status == 'processing' ? 'selected' : '' }}>قيد التجهيز</option>
                            <option value="shipped" {{ $order->status == 'shipped' ? 'selected' : '' }}>تم الشحن</option>
                            <option value="delivered" {{ $order->status == 'delivered' ? 'selected' : '' }}>تم التوصيل</option>
                            <option value="cancelled" {{ $order->status == 'cancelled' ? 'selected' : '' }}>ملغي</option>
                        </select>
                    </div>
                    <button type="submit" class="w-full bg-amber-500 hover:bg-amber-600 py-3 rounded-xl text-sm font-bold shadow-lg shadow-amber-500/20 transition-all text-white">تحديث الحالة</button>
                </form>
            </div>

            <!-- Customer Info Section -->
            <div class="glass p-8 rounded-3xl space-y-6">
                <h3 class="text-lg font-bold text-white border-b border-white/5 pb-4">معلومات الزبون</h3>
                
                <div class="space-y-4">
                    <div class="flex items-center gap-4">
                        <div class="w-12 h-12 rounded-2xl bg-amber-500/10 flex items-center justify-center text-amber-500 font-bold">
                            {{ substr($order->user->name ?? 'G', 0, 1) }}
                        </div>
                        <div>
                            <p class="text-sm font-bold text-white">{{ $order->user->name ?? 'Guest' }}</p>
                            <p class="text-xs text-slate-500">{{ $order->user->email ?? 'لا يوجد بريد إلكتروني' }}</p>
                        </div>
                    </div>

                    <div class="space-y-3 pt-4">
                        <div class="flex items-start gap-3">
                            <svg class="w-5 h-5 text-slate-500 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"/></svg>
                            <span class="text-sm text-slate-300">{{ $order->user->phone ?? 'لا يتوفر رقم هاتف' }}</span>
                        </div>
                        <div class="flex items-start gap-3">
                            <svg class="w-5 h-5 text-slate-500 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
                            <span class="text-sm text-slate-300 leading-relaxed">{{ $order->address ?? 'العراق، محافظة بابل، الحلة' }}</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Total Calculation Section -->
            <div class="glass p-8 rounded-3xl space-y-4">
                <div class="flex items-center justify-between text-sm">
                    <span class="text-slate-500">المجموع الفرعي:</span>
                    <span class="text-white font-medium">{{ number_format($order->total_amount) }} IQD</span>
                </div>
                <div class="flex items-center justify-between text-sm">
                    <span class="text-slate-500">الضريبة (0%):</span>
                    <span class="text-white font-medium">0 IQD</span>
                </div>
                <div class="flex items-center justify-between text-sm">
                    <span class="text-slate-500">الشحن:</span>
                    <span class="text-white font-medium">{{ number_format($order->shipping_amount ?? 5000) }} IQD</span>
                </div>
                <div class="h-px bg-white/5 my-2"></div>
                <div class="flex items-center justify-between">
                    <span class="text-lg font-bold text-white">المجموع النهائي:</span>
                    <span class="text-xl font-black text-amber-500">{{ number_format($order->total_amount) }} <span class="text-xs font-bold uppercase">IQD</span></span>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
