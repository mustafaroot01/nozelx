<?php

namespace App\Filament\Admin\Widgets;

use App\Models\Product;
use Filament\Widgets\Widget;

class InventoryAlertsWidget extends Widget
{
    protected static ?int $sort = 5;
    protected static bool $isLazy = false;
    protected string $view = 'filament.admin.widgets.inventory-alerts-widget';

    protected function getViewData(): array
    {
        $lowStockProducts = Product::where('quantity', '<=', 5)
            ->limit(5)
            ->get();

        return [
            'products' => $lowStockProducts,
        ];
    }
}
