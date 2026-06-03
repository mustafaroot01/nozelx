<?php

namespace App\Filament\Admin\Resources\Products\RelationManagers;

use Filament\Actions\CreateAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\TextInput;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class VariationsRelationManager extends RelationManager
{
    protected static string $relationship = 'variations';

    protected static ?string $recordTitleAttribute = 'sku';

    protected static ?string $title = 'خيارات المنتج (Variations)';
    protected static ?string $modelLabel = 'خيار';
    protected static ?string $pluralModelLabel = 'خيارات المنتج';

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('sku')
                    ->label('Code (SKU)')
                    ->required()
                    ->maxLength(255),
                
                TextInput::make('price')
                    ->label('السعر الخاص (اختياري)')
                    ->numeric()
                    ->prefix('IQD'),
                
                TextInput::make('stock')
                    ->label('الكمية')
                    ->numeric()
                    ->default(0)
                    ->required(),

                FileUpload::make('image')
                    ->label('صورة الخيار')
                    ->image()
                    ->directory('products/variations'),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                ImageColumn::make('image')
                    ->label('الصورة'),
                
                TextColumn::make('sku')
                    ->label('SKU')
                    ->searchable(),
                
                TextColumn::make('price')
                    ->label('السعر')
                    ->money('IQD'),
                
                TextColumn::make('stock')
                    ->label('الكمية')
                    ->badge(),
            ])
            ->headerActions([
                CreateAction::make(),
            ])
            ->actions([
                EditAction::make(),
                DeleteAction::make(),
            ]);
    }
}
