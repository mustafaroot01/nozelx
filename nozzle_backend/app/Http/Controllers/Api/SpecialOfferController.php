<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Banner;
use Illuminate\Http\JsonResponse;

class SpecialOfferController extends Controller
{
    /**
     * Display a listing of special offers (banners linking to products) for client apps.
     */
    public function index(): JsonResponse
    {
        $banners = Banner::where('is_active', true)
            ->where('link_type', 'product')
            ->orderBy('sort_order', 'asc')
            ->get()
            ->map(function ($banner) {
                $imageUrl = $banner->image_url;
                if ($imageUrl && !str_starts_with($imageUrl, 'http')) {
                    $imageUrl = rtrim(request()->getSchemeAndHttpHost(), '/') . '/' . ltrim($imageUrl, '/');
                }
                $mobileImageUrl = $banner->mobile_image_url;
                if ($mobileImageUrl && !str_starts_with($mobileImageUrl, 'http')) {
                    $mobileImageUrl = rtrim(request()->getSchemeAndHttpHost(), '/') . '/' . ltrim($mobileImageUrl, '/');
                }

                return [
                    'id' => $banner->id,
                    'title' => $banner->title,
                    'subtitle' => $banner->subtitle,
                    'description' => $banner->title,
                    'image' => $imageUrl,
                    'image_url' => $imageUrl,
                    'mobile_image_url' => $mobileImageUrl,
                    'link_type' => $banner->link_type ?? 'product',
                    'product_id' => $banner->product_id,
                    'category_id' => $banner->category_id,
                    'external_url' => $banner->external_url,
                    'text_alignment' => $banner->text_alignment ?? 'center',
                    'text_color' => $banner->text_color ?? '#ffffff',
                    'overlay_color' => $banner->overlay_color ?? '#000000',
                    'overlay_opacity' => (double)($banner->overlay_opacity ?? 0.4),
                    'button_text' => $banner->button_text,
                    'sort_order' => $banner->sort_order ?? 0,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => [
                'offers' => $banners
            ]
        ]);
    }
}
