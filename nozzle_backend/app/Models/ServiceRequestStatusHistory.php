<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ServiceRequestStatusHistory extends Model
{
    use HasFactory;

    protected $table = 'service_request_status_history';
    protected $guarded = [];
    public $timestamps = false; // only has created_at

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($model) {
            if (!$model->created_at) {
                $model->created_at = now()->toDateTimeString();
            }
        });
    }
}
