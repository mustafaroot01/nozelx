<?php

namespace App\Filament\Resources\Orders\Schemas;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class OrderForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                \Filament\Forms\Components\Tabs::make('إدارة الطلب')
                    ->tabs([
                        \Filament\Forms\Components\Tabs\Tab::make('بيانات العميل والشحن')
                            ->icon('heroicon-m-user')
                            ->schema([
                                TextInput::make('customer_name')
                                    ->label('اسم العميل')
                                    ->placeholder('مثلاً: أحمد محمد')
                                    ->required()
                                    ->maxLength(255),
                                TextInput::make('customer_phone')
                                    ->label('رقم هاتف العميل')
                                    ->placeholder('07XXXXXXXXX')
                                    ->tel()
                                    ->required()
                                    ->maxLength(255),
                                Select::make('user_id')
                                    ->label('الحساب المرتبط')
                                    ->relationship('user', 'name')
                                    ->searchable()
                                    ->preload()
                                    ->helperText('ربط الطلب بحساب مستخدم مسجل في التطبيق (اختياري)'),
                            ])->columns(2),

                        \Filament\Forms\Components\Tabs\Tab::make('الدفع والحالة')
                            ->icon('heroicon-m-credit-card')
                            ->schema([
                                Select::make('status')
                                    ->label('حالة الطلب')
                                    ->options([
                                        'pending' => 'قيد الانتظار',
                                        'processing' => 'جاري المعالجة',
                                        'shipped' => 'تم الشحن',
                                        'delivered' => 'تم التوصيل',
                                        'cancelled' => 'تم الإلغاء',
                                    ])
                                    ->required()
                                    ->default('pending')
                                    ->native(false),
                                Select::make('payment_method')
                                    ->label('طريقة الدفع')
                                    ->options([
                                        'cash' => 'نقداً (عند الاستلام)',
                                        'wallet' => 'المحفظة الإلكترونية',
                                    ])
                                    ->required()
                                    ->native(false),
                                TextInput::make('total_amount')
                                    ->label('إجمالي المبلغ')
                                    ->numeric()
                                    ->prefix('د.ع')
                                    ->readOnly()
                                    ->helperText('يتم احتساب الإجمالي تلقائياً بناءً على المنتجات'),
                            ])->columns(3),

                        \Filament\Forms\Components\Tabs\Tab::make('منتجات الطلب')
                            ->icon('heroicon-m-shopping-bag')
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
                                            ->prefix('د.ع')
                                            ->required()
                                            ->readOnly(),
                                    ])
                                    ->columns(3)
                                    ->defaultItems(1)
                                    ->columnSpanFull()
                                    ->reorderableWithButtons()
                                    ->addActionLabel('إضافة منتج آخر'),
                            ]),
                    ])->columnSpanFull(),
            ]);


    }
}
