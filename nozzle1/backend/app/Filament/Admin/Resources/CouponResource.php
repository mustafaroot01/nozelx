<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\CouponResource\Pages;
use App\Models\Coupon;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Grid;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Toggle;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\IconColumn;

class CouponResource extends Resource
{
    protected static ?string $model = Coupon::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-ticket';

    protected static string|\UnitEnum|null $navigationGroup = 'التجارة الإلكترونية';

    protected static ?string $modelLabel = 'كوبون';
    protected static ?string $pluralModelLabel = 'الكوبونات';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Section::make('معلومات الكوبون')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                TextInput::make('code')
                                    ->label('رمز الكوبون')
                                    ->required()
                                    ->unique(ignoreRecord: true)
                                    ->placeholder('مثال: SAVE20'),
                                Select::make('type')
                                    ->label('نوع الخصم')
                                    ->options([
                                        'fixed' => 'مبلغ ثابت',
                                        'percentage' => 'نسبة مئوية',
                                    ])
                                    ->required()
                                    ->default('percentage'),
                                TextInput::make('value')
                                    ->label('قيمة الخصم')
                                    ->numeric()
                                    ->required(),
                                TextInput::make('min_cart_value')
                                    ->label('الحد الأدنى للسلة')
                                    ->numeric()
                                    ->placeholder('0.00'),
                                TextInput::make('max_discount')
                                    ->label('الحد الأقصى للخصم')
                                    ->numeric()
                                    ->placeholder('في حال النسبة المئوية'),
                            ]),
                    ]),
                Section::make('الصلاحية والقيود')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                DateTimePicker::make('starts_at')
                                    ->label('تاريخ البدء'),
                                DateTimePicker::make('expires_at')
                                    ->label('تاريخ الانتهاء'),
                                TextInput::make('usage_limit')
                                    ->label('حد الاستخدام الإجمالي')
                                    ->numeric()
                                    ->placeholder('اتركه فارغاً لغير محدود'),
                                Toggle::make('is_active')
                                    ->label('نشط')
                                    ->default(true),
                            ]),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('code')
                    ->label('الرمز')
                    ->searchable()
                    ->sortable()
                    ->copyable(),
                TextColumn::make('type')
                    ->label('النوع')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'fixed' => 'info',
                        'percentage' => 'success',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'fixed' => 'مبلغ ثابت',
                        'percentage' => 'نسبة مئوية',
                        default => $state,
                    }),
                TextColumn::make('value')
                    ->label('القيمة')
                    ->sortable(),
                TextColumn::make('used_count')
                    ->label('مرات الاستخدام')
                    ->sortable(),
                IconColumn::make('is_active')
                    ->label('نشط')
                    ->boolean(),
                TextColumn::make('expires_at')
                    ->label('تاريخ الانتهاء')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('نشط'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListCoupons::route('/'),
            'create' => Pages\CreateCoupon::route('/create'),
            'edit' => Pages\EditCoupon::route('/{record}/edit'),
        ];
    }
}
