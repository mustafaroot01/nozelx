<?php

namespace App\Filament\Admin\Widgets;

use App\Models\Order;
use App\Models\Product;
use Filament\Widgets\Widget;
use Illuminate\Support\Facades\DB;

class TopProductsWidget extends Widget
{
    protected static ?int $sort = 3;
    protected static bool $isLazy = false;
    protected string $view = 'filament.admin.widgets.top-products-widget';

    protected function getViewData(): array
    {
        $topProducts = DB::table('order_items')
            ->join('products', 'order_items.product_id', '=', 'products.id')
            ->select('products.name', DB::raw('COUNT(*) as total_orders'))
            ->groupBy('products.id', 'products.name')
            ->orderByDesc('total_orders')
            ->limit(5)
            ->get();

        return [
            'products' => $topProducts,
        ];
    }
}
