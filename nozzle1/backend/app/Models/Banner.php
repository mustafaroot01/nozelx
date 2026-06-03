<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Banner extends Model
{
    protected $fillable = [
        'title',
        'subtitle',
        'image',
        'link_type',
        'link_id',
        'link_url',
        'link',
        'is_active',
        'order_index',
        'sort_order',
        'category_id',
        'subcategory_id',
        'brand_id',
        'product_id',
    ];

    public function category()
    {
        return $this->belongsTo(Category::class, 'category_id');
    }

    public function subcategory()
    {
        return $this->belongsTo(Category::class, 'subcategory_id');
    }

    public function brand()
    {
        return $this->belongsTo(Brand::class, 'brand_id');
    }

    public function product()
    {
        return $this->belongsTo(Product::class, 'product_id');
    }
}

