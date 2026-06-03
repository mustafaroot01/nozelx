<?php
 
namespace App\Filament\Admin\Resources\Banners\Schemas;
 
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;
use Filament\Forms\Get;
 
class BannerForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('title')
                    ->label('العنوان (اختياري)'),
                TextInput::make('subtitle')
                    ->label('العنوان الفرعي (اختياري)'),
                FileUpload::make('image')
                    ->label('الصورة')
                    ->image()
                    ->directory('banners')
                    ->required()
                    ->helperText('القياس الموصى به: 1024 × 500 بكسل (نسبة 2:1)'),
                
                Select::make('category_id')
                    ->label('القسم الرئيسي (اختياري)')
                    ->relationship('category', 'name')
                    ->searchable()
                    ->preload()
                    ->live(),
                
                Select::make('subcategory_id')
                    ->label('القسم الفرعي (اختياري)')
                    ->options(fn (Get $get) => \App\Models\Category::where('parent_id', $get('category_id'))->pluck('name', 'id'))
                    ->searchable()
                    ->preload()
                    ->live()
                    ->visible(fn (Get $get) => filled($get('category_id'))),

                Select::make('brand_id')
                    ->label('الشركة المصنعة / الفئة (اختياري)')
                    ->relationship('brand', 'name')
                    ->searchable()
                    ->preload(),

                Select::make('product_id')
                    ->label('المنتج المرتبط (اختياري)')
                    ->relationship('product', 'name')
                    ->searchable()
                    ->preload(),

                TextInput::make('link_url')
                    ->label('رابط خارجي URL (اختياري)')
                    ->url(),
                
                TextInput::make('order_index')
                    ->label('ترتيب العرض')
                    ->numeric()
                    ->default(0),
                Toggle::make('is_active')
                    ->label('نشط')
                    ->default(true),
            ]);
    }
}
