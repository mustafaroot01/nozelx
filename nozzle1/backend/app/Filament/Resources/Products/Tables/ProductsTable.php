<?php

namespace App\Filament\Resources\Products\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ProductsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                ImageColumn::make('image')

                    ->label('')
                    ->circular(),
                TextColumn::make('name')
                    ->label('المنتج')
                    ->searchable()
                    ->sortable()
                    ->description(fn ($record) => $record->brand),
                TextColumn::make('category.name')
                    ->label('القسم')
                    ->badge()
                    ->color('gray')
                    ->sortable(),
                TextColumn::make('price')
                    ->label('السعر')
                    ->money('IQD')
                    ->sortable()
                    ->description(fn ($record) => $record->old_price ? 'كان: ' . number_format($record->old_price) . ' د.ع' : null)
                    ->color('primary')
                    ->weight('bold'),
                TextColumn::make('quantity')
                    ->label('المخزون')
                    ->numeric()
                    ->sortable()
                    ->badge()
                    ->color(fn ($state) => match (true) {
                        $state <= 0 => 'danger',
                        $state <= 5 => 'warning',
                        default => 'success',
                    }),
                \Filament\Tables\Columns\ToggleColumn::make('is_available')
                    ->label('متاح'),
                \Filament\Tables\Columns\ToggleColumn::make('in_stock')
                    ->label('متوفر'),
                \Filament\Tables\Columns\ToggleColumn::make('is_featured')
                    ->label('مميز'),
                TextColumn::make('created_at')
                    ->label('تاريخ الإضافة')
                    ->dateTime('Y-m-d')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])


            ->filters([
                //
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
