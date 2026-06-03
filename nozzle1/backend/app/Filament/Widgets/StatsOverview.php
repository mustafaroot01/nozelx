<?php

namespace App\Filament\Widgets;

use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Filament\Support\Colors\Color;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        $revenue = Order::where('status', 'delivered')->sum('total_amount');
        $ordersCount = Order::count();
        $productsCount = Product::count();
        $usersCount = User::count();

        return [
            Stat::make('Total Revenue', 'IQD ' . number_format($revenue))
                ->description('Total delivered sales')
                ->descriptionIcon('heroicon-m-banknotes')
                ->color('success')
                ->chart([7, 2, 10, 3, 15, 4, 17]),

            Stat::make('Total Orders', $ordersCount)
                ->description('Orders placed to date')
                ->descriptionIcon('heroicon-m-shopping-cart')
                ->color('info')
                ->chart([3, 5, 2, 8, 4, 10, 6]),

            Stat::make('Active Products', $productsCount)
                ->description('Products in catalog')
                ->descriptionIcon('heroicon-m-archive-box')
                ->color('warning'),

            Stat::make('Total Customers', $usersCount)
                ->description('Registered app users')
                ->descriptionIcon('heroicon-m-users')
                ->color('primary'),
        ];
    }
}
