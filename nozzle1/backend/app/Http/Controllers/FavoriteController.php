<?php

namespace App\Http\Controllers;

use App\Models\Favorite;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $userId = $request->query('user_id');
        if (!$userId) {
            return response()->json(['success' => false, 'message' => 'User ID is required']);
        }

        $favorites = Favorite::where('user_id', $userId)
            ->with(['product.category', 'product.brandRelation'])
            ->get()
            ->map(function ($fav) {
                if (!$fav->product) return null;
                
                $product = $fav->product;
                return [
                    'id' => $fav->id,
                    'user_id' => $fav->user_id,
                    'product_id' => $fav->product_id,
                    'product' => [
                        'id' => $product->id,
                        'name' => $product->name,
                        'name_ar' => $product->name_ar ?? $product->name,
                        'description' => $product->description,
                        'description_ar' => $product->description_ar ?? $product->description,
                        'brand' => $product->brandRelation?->name ?? (is_string($product->brand) ? $product->brand : ''),
                        'brand_ar' => $product->brandRelation?->name_ar ?? $product->brandRelation?->name ?? (is_string($product->brand) ? $product->brand : ''),
                        'price' => (double) $product->price,
                        'old_price' => $product->old_price ? (double) $product->old_price : null,
                        'image' => $product->image ? (str_starts_with($product->image, 'http') ? $product->image : asset('storage/' . $product->image)) : null,
                        'image_url' => $product->image ? (str_starts_with($product->image, 'http') ? $product->image : asset('storage/' . $product->image)) : null,
                        'images' => is_array($product->images) ? array_map(fn($img) => str_starts_with($img, 'http') ? $img : asset('storage/' . $img), $product->images) : [],
                        'is_available' => (bool) $product->is_available,
                        'is_featured' => (bool) $product->is_featured,
                        'home_section' => $product->home_section ?? 'none',
                        'quantity' => (int) $product->quantity,
                        'in_stock' => $product->quantity > 0 && $product->is_available,
                        'is_low_stock' => $product->quantity <= ($product->low_stock_threshold ?? 5),
                        'features' => is_array($product->features) ? $product->features : [],
                        'specifications' => is_array($product->specifications) ? $product->specifications : new \stdClass(),
                        'category_id' => $product->category_id,
                        'category_name' => $product->category?->name_ar ?? $product->category?->name,
                        'created_at' => $product->created_at,
                    ]
                ];
            })
            ->filter()
            ->values();

        return response()->json([
            'success' => true,
            'data' => [
                'favorites' => $favorites
            ]
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'product_id' => 'required|exists:products,id',
        ]);

        $favorite = Favorite::updateOrCreate([
            'user_id' => $request->user_id,
            'product_id' => $request->product_id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Product added to favorites',
            'data' => $favorite
        ]);
    }

    public function destroy(Request $request)
    {
        $userId = $request->query('user_id');
        $productId = $request->query('product_id');

        if (!$userId || !$productId) {
             return response()->json(['success' => false, 'message' => 'User ID and Product ID are required']);
        }

        Favorite::where('user_id', $userId)
            ->where('product_id', $productId)
            ->delete();

        return response()->json([
            'success' => true,
            'message' => 'Product removed from favorites'
        ]);
    }

    public function check(Request $request)
    {
        $userId = $request->query('user_id');
        $productId = $request->query('product_id');

        $isFavorite = Favorite::where('user_id', $userId)
            ->where('product_id', $productId)
            ->exists();

        return response()->json([
            'success' => true,
            'data' => ['is_favorite' => $isFavorite]
        ]);
    }
}
