<?php

namespace App\Filament\Admin\Resources\Coupons;

use App\Filament\Admin\Resources\Coupons\Pages\ManageCoupons;
use App\Models\Coupon;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Actions\EditAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;

class CouponResource extends Resource
{
    protected static ?string $model = Coupon::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-ticket';
    protected static string|\UnitEnum|null $navigationGroup = 'القائمة الرئيسية';
    protected static ?string $navigationLabel = 'الكوبونات';
    protected static ?string $modelLabel = 'كوبون';
    protected static ?string $pluralModelLabel = 'الكوبونات';

    public static function form(\Filament\Schemas\Schema $schema): \Filament\Schemas\Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('code')
                    ->label('رمز الكوبون')
                    ->required()
                    ->unique(ignoreRecord: true),
                Forms\Components\Select::make('type')
                    ->label('نوع الخصم')
                    ->options([
                        'fixed' => 'مبلغ ثابت',
                        'percentage' => 'نسبة مئوية',
                    ])
                    ->required()
                    ->default('percentage'),
                Forms\Components\TextInput::make('value')
                    ->label('قيمة الخصم')
                    ->required()
                    ->numeric(),
                Forms\Components\TextInput::make('min_cart_value')
                    ->label('الحد الأدنى للطلب')
                    ->numeric(),
                Forms\Components\TextInput::make('max_discount')
                    ->label('الحد الأقصى للخصم (لصنف النسبة)')
                    ->numeric(),
                Forms\Components\DateTimePicker::make('starts_at')
                    ->label('تاريخ البداية'),
                Forms\Components\DateTimePicker::make('expires_at')
                    ->label('تاريخ الانتهاء'),
                Forms\Components\TextInput::make('usage_limit')
                    ->label('الحد الأقصى للاستخدام')
                    ->numeric()
                    ->placeholder('اتركه فارغاً للاستخدام غير المحدود'),
                Forms\Components\Toggle::make('is_active')
                    ->label('مفعل')
                    ->default(true),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('code')->label('الرمز')->searchable(),
                Tables\Columns\TextColumn::make('type')->label('النوع')
                    ->formatStateUsing(fn(string $state): string => $state === 'fixed' ? 'مبلغ ثابت' : 'نسبة مئوية'),
                Tables\Columns\TextColumn::make('value')->label('القيمة'),
                Tables\Columns\IconColumn::make('is_active')->label('مفعل')->boolean(),
                Tables\Columns\TextColumn::make('expires_at')->label('ينتهي في')->date(),
            ])
            ->filters([
                //
            ])
            ->actions([
                EditAction::make(),
                DeleteAction::make(),
            ])
            ->bulkActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ManageCoupons::route('/'),
        ];
    }
}
