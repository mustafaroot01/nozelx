<?php

namespace App\Filament\Admin\Resources\ServiceBookingResource\Tables;

use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\BadgeColumn;
use Filament\Tables\Table;
use Filament\Actions\EditAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;

class ServiceBookingsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('service.title_ar')
                    ->label('الخدمة')
                    ->sortable(),

                TextColumn::make('customer_name')
                    ->label('العميل')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('customer_phone')
                    ->label('الهاتف')
                    ->searchable(),

                TextColumn::make('booking_date')
                    ->label('الموعد')
                    ->dateTime()
                    ->sortable(),

                TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'confirmed' => 'success',
                        'completed' => 'info',
                        'cancelled' => 'danger',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'قيد الانتظار',
                        'confirmed' => 'تم التأكيد',
                        'completed' => 'تم الإنجاز',
                        'cancelled' => 'ملغي',
                        default => $state,
                    }),

                TextColumn::make('created_at')
                    ->label('تاريخ الطلب')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                \Filament\Tables\Filters\SelectFilter::make('service')
                    ->label('الخدمة')
                    ->relationship('service', 'title_ar'),
                
                \Filament\Tables\Filters\SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'pending' => 'قيد الانتظار',
                        'confirmed' => 'تم التأكيد',
                        'completed' => 'تم الإنجاز',
                        'cancelled' => 'ملغي',
                    ]),
            ])
            ->actions([
                EditAction::make(),
                DeleteAction::make(),
            ])
            ->bulkActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
