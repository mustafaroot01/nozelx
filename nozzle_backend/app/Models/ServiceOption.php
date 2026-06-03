<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ServiceOption extends Model
{
    use HasFactory;

    protected $table = 'service_options';
    protected $guarded = [];
    public $timestamps = false;

    public function service()
    {
        return $this->belongsTo(Service::class);
    }
}
