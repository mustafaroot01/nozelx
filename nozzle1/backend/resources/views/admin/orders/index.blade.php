@extends('layouts.admin')

@section('content')
<div class="space-y-8">
    
    <!-- Page Header -->
    <div class="flex items-center justify-between">
        <div>
            <h2 class="text-3xl font-bold text-white tracking-tight">إدارة الطلبيات</h2>
            <p class="text-slate-400">متابعة المبيعات، تحديث حالات الشحن، وإدارة طلبات الزبائن.</p>
        </div>
        <div class="flex gap-4">
            <button class="glass px-4 py-2 rounded-lg text-sm font-semibold flex items-center gap-2 hover:bg-white/10 transition-colors">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                تصدير PDF
            </button>
        </div>
    </div>

    <!-- Filters -->
    <div class="glass p-6 rounded-2xl flex flex-wrap gap-4 items-center justify-between">
        <div class="flex flex-wrap gap-4 items-center">
            <div class="relative">
                <input type="text" placeholder="رقم الطلب أو اسم الزبون..." class="bg-slate-800 border border-white/10 rounded-lg py-2 pr-10 pl-4 text-sm focus:outline-none focus:ring-2 focus:ring-amber-500/50 w-72 text-slate-300">
                <svg class="w-4 h-4 text-slate-500 absolute right-3 top-1/2 -translate-y-1/2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
            </div>
            <select class="bg-slate-800 border border-white/10 rounded-lg py-2 px-4 text-sm focus:outline-none text-slate-300">
                <option>جميع الحالات</option>
                <option>قيد الانتظار</option>
                <option>قيد التجهيز</option>
                <option>تم الشحن</option>
                <option>تم التوصيل</option>
                <option>ملغي</option>
            </select>
        </div>
    </div>

    <!-- Orders Table -->
    <div class="glass overflow-hidden rounded-3xl">
        <table class="w-full text-right">
            <thead class="bg-white/5">
                <tr class="text-slate-500 text-[11px] font-bold uppercase tracking-widest border-b border-white/10">
                    <th class="py-4 pr-8">الطلب</th>
                    <th class="py-4">الزبون</th>
                    <th class="py-4">التاريخ</th>
                    <th class="py-4 text-center">الحالة</th>
                    <th class="py-4 text-left">المجموع</th>
                    <th class="py-4 pl-8 text-left">إجراءات</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-white/5">
                @foreach($orders as $order)
                <tr class="hover:bg-white/5 transition-colors group">
                    <td class="py-5 pr-8">
                        <div class="flex flex-col">
                            <span class="text-sm font-bold text-white tracking-widest">#{{ $order->order_number ?? rand(10000, 99999) }}</span>
                            <span class="text-[10px] text-slate-500 font-bold uppercase tracking-widest mt-0.5">{{ $order->orderItems->count() }} عناصر</span>
                        </div>
                    </td>
                    <td class="py-5">
                        <div class="flex items-center gap-3">
                            <div class="w-9 h-9 rounded-xl bg-slate-800 flex items-center justify-center text-amber-500 font-bold text-xs border border-white/5 shadow-inner">
                                {{ substr($order->user->name ?? 'G', 0, 1) }}
                            </div>
                            <div class="flex flex-col">
                                <span class="text-sm font-semibold text-slate-200">{{ $order->user->name ?? 'Guest' }}</span>
                                <span class="text-[10px] text-slate-500">{{ $order->user->phone ?? 'لا يتوفر رقم' }}</span>
                            </div>
                        </div>
                    </td>
                    <td class="py-5">
                        <div class="flex flex-col">
                            <span class="text-sm text-slate-300">{{ $order->created_at->format('Y/m/d') }}</span>
                            <span class="text-[10px] text-slate-500">{{ $order->created_at->format('H:i') }}</span>
                        </div>
                    </td>
                    <td class="py-5 text-center">
                        @php
                            $statusMap = [
                                'pending' => ['label' => 'قيد الانتظار', 'color' => 'amber'],
                                'processing' => ['label' => 'قيد التجهيز', 'color' => 'blue'],
                                'shipped' => ['label' => 'تم الشحن', 'color' => 'purple'],
                                'delivered' => ['label' => 'تم التوصيل', 'color' => 'green'],
                                'cancelled' => ['label' => 'ملغي', 'color' => 'red'],
                            ];
                            $status = $statusMap[$order->status] ?? $statusMap['pending'];
                        @endphp
                        <span class="px-3 py-1 rounded-full text-[10px] font-bold bg-{{ $status['color'] }}-500/10 text-{{ $status['color'] }}-500 border border-{{ $status['color'] }}-500/20">
                            {{ $status['label'] }}
                        </span>
                    </td>
                    <td class="py-5 text-left">
                        <span class="text-sm font-bold text-white">{{ number_format($order->total_amount) }}</span>
                        <span class="text-[10px] text-slate-500 font-bold block">IQD</span>
                    </td>
                    <td class="py-5 pl-8 text-left">
                        <div class="flex items-center justify-end gap-2">
                            <a href="{{ route('admin.orders.show', $order) }}" class="w-9 h-9 flex items-center justify-center rounded-lg bg-slate-800 text-slate-400 hover:text-white hover:bg-slate-700 transition-all border border-white/5">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                            </a>
                            <button class="w-9 h-9 flex items-center justify-center rounded-lg bg-slate-800 text-slate-400 hover:text-amber-500 hover:bg-amber-500/10 transition-all border border-white/5">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                            </button>
                        </div>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>

        <!-- Pagination -->
        <div class="p-6 bg-white/5 border-t border-white/5">
            {{ $orders->links() }}
        </div>
    </div>
</div>
@endsection
