<x-filament-widgets::widget>
    <div class="p-8 rounded-[2.5rem] bg-white dark:bg-slate-900 border-2 border-slate-100 dark:border-slate-800 shadow-xl h-full flex flex-col transition-all hover:shadow-2xl">
        <div class="flex items-center justify-between mb-8">
            <h3 class="text-xl font-black text-slate-900 dark:text-white" translate="no">أكثر المنتجات طلباً</h3>
            <div class="p-3 rounded-2xl bg-orange-500 text-white shadow-[0_10px_15px_rgba(249,115,22,0.3)]">
                <x-filament::icon
                    icon="heroicon-m-fire"
                    class="h-6 w-6"
                />
            </div>
        </div>

        <div class="space-y-4 flex-1">
            @forelse($products as $product)
                <div class="flex items-center justify-between p-5 rounded-2xl bg-slate-50 dark:bg-slate-800/50 border border-slate-100 dark:border-slate-700/50">
                    <span class="text-sm font-black text-slate-700 dark:text-slate-200" translate="no">{{ $product->name }}</span>
                    <span class="text-xs font-black px-4 py-2 rounded-xl bg-white dark:bg-slate-900 text-slate-500 shadow-sm border border-slate-100 dark:border-slate-700" translate="no">{{ $product->total_orders }} طلب</span>
                </div>
            @empty
                <div class="flex-1 flex flex-col items-center justify-center py-10 opacity-30">
                    <x-filament::icon icon="heroicon-o-archive-box" class="h-16 w-16 mb-4" />
                    <p class="text-sm font-black" translate="no">لا توجد بيانات</p>
                </div>
            @endforelse
        </div>
    </div>
</x-filament-widgets::widget>
