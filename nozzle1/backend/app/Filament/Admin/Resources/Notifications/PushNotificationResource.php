<?php

namespace App\Filament\Admin\Resources\Notifications;

use App\Filament\Admin\Resources\Notifications\Pages\ManagePushNotifications;
use App\Models\PushNotification;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Forms\Get;
use Filament\Forms\Set;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Actions\EditAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;

class PushNotificationResource extends Resource
{
    protected static ?string $model = PushNotification::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-bell';
    protected static string|\UnitEnum|null $navigationGroup = 'التسويق والمحتوى';
    protected static ?string $navigationLabel = 'إرسال إشعار';
    protected static ?string $modelLabel = 'إشعار';
    protected static ?string $pluralModelLabel = 'الإشعارات الترويجية';

    public static function form(\Filament\Schemas\Schema $schema): \Filament\Schemas\Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('title')
                    ->label('عنوان الإشعار')
                    ->required()
                    ->maxLength(255),
                Forms\Components\Textarea::make('body')
                    ->label('نص الإشعار')
                    ->required()
                    ->columnSpanFull(),
                Forms\Components\Select::make('type')
                    ->label('نوع الإشعار')
                    ->options([
                        'general' => 'عام لجميع المستخدمين',
                        'personal' => 'مخصص لمستخدم معين',
                        'promo' => 'عرض ترويجي',
                    ])
                    ->default('general')
                    ->required()
                    ->live(),
                Forms\Components\Select::make('user_id')
                    ->label('المستخدم المستهدف')
                    ->relationship('user', 'name')
                    ->searchable()
                    ->visible(fn (Get $get) => $get('type') === 'personal'),
                Forms\Components\FileUpload::make('image')
                    ->label('صورة مرفقة')
                    ->image()
                    ->directory('notifications/images'),
                Forms\Components\TextInput::make('target_url')
                    ->label('الرابط الداخلي')
                    ->placeholder('اختياري: رابط يُفتح عند الضغط على الإشعار'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->label('العنوان')
                    ->searchable(),
                Tables\Columns\TextColumn::make('type')
                    ->label('النوع')
                    ->formatStateUsing(fn(string $state): string => match($state) {
                        'general' => 'عام',
                        'personal' => 'مخصص',
                        'promo' => 'ترويجي',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('user.name')
                    ->label('المستخدم')
                    ->placeholder('الجميع'),
                Tables\Columns\IconColumn::make('is_sent')
                    ->label('تم الإرسال')
                    ->boolean(),
                Tables\Columns\TextColumn::make('sent_at')
                    ->label('وقت الإرسال')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                //
            ])
            ->actions([
                EditAction::make(),
                DeleteAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ManagePushNotifications::route('/'),
        ];
    }
}
