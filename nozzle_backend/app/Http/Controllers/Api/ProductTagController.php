<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProductTag;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProductTagController extends Controller
{
    /**
     * Display a listing of product tags.
     */
    public function index(Request $request): JsonResponse
    {
        $query = ProductTag::query();

        if ($request->has('subcategory_id')) {
            $query->where('subcategory_id', $request->subcategory_id);
        }

        if ($request->has('is_active')) {
            $query->where('is_active', filter_var($request->is_active, FILTER_VALIDATE_BOOLEAN));
        }

        $tags = $query->orderBy('sort_order')
            ->get()
            ->map(function ($tag) {
                return [
                    'id' => $tag->id,
                    'name' => $tag->name,
                    'subcategory_id' => $tag->subcategory_id,
                    'parent_id' => $tag->parent_id ? (int)$tag->parent_id : null,
                    'image_url' => $tag->image_url ? (str_starts_with($tag->image_url, 'http') ? $tag->image_url : asset('storage/' . $tag->image_url)) : null,
                    'icon_emoji' => $tag->icon_emoji,
                    'sort_order' => (int)($tag->sort_order ?? 0),
                    'is_active' => (bool)$tag->is_active,
                    'products_count' => $tag->products()->count(),
                ];
            });

        return response()->json([
            'success' => true,
            'status' => 'success',
            'data' => $tags
        ]);
    }

    /**
     * Store a newly created product tag.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'subcategory_id' => 'required|exists:categories,id',
            'parent_id' => 'nullable|exists:product_tags,id',
            'image_url' => 'nullable|string',
            'icon_emoji' => 'nullable|string',
            'sort_order' => 'nullable|integer',
            'is_active' => 'nullable|boolean',
            'product_ids' => 'nullable|array',
            'product_ids.*' => 'exists:products,id',
        ]);

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('product_tags', 'public');
            $validated['image_url'] = $path;
        }

        $tag = ProductTag::create([
            'name' => $validated['name'],
            'subcategory_id' => $validated['subcategory_id'],
            'parent_id' => $validated['parent_id'] ?? null,
            'image_url' => $validated['image_url'] ?? null,
            'icon_emoji' => $validated['icon_emoji'] ?? null,
            'sort_order' => $validated['sort_order'] ?? 0,
            'is_active' => filter_var($validated['is_active'] ?? true, FILTER_VALIDATE_BOOLEAN),
        ]);

        if (!empty($validated['product_ids'])) {
            $tag->products()->sync($validated['product_ids']);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم إنشاء التصنيف بنجاح',
            'data' => [
                'id' => $tag->id,
                'name' => $tag->name,
                'subcategory_id' => $tag->subcategory_id,
                'parent_id' => $tag->parent_id ? (int)$tag->parent_id : null,
                'image_url' => $tag->image_url ? (str_starts_with($tag->image_url, 'http') ? $tag->image_url : asset('storage/' . $tag->image_url)) : null,
                'icon_emoji' => $tag->icon_emoji,
                'sort_order' => (int)$tag->sort_order,
                'is_active' => (bool)$tag->is_active,
                'products_count' => $tag->products()->count(),
            ]
        ], 201);
    }

    /**
     * Display the specified product tag.
     */
    public function show($id): JsonResponse
    {
        $tag = ProductTag::findOrFail($id);
        
        // Load associated product IDs
        $productIds = $tag->products()->pluck('products.id')->toArray();

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $tag->id,
                'name' => $tag->name,
                'subcategory_id' => $tag->subcategory_id,
                'parent_id' => $tag->parent_id ? (int)$tag->parent_id : null,
                'image_url' => $tag->image_url ? (str_starts_with($tag->image_url, 'http') ? $tag->image_url : asset('storage/' . $tag->image_url)) : null,
                'icon_emoji' => $tag->icon_emoji,
                'sort_order' => (int)$tag->sort_order,
                'is_active' => (bool)$tag->is_active,
                'product_ids' => $productIds,
                'products_count' => count($productIds),
            ]
        ]);
    }

    /**
     * Update the specified product tag.
     */
    public function update(Request $request, $id): JsonResponse
    {
        $tag = ProductTag::findOrFail($id);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'subcategory_id' => 'required|exists:categories,id',
            'parent_id' => 'nullable|exists:product_tags,id',
            'image_url' => 'nullable|string',
            'icon_emoji' => 'nullable|string',
            'sort_order' => 'nullable|integer',
            'is_active' => 'nullable|boolean',
            'product_ids' => 'nullable|array',
            'product_ids.*' => 'exists:products,id',
        ]);

        if ($request->hasFile('image')) {
            // Delete old image if exists
            if ($tag->image_url && !str_starts_with($tag->image_url, 'http')) {
                Storage::disk('public')->delete($tag->image_url);
            }
            $path = $request->file('image')->store('product_tags', 'public');
            $validated['image_url'] = $path;
        }

        // If explicitly passing null to clear the image
        if ($request->input('clear_image') === 'true' || $request->input('clear_image') === true) {
            if ($tag->image_url && !str_starts_with($tag->image_url, 'http')) {
                Storage::disk('public')->delete($tag->image_url);
            }
            $tag->image_url = null;
        }

        $tag->update([
            'name' => $validated['name'],
            'subcategory_id' => $validated['subcategory_id'],
            'parent_id' => $request->has('parent_id') ? $validated['parent_id'] : $tag->parent_id,
            'image_url' => $validated['image_url'] ?? $tag->image_url,
            'icon_emoji' => $request->has('icon_emoji') ? $validated['icon_emoji'] : $tag->icon_emoji,
            'sort_order' => $validated['sort_order'] ?? $tag->sort_order,
            'is_active' => $request->has('is_active') ? filter_var($validated['is_active'], FILTER_VALIDATE_BOOLEAN) : $tag->is_active,
        ]);

        if (isset($validated['product_ids'])) {
            $tag->products()->sync($validated['product_ids']);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم تعديل التصنيف بنجاح',
            'data' => [
                'id' => $tag->id,
                'name' => $tag->name,
                'subcategory_id' => $tag->subcategory_id,
                'parent_id' => $tag->parent_id ? (int)$tag->parent_id : null,
                'image_url' => $tag->image_url ? (str_starts_with($tag->image_url, 'http') ? $tag->image_url : asset('storage/' . $tag->image_url)) : null,
                'icon_emoji' => $tag->icon_emoji,
                'sort_order' => (int)$tag->sort_order,
                'is_active' => (bool)$tag->is_active,
                'products_count' => $tag->products()->count(),
            ]
        ]);
    }

    /**
     * Remove the specified product tag.
     */
    public function destroy($id): JsonResponse
    {
        $tag = ProductTag::findOrFail($id);

        // Delete image from disk if exists
        if ($tag->image_url && !str_starts_with($tag->image_url, 'http')) {
            Storage::disk('public')->delete($tag->image_url);
        }

        $tag->products()->detach();
        $tag->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم حذف التصنيف بنجاح'
        ]);
    }
}
