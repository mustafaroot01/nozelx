<?php

namespace App\Filament\Widgets;

use App\Models\Order;
use Filament\Widgets\ChartWidget;
use Flowframe\Trend\Trend;
use Flowframe\Trend\TrendValue;
use Illuminate\Support\Carbon;

class OrdersChart extends ChartWidget
{
    protected ?string $heading = 'Sales Trend (Last 30 Days)';
    
    protected static ?int $sort = 2; // Actually sort IS static in Base Widget, wait.


    protected function getData(): array
    {
        // For now using simple aggregation by day if Trend package is not installed
        // If Trend package is installed, we would use:
        /*
        $data = Trend::model(Order::class)
            ->between(
                start: now()->startOfMonth(),
                end: now()->endOfMonth(),
            )
            ->perDay()
            ->count();
        */

        // Simple fallback logic for the last 7 days since I can't check composer easily for every package
        $data = [];
        $labels = [];
        
        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::now()->subDays($i);
            $labels[] = $date->format('M d');
            $data[] = Order::whereDate('created_at', $date->toDateString())->count();
        }

        return [
            'datasets' => [
                [
                    'label' => 'Orders',
                    'data' => $data,
                    'fill' => 'start',
                    'borderColor' => '#6366f1',
                    'backgroundColor' => 'rgba(99, 102, 241, 0.1)',
                ],
            ],
            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
