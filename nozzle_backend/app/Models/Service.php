<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Service extends Model
{
    use HasFactory;

    protected $table = 'services';
    protected $guarded = [];
    public $timestamps = false; // Handle timestamps manually

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($model) {
            if (!$model->created_at) {
                $model->created_at = now()->toDateTimeString();
            }
            if (!$model->updated_at) {
                $model->updated_at = now()->toDateTimeString();
            }
        });

        static::updating(function ($model) {
            $model->updated_at = now()->toDateTimeString();
        });
    }

    protected $casts = [
        'gallery_urls' => 'array',
        'tags' => 'array',
        'working_hours' => 'array',
        'is_available' => 'boolean',
        'is_featured' => 'boolean',
        'base_price' => 'float',
        'rating' => 'float',
    ];

    public function options()
    {
        return $this->hasMany(ServiceOption::class, 'service_id');
    }

    public function bookings()
    {
        return $this->hasMany(ServiceBooking::class, 'service_id');
    }
}
