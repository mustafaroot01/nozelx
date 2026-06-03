<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Banner;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class BannersController extends Controller
{
    public function index()
    {
        $banners = Banner::orderBy('sort_order')->get();
        return view('admin.banners.index', compact('banners'));
    }

    public function create()
    {
        $categories = Category::where('is_active', true)->get();
        $products = Product::all();
        return view('admin.banners.create', compact('categories', 'products'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|max:255',
            'subtitle' => 'nullable|max:255',
            'image' => 'required|image|max:2048',
            'link' => 'nullable|string',
            'is_active' => 'boolean',
        ]);

        if ($request->hasFile('image')) {
            $validated['image'] = $request->file('image')->store('banners', 'public');
        }

        $validated['is_active'] = $request->has('is_active');
        $validated['sort_order'] = Banner::max('sort_order') + 1;

        Banner::create($validated);

        return redirect()->route('admin.banners.index')->with('success', 'تم إضافة البانر بنجاح');
    }

    public function edit(Banner $banner)
    {
        $categories = Category::where('is_active', true)->get();
        $products = Product::all();
        return view('admin.banners.edit', compact('banner', 'categories', 'products'));
    }

    public function update(Request $request, Banner $banner)
    {
        $validated = $request->validate([
            'title' => 'required|max:255',
            'subtitle' => 'nullable|max:255',
            'image' => 'nullable|image|max:2048',
            'link' => 'nullable|string',
            'is_active' => 'boolean',
        ]);

        if ($request->hasFile('image')) {
            // Delete old image
            if ($banner->image) {
                Storage::disk('public')->delete($banner->image);
            }
            $validated['image'] = $request->file('image')->store('banners', 'public');
        }

        $validated['is_active'] = $request->has('is_active');

        $banner->update($validated);

        return redirect()->route('admin.banners.index')->with('success', 'تم تحديث البانر بنجاح');
    }

    public function destroy(Banner $banner)
    {
        if ($banner->image) {
            Storage::disk('public')->delete($banner->image);
        }
        $banner->delete();
        return redirect()->route('admin.banners.index')->with('success', 'تم حذف البانر بنجاح');
    }

    public function toggle(Banner $banner)
    {
        $banner->update(['is_active' => !$banner->is_active]);
        return back()->with('success', 'تم تغيير حالة البانر');
    }
}
