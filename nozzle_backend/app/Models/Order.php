<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $guarded = [];

    public $timestamps = false;

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($model) {
            if (!$model->created_at) {
                $model->created_at = now()->toDateTimeString();
            }
        });
    }

    protected $casts = [
        'shipping_address' => 'array',
        'status_history' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function coupon()
    {
        return $this->belongsTo(Coupon::class);
    }

    // Alias for compatibility
    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function getCustomerAddressAttribute()
    {
        return $this->attributes['customer_address'] ?? $this->attributes['address'] ?? null;
    }

    public function getAddressAttribute()
    {
        return $this->attributes['address'] ?? $this->attributes['customer_address'] ?? null;
    }
}
