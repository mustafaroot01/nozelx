<?php

namespace App\Filament\Admin\Resources\ServiceResource\Schemas;

use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class ServiceForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('معلومات الخدمة')
                    ->schema([
                        TextInput::make('title')
                            ->label('عنوان الخدمة (EN)')
                            ->required(),
                        
                        TextInput::make('title_ar')
                            ->label('عنوان الخدمة (AR)')
                            ->required(),

                        Textarea::make('description')
                            ->label('وصف الخدمة (EN)')
                            ->rows(3),

                        Textarea::make('description_ar')
                            ->label('وصف الخدمة (AR)')
                            ->rows(3),
                        
                        TextInput::make('price')
                            ->label('السعر')
                            ->numeric()
                            ->prefix('IQD'),

                        FileUpload::make('image')
                            ->label('الصورة (بنر)')
                            ->image()
                            ->directory('services')
                            ->required()
                            ->helperText('القياس الموصى به: 800 × 400 بكسل (أو نسبة 2:1)'),

                        Toggle::make('is_active')
                            ->label('نشط')
                            ->default(true),

                        TextInput::make('sort_order')
                            ->label('ترتيب العرض')
                            ->numeric()
                            ->default(0),
                    ])
                    ->columns(2),
            ]);
    }
}
