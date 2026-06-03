<?php

namespace App\Filament\Admin\Resources\Products\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ToggleColumn;
use Filament\Tables\Table;

class ProductsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                ImageColumn::make('image')
                    ->label('المنتج')
                    ->rounded(),
                
                TextColumn::make('name')
                    ->label('الاسم (EN)')
                    ->description(fn ($record) => $record->sku ? 'رمز: ' . $record->sku : '')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('name_ar')
                    ->label('الاسم (AR)')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('category.name')
                    ->label('القسم')
                    ->badge()
                    ->color('info')
                    ->sortable(),

                TextColumn::make('brandRelation.name')
                    ->label('الماركة')
                    ->badge()
                    ->color('gray')
                    ->placeholder('بدون ماركة')
                    ->sortable(),

                TextColumn::make('price')
                    ->label('السعر')
                    ->money('IQD')
                    ->sortable()
                    ->color('danger'),

                TextColumn::make('quantity')
                    ->label('الكمية')
                    ->numeric()
                    ->sortable(),

                TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->color(fn ($state) => match ($state) {
                        'published' => 'success',
                        'draft' => 'warning',
                        'out_of_stock' => 'danger',
                        default => 'gray',
                    })
                    ->sortable(),

                ToggleColumn::make('is_active')
                    ->label('نشط'),

                ToggleColumn::make('is_featured')
                    ->label('مميز'),
            ])
            ->filters([
                \Filament\Tables\Filters\SelectFilter::make('category')
                    ->label('القسم')
                    ->relationship('category', 'name'),
                
                \Filament\Tables\Filters\SelectFilter::make('brand')
                    ->label('الماركة')
                    ->relationship('brandRelation', 'name'),

                \Filament\Tables\Filters\SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'draft' => 'مسودة',
                        'published' => 'منشور',
                        'out_of_stock' => 'نفذ من المخزن',
                    ]),
                
                \Filament\Tables\Filters\TernaryFilter::make('is_available')
                    ->label('التوفر')
                    ->placeholder('الكل')
                    ->trueLabel('متوفر')
                    ->falseLabel('غير متوفر'),

                \Filament\Tables\Filters\TernaryFilter::make('is_featured')
                    ->label('المنتجات المميزة')
                    ->placeholder('الكل')
                    ->trueLabel('مميز')
                    ->falseLabel('عادي'),
            ])
            ->actions([
                EditAction::make(),
            ])
            ->bulkActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
