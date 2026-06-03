<?php

namespace App\Filament\Admin\Resources\Categories\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\ColorColumn;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Table;

class CategoriesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                ImageColumn::make('image')
                    ->label('صورة التصنيف')
                    ->circular(),
                
                TextColumn::make('name')
                    ->label('الاسم (EN)')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('name_ar')
                    ->label('الاسم (AR)')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('parent.name')
                    ->label('التصنيف الأب')
                    ->badge()
                    ->placeholder('تصنيف أساسي')
                    ->sortable(),

                IconColumn::make('is_active')
                    ->label('نشط')
                    ->boolean()
                    ->sortable(),

                IconColumn::make('is_featured')
                    ->label('مميز')
                    ->boolean()
                    ->sortable(),

                TextColumn::make('icon')
                    ->label('الأيقونة')
                    ->toggleable(),

                ColorColumn::make('color')
                    ->label('اللون')
                    ->toggleable(),

                TextColumn::make('products_count')
                    ->label('عدد المنتجات')
                    ->counts('products'),

                TextColumn::make('order_index')
                    ->label('الترتيب')
                    ->numeric()
                    ->sortable(),
            ])
            ->filters([
                //
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

