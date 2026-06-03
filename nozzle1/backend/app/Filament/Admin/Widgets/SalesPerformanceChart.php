<?php

namespace App\Filament\Admin\Widgets;

use App\Models\Order;
use Carbon\Carbon;
use Filament\Widgets\ChartWidget;

class SalesPerformanceChart extends ChartWidget
{
    protected ?string $heading = 'أداء المبيعات';
    protected static ?int $sort = 2;

    protected function getData(): array
    {
        $driver = config('database.default');
        $monthExpr = $driver === 'sqlite'
            ? "CAST(strftime('%m', created_at) AS INTEGER)"
            : "MONTH(created_at)";

        $data = Order::where('status', 'completed')
            ->where('created_at', '>=', Carbon::now()->subYear())
            ->selectRaw("SUM(total_amount) as total, {$monthExpr} as month")
            ->groupBy('month')
            ->orderBy('month')
            ->pluck('total', 'month')
            ->toArray();

        $months = [];
        $values = [];

        for ($i = 11; $i >= 0; $i--) {
            $month = Carbon::now()->subMonths($i);
            $monthNum = (int)$month->format('n');
            $months[] = $month->translatedFormat('F');
            $values[] = $data[$monthNum] ?? 0;
        }

        return [
            'datasets' => [
                [
                    'label' => 'المبيعات (د.ع)',
                    'data' => $values,
                    'fill' => 'start',
                    'borderColor' => '#0ea5e9',
                    'backgroundColor' => 'rgba(14, 165, 233, 0.1)',
                    'tension' => 0.5,
                    'pointRadius' => 4,
                    'pointBackgroundColor' => '#0ea5e9',
                ],
            ],
            'labels' => $months,
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
