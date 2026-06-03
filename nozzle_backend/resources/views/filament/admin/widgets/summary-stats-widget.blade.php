<x-filament-widgets::widget>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        @foreach ($stats as $stat)
            <div class="relative overflow-hidden p-6 rounded-[2rem] bg-white dark:bg-slate-900 border-2 border-slate-100 dark:border-slate-800 shadow-xl transition-all duration-300 hover:-translate-y-2">
                <div class="flex items-center gap-6">
                    {{-- Icon on the Right for RTL --}}
                    <div class="flex-shrink-0 p-5 rounded-3xl @if($stat['color'] === 'blue') bg-blue-500 text-white shadow-[0_10px_20px_rgba(59,130,246,0.3)] @elseif($stat['color'] === 'success') bg-emerald-500 text-white shadow-[0_10px_20px_rgba(16,185,129,0.3)] @elseif($stat['color'] === 'purple') bg-purple-500 text-white shadow-[0_10px_20px_rgba(168,85,247,0.3)] @else bg-amber-500 text-white shadow-[0_10px_20px_rgba(245,158,11,0.3)] @endif">
                        <x-filament::icon
                            icon="{{ $stat['icon'] }}"
                            class="h-10 w-10"
                        />
                    </div>

                    {{-- Text on the Left --}}
                    <div class="flex-1">
                        <p class="text-xs font-black text-slate-400 uppercase tracking-widest mb-1" translate="no">{{ $stat['label'] }}</p>
                        <h3 class="text-3xl font-black text-slate-900 dark:text-white">{{ $stat['value'] }}</h3>
                        
                        @if(isset($stat['trend']))
                            <div class="mt-2 text-[10px] font-black px-3 py-1 bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400 rounded-full inline-block" translate="no">
                                {{ $stat['trend'] }}
                            </div>
                        @endif
                    </div>
                </div>
            </div>
        @endforeach
    </div>
</x-filament-widgets::widget>
