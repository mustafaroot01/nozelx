<?php

namespace App\Filament\Admin\Resources\Orders\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\Action;
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
                    ->sortable(),

                TextColumn::make('user.name')
                    ->label('الزبون')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'gray',
                        'processing' => 'warning',
                        'shipped' => 'info',
                        'delivered' => 'success',
                        'cancelled' => 'danger',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'قيد الانتظار',
                        'processing' => 'جاري التجهيز',
                        'shipped' => 'تم الشحن',
                        'delivered' => 'تم التوصيل',
                        'cancelled' => 'ملغي',
                    }),

                TextColumn::make('final_amount')
                    ->label('صافي المبلغ')
                    ->money('IQD')
                    ->sortable(),

                TextColumn::make('created_at')
                    ->label('تاريخ الطلب')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                \Filament\Tables\Filters\SelectFilter::make('status')
                    ->label('حالة الطلب')
                    ->options([
                        'pending' => 'قيد الانتظار',
                        'processing' => 'جاري التجهيز',
                        'shipped' => 'تم الشحن',
                        'delivered' => 'تم التوصيل',
                        'cancelled' => 'ملغي',
                    ]),
            ])
            ->actions([
                Action::make('print_invoice')
                    ->label('طباعة الفاتورة')
                    ->icon('heroicon-o-printer')
                    ->color('success')
                    ->action(function (\App\Models\Order $record) {
                        $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('invoices.invoice', ['order' => $record])
                            ->setOption('isRemoteEnabled', true)
                            ->setOption('isHtml5ParserEnabled', true);
                        return response()->streamDownload(function () use ($pdf) {
                            echo $pdf->stream();
                        }, "invoice-{$record->id}.pdf");
                    }),
                EditAction::make(),
            ])
            ->bulkActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
