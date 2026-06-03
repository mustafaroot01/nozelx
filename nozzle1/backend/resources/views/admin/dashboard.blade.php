@extends('layouts.admin')

@section('content')
<div class="space-y-8">
    
    <!-- Welcome Section -->
    <div class="flex items-center justify-between">
        <div class="space-y-1">
            <h2 class="text-3xl font-bold text-white tracking-tight">أهلاً بك مرة أخرى، يا مدير! 👋</h2>
            <p class="text-slate-400">إليك نظرة سريعة على ما يحدث في متجر <span class="text-amber-500 font-semibold tracking-wide">نوزل Nozzle</span> اليوم.</p>
        </div>
        <div class="flex gap-4">
            <button class="glass px-4 py-2 rounded-lg text-sm font-semibold flex items-center gap-2 hover:bg-white/10 transition-colors">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                تنزيل التقرير
            </button>
            <button class="bg-amber-500 hover:bg-amber-600 px-4 py-2 rounded-lg text-sm font-bold flex items-center gap-2 shadow-lg shadow-amber-500/20 transition-all text-white">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
                منتج جديد
            </button>
        </div>
    </div>

    <!-- Stats Cards Grid -->
    <div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-6">
        <!-- Revenue Card -->
        <div class="glass p-6 rounded-2xl relative overflow-hidden group">
            <div class="absolute -right-4 -top-4 w-24 h-24 bg-amber-500/10 rounded-full blur-2xl group-hover:bg-amber-500/20 transition-colors"></div>
            <div class="flex items-center justify-between relative z-10 mb-4">
                <div class="p-3 bg-amber-500/10 rounded-xl">
                    <svg class="w-6 h-6 text-amber-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
                <span class="text-xs font-bold text-green-500 flex items-center gap-1">
                    +12.5%
                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M5 15l7-7 7 7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                </span>
            </div>
            <p class="text-slate-400 text-sm font-medium">إجمالي الإيرادات</p>
            <h3 class="text-2xl font-bold text-white mt-1">{{ number_format($stats['total_revenue']) }} <span class="text-xs font-normal text-slate-500">IQD</span></h3>
        </div>

        <!-- Orders Card -->
        <div class="glass p-6 rounded-2xl relative overflow-hidden group">
            <div class="absolute -right-4 -top-4 w-24 h-24 bg-blue-500/10 rounded-full blur-2xl group-hover:bg-blue-500/20 transition-colors"></div>
            <div class="flex items-center justify-between relative z-10 mb-4">
                <div class="p-3 bg-blue-500/10 rounded-xl">
                    <svg class="w-6 h-6 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
                    </svg>
                </div>
                <span class="text-xs font-bold text-green-500 flex items-center gap-1">
                    +8.3%
                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M5 15l7-7 7 7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                </span>
            </div>
            <p class="text-slate-400 text-sm font-medium">إجمالي الطلبيات</p>
            <h3 class="text-2xl font-bold text-white mt-1">{{ $stats['orders_count'] }}</h3>
        </div>

        <!-- Products Card -->
        <div class="glass p-6 rounded-2xl relative overflow-hidden group">
            <div class="absolute -right-4 -top-4 w-24 h-24 bg-purple-500/10 rounded-full blur-2xl group-hover:bg-purple-500/20 transition-colors"></div>
            <div class="flex items-center justify-between relative z-10 mb-4">
                <div class="p-3 bg-purple-500/10 rounded-xl">
                    <svg class="w-6 h-6 text-purple-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                    </svg>
                </div>
                <span class="text-xs font-bold text-slate-500">ثابت</span>
            </div>
            <p class="text-slate-400 text-sm font-medium">عدد المنتجات</p>
            <h3 class="text-2xl font-bold text-white mt-1">{{ $stats['products_count'] }}</h3>
        </div>

        <!-- Banners Card (NEW) -->
        <div class="glass p-6 rounded-2xl relative overflow-hidden group">
            <div class="absolute -right-4 -top-4 w-24 h-24 bg-rose-500/10 rounded-full blur-2xl group-hover:bg-rose-500/20 transition-colors"></div>
            <div class="flex items-center justify-between relative z-10 mb-4">
                <div class="p-3 bg-rose-500/10 rounded-xl">
                    <svg class="w-6 h-6 text-rose-500" fill="none" stroke="currentColor" viewBox="0 2 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                </div>
                <span class="text-xs font-bold text-slate-500">نشط</span>
            </div>
            <p class="text-slate-400 text-sm font-medium">البانرات الإعلانية</p>
            <h3 class="text-2xl font-bold text-white mt-1">{{ $stats['banners_count'] }}</h3>
        </div>

        <!-- Users Card -->
        <div class="glass p-6 rounded-2xl relative overflow-hidden group">
            <div class="absolute -right-4 -top-4 w-24 h-24 bg-emerald-500/10 rounded-full blur-2xl group-hover:bg-emerald-500/20 transition-colors"></div>
            <div class="flex items-center justify-between relative z-10 mb-4">
                <div class="p-3 bg-emerald-500/10 rounded-xl">
                    <svg class="w-6 h-6 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                    </svg>
                </div>
                <span class="text-xs font-bold text-green-500 flex items-center gap-1">
                    +24%
                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M5 15l7-7 7 7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                </span>
            </div>
            <p class="text-slate-400 text-sm font-medium">إجمالي المستخدمين</p>
            <h3 class="text-2xl font-bold text-white mt-1">{{ $stats['users_count'] }}</h3>
        </div>
    </div>

    <!-- Charts and Tables -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        <!-- Main Sales Chart -->
        <div class="lg:col-span-2 glass p-8 rounded-3xl">
            <div class="flex items-center justify-between mb-8">
                <div>
                    <h3 class="text-xl font-bold text-white">إحصائيات المبيعات</h3>
                    <p class="text-slate-400 text-sm">مقارنة المبيعات الشهرية لهذا العام.</p>
                </div>
                <select class="bg-slate-800 border border-white/10 rounded-lg py-1 px-3 text-sm focus:outline-none">
                    <option>أخر 7 أيام</option>
                    <option>أخر 30 يوم</option>
                    <option>هذا العام</option>
                </select>
            </div>
            <canvas id="salesChart" height="250"></canvas>
        </div>

        <!-- Recent Activity Table / Top Categories -->
        <div class="glass p-8 rounded-3xl">
            <h3 class="text-xl font-bold text-white mb-6">أهم التصنيفات</h3>
            <div class="space-y-6">
                @foreach(['الإلكترونيات', 'الملابس', 'المنزل', 'الساعات'] as $cat)
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-4">
                        <div class="w-10 h-10 rounded-xl bg-slate-800 flex items-center justify-center font-bold text-amber-500 text-xs">
                            #{{ $loop->iteration }}
                        </div>
                        <div>
                            <p class="text-sm font-semibold text-white">{{ $cat }}</p>
                            <p class="text-[10px] text-slate-500 uppercase tracking-widest font-bold">24 منتج</p>
                        </div>
                    </div>
                    <div class="text-right">
                        <p class="text-xs font-bold text-white">45,000</p>
                        <div class="w-16 h-1.5 bg-slate-800 rounded-full mt-1.5 overflow-hidden">
                            <div class="h-full bg-amber-500 rounded-full" style="width: {{ rand(40, 90) }}%"></div>
                        </div>
                    </div>
                </div>
                @endforeach
            </div>
            <button class="w-full mt-8 py-3 bg-slate-800 hover:bg-slate-700/50 rounded-xl text-xs font-bold border border-white/5 transition-colors">عرض جميع التصنيفات</button>
        </div>
    </div>

    <!-- Recent Orders Table -->
    <div class="glass p-8 rounded-3xl">
        <div class="flex items-center justify-between mb-8">
            <div>
                <h3 class="text-xl font-bold text-white">الطلبات الأخيرة</h3>
                <p class="text-slate-400 text-sm">أحدث 5 طلبات تم تسجيلها في النظام.</p>
            </div>
            <button class="text-amber-500 text-sm font-bold hover:underline">عرض جميع الطلبات</button>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-right">
                <thead>
                    <tr class="text-slate-500 text-[11px] font-bold uppercase tracking-widest border-b border-white/5">
                        <th class="pb-4 pr-4">الزبون</th>
                        <th class="pb-4">رقم الطلب</th>
                        <th class="pb-4">الحالة</th>
                        <th class="pb-4">التاريخ</th>
                        <th class="pb-4 pl-4 text-left">المبلغ الصافي</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-white/5">
                    @foreach($stats['recent_orders'] as $order)
                    <tr class="group hover:bg-white/5 transition-colors">
                        <td class="py-4 pr-4">
                            <div class="flex items-center gap-3">
                                <div class="w-8 h-8 rounded-lg bg-amber-500/20 flex items-center justify-center text-amber-500 font-bold text-[10px]">
                                    {{ substr($order->user->name ?? 'Guest', 0, 1) }}
                                </div>
                                <span class="text-sm font-medium text-slate-200">{{ $order->user->name ?? 'Guest' }}</span>
                            </div>
                        </td>
                        <td class="py-4 text-xs font-mono text-slate-400">#{{ $order->order_number ?? rand(1000, 9999) }}</td>
                        <td class="py-4">
                            @php
                                $statusColors = [
                                    'pending' => 'bg-amber-500/10 text-amber-500',
                                    'processing' => 'bg-blue-500/10 text-blue-500',
                                    'shipped' => 'bg-purple-500/10 text-purple-500',
                                    'delivered' => 'bg-green-500/10 text-green-500',
                                    'cancelled' => 'bg-red-500/10 text-red-500',
                                ];
                            @endphp
                            <span class="px-2.5 py-1 rounded-full text-[10px] font-bold {{ $statusColors[$order->status] ?? $statusColors['pending'] }}">
                                {{ $order->status }}
                            </span>
                        </td>
                        <td class="py-4 text-xs text-slate-500">{{ $order->created_at->diffForHumans() }}</td>
                    <td class="py-4 pl-4 text-left font-bold text-white text-sm">
                        {{ number_format($order->total_amount) }} <span class="text-[10px] font-normal text-slate-500 uppercase">IQD</span>
                    </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const ctx = document.getElementById('salesChart').getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو'],
                datasets: [{
                    label: 'المبيعات',
                    data: [12, 19, 3, 5, 2, 3],
                    borderColor: '#f59e0b',
                    backgroundColor: 'rgba(245, 158, 11, 0.1)',
                    borderWidth: 3,
                    tension: 0.4,
                    fill: true,
                    pointBackgroundColor: '#f59e0b',
                    pointRadius: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: 'rgba(255, 255, 255, 0.05)' },
                        ticks: { color: '#64748b', font: { size: 10 } }
                    },
                    x: {
                        grid: { display: false },
                        ticks: { color: '#64748b', font: { size: 10 } }
                    }
                }
            }
        });
    });
</script>
@endsection
