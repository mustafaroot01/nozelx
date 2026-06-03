<?php

namespace App\Filament\Admin\Widgets;

use App\Models\Product;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class LowStockAlerts extends BaseWidget
{
    protected static ?string $heading = 'تنبيه: منتجات منخفضة المخزون';
    protected static ?int $sort = 4;
    protected int|string|array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Product::query()->where('quantity', '<', 10)->where('is_active', true)
            )
            ->columns([
                TextColumn::make('name')
                    ->label('اسم المنتج'),
                TextColumn::make('sku')
                    ->label('SKU'),
                TextColumn::make('quantity')
                    ->label('الكمية المتبقية')
                    ->badge()
                    ->color(fn ($state) => $state < 5 ? 'danger' : 'warning'),
                TextColumn::make('price')
                    ->label('السعر الحالي')
                    ->money('IQD'),
            ])
            ->paginated(false);
    }
}
