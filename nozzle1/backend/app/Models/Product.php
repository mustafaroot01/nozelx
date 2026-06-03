<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $guarded = [];

    protected $casts = [
        'images' => 'array',
        'is_active' => 'boolean',
        'is_available' => 'boolean',
        'is_featured' => 'boolean',
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function brand()
    {
        return $this->belongsTo(Brand::class);
    }

    public function brandRelation()
    {
        return $this->belongsTo(Brand::class, 'brand_id');
    }

    public function reviews()
    {
        return $this->hasMany(ProductReview::class);
    }

    public function variations()
    {
        return $this->hasMany(ProductVariation::class);
    }

    public function tags()
    {
        return $this->belongsToMany(ProductTag::class, 'product_product_tag');
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    public function scopePublished($query)
    {
        return $query->where('status', 'published')
                     ->where('is_active', true)
                     ->latest()
                     ->orderBy('is_featured', 'desc');
    }
}
