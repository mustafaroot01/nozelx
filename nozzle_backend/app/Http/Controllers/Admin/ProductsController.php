<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Brand;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class ProductsController extends Controller
{
    public function index()
    {
        $products = Product::with(['category', 'brandRelation'])->latest()->paginate(10);
        return view('admin.products.index', compact('products'));
    }

    public function create()
    {
        $categories = Category::all();
        $brands = Brand::all();
        return view('admin.products.create', compact('categories', 'brands'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|max:255',
            'name_ar' => 'nullable|max:255',
            'price' => 'required|numeric',
            'old_price' => 'nullable|numeric',
            'category_id' => 'required|exists:categories,id',
            'brand_id' => 'nullable|exists:brands,id',
            'quantity' => 'required|integer',
            'low_stock_threshold' => 'required|integer|min:0',
            'image' => 'nullable|image|max:2048',
            'description' => 'nullable|string',
            'description_ar' => 'nullable|string',
            'home_section' => 'nullable|string|in:featured,best_seller,new_arrival,none',
            'features' => 'nullable|array',
            'specifications' => 'nullable|array',
            'is_available' => 'boolean',
        ]);

        if ($request->hasFile('image')) {
            $validated['image'] = $request->file('image')->store('products', 'public');
        }

        $validated['slug'] = str()->slug($request->name) . '-' . rand(1000, 9999);
        $validated['is_available'] = $request->has('is_available');
        $validated['in_stock'] = $request->quantity > 0;

        // Features & Specs processing (ensure they are clean)
        if ($request->has('features')) {
            $validated['features'] = array_filter($request->features);
        }
        if ($request->has('specifications')) {
            $validated['specifications'] = array_filter($request->specifications);
        }

        Product::create($validated);

        // Clear dashboard cache since data changed
        Cache::forget('admin_dashboard_stats');

        return redirect()->route('admin.products.index')->with('success', 'تم إضافة المنتج بنجاح');
    }
}
