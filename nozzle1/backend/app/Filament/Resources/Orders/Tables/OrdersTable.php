<?php

namespace App\Filament\Resources\Orders\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class OrdersTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')
                    ->label('رقم الطلب')
                    ->searchable()
                    ->sortable()
                    ->weight('bold')
                    ->prefix('#'),
                TextColumn::make('customer_name')
                    ->label('العميل')
                    ->searchable()
                    ->sortable()
                    ->description(fn ($record) => $record->customer_phone),
                TextColumn::make('total_amount')
                    ->label('الإجمالي')
                    ->money('IQD')
                    ->sortable()
                    ->color('primary')
                    ->weight('bold'),
                \Filament\Tables\Columns\SelectColumn::make('status')
                    ->label('الحالة')
                    ->options([
                        'pending' => 'قيد الانتظار',
                        'processing' => 'جاري المعالجة',
                        'shipped' => 'تم الشحن',
                        'delivered' => 'تم التوصيل',
                        'cancelled' => 'تم الإلغاء',
                    ])
                    ->sortable()
                    ->selectablePlaceholder(false),
                TextColumn::make('payment_method')
                    ->label('الدفع')
                    ->badge()
                    ->color('gray')
                    ->formatStateUsing(fn ($state) => match ($state) {
                        'cash' => 'نقداً',
                        'wallet' => 'المحفظة',
                        default => $state,
                    })
                    ->sortable(),
                TextColumn::make('created_at')
                    ->label('تاريخ الطلب')
                    ->dateTime('Y-m-d H:i')
                    ->sortable(),
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
