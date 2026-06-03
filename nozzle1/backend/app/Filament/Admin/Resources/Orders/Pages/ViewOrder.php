<?php

namespace App\Filament\Admin\Resources\Orders\Pages;

use App\Filament\Admin\Resources\Orders\OrderResource;
use Filament\Resources\Pages\ViewRecord;

class ViewOrder extends ViewRecord
{
    protected static string $resource = OrderResource::class;

    protected function getHeaderActions(): array
    {
        return [
            \Filament\Actions\Action::make('print_invoice')
                ->label('طباعة الفاتورة')
                ->icon('heroicon-o-printer')
                ->color('success')
                ->action(function (\App\Models\Order $record) {
                    $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('invoices.invoice', ['order' => $record])
                        ->setOption('isRemoteEnabled', true)
                        ->setOption('isHtml5ParserEnabled', true);
                    return response()->streamDownload(function () use ($pdf) {
                        echo $pdf->stream();
                    }, "invoice-{$record->id}.pdf");
                }),
            \Filament\Actions\EditAction::make(),
        ];
    }
}
