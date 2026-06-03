<?php

namespace App\Filament\Admin\Widgets;

use App\Models\Order;
use App\Models\User;
use Filament\Widgets\Widget;

class SummaryStatsWidget extends Widget
{
    protected static ?int $sort = 1;
    protected static bool $isLazy = false;
    protected string $view = 'filament.admin.widgets.summary-stats-widget';

    protected function getViewData(): array
    {
        $deliveredRevenue = Order::where('status', 'delivered')->sum('total_amount');
        
        $netProfit = \App\Models\OrderItem::join('products', 'order_items.product_id', '=', 'products.id')
            ->join('orders', 'order_items.order_id', '=', 'orders.id')
            ->where('orders.status', 'delivered')
            ->select(\Illuminate\Support\Facades\DB::raw('SUM((order_items.price - IFNULL(products.cost_price, 0)) * order_items.quantity) as profit'))
            ->first()
            ->profit ?? 0;

        return [
            'stats' => [
                [
                    'label' => 'إجمالي الطلبات',
                    'value' => number_format(Order::count()),
                    'color' => 'blue',
                    'icon' => 'heroicon-m-shopping-bag',
                    'trend' => '+' . Order::whereDate('created_at', today())->count() . ' طلبات اليوم',
                ],
                [
                    'label' => 'الإيرادات المستلمة',
                    'value' => number_format($deliveredRevenue, 0) . ' د.ع',
                    'color' => 'success',
                    'icon' => 'heroicon-m-currency-dollar',
                ],
                [
                    'label' => 'الربح الصافي',
                    'value' => number_format($netProfit, 0) . ' د.ع',
                    'color' => 'purple',
                    'icon' => 'heroicon-m-arrow-trending-up',
                ],
                [
                    'label' => 'العملاء الجدد',
                    'value' => number_format(User::where('is_admin', false)->count()),
                    'color' => 'warning',
                    'icon' => 'heroicon-m-user-group',
                    'trend' => '+' . User::whereDate('created_at', today())->count() . ' عضو جديد',
                ],
            ],
        ];
    }
}
