<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class ProductTag extends Model
{
    use HasFactory;

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
        'is_active' => 'boolean',
    ];

    public function products()
    {
        return $this->belongsToMany(Product::class, 'product_tag_items', 'tag_id', 'product_id');
    }

    public function parent()
    {
        return $this->belongsTo(ProductTag::class, 'parent_id');
    }

    public function subTags()
    {
        return $this->hasMany(ProductTag::class, 'parent_id')->orderBy('sort_order');
    }

    public function brand()
    {
        return $this->belongsTo(Brand::class);
    }
}
