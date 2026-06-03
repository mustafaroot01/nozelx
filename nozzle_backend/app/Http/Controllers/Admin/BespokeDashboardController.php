<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class BespokeDashboardController extends Controller
{
    public function index()
    {
        // Cache stats for 5 minutes to improve performance
        $stats = Cache::remember('admin_dashboard_stats', 300, function () {
            return [
                'products_count' => Product::count(),
                'orders_count' => Order::count(),
                'users_count' => User::count(),
                'categories_count' => Category::count(),
                'banners_count' => \App\Models\Banner::count(),
                'total_revenue' => Order::where('status', 'delivered')->sum('total_amount'),
                'recent_orders' => Order::with('user')->latest()->take(5)->get(),
            ];
        });

        return view('admin.dashboard', compact('stats'));
    }
}
