<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DashboardDataSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Create Categories
        $categories = [
            ['name' => 'الهواتف الذكية', 'icon' => 'device-phone-mobile'],
            ['name' => 'الإكسسوارات', 'icon' => 'bolt'],
            ['name' => 'الساعات الذكية', 'icon' => 'watch-phone'],
            ['name' => 'السماعات', 'icon' => 'speaker-wave'],
        ];

        foreach ($categories as $cat) {
            Category::updateOrCreate(['name' => $cat['name']], [
                'slug' => str()->slug($cat['name']),
                'icon' => $cat['icon'],
                'is_active' => true,
            ]);
        }

        $allCategories = Category::all();

        // 2. Create Products
        $products = [
            ['name' => 'iPhone 15 Pro Max', 'price' => 1650000, 'quantity' => 12],
            ['name' => 'Samsung Galaxy S24 Ultra', 'price' => 1450000, 'quantity' => 3],
            ['name' => 'AirPods Pro 2', 'price' => 350000, 'quantity' => 25],
            ['name' => 'Apple Watch Series 9', 'price' => 600000, 'quantity' => 4],
            ['name' => 'PlayStation 5 Slim', 'price' => 750000, 'quantity' => 1],
        ];

        foreach ($products as $prod) {
            Product::updateOrCreate(['name' => $prod['name']], [
                'category_id' => $allCategories->random()->id,
                'price' => $prod['price'],
                'quantity' => $prod['quantity'],
                'is_available' => true,
                'is_active' => true,
                'sku' => strtoupper(str()->random(8)),
            ]);
        }

        $allProducts = Product::all();

        // 3. Create Orders
        $statuses = ['pending', 'received', 'processing', 'on_delivery', 'delivered', 'cancelled'];
        $cities = ['بغداد', 'البصرة', 'أربيل', 'الموصل', 'النجف', 'كربلاء'];

        for ($i = 0; $i < 50; $i++) {
            $status = $statuses[array_rand($statuses)];
            $order = Order::create([
                'user_id' => User::first()->id ?? null,
                'customer_name' => 'عميل تجريبي ' . ($i + 1),
                'customer_phone' => '077000000' . $i,
                'customer_address' => $cities[array_rand($cities)],
                'total_amount' => rand(50000, 2000000),
                'status' => $status,
                'payment_method' => 'cash',
                'payment_status' => rand(0, 1) ? 'paid' : 'unpaid',
                'created_at' => now()->subDays(rand(0, 30)),
            ]);

            // Add items to order
            for ($j = 0; $j < rand(1, 3); $j++) {
                $product = $allProducts->random();
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $product->id,
                    'quantity' => rand(1, 2),
                    'price' => $product->price,
                    'total_price' => $product->price * rand(1, 2),
                ]);
            }
        }
    }
}
