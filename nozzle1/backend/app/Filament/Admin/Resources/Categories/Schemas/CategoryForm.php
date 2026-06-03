<?php

namespace App\Filament\Admin\Resources\Categories\Schemas;

use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Forms\Get;
use Filament\Forms\Set;

class CategoryForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('تفاصيل التصنيف')
                    ->description('أدخل اسم التصنيف وحدد إذا كان يتبع لتصنيف أب.')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                TextInput::make('name')
                                    ->label('اسم التصنيف (EN)')
                                    ->required()
                                    ->live(onBlur: true)
                                    ->afterStateUpdated(fn (string $operation, $state, $set) => $operation === 'create' ? $set('slug', \Illuminate\Support\Str::slug($state)) : null)
                                    ->maxLength(255),

                                TextInput::make('name_ar')
                                    ->label('اسم التصنيف (AR)')
                                    ->required()
                                    ->maxLength(255),
                                
                                TextInput::make('slug')
                                    ->label('الرابط (Slug)')
                                    ->required()
                                    ->unique(ignoreRecord: true)
                                    ->maxLength(255),

                                Select::make('parent_id')
                                    ->label('التصنيف الأب')
                                    ->relationship('parent', 'name')
                                    ->searchable()
                                    ->preload(),
                            ]),

                        Grid::make(3)
                            ->schema([
                                TextInput::make('icon')
                                    ->label('الأيقونة (FontAwesome)')
                                    ->placeholder('fa-car'),
                                
                                TextInput::make('color')
                                    ->label('اللون')
                                    ->placeholder('#FF0000'),

                                TextInput::make('order_index')
                                    ->label('الترتيب')
                                    ->numeric()
                                    ->default(0),
                            ]),

                        \Filament\Forms\Components\Textarea::make('description')
                            ->label('وصف التصنيف (EN)')
                            ->rows(3)
                            ->columnSpanFull(),

                        \Filament\Forms\Components\Textarea::make('description_ar')
                            ->label('وصف التصنيف (AR)')
                            ->rows(3)
                            ->columnSpanFull(),

                        Grid::make(2)
                            ->schema([
                                \Filament\Forms\Components\Toggle::make('is_active')
                                    ->label('حالة التفعيل')
                                    ->default(true),

                                \Filament\Forms\Components\Toggle::make('is_featured')
                                    ->label('تصنيف مميز')
                                    ->default(false),
                            ]),
                    ]),

                Section::make('صورة التصنيف')
                    ->schema([
                        FileUpload::make('image')
                            ->label('صورة التصنيف / بنر القسم')
                            ->image()
                            ->directory('categories')
                            ->helperText('القياس الموصى به: مربع (500 × 500 بكسل) أو بنر قسم (1024 × 400 بكسل)'),
                    ]),
            ]);
    }
}
