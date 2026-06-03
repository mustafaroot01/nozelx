<?php

namespace App\Filament\Admin\Resources\DeliveryZones\Pages;

use App\Filament\Admin\Resources\DeliveryZones\DeliveryZoneResource;
use Filament\Actions;
use Filament\Resources\Pages\ManageRecords;

class ManageDeliveryZones extends ManageRecords
{
    protected static string $resource = DeliveryZoneResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
