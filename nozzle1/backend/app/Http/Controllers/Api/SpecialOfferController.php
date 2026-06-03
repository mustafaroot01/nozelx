<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\JsonResponse;

class SpecialOfferController extends Controller
{
    public function index(): JsonResponse
    {
        $offers = Product::where('is_featured', true)
            ->where('is_available', true)
            ->with('category')
            ->get()
            ->map(function ($product) {
                return [
                    'id' => $product->id,
                    'name' => $product->name,
                    'name_ar' => $product->name_ar ?? $product->name,
                    'description' => $product->description,
                    'description_ar' => $product->description_ar ?? $product->description,
                    'price' => (double) $product->price,
                    'old_price' => $product->old_price ? (double) $product->old_price : null,
                    'image_url' => $product->image ? (str_starts_with($product->image, 'http') ? $product->image : asset('storage/' . $product->image)) : null,
                    'category_name' => $product->category?->name_ar ?? $product->category?->name,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => [
                'offers' => $offers
            ]
        ]);
    }
}
