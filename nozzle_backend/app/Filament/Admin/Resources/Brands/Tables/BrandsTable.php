<?php

namespace App\Filament\Admin\Resources\Brands\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Table;

class BrandsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                ImageColumn::make('logo')
                    ->label('الشعار (Logo)')
                    ->circular(),

                ImageColumn::make('image')
                    ->label('الشعار (Image)')
                    ->circular(),
                
                TextColumn::make('name')
                    ->label('الاسم (EN)')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('name_ar')
                    ->label('الاسم (AR)')
                    ->searchable()
                    ->sortable(),

                IconColumn::make('is_active')
                    ->label('نشط')
                    ->boolean()
                    ->sortable(),

                TextColumn::make('sort_order')
                    ->label('الترتيب')
                    ->sortable(),

                TextColumn::make('products_count')
                    ->label('عدد المنتجات')
                    ->counts('products'),
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

