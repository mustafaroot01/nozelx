<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Brand;
use Illuminate\Http\JsonResponse;

class BrandController extends Controller
{
    public function index(): JsonResponse
    {
        $brands = Brand::where('is_active', true)
            ->orderBy('sort_order')
            ->get()
            ->map(function ($brand) {
                return [
                    'id' => $brand->id,
                    'name' => $brand->name,
                    'name_ar' => $brand->name_ar ?? $brand->name,
                    'logo' => $brand->logo ? (str_starts_with($brand->logo, 'http') ? $brand->logo : asset('storage/' . $brand->logo)) : ($brand->image ? (str_starts_with($brand->image, 'http') ? $brand->image : asset('storage/' . $brand->image)) : null),
                    'slug' => $brand->slug,
                ];
            });

        return response()->json([
            'status' => 'success',
            'data' => $brands
        ]);
    }
}
