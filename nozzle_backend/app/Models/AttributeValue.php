<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class AttributeValue extends Model
{
    use HasFactory;

    protected $guarded = [];

    public function attribute()
    {
        return $this->belongsTo(Attribute::class);
    }

    public function productVariations()
    {
        return $this->belongsToMany(ProductVariation::class);
    }
}
