<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\ServiceResource\Pages;
use App\Models\Service;
use App\Filament\Admin\Resources\ServiceResource\Schemas\ServiceForm;
use App\Filament\Admin\Resources\ServiceResource\Tables\ServicesTable;
use Filament\Resources\Resource;
use Filament\Tables\Table;

class ServiceResource extends Resource
{
    protected static ?string $model = Service::class;

    protected static string|\Filament\Support\Icons\Heroicon|\BackedEnum|null $navigationIcon = 'heroicon-o-wrench-screwdriver';

    protected static string|\UnitEnum|null $navigationGroup = 'إدارة الخدمات';

    protected static ?string $modelLabel = 'خدمة';

    protected static ?string $pluralModelLabel = 'الخدمات';

    public static function form(\Filament\Schemas\Schema $schema): \Filament\Schemas\Schema
    {
        return ServiceForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return ServicesTable::configure($table);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListServices::route('/'),
            'create' => Pages\CreateService::route('/create'),
            'edit' => Pages\EditService::route('/{record}/edit'),
        ];
    }
}
