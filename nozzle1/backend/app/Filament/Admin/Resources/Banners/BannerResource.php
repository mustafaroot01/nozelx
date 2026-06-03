<?php

namespace App\Filament\Admin\Resources\Banners;

use App\Filament\Admin\Resources\Banners\Pages\CreateBanner;
use App\Filament\Admin\Resources\Banners\Pages\EditBanner;
use App\Filament\Admin\Resources\Banners\Pages\ListBanners;
use App\Filament\Admin\Resources\Banners\Schemas\BannerForm;
use App\Filament\Admin\Resources\Banners\Tables\BannersTable;
use App\Models\Banner;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class BannerResource extends Resource
{
    protected static ?string $model = Banner::class;

    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-photo';
    protected static string|\UnitEnum|null $navigationGroup = 'القائمة الرئيسية';
    protected static ?string $navigationLabel = 'البنرات الإعلانية';
    protected static ?string $modelLabel = 'بنر';
    protected static ?string $pluralModelLabel = 'البنرات الإعلانية';

    public static function form(Schema $schema): Schema
    {
        return BannerForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return BannersTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListBanners::route('/'),
            'create' => CreateBanner::route('/create'),
            'edit' => EditBanner::route('/{record}/edit'),
        ];
    }
}
