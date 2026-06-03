<?php

namespace App\Filament\Admin\Resources\ActivityLogs;

use App\Filament\Admin\Resources\ActivityLogs\Pages\ListActivityLogs;
use App\Filament\Admin\Resources\ActivityLogs\Tables\ActivityLogsTable;
use Filament\Resources\Resource;
use Filament\Tables\Table;
use Spatie\Activitylog\Models\Activity;
use BackedEnum;

class ActivityLogResource extends Resource
{
    protected static ?string $model = Activity::class;

    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-presentation-chart-bar';
    protected static string|\UnitEnum|null $navigationGroup = 'التقارير والمراقبة';
    protected static ?string $navigationLabel = 'الجرد والتقارير';
    protected static ?string $modelLabel = 'نشاط';
    protected static ?string $pluralModelLabel = 'سجل النشاطات';

    public static function table(Table $table): Table
    {
        return ActivityLogsTable::configure($table);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListActivityLogs::route('/'),
        ];
    }

    public static function canCreate(): bool
    {
        return false;
    }
}
