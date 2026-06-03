<?php

namespace App\Filament\Resources\Banners\Schemas;

use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class BannerForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                \Filament\Forms\Components\Section::make('تفاصيل البنر الإعلاني')
                    ->description('تحكم في محتوى وصور الإعلانات المعروضة في التطبيق')
                    ->schema([
                        TextInput::make('title')
                            ->label('عنوان البنر')
                            ->placeholder('أدخل عنواناً جذاباً للإعلان')
                            ->maxLength(255),
                        Select::make('link_type')
                            ->label('نوع الرابط')
                            ->options([
                                'category' => 'قسم معين',
                                'product' => 'منتج معين',
                                'external' => 'رابط خارجي',
                            ])
                            ->native(false),
                        TextInput::make('link_id')
                            ->label('القيمة المرتبطة')
                            ->placeholder('ادخل معرف القسم أو المنتج أو الرابط الخارجي')
                            ->maxLength(255),
                        Toggle::make('is_active')
                            ->label('حالة البنر (نشط)')
                            ->required()
                            ->default(true),
                        FileUpload::make('image')
                            ->label('صورة البنر')
                            ->image()
                            ->directory('banners')
                            ->columnSpanFull()
                            ->required(),
                    ])->columns(2),
            ]);

    }
}
