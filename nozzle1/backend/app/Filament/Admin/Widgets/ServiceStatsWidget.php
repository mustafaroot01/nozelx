<?php

namespace App\Filament\Admin\Widgets;

use App\Models\ServiceBooking;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class ServiceStatsWidget extends BaseWidget
{
    protected static ?int $sort = 3;

    protected function getStats(): array
    {
        return [
            Stat::make('إجمالي طلبات الخدمات', ServiceBooking::count())
                ->description('إجمالي الحجوزات المستلمة')
                ->descriptionIcon('heroicon-m-wrench-screwdriver')
                ->color('info'),
            Stat::make('طلبات قيد الانتظار', ServiceBooking::where('status', 'pending')->count())
                ->description('تحتاج إلى مراجعة')
                ->descriptionIcon('heroicon-m-clock')
                ->color('warning'),
            Stat::make('الحجوزات المكتملة', ServiceBooking::where('status', 'completed')->count())
                ->description('تم إنجازها بنجاح')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color('success'),
        ];
    }
}
