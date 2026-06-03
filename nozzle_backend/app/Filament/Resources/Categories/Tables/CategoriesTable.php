<?php

namespace App\Filament\Resources\Categories\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class CategoriesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                ImageColumn::make('image')

                    ->label('')
                    ->circular(),
                TextColumn::make('name')
                    ->label('اسم القسم (بالإنكليزية)')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),
                TextColumn::make('name_ar')
                    ->label('اسم القسم (بالعربية)')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('parent.name')
                    ->label('القسم الرئيسي')
                    ->badge()
                    ->placeholder('قسم رئيسي')
                    ->sortable(),
                \Filament\Tables\Columns\ColorColumn::make('color')
                    ->label('اللون'),
                TextColumn::make('order_index')
                    ->label('الترتيب')
                    ->numeric()
                    ->sortable(),
                TextColumn::make('products_count')
                    ->label('عدد المنتجات')
                    ->counts('products')
                    ->badge(),
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
