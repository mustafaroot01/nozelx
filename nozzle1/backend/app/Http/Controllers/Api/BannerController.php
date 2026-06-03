<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Banner;
use Illuminate\Http\JsonResponse;

class BannerController extends Controller
{
    /**
     * Display a listing of active banners for the mobile app.
     */
    public function index(): JsonResponse
    {
        $banners = Banner::where('is_active', true)
            ->orderBy('sort_order', 'asc')
            ->get()
            ->map(function ($banner) {
                return [
                    'id' => $banner->id,
                    'title' => $banner->title,
                    'subtitle' => $banner->subtitle,
                    'image_url' => $banner->image ? (str_starts_with($banner->image, 'http') ? $banner->image : asset('storage/' . $banner->image)) : null,
                    'link' => $banner->link,
                    'category_id' => $banner->category_id,
                    'subcategory_id' => $banner->subcategory_id,
                    'brand_id' => $banner->brand_id,
                    'product_id' => $banner->product_id,
                    'link_url' => $banner->link_url,
                ];
            });

        return response()->json([
            'status' => 'success',
            'data' => $banners
        ]);
    }
}
