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
            ->orderBy('sort_order', 'asc')
            ->get()
            ->map(function ($banner) {
                $imageUrl = $banner->image_url;
                if ($imageUrl && !str_starts_with($imageUrl, 'http')) {
                    $imageUrl = rtrim(request()->getSchemeAndHttpHost(), '/') . '/' . ltrim($imageUrl, '/');
                }

                return [
                    'id' => $banner->id,
                    'title' => $banner->title,
                    'image_url' => $imageUrl,
                    'category_id' => $banner->category_id,
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
