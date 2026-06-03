<?php

namespace App\Http\Controllers;

use App\Models\Favorite;
use App\Models\User;
use App\Helpers\JWTHelper;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    /**
     * Helper to resolve the user ID from request, Authorization header, or phone fallback.
     */
    private function resolveUserId(Request $request, ?int $userId = null): ?int
    {
        // 1. If we have a user ID, check if it exists in db
        if ($userId) {
            if (User::where('id', $userId)->exists()) {
                return $userId;
            }
        }

        // 2. Try to get user ID from Authorization header
        $authHeader = $request->header('Authorization');
        if ($authHeader && preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
            $token = $matches[1];
            try {
                $payload = JWTHelper::decode($token);
                if ($payload && isset($payload['sub'])) {
                    $email = $payload['sub'];
                    $user = User::where('email', $email)->orWhere('phone', $email)->first();
                    if ($user) {
                        return $user->id;
                    }
                }
            } catch (\Exception $e) {
                // Ignore
            }
        }

        // 3. Fallback: if we have a phone number in the request, try to lookup
        $phone = $request->input('phone') ?: $request->input('customer_phone') ?: $request->query('phone');
        if ($phone) {
            $user = User::where('phone', $phone)->first();
            if ($user) {
                return $user->id;
            }
        }

        return $userId;
    }

    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $userId = $this->resolveUserId($request, $request->query('user_id'));
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
            'data' => $favorites
        ]);
    }

    public function store(Request $request)
    {
        $resolvedUserId = $this->resolveUserId($request, $request->input('user_id'));
        if ($resolvedUserId) {
            $request->merge(['user_id' => $resolvedUserId]);
        }

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

    public function destroy(Request $request, $productId = null)
    {
        $userId = $this->resolveUserId($request, $request->query('user_id'));
        $productId = $productId ?: $request->query('product_id') ?: $request->input('product_id');

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
        $userId = $this->resolveUserId($request, $request->query('user_id'));
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

