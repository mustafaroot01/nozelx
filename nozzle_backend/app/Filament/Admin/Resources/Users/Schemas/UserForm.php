<?php

namespace App\Filament\Admin\Resources\Users\Schemas;

use Filament\Schemas\Schema;

class UserForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                \Filament\Schemas\Components\Section::make('معلومات الحساب')
                    ->description('تعديل الاسم والبريد وكلمة المرور.')
                    ->schema([
                        \Filament\Schemas\Components\Grid::make(2)
                            ->schema([
                                \Filament\Forms\Components\TextInput::make('name')
                                    ->label('الاسم')
                                    ->required()
                                    ->maxLength(255),
                                
                                \Filament\Forms\Components\TextInput::make('email')
                                    ->label('البريد الإلكتروني')
                                    ->email()
                                    ->required()
                                    ->unique(ignoreRecord: true),

                                \Filament\Forms\Components\TextInput::make('phone')
                                    ->label('رقم الهاتف')
                                    ->tel(),

                                \Filament\Forms\Components\TextInput::make('password')
                                    ->label('كلمة المرور')
                                    ->password()
                                    ->dehydrated(fn ($state) => filled($state))
                                    ->required(fn (string $context): bool => $context === 'create'),
                            ]),

                        \Filament\Forms\Components\Select::make('roles')
                            ->label('الصلاحيات / الأدوار')
                            ->relationship('roles', 'name')
                            ->multiple()
                            ->preload()
                            ->searchable(),
                        
                        \Filament\Forms\Components\Toggle::make('is_admin')
                            ->label('مشرف (Admin)')
                            ->default(false),
                    ]),
            ]);
    }
}
