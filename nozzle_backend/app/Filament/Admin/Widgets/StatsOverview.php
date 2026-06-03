<?php

namespace App\Filament\Admin\Widgets;

use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        return [
            Stat::make('إجمالي المبيعات', number_format(Order::where('status', 'completed')->sum('total_amount'), 0) . ' IQD')
                ->description('إجمالي أرباح الطلبات المكتملة')
                ->descriptionIcon('heroicon-m-banknotes')
                ->chart([7, 2, 10, 3, 15, 4, 17])
                ->color('success'),

            Stat::make('الطلبات الجديدة', Order::where('status', 'pending')->count())
                ->description('طلبات قيد الانتظار')
                ->descriptionIcon('heroicon-m-shopping-cart')
                ->color('warning'),
            
            Stat::make('إجمالي المنتجات', Product::count())
                ->description('المنتجات في المخزن')
                ->descriptionIcon('heroicon-m-shopping-bag')
                ->color('info'),
                
            Stat::make('إجمالي الزبائن', User::where('is_admin', false)->count())
                ->description('المستخدمين المسجلين')
                ->descriptionIcon('heroicon-m-users')
                ->color('primary'),
        ];
    }
}
