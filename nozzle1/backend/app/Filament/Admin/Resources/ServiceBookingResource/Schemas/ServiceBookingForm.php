<?php

namespace App\Filament\Admin\Resources\ServiceBookingResource\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class ServiceBookingForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('تفاصيل الحجز')
                    ->schema([
                        Select::make('service_id')
                            ->relationship('service', 'title_ar')
                            ->label('الخدمة')
                            ->required(),
                        
                        Select::make('user_id')
                            ->relationship('user', 'name')
                            ->label('المستخدم')
                            ->searchable(),

                        TextInput::make('customer_name')
                            ->label('اسم العميل')
                            ->required(),

                        TextInput::make('customer_phone')
                            ->label('رقم الهاتف')
                            ->required(),

                        DateTimePicker::make('booking_date')
                            ->label('موعد الحجز'),

                        Select::make('status')
                            ->label('الحالة')
                            ->options([
                                'pending' => 'قيد الانتظار',
                                'confirmed' => 'تم التأكيد',
                                'completed' => 'تم الإنجاز',
                                'cancelled' => 'ملغي',
                            ])
                            ->default('pending')
                            ->required(),

                        Textarea::make('notes')
                            ->label('ملاحظات')
                            ->columnSpanFull(),
                    ])
                    ->columns(2),
            ]);
    }
}
