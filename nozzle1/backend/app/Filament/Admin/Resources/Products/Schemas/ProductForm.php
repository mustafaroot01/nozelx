<?php

namespace App\Filament\Admin\Resources\Products\Schemas;

use App\Models\Brand;
use App\Models\Category;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class ProductForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Grid::make(3)
                    ->schema([
                        Section::make('معلومات المنتج الأساسية')
                            ->description('أدخل اسم المنتج والوصف والتصنيف.')
                            ->schema([
                                TextInput::make('name')
                                    ->label('اسم المنتج (EN)')
                                    ->required()
                                    ->maxLength(255),

                                TextInput::make('name_ar')
                                    ->label('اسم المنتج (AR)')
                                    ->required()
                                    ->maxLength(255),
                                
                                Grid::make(2)
                                    ->schema([
                                        Select::make('category_id')
                                            ->label('التصنيف')
                                            ->relationship('category', 'name')
                                            ->searchable()
                                            ->preload()
                                            ->required(),
                                        
                                        Select::make('brand_id')
                                            ->label('الماركة')
                                            ->relationship('brandRelation', 'name')
                                            ->searchable()
                                            ->preload(),
                                    ]),

                                Textarea::make('description')
                                    ->label('وصف المنتج (EN)')
                                    ->rows(5)
                                    ->columnSpanFull(),

                                Textarea::make('description_ar')
                                    ->label('وصف المنتج (AR)')
                                    ->rows(5)
                                    ->columnSpanFull(),
                            ])
                            ->columnSpan(2),

                        Section::make('حالة الظهور')
                            ->schema([
                                Select::make('status')
                                    ->label('الحالة')
                                    ->options([
                                        'draft' => 'مسودة',
                                        'published' => 'منشور',
                                        'out_of_stock' => 'نفذ من المخزن',
                                    ])
                                    ->default('published')
                                    ->required(),

                                Select::make('home_section')
                                    ->label('الظهور في الرئيسية')
                                    ->options([
                                        'none' => 'لا يظهر',
                                        'featured' => 'المنتجات المميزة',
                                        'best_seller' => 'الأكثر مبيعاً',
                                        'new_arrival' => 'وصل حديثاً',
                                    ])
                                    ->default('none'),

                                Toggle::make('is_featured')
                                    ->label('منتج مميز (يدوي)')
                                    ->default(false),
                                
                                Toggle::make('is_active')
                                    ->label('نشط')
                                    ->default(true),
                            ])
                            ->columnSpan(1),

                        Section::make('التسعير والمخزن')
                            ->description('إدارة السعر والكمية والرموز الشريطية.')
                            ->schema([
                                Grid::make(2)
                                    ->schema([
                                        TextInput::make('price')
                                            ->label('سعر البيع')
                                            ->numeric()
                                            ->prefix('IQD')
                                            ->required(),

                                        TextInput::make('cost_price')
                                            ->label('سعر التكلفة')
                                            ->numeric()
                                            ->prefix('IQD'),
                                    ]),

                                TextInput::make('old_price')
                                    ->label('السعر القديم (قبل الخصم)')
                                    ->numeric()
                                    ->prefix('IQD'),

                                Grid::make(2)
                                    ->schema([
                                        TextInput::make('sku')
                                            ->label('Code (SKU)')
                                            ->unique(ignoreRecord: true),
                                        
                                        TextInput::make('barcode')
                                            ->label('المعرف (Barcode)'),
                                    ]),

                                TextInput::make('quantity')
                                    ->label('الكمية المتوفرة')
                                    ->numeric()
                                    ->default(0)
                                    ->required(),
                            ])
                            ->columnSpan(2),

                        Section::make('الشحن والأبعاد')
                            ->description('أدخل تفاصيل الوزن والأبعاد للشحن.')
                            ->schema([
                                TextInput::make('weight')
                                    ->label('الوزن (كجم)')
                                    ->numeric()
                                    ->prefix('Kg'),
                                
                                TextInput::make('dimensions')
                                    ->label('الأبعاد (طول x عرض x ارتفاع)')
                                    ->placeholder('10x20x30'),
                            ])
                            ->columnSpan(1),

                        Section::make('صور المنتج')
                            ->description('ارفع الصورة الأساسية وصور المعرض.')
                            ->schema([
                                FileUpload::make('image')
                                    ->label('الصورة الأساسية')
                                    ->image()
                                    ->directory('products')
                                    ->required()
                                    ->helperText('القياس الموصى به: 500 × 500 بكسل (أو نسبة 1:1)'),
                                
                                FileUpload::make('images')
                                    ->label('صور إضافية')
                                    ->image()
                                    ->multiple()
                                    ->directory('products/gallery')
                                    ->reorderable()
                                    ->helperText('القياس الموصى به: 500 × 500 بكسل (أو نسبة 1:1)'),
                            ])
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
