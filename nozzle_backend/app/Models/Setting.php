<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    use HasFactory;

    protected $table = 'system_settings';
    protected $fillable = ['key', 'value'];
    
    // The system_settings table has no created_at, only updated_at
    public $timestamps = false;

    protected static function boot()
    {
        parent::boot();

        static::saving(function ($model) {
            $model->updated_at = now()->toDateTimeString();
        });
    }
}
