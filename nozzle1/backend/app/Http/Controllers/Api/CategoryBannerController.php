<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Banner;
use Illuminate\Http\JsonResponse;

class CategoryBannerController extends Controller
{
    public function index(): JsonResponse
    {
        $banners = Banner::where('is_active', true)
            ->where('link_type', 'category')
            ->orderBy('order_index')
            ->get()
            ->map(function ($banner) {
                return [
                    'id' => $banner->id,
                    'title' => $banner->title,
                    'image_url' => $banner->image ? (str_starts_with($banner->image, 'http') ? $banner->image : asset('storage/' . $banner->image)) : null,
                    'category_id' => $banner->category_id ?? $banner->link_id,
                    'subcategory_id' => $banner->subcategory_id,
                    'brand_id' => $banner->brand_id,
                    'product_id' => $banner->product_id,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => [
                'banners' => $banners
            ]
        ]);
    }
}
