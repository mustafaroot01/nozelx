<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ServiceBooking extends Model
{
    use HasFactory;

    protected $table = 'service_requests';
    protected $guarded = [];
    public $timestamps = false; // We set created_at and updated_at manually or let boot hook handle it since SQLite schema lacks standard laravel types sometimes

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
        'scheduled_date' => 'string',
        'scheduled_time' => 'string',
        'latitude' => 'float',
        'longitude' => 'float',
        'total_price' => 'float',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function service()
    {
        return $this->belongsTo(Service::class, 'service_id');
    }

    public function option()
    {
        return $this->belongsTo(ServiceOption::class, 'service_option_id');
    }

    public function status_history()
    {
        return $this->hasMany(ServiceRequestStatusHistory::class, 'service_request_id');
    }
}
