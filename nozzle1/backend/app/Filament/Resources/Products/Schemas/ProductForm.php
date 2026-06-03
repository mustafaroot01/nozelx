<?php

namespace App\Filament\Resources\Products\Schemas;

use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class ProductForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                \Filament\Forms\Components\Tabs::make('تفاصيل المنتج')
                    ->tabs([
                        \Filament\Forms\Components\Tabs\Tab::make('المعلومات الأساسية')
                            ->icon('heroicon-m-information-circle')
                            ->schema([
                                Select::make('category_id')
                                    ->label('القسم')
                                    ->relationship('category', 'name')
                                    ->required()
                                    ->searchable()
                                    ->preload(),
                                TextInput::make('name')
                                    ->label('اسم المنتج')
                                    ->placeholder('مثلاً: غسيل نانو سيراميك')
                                    ->required()
                                    ->maxLength(255),
                                TextInput::make('brand')
                                    ->label('العلامة التجارية / الماركة')
                                    ->placeholder('مثلاً: تويوتا، نيزك...')
                                    ->maxLength(255),
                                \Filament\Forms\Components\RichEditor::make('description')
                                    ->label('وصف المنتج')
                                    ->maxLength(65535)
                                    ->columnSpanFull(),
                            ])->columns(2),

                        \Filament\Forms\Components\Tabs\Tab::make('الأسعار والمخزون')
                            ->icon('heroicon-m-currency-dollar')
                            ->schema([
                                TextInput::make('price')
                                    ->label('سعر البيع')
                                    ->required()
                                    ->numeric()
                                    ->prefix('د.ع'),
                                TextInput::make('old_price')
                                    ->label('السعر القديم')
                                    ->numeric()
                                    ->prefix('د.ع')
                                    ->helperText('السعر الأصلي قبل التخفيض (سيظهر مشطوباً)'),
                                TextInput::make('quantity')
                                    ->label('الكمية المتوفرة')
                                    ->numeric()
                                    ->default(0)
                                    ->required(),
                                Toggle::make('is_available')
                                    ->label('متاح للبيع حالياً')
                                    ->default(true),
                                Toggle::make('in_stock')
                                    ->label('متوفر في المخزن')
                                    ->default(true),
                                Toggle::make('is_featured')
                                    ->label('منتج مميز (Featured)')
                                    ->helperText('سيظهر المنتج في قسم العروض المميزة في الصفحة الرئيسية')
                                    ->default(false),
                            ])->columns(2),

                        \Filament\Forms\Components\Tabs\Tab::make('الصور والوسائط')
                            ->icon('heroicon-m-photo')
                            ->schema([
                                FileUpload::make('image')
                                    ->label('صورة المنتج الرئيسية')
                                    ->image()
                                    ->directory('products')
                                    ->imageEditor()
                                    ->columnSpanFull(),
                            ]),
                    ])->columnSpanFull(),
            ]);


    }
}
