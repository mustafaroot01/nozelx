<?php

namespace App\Filament\Admin\Widgets;

use App\Models\User;
use Carbon\Carbon;
use Filament\Widgets\ChartWidget;

class NewUsersChart extends ChartWidget
{
    protected ?string $heading = 'تسجيل المستخدمين الجدد';
    protected static ?int $sort = 3;

    protected function getData(): array
    {
        $users = User::where('is_admin', false)
            ->where('created_at', '>=', Carbon::now()->subYear())
            ->get()
            ->groupBy(fn ($user) => $user->created_at->format('n'));

        $months = [];
        $values = [];

        for ($i = 11; $i >= 0; $i--) {
            $month = Carbon::now()->subMonths($i);
            $monthNum = (int)$month->format('n');
            $months[] = $month->translatedFormat('F');
            $values[] = count($users[$monthNum] ?? []);
        }

        return [
            'datasets' => [
                [
                    'label' => 'المستخدمين الجدد',
                    'data' => $values,
                    'borderColor' => '#6366f1',
                    'backgroundColor' => 'rgba(99, 102, 241, 0.1)',
                ],
            ],
            'labels' => $months,
        ];
    }

    protected function getType(): string
    {
        return 'bar';
    }
}
