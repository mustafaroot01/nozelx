<?php

namespace App\Filament\Admin\Widgets;

use App\Models\Order;
use Filament\Widgets\Widget;

class OrderStatusStatsWidget extends Widget
{
    protected static ?int $sort = 2;
    protected static bool $isLazy = false;
    protected string $view = 'filament.admin.widgets.order-status-stats-widget';

    protected function getViewData(): array
    {
        return [
            'statuses' => [
                [
                    'label' => 'قيد الانتظار',
                    'count' => Order::where('status', 'pending')->count(),
                    'color' => 'amber',
                ],
                [
                    'label' => 'تم استلام الطلب',
                    'count' => Order::where('status', 'received')->count(),
                    'color' => 'blue',
                ],
                [
                    'label' => 'جاري التجهيز',
                    'count' => Order::where('status', 'processing')->count(),
                    'color' => 'purple',
                ],
                [
                    'label' => 'جاري التوصيل',
                    'count' => Order::where('status', 'on_delivery')->count(),
                    'color' => 'sky',
                ],
                [
                    'label' => 'تم التسليم',
                    'count' => Order::where('status', 'delivered')->count(),
                    'color' => 'emerald',
                ],
                [
                    'label' => 'تم رفض الطلب',
                    'count' => Order::where('status', 'cancelled')->count(),
                    'color' => 'rose',
                ],
            ],
        ];
    }
}
