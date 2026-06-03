<?php

namespace App\Filament\Admin\Resources\Orders\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Enums\TextSize;

class OrderInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Grid::make(3)
                    ->schema([
                        Section::make('معلومات الطلب')
                            ->schema([
                                TextEntry::make('id')
                                    ->label('رقم الطلب'),
                                TextEntry::make('status')
                                    ->label('حالة الطلب')
                                    ->badge()
                                    ->color(fn (string $state): string => match ($state) {
                                        'pending' => 'gray',
                                        'processing' => 'warning',
                                        'shipped' => 'info',
                                        'delivered' => 'success',
                                        'cancelled' => 'danger',
                                    }),
                                TextEntry::make('payment_method')
                                    ->label('طريقة الدفع'),
                                TextEntry::make('created_at')
                                    ->label('تاريخ الطلب')
                                    ->dateTime(),
                            ])
                            ->columnSpan(2),

                        Section::make('معلومات العميل')
                            ->schema([
                                TextEntry::make('customer_name')
                                    ->label('اسم المستلم'),
                                TextEntry::make('user.name')
                                    ->label('حساب المستخدم'),
                                TextEntry::make('user.email')
                                    ->label('البريد الإلكتروني'),
                                TextEntry::make('customer_phone')
                                    ->label('رقم الهاتف'),
                            ])
                            ->columnSpan(1),

                        Section::make('تفاصيل الشحن')
                            ->schema([
                                TextEntry::make('customer_address')
                                    ->label('العنوان'),
                                TextEntry::make('notes')
                                    ->label('ملاحظات العميل'),
                                TextEntry::make('shipping_method')
                                    ->label('طريقة الشحن'),
                                TextEntry::make('tracking_number')
                                    ->label('رقم التتبع'),
                            ])
                            ->columnSpan(2),

                        Section::make('المبالغ')
                            ->schema([
                                TextEntry::make('subtotal')
                                    ->label('المجموع الفرعي')
                                    ->money('IQD'),
                                TextEntry::make('discount_amount')
                                    ->label('الخصم')
                                    ->money('IQD'),
                                TextEntry::make('shipping_amount')
                                    ->label('تكلفة الشحن')
                                    ->money('IQD'),
                                TextEntry::make('total_amount')
                                    ->label('الإجمالي الكلي')
                                    ->money('IQD')
                                    ->size(TextSize::Large)
                                    ->color('primary'),
                            ])
                            ->columnSpan(1),
                    ]),
            ]);
    }
}
