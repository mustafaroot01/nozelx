<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class CategoriesController extends Controller
{
    public function index()
    {
        // Get only root categories with their subcategories and products count, paginated
        $categories = Category::whereNull('parent_id')
            ->with(['subCategories', 'parent'])
            ->withCount(['products', 'subCategories'])
            ->orderBy('order_index')
            ->paginate(10);
            
        return view('admin.categories.index', compact('categories'));
    }

    public function create()
    {
        $parentCategories = Category::whereNull('parent_id')->get();
        return view('admin.categories.create', compact('parentCategories'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|max:255',
            'name_ar' => 'nullable|max:255',
            'parent_id' => 'nullable|exists:categories,id',
            'description' => 'nullable|string',
            'image' => 'nullable|image|max:2048',
            'is_active' => 'boolean',
        ]);

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('categories', 'public');
            $validated['image'] = $path;
        }

        $validated['slug'] = Str::slug($request->name);
        $validated['is_active'] = $request->has('is_active');
        $validated['order_index'] = Category::max('order_index') + 1;

        Category::create($validated);

        return redirect()->route('admin.categories.index')->with('success', 'تم إضافة التصنيف بنجاح');
    }

    public function edit(Category $category)
    {
        $parentCategories = Category::whereNull('parent_id')->where('id', '!=', $category->id)->get();
        return view('admin.categories.edit', compact('category', 'parentCategories'));
    }

    public function update(Request $request, Category $category)
    {
        $validated = $request->validate([
            'name' => 'required|max:255',
            'name_ar' => 'nullable|max:255',
            'parent_id' => 'nullable|exists:categories,id',
            'description' => 'nullable|string',
            'image' => 'nullable|image|max:2048',
            'is_active' => 'boolean',
        ]);

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('categories', 'public');
            $validated['image'] = $path;
        }

        $validated['slug'] = Str::slug($request->name);
        $validated['is_active'] = $request->has('is_active');

        $category->update($validated);

        return redirect()->route('admin.categories.index')->with('success', 'تم تحديث التصنيف بنجاح');
    }

    public function destroy(Category $category)
    {
        // Check if has children
        if ($category->subCategories()->count() > 0) {
            return back()->with('error', 'لا يمكن حذف تصنيف يحتوي على أقسام فرعية');
        }

        $category->delete();
        return redirect()->route('admin.categories.index')->with('success', 'تم حذف التصنيف بنجاح');
    }

    public function toggle(Category $category)
    {
        $category->update(['is_active' => !$category->is_active]);
        return back()->with('success', 'تم تغيير حالة التصنيف');
    }
}
