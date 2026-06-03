<?php

namespace App\Filament\Admin\Resources\Orders\Schemas;

use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Schema;

class OrderForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('معلومات الزبون والشحن')
                    ->schema([
                        Select::make('user_id')
                            ->label('الزبون')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->preload()
                            ->required(),

                        TextInput::make('customer_phone')
                            ->label('رقم الهاتف')
                            ->tel(),

                        TextInput::make('shipping_address')
                            ->label('عنوان التوصيل')
                            ->columnSpanFull(),
                    ])->columns(2),

                Section::make('منتجات الطلب')
                    ->schema([
                        Repeater::make('orderItems')
                            ->label('المنتجات')
                            ->relationship('items')
                            ->schema([
                                Select::make('product_id')
                                    ->label('المنتج')
                                    ->relationship('product', 'name')
                                    ->required()
                                    ->searchable()
                                    ->preload()
                                    ->reactive()
                                    ->afterStateUpdated(fn ($state, callable $set) => $set('price', \App\Models\Product::find($state)?->price ?? 0)),
                                
                                TextInput::make('quantity')
                                    ->label('الكمية')
                                    ->numeric()
                                    ->required()
                                    ->default(1)
                                    ->minValue(1)
                                    ->reactive(),
                                
                                TextInput::make('price')
                                    ->label('السعر')
                                    ->numeric()
                                    ->prefix('IQD')
                                    ->required(),
                            ])
                            ->columns(3)
                            ->defaultItems(1)
                            ->columnSpanFull()
                            ->addActionLabel('إضافة منتج'),
                    ]),

                Section::make('الحالة والمبالغ')
                    ->schema([
                        Select::make('status')
                            ->label('حالة الطلب')
                            ->options([
                                'pending' => 'قيد الانتظار',
                                'processing' => 'جاري التجهيز',
                                'shipped' => 'تم الشحن',
                                'delivered' => 'تم التوصيل',
                                'cancelled' => 'ملغي',
                            ])
                            ->required()
                            ->native(false),

                        Grid::make(3)
                            ->schema([
                                TextInput::make('total_amount')
                                    ->label('المبلغ الإجمالي')
                                    ->numeric()
                                    ->prefix('IQD')
                                    ->required(),
                                
                                TextInput::make('discount_amount')
                                    ->label('مبلغ الخصم')
                                    ->numeric()
                                    ->prefix('IQD')
                                    ->default(0),

                                TextInput::make('final_amount')
                                    ->label('المبلغ الصافي')
                                    ->numeric()
                                    ->prefix('IQD')
                                    ->required(),
                            ]),
                    ]),
            ]);
    }
}
