<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\ServiceBookingResource\Pages;
use App\Models\ServiceBooking;
use App\Filament\Admin\Resources\ServiceBookingResource\Schemas\ServiceBookingForm;
use App\Filament\Admin\Resources\ServiceBookingResource\Tables\ServiceBookingsTable;
use Filament\Resources\Resource;
use Filament\Tables\Table;

class ServiceBookingResource extends Resource
{
    protected static ?string $model = ServiceBooking::class;

    protected static string|\Filament\Support\Icons\Heroicon|\BackedEnum|null $navigationIcon = 'heroicon-o-calendar-days';

    protected static string|\UnitEnum|null $navigationGroup = 'إدارة الخدمات';

    protected static ?string $modelLabel = 'حجز خدمة';

    protected static ?string $pluralModelLabel = 'حجوزات الخدمات';

    public static function form(\Filament\Schemas\Schema $schema): \Filament\Schemas\Schema
    {
        return ServiceBookingForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return ServiceBookingsTable::configure($table);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListServiceBookings::route('/'),
            'create' => Pages\CreateServiceBooking::route('/create'),
            'edit' => Pages\EditServiceBooking::route('/{record}/edit'),
        ];
    }
}
