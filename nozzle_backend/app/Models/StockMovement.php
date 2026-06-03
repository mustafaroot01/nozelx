<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class StockMovement extends Model
{
    protected $table = 'stock_movements';
    public $timestamps = false;

    protected $fillable = [
        'product_id',
        'type',
        'quantity_change',
        'quantity_before',
        'quantity_after',
        'reason',
        'invoice_number',
        'created_by',
        'created_at'
    ];

    protected $casts = [
        'created_at' => 'datetime',
    ];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
