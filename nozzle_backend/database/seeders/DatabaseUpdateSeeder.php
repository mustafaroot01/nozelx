<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;
use App\Models\Brand;
use App\Models\Product;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class DatabaseUpdateSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Disable foreign key checks to truncate tables
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        
        Product::truncate();
        Category::truncate();
        Brand::truncate();
        
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // 1. Create Brands
        $brands = [
            ['name' => 'Shell', 'name_ar' => 'شل', 'slug' => 'shell'],
            ['name' => 'Castrol', 'name_ar' => 'كاسترول', 'slug' => 'castrol'],
            ['name' => 'Mobil', 'name_ar' => 'موبيل', 'slug' => 'mobil'],
            ['name' => 'Nozzle', 'name_ar' => 'نوزل', 'slug' => 'nozzle'],
        ];

        $brandIds = [];
        foreach ($brands as $brandData) {
            $brand = Brand::create($brandData);
            $brandIds[$brandData['name']] = $brand->id;
        }

        // 2. Create Categories
        $categories = [
            [
                'name' => 'Engine Oils',
                'name_ar' => 'زيوت المحركات',
                'slug' => 'engine-oils',
                'icon' => 'oil_barrel',
                'color' => '#E53935',
            ],
            [
                'name' => 'Filters',
                'name_ar' => 'الفلاتر',
                'slug' => 'filters',
                'icon' => 'filter_alt',
                'color' => '#43A047',
            ],
            [
                'name' => 'Fluids',
                'name_ar' => 'السوائل',
                'slug' => 'fluids',
                'icon' => 'water_drop',
                'color' => '#1E88E5',
            ],
            [
                'name' => 'Batteries',
                'name_ar' => 'البطاريات',
                'slug' => 'batteries',
                'icon' => 'battery_charging_full',
                'color' => '#FB8C00',
            ],
        ];

        $categoryIds = [];
        foreach ($categories as $catData) {
            $cat = Category::create($catData);
            $categoryIds[$catData['name']] = $cat->id;
        }

        // 3. Create Products with realistic IQD prices
        $products = [
            [
                'category_id' => $categoryIds['Engine Oils'],
                'brand_id' => $brandIds['Shell'],
                'name' => 'Shell Helix Ultra 5W-40 (4L)',
                'name_ar' => 'شل هيلكس الترا 5W-40 (4 لتر)',
                'description' => 'Fully synthetic motor oil - Shell\'s most advanced formulation for high-performance engines.',
                'description_ar' => 'زيت محرك تخليقي بالكامل - تركيبة شل الأكثر تقدماً للمحركات عالية الأداء.',
                'price' => 55000.00,
                'old_price' => 60000.00,
                'image' => 'https://images.unsplash.com/photo-1635773054018-22c38822450b?q=80&w=1000&auto=format&fit=crop',
                'quantity' => 50,
                'is_available' => true,
                'is_featured' => true,
                'home_section' => 'featured',
                'status' => 'published',
            ],
            [
                'category_id' => $categoryIds['Engine Oils'],
                'brand_id' => $brandIds['Castrol'],
                'name' => 'Castrol Magnatec 10W-40 (4L)',
                'name_ar' => 'كاسترول ماجناتيك 10W-40 (4 لتر)',
                'description' => 'Semi-synthetic motor oil with intelligent molecules that cling to your engine.',
                'description_ar' => 'زيت محرك شبه تخليقي مع جزيئات ذكية تلتصق بمحركك.',
                'price' => 42000.00,
                'old_price' => 45000.00,
                'image' => 'https://images.unsplash.com/photo-159742324403d-d1950bcba4f8?q=80&w=1000&auto=format&fit=crop',
                'quantity' => 40,
                'is_available' => true,
                'is_featured' => true,
                'home_section' => 'best_seller',
                'status' => 'published',
            ],
            [
                'category_id' => $categoryIds['Engine Oils'],
                'brand_id' => $brandIds['Mobil'],
                'name' => 'Mobil 1 0W-40 (4L)',
                'name_ar' => 'موبيل 1 0W-40 (4 لتر)',
                'description' => 'Advanced full synthetic motor oil designed to keep your engine running like new.',
                'description_ar' => 'زيت محرك تخليقي بالكامل متطور مصمم للحفاظ على محركك يعمل وكأنه جديد.',
                'price' => 65000.00,
                'old_price' => 70000.00,
                'image' => 'https://images.unsplash.com/photo-1619641782822-233bc68e5473?q=80&w=1000&auto=format&fit=crop',
                'quantity' => 30,
                'is_available' => true,
                'is_featured' => false,
                'home_section' => 'new_arrival',
                'status' => 'published',
            ],
            [
                'category_id' => $categoryIds['Engine Oils'],
                'brand_id' => $brandIds['Nozzle'],
                'name' => 'Nozzle Premium 20W-50 (4L)',
                'name_ar' => 'نوزل بريميوم 20W-50 (4 لتر)',
                'description' => 'High quality mineral oil for older engines or hot climates.',
                'description_ar' => 'زيت معدني عالي الجودة للمحركات القديمة أو المناخات الحارة.',
                'price' => 22000.00,
                'old_price' => 25000.00,
                'image' => 'https://images.unsplash.com/photo-1486006396193-47101993e36e?q=80&w=1000&auto=format&fit=crop',
                'quantity' => 100,
                'is_available' => true,
                'is_featured' => true,
                'home_section' => 'featured',
                'status' => 'published',
            ],
            [
                'category_id' => $categoryIds['Filters'],
                'brand_id' => $brandIds['Nozzle'],
                'name' => 'Nozzle Oil Filter Toyota',
                'name_ar' => 'فلتر زيت نوزل لتويوتا',
                'description' => 'Premium oil filter for Toyota vehicles.',
                'description_ar' => 'فلتر زيت بريميوم لسيارات تويوتا.',
                'price' => 8500.00,
                'old_price' => 10000.00,
                'image' => 'https://images.unsplash.com/photo-1486006396193-47101993e36e?q=80&w=1000&auto=format&fit=crop',
                'quantity' => 200,
                'is_available' => true,
                'is_featured' => false,
                'home_section' => 'none',
                'status' => 'published',
            ],
        ];

        foreach ($products as $pData) {
            Product::create($pData);
        }
    }
}
