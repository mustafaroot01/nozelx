<?php

namespace App\Filament\Admin\Resources\Notifications\Pages;

use App\Filament\Admin\Resources\Notifications\PushNotificationResource;
use Filament\Actions;
use Filament\Resources\Pages\ManageRecords;

class ManagePushNotifications extends ManageRecords
{
    protected static string $resource = PushNotificationResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make()
                ->label('إرسال إشعار جديد')
                ->mutateFormDataUsing(function (array $data): array {
                    $data['is_sent'] = true;
                    $data['sent_at'] = now();
                    return $data;
                }),
        ];
    }
}
