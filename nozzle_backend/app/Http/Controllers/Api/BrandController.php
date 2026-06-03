<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\JsonResponse;

class BrandController extends Controller
{
    public function index(): JsonResponse
    {
        $products = Product::where('is_deleted', false)->get(['name']);
        
        $brands = [];
        foreach ($products as $p) {
            $brand = $this->extractBrand($p->name);
            if ($brand) {
                $brands[$brand] = true;
            }
        }

        $brandList = [];
        $idx = 1;
        $sortedBrands = array_keys($brands);
        sort($sortedBrands);

        foreach ($sortedBrands as $b) {
            $brandList[] = [
                'id' => $idx++,
                'name' => $b,
                'name_ar' => $b,
                'logo' => '',
                'slug' => \Illuminate\Support\Str::slug($b) ?: 'brand',
                'image' => ''
            ];
        }

        return response()->json([
            'success' => true,
            'status' => 'success',
            'data' => $brandList
        ]);
    }

    private function extractBrand(string $name): string
    {
        $known_brands = [
            "موبيل 1", "موبيل", "كاسترول", "موتول", "يورل", "كيو", "امسويل", 
            "ليكوي مولي", "ليكويمولي", "فرام", "ميجوايرز", "تويوتا", "شل", "توتال"
        ];
        $name_lower = mb_strtolower($name, 'UTF-8');
        foreach ($known_brands as $brand) {
            if (mb_strpos($name_lower, $brand) !== false) {
                return $brand;
            }
        }
        $words = explode(' ', $name);
        $words = array_values(array_filter($words));
        $first_word = count($words) > 0 ? $words[0] : "أخرى";
        if (in_array($first_word, ["فلتر", "سائل", "شامبو", "منظف", "زيت"])) {
            if (count($words) > 2) {
                return $words[2];
            } elseif (count($words) > 1) {
                return $words[1];
            }
        }
        return $first_word;
    }
}
