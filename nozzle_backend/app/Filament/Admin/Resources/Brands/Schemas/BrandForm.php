<?php

namespace App\Filament\Admin\Resources\Brands\Schemas;

use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Schema;
use Illuminate\Support\Str;

class BrandForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('تفاصيل الماركة')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                TextInput::make('name')
                                    ->label('اسم الماركة (EN)')
                                    ->required()
                                    ->live(onBlur: true)
                                    ->afterStateUpdated(function (string $operation, $state, $set) {
                                        if ($operation !== 'create') return;
                                        $slug = \Illuminate\Support\Str::slug($state);
                                        $originalSlug = $slug;
                                        $count = 1;
                                        while (\App\Models\Brand::where('slug', $slug)->exists()) {
                                            $slug = "{$originalSlug}-{$count}";
                                            $count++;
                                        }
                                        $set('slug', $slug);
                                    })
                                    ->maxLength(255),
                                
                                TextInput::make('name_ar')
                                    ->label('اسم الماركة (AR)')
                                    ->required()
                                    ->maxLength(255),
                                
                                TextInput::make('slug')
                                    ->label('الرابط الفريد (Slug)')
                                    ->required()
                                    ->unique(ignoreRecord: true, modifyRuleUsing: fn ($rule) => $rule)
                                    ->maxLength(255),

                                TextInput::make('sort_order')
                                    ->label('ترتيب العرض')
                                    ->numeric()
                                    ->default(0),
                            ]),

                        Toggle::make('is_active')
                            ->label('نشط')
                            ->default(true),

                        FileUpload::make('logo')
                            ->label('شعار الماركة (Logo)')
                            ->image()
                            ->directory('brands')
                            ->helperText('القياس الموصى به: مربع (200 × 200 بكسل) أو نسبة 1:1'),

                        FileUpload::make('image')
                            ->label('صورة الماركة (Image - احتياطي)')
                            ->image()
                            ->directory('brands')
                            ->helperText('يمكنك رفع نفس الشعار هنا للتوافقية'),
                    ]),
            ]);
    }
}

