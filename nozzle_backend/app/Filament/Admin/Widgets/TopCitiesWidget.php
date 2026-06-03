<?php

namespace App\Filament\Admin\Widgets;

use App\Models\Order;
use Filament\Widgets\Widget;
use Illuminate\Support\Facades\DB;

class TopCitiesWidget extends Widget
{
    protected static ?int $sort = 4;
    protected static bool $isLazy = false;
    protected string $view = 'filament.admin.widgets.top-cities-widget';

    protected function getViewData(): array
    {
        $topCities = DB::table('orders')
            ->select('customer_address as name', DB::raw('COUNT(*) as total_orders'))
            ->whereNotNull('customer_address')
            ->groupBy('customer_address')
            ->orderByDesc('total_orders')
            ->limit(5)
            ->get();

        return [
            'cities' => $topCities,
        ];
    }
}
