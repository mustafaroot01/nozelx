<x-filament-widgets::widget>
    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-6">
        @foreach ($statuses as $status)
            <div class="flex flex-col items-center justify-center p-8 rounded-[2.5rem] bg-white dark:bg-slate-900 border-2 border-slate-100 dark:border-slate-800 shadow-xl transition-all duration-300 hover:-translate-y-2 group">
                <span class="text-4xl font-black text-slate-900 dark:text-white group-hover:scale-110 transition-transform">{{ $status['count'] }}</span>
                <span class="text-[11px] font-black mt-3 text-slate-500 dark:text-slate-400 text-center uppercase tracking-widest" translate="no">{{ $status['label'] }}</span>
                
                <div class="mt-4 h-3 w-3 rounded-full @if($status['color'] === 'amber') bg-amber-500 shadow-[0_0_15px_rgba(245,158,11,0.6)] @elseif($status['color'] === 'blue') bg-blue-500 shadow-[0_0_15px_rgba(59,130,246,0.6)] @elseif($status['color'] === 'purple') bg-purple-500 shadow-[0_0_15px_rgba(168,85,247,0.6)] @elseif($status['color'] === 'sky') bg-sky-500 shadow-[0_0_15px_rgba(14,165,233,0.6)] @elseif($status['color'] === 'emerald') bg-emerald-500 shadow-[0_0_15px_rgba(16,185,129,0.6)] @else bg-rose-500 shadow-[0_0_15_rgba(244,63,94,0.6)] @endif"></div>
            </div>
        @endforeach
    </div>
</x-filament-widgets::widget>
