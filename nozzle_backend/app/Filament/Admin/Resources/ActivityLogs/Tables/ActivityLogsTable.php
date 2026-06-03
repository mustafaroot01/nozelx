<?php

namespace App\Filament\Admin\Resources\ActivityLogs\Tables;

use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ActivityLogsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('created_at')
                    ->label('الوقت')
                    ->dateTime()
                    ->sortable(),

                TextColumn::make('causer.name')
                    ->label('المسؤول')
                    ->searchable(),

                TextColumn::make('description')
                    ->label('العملية')
                    ->searchable(),

                TextColumn::make('subject_type')
                    ->label('النوع')
                    ->toggleable(isToggledHiddenByDefault: true),

                TextColumn::make('properties')
                    ->label('التفاصيل')
                    ->limit(50)
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('created_at', 'desc');
    }
}
