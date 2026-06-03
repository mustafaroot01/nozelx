<x-filament-widgets::widget>
    <div class="p-8 rounded-[2.5rem] bg-white dark:bg-slate-900 border-2 border-slate-100 dark:border-slate-800 shadow-xl h-full flex flex-col transition-all hover:shadow-2xl">
        <div class="flex items-center justify-between mb-8">
            <h3 class="text-xl font-black text-slate-900 dark:text-white" translate="no">تنبيهات المخزون</h3>
            <div class="flex items-center gap-2 px-4 py-2 rounded-full bg-rose-500 text-white shadow-[0_10px_15px_rgba(244,63,94,0.3)]">
                <span class="text-xs font-black" translate="no">{{ $products->count() }} تنبيه</span>
                <x-filament::icon
                    icon="heroicon-m-exclamation-triangle"
                    class="h-5 w-5"
                />
            </div>
        </div>

        <div class="space-y-4 flex-1">
            @forelse($products as $product)
                <div class="flex items-center justify-between p-6 rounded-[2rem] border-2 border-rose-50 dark:border-rose-500/10 bg-rose-50/20 dark:bg-rose-500/5 transition-all hover:bg-rose-50">
                    <div class="flex-1 pr-4">
                        <p class="text-sm font-black text-slate-800 dark:text-slate-100 uppercase" translate="no">{{ $product->name }}</p>
                        <p class="text-[10px] font-bold text-slate-500 dark:text-slate-400 mt-1 uppercase" translate="no">المتوفر: {{ $product->quantity }} قطعة</p>
                    </div>
                    <div class="flex-shrink-0 h-12 w-12 rounded-2xl bg-rose-500 flex items-center justify-center shadow-lg">
                         <span class="text-base font-black text-white">{{ $product->quantity }}</span>
                    </div>
                </div>
            @empty
                <div class="flex-1 flex flex-col items-center justify-center py-10">
                    <div class="p-6 rounded-3xl bg-emerald-50 dark:bg-emerald-500/10 mb-4 shadow-sm">
                        <x-filament::icon
                            icon="heroicon-o-check-circle"
                            class="h-12 w-12 text-emerald-500"
                        />
                    </div>
                    <p class="text-sm font-black text-slate-500 text-center uppercase" translate="no">المخزون مكتمل حالياً</p>
                </div>
            @endforelse
            
            @if($products->count() > 0)
                <button class="w-full mt-6 py-4 text-xs font-black text-rose-500 bg-rose-50 dark:bg-rose-500/10 hover:bg-rose-100 rounded-2xl transition-all" translate="no">عرض السجل الكامل</button>
            @endif
        </div>
    </div>
</x-filament-widgets::widget>
