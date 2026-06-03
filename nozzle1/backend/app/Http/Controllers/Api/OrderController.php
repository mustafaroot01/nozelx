<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class OrderController extends Controller
{
    /**
     * Store a newly created order in storage.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'customer_name'    => 'required|string|max:255',
            'customer_phone'   => 'required|string|max:255',
            'customer_address' => 'nullable|string|max:500',
            'payment_method'   => 'required|string|in:cash,wallet,card',
            'items'            => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity'   => 'required|integer|min:1',
            'items.*.price'      => 'required|numeric',
            'total_amount'     => 'required|numeric',
            'coupon_code'      => 'nullable|string|max:50',
            'notes'            => 'nullable|string|max:1000',
            'user_id'          => 'nullable|integer',
        ]);

        try {
            return DB::transaction(function () use ($validated, $request) {
                // Create Order
                $order = Order::create([
                    'user_id'          => $validated['user_id'] ?? null,
                    'customer_name'    => $validated['customer_name'],
                    'customer_phone'   => $validated['customer_phone'],
                    'customer_address' => $validated['customer_address'] ?? null,
                    'payment_method'   => $validated['payment_method'],
                    'total_amount'     => $validated['total_amount'],
                    'coupon_code'      => $validated['coupon_code'] ?? null,
                    'notes'            => $validated['notes'] ?? null,
                    'status'           => 'pending',
                ]);

                // Create Order Items & update stock
                foreach ($validated['items'] as $item) {
                    OrderItem::create([
                        'order_id'   => $order->id,
                        'product_id' => $item['product_id'],
                        'quantity'   => $item['quantity'],
                        'price'      => $item['price'],
                    ]);

                    // Decrease product quantity
                    Product::where('id', $item['product_id'])
                        ->decrement('quantity', $item['quantity']);
                }

                return response()->json([
                    'status'  => 'success',
                    'message' => 'Order created successfully',
                    'data'    => $order->load('orderItems.product')
                ], 201);
            });
        } catch (\Exception $e) {
            Log::error('Order creation failed: ' . $e->getMessage());
            return response()->json([
                'status'  => 'error',
                'message' => 'Failed to create order: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get orders by user ID.
     */
    public function index(Request $request): JsonResponse
    {
        $userId = $request->query('user_id');

        $query = Order::with('orderItems.product');
        if ($userId) {
            $query->where('user_id', $userId);
        }

        $orders = $query->latest()->get();

        return response()->json([
            'status' => 'success',
            'data'   => $orders,
        ]);
    }

    /**
     * Get a single order.
     */
    public function show(Order $order): JsonResponse
    {
        return response()->json([
            'status' => 'success',
            'data'   => $order->load('orderItems.product'),
        ]);
    }

    /**
     * Update order status.
     */
    public function update(Request $request, Order $order): JsonResponse
    {
        $validated = $request->validate([
            'status' => 'required|string|in:pending,processing,shipped,delivered,cancelled',
        ]);

        $order->update(['status' => $validated['status']]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Order updated successfully',
            'data'    => $order->fresh('orderItems.product'),
        ]);
    }
}

