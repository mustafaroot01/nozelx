<?php

namespace App\Filament\Resources\Users\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class UserForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                \Filament\Forms\Components\Tabs::make('إدارة الحساب')
                    ->tabs([
                        \Filament\Forms\Components\Tabs\Tab::make('المعلومات الشخصية')
                            ->icon('heroicon-m-user')
                            ->schema([
                                \Filament\Forms\Components\FileUpload::make('avatar')
                                    ->label('الصورة الشخصية')
                                    ->image()
                                    ->avatar()
                                    ->imageEditor()
                                    ->directory('avatars')
                                    ->columnSpanFull()
                                    ->alignCenter(),
                                TextInput::make('name')
                                    ->label('الاسم الكامل')
                                    ->placeholder('مثلاً: أحمد محمد')
                                    ->required()
                                    ->maxLength(255),
                                TextInput::make('email')
                                    ->label('البريد الإلكتروني')
                                    ->placeholder('name@example.com')
                                    ->email()
                                    ->required()
                                    ->unique(ignoreRecord: true)
                                    ->maxLength(255),
                                TextInput::make('phone')
                                    ->label('رقم الهاتف')
                                    ->placeholder('07XXXXXXXXX')
                                    ->tel()
                                    ->maxLength(255),
                            ])->columns(2),

                        \Filament\Forms\Components\Tabs\Tab::make('الأمان والصلاحيات')
                            ->icon('heroicon-m-lock-closed')
                            ->schema([
                                TextInput::make('password')
                                    ->label('كلمة المرور')
                                    ->placeholder('أدخل كلمة مرور قوية')
                                    ->password()
                                    ->dehydrated(fn ($state) => filled($state))
                                    ->required(fn (string $context): bool => $context === 'create')
                                    ->maxLength(255)
                                    ->helperText('اتركه فارغاً إذا كنت لا تريد تغيير كلمة المرور الحالية'),
                                \Filament\Forms\Components\Toggle::make('is_admin')
                                    ->label('صلاحية مسؤول (مدير)')
                                    ->helperText('منح المستخدم صلاحيات كاملة للدخول إلى لوحة التحكم')
                                    ->default(false),
                                DateTimePicker::make('email_verified_at')
                                    ->label('تاريخ التوثيق')
                                    ->placeholder('تاريخ توثيق البريد الإلكتروني')
                                    ->native(false),
                            ])->columns(2),
                    ])->columnSpanFull(),
            ]);


    }
}
