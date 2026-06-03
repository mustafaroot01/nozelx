<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\AuditLog;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class CategoryController extends Controller
{
    /**
     * Display a listing of categories.
     */
    public function index(Request $request): JsonResponse
    {
        $parentId = $request->input('parent_id');
        $parentOnly = $request->boolean('parent_only', false);
        $includeChildren = $request->boolean('include_children', false);

        $query = Category::withCount(['products' => function($q) {
            $q->where('is_deleted', false);
        }])->orderBy('sort_order');

        if ($parentId !== null) {
            $query->where('parent_id', $parentId);
        } elseif ($parentOnly) {
            $query->whereNull('parent_id');
        } else {
            // Default behavior if neither is specified: get parent categories
            $query->whereNull('parent_id');
        }

        $categories = $query->get()->map(function ($category) use ($includeChildren) {
            return $this->transformCategory($category, $includeChildren);
        });

        return response()->json([
            'status' => 'success',
            'data' => $categories
        ]);
    }

    /**
     * Display the specified category.
     */
    public function show($id): JsonResponse
    {
        $category = Category::withCount(['products' => function($q) {
            $q->where('is_deleted', false);
        }])->find($id);

        if (!$category) {
            return response()->json(['detail' => 'Category not found'], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $this->transformCategory($category, true)
        ]);
    }

    /**
     * Store a newly created category.
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'required|string',
        ]);

        $name = $request->input('name');
        $parentId = $request->input('parent_id');

        $existing = Category::where('name', $name)->where('parent_id', $parentId)->first();
        if ($existing) {
            return response()->json(['detail' => 'Category already exists under this section'], 400);
        }

        $slug = $request->input('slug') ?: $this->generateUniqueSlug($name);

        $cat = new Category();
        $cat->name = $name;
        $cat->description = $request->input('description');
        $cat->parent_id = $parentId;
        $cat->icon_url = $request->input('icon_url');
        $cat->image_url = $request->input('image_url');
        $cat->sort_order = $request->input('sort_order', 0);
        $cat->seo_title = $request->input('seo_title');
        $cat->seo_description = $request->input('seo_description');
        $cat->slug = $slug;
        $cat->is_active = $request->boolean('is_active', true);
        $cat->save();

        AuditLog::create([
            'user_id' => auth()->id() ?: 2,
            'action' => 'CREATE_CATEGORY',
            'details' => "Created category {$cat->name}",
            'timestamp' => now()
        ]);

        return response()->json([
            'status' => 'success',
            'data' => $this->transformCategory($cat)
        ]);
    }

    /**
     * Update the specified category.
     */
    public function update(Request $request, $id): JsonResponse
    {
        $cat = Category::find($id);
        if (!$cat) {
            return response()->json(['detail' => 'Category not found'], 404);
        }

        if ($request->has('name')) {
            $cat->name = $request->input('name');
        }
        if ($request->has('description')) {
            $cat->description = $request->input('description');
        }
        if ($request->has('parent_id')) {
            $cat->parent_id = $request->input('parent_id');
        }
        if ($request->has('icon_url')) {
            $cat->icon_url = $request->input('icon_url');
        }
        if ($request->has('image_url')) {
            $cat->image_url = $request->input('image_url');
        }
        if ($request->has('sort_order')) {
            $cat->sort_order = $request->input('sort_order');
        }
        if ($request->has('seo_title')) {
            $cat->seo_title = $request->input('seo_title');
        }
        if ($request->has('seo_description')) {
            $cat->seo_description = $request->input('seo_description');
        }
        if ($request->has('slug')) {
            $cat->slug = $request->input('slug') ?: $this->generateUniqueSlug($cat->name, $id);
        } elseif ($request->has('name')) {
            $cat->slug = $this->generateUniqueSlug($cat->name, $id);
        }
        if ($request->has('is_active')) {
            $cat->is_active = $request->boolean('is_active');
        }

        $cat->save();

        AuditLog::create([
            'user_id' => auth()->id() ?: 2,
            'action' => 'UPDATE_CATEGORY',
            'details' => "Updated category {$cat->name}",
            'timestamp' => now()
        ]);

        return response()->json([
            'status' => 'success',
            'data' => $this->transformCategory($cat)
        ]);
    }

    /**
     * Reorder categories.
     */
    public function reorder(Request $request): JsonResponse
    {
        $sortData = $request->all(); // List of [id => ..., sort_order => ...]
        
        foreach ($sortData as $item) {
            $catId = $item['id'] ?? null;
            $newOrder = $item['sort_order'] ?? null;
            if ($catId !== null && $newOrder !== null) {
                Category::where('id', $catId)->update(['sort_order' => $newOrder]);
            }
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Category sorting updated successfully'
        ]);
    }

    /**
     * Delete the specified category.
     */
    public function destroy($id): JsonResponse
    {
        $cat = Category::find($id);
        if (!$cat) {
            return response()->json(['detail' => 'Category not found'], 404);
        }

        $categoryName = $cat->name;
        $cat->delete();

        AuditLog::create([
            'user_id' => auth()->id() ?: 2,
            'action' => 'DELETE_CATEGORY',
            'details' => "Deleted category {$categoryName}",
            'timestamp' => now()
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Category deleted successfully'
        ]);
    }

    private function transformCategory($category, $includeChildren = false): array
    {
        $imageUrl = $category->image_url;
        if ($imageUrl && !str_starts_with($imageUrl, 'http')) {
            $imageUrl = rtrim(request()->getSchemeAndHttpHost(), '/') . '/' . ltrim($imageUrl, '/');
        }

        $data = [
            'id' => $category->id,
            'name' => $category->name,
            'description' => $category->description,
            'parent_id' => $category->parent_id,
            'icon_url' => $category->icon_url,
            'image_url' => $imageUrl,
            'sort_order' => $category->sort_order,
            'seo_title' => $category->seo_title,
            'seo_description' => $category->seo_description,
            'slug' => $category->slug,
            'is_active' => (bool)$category->is_active,
            'created_at' => $category->created_at ? \Illuminate\Support\Carbon::parse($category->created_at)->toIso8601String() : null,
            'product_count' => $category->products_count ?? $category->products()->where('is_deleted', false)->count(),
        ];

        if ($includeChildren) {
            $subCategoriesData = $category->subCategories->map(function($sub) {
                $subImageUrl = $sub->image_url;
                if ($subImageUrl && !str_starts_with($subImageUrl, 'http')) {
                    $subImageUrl = rtrim(request()->getSchemeAndHttpHost(), '/') . '/' . ltrim($subImageUrl, '/');
                }

                return [
                    'id' => $sub->id,
                    'name' => $sub->name,
                    'parent_id' => $sub->parent_id,
                    'icon_url' => $sub->icon_url,
                    'image_url' => $subImageUrl,
                    'sort_order' => $sub->sort_order,
                    'products_count' => $sub->products()->where('is_deleted', false)->count(),
                    'slug' => $sub->slug,
                    'is_active' => (bool)$sub->is_active,
                ];
            })->toArray();
            
            $data['sub_categories'] = $subCategoriesData;
            $data['subcategories'] = $subCategoriesData;
        }

        return $data;
    }

    private function generateUniqueSlug(string $name, $excludeId = null): string
    {
        $slug = Str::slug($name);
        if (empty($slug)) {
            $slug = "category";
        }
        
        $originalSlug = $slug;
        $i = 1;
        while (true) {
            $query = Category::where('slug', $slug);
            if ($excludeId !== null) {
                $query->where('id', '!=', $excludeId);
            }
            if (!$query->exists()) {
                break;
            }
            $slug = $originalSlug . '-' . $i;
            $i++;
        }
        return $slug;
    }
}
