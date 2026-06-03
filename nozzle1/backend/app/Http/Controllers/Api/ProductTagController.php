<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProductTag;
use Illuminate\Http\JsonResponse;

class ProductTagController extends Controller
{
    public function index(): JsonResponse
    {
        $tags = ProductTag::where('is_active', true)
            ->orderBy('sort_order')
            ->get()
            ->map(function ($tag) {
                return [
                    'id' => $tag->id,
                    'name' => $tag->name,
                    'image' => $tag->image ? (str_starts_with($tag->image, 'http') ? $tag->image : asset('storage/' . $tag->image)) : null,
                    'type' => $tag->type,
                    'brand_id' => $tag->brand_id,
                ];
            });

        return response()->json([
            'status' => 'success',
            'data' => $tags
        ]);
    }
}
