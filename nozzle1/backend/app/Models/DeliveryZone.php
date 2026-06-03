<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DeliveryZone extends Model
{
    protected $guarded = [];

    protected $casts = [
        'is_active' => 'boolean',
        'included_areas' => 'array',
        'delivery_fee' => 'decimal:2',
        'minimum_order_amount' => 'decimal:2',
    ];
}
