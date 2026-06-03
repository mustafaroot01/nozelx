<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\JsonResponse;

class CategoryController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(): JsonResponse
    {
        $parentId = request('parent_id');
        $includeChildren = request('include_children', false);
        
        $query = Category::withCount('products')
            ->orderBy('order_index');
            
        if ($parentId !== null) {
            $query->where('parent_id', $parentId);
        } else {
            $query->whereNull('parent_id');
        }

        $categories = $query->get()->map(function ($category) use ($includeChildren) {
            $data = [
                'id' => $category->id,
                'name' => $category->name,
                'name_ar' => $category->name_ar ?? $category->name,
                'description' => $category->description,
                'description_ar' => $category->description_ar ?? $category->description,
                'icon' => $category->icon ?? 'folder',
                'color' => $category->color ?? '#1E4DB7',
                'order_index' => $category->order_index,
                'products_count' => $category->products_count,
                'has_subcategories' => $category->subCategories->count() > 0,
                'image_url' => $category->image ? (str_starts_with($category->image, 'http') ? $category->image : url('storage/' . $category->image)) : null,
            ];

            if ($includeChildren) {
                $data['sub_categories'] = $category->subCategories->map(function($sub) {
                    return [
                        'id' => $sub->id,
                        'name' => $sub->name,
                        'name_ar' => $sub->name_ar ?? $sub->name,
                        'image_url' => $sub->image ? (str_starts_with($sub->image, 'http') ? $sub->image : url('storage/' . $sub->image)) : null,
                        'products_count' => $sub->products()->count(),
                    ];
                });
            }

            return $data;
        });
        
        return response()->json([
            'status' => 'success',
            'data' => $categories
        ]);
    }
}
