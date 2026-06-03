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
use Illuminate\Support\Facades\Schema;

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
            'subtotal'         => 'nullable|numeric',
            'delivery_fee'     => 'nullable|numeric',
            'coupon_discount'  => 'nullable|numeric',
        ]);

        try {
            return DB::transaction(function () use ($validated, $request) {
                $userId = $validated['user_id'] ?? null;
                if ($userId) {
                    $userExists = \App\Models\User::where('id', $userId)->exists();
                    if (!$userExists) {
                        // Fallback to phone-number resolution to prevent foreign key errors on session desync
                        $userByPhone = \App\Models\User::where('phone', $validated['customer_phone'])->first();
                        $userId = $userByPhone ? $userByPhone->id : null;
                    }
                }

                $orderData = [
                    'user_id'          => $userId,
                    'customer_name'    => $validated['customer_name'],
                    'customer_phone'   => $validated['customer_phone'],
                    'payment_method'   => $validated['payment_method'],
                    'total_amount'     => $validated['total_amount'],
                    'coupon_code'      => $validated['coupon_code'] ?? null,
                    'notes'            => $validated['notes'] ?? null,
                    'status'           => 'pending',
                    'subtotal'         => $validated['subtotal'] ?? null,
                    'delivery_fee'     => $validated['delivery_fee'] ?? null,
                    'coupon_discount'  => $validated['coupon_discount'] ?? null,
                ];

                if (Schema::hasColumn('orders', 'customer_address')) {
                    $orderData['customer_address'] = $validated['customer_address'] ?? null;
                }
                if (Schema::hasColumn('orders', 'address')) {
                    $orderData['address'] = $validated['customer_address'] ?? null;
                }

                // Create Order
                $order = Order::create($orderData);

                // Create Order Items & update stock
                foreach ($validated['items'] as $item) {
                    OrderItem::create([
                        'order_id'   => $order->id,
                        'product_id' => $item['product_id'],
                        'quantity'   => $item['quantity'],
                        'price'      => $item['price'],
                    ]);

                    // Decrease product quantity
                    $stockColumn = Schema::hasColumn('products', 'stock_quantity') ? 'stock_quantity' : 'quantity';
                    Product::where('id', $item['product_id'])
                        ->decrement($stockColumn, $item['quantity']);
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
        $formatted = [];
        foreach ($orders as $o) {
            $items = [];
            foreach ($o->orderItems as $item) {
                $items[] = [
                    'id' => $item->id,
                    'product_id' => $item->product_id,
                    'quantity' => (int)$item->quantity,
                    'price' => (float)$item->price,
                    'product' => $item->product ? [
                        'id' => $item->product->id,
                        'name' => $item->product->name,
                        'price' => (float)$item->product->price,
                    ] : null,
                ];
            }
            $formatted[] = [
                'id' => $o->id,
                'customer_name' => $o->customer_name ?: 'عميل',
                'customer_email' => $o->customer_email ?: '',
                'customer_phone' => $o->customer_phone ?: '',
                'total_amount' => (float)$o->total_amount,
                'status' => $o->status ?: 'pending',
                'created_at' => $o->created_at ? \Carbon\Carbon::parse($o->created_at)->toIso8601String() : null,
                'items' => $items,
            ];
        }

        if ($userId) {
            return response()->json([
                'status' => 'success',
                'data'   => $formatted,
            ]);
        }

        return response()->json($formatted);
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
     * Get single order detailed view for dashboard.
     */
    public function showDetail(Order $order): JsonResponse
    {
        $order->load('orderItems.product');
        
        $items = [];
        foreach ($order->orderItems as $item) {
            $items[] = [
                'id' => $item->id,
                'product_id' => $item->product_id,
                'quantity' => (int)$item->quantity,
                'price' => (float)$item->price,
                'selected_size' => $item->selected_size ?: null,
                'selected_color' => $item->selected_color ?: null,
                'product' => $item->product ? [
                    'id' => $item->product->id,
                    'name' => $item->product->name,
                    'price' => (float)$item->product->price,
                    'sku' => $item->product->sku ?: '',
                    'image_url' => $item->product->image_url ?: '',
                ] : null,
            ];
        }

        $subtotal = (float)($order->subtotal ?? ($order->total_amount - ($order->delivery_fee ?? 0) + ($order->coupon_discount ?? 0)));
        if ($subtotal <= 0) {
            $subtotal = 0;
            foreach ($items as $item) {
                $subtotal += $item['price'] * $item['quantity'];
            }
        }

        $formattedOrder = [
            'id' => $order->id,
            'invoice_number' => $order->invoice_number ?: ('INV-' . str_pad($order->id, 6, '0', STR_PAD_LEFT)),
            'customer_name' => $order->customer_name ?: 'عميل',
            'customer_email' => $order->customer_email ?: '',
            'customer_phone' => $order->customer_phone ?: '',
            'address' => $order->address ?: $order->customer_address ?: '',
            'notes' => $order->notes ?: '',
            'payment_method' => $order->payment_method ?: 'cash',
            'subtotal' => $subtotal,
            'delivery_fee' => (float)($order->delivery_fee ?? 0.0),
            'coupon_discount' => (float)($order->coupon_discount ?? 0.0),
            'coupon_code' => $order->coupon_code ?: '',
            'total' => (float)$order->total_amount,
            'total_amount' => (float)$order->total_amount,
            'status' => $order->status ?: 'pending',
            'created_at' => $order->created_at ? \Carbon\Carbon::parse($order->created_at)->toIso8601String() : null,
            'items' => $items,
        ];

        // Format/normalize status history
        $history = $order->status_history;
        if (!is_array($history)) {
            $history = [];
        }
        if (empty($history)) {
            $history = [
                [
                    'status' => $order->status ?: 'pending',
                    'timestamp' => $order->created_at ? \Carbon\Carbon::parse($order->created_at)->toIso8601String() : now()->toIso8601String(),
                    'note' => 'تم إنشاء الطلب بنجاح',
                ]
            ];
        } else {
            foreach ($history as &$h) {
                if (isset($h['timestamp'])) {
                    $h['timestamp'] = \Carbon\Carbon::parse($h['timestamp'])->toIso8601String();
                }
            }
        }
        $formattedOrder['status_history'] = $history;

        // Fetch customer statistics
        $userId = $order->user_id;
        $customer = null;
        if ($userId) {
            $totalOrders = Order::where('user_id', $userId)->count();
            $totalSpent = Order::where('user_id', $userId)->where('status', 'completed')->sum('total_amount');
            $customer = [
                'name' => $order->customer_name,
                'phone' => $order->customer_phone,
                'total_orders' => $totalOrders,
                'total_spent' => (float)$totalSpent,
            ];
        } else if ($order->customer_phone) {
            $totalOrders = Order::where('customer_phone', $order->customer_phone)->count();
            $totalSpent = Order::where('customer_phone', $order->customer_phone)->where('status', 'completed')->sum('total_amount');
            $customer = [
                'name' => $order->customer_name,
                'phone' => $order->customer_phone,
                'total_orders' => $totalOrders,
                'total_spent' => (float)$totalSpent,
            ];
        }
        $formattedOrder['customer'] = $customer;

        return response()->json([
            'success' => true,
            'data'    => $formattedOrder,
        ]);
    }

    /**
     * Update order status.
     */
    public function update(Request $request, Order $order): JsonResponse
    {
        $validated = $request->validate([
            'status' => 'required|string|in:new,pending,confirmed,processing,shipped,on_the_way,delivered,completed,cancelled',
        ]);

        $order->update(['status' => $validated['status']]);

        return response()->json([
            'success' => true,
            'status'  => 'success',
            'message' => 'Order updated successfully',
            'data'    => $order->fresh('orderItems.product'),
        ]);
    }

    /**
     * Update order status with detailed history log.
     */
    public function updateStatus(Request $request, Order $order): JsonResponse
    {
        $validated = $request->validate([
            'status' => 'required|string|in:new,pending,confirmed,processing,shipped,on_the_way,delivered,completed,cancelled',
            'note' => 'nullable|string|max:1000',
        ]);

        $status = $validated['status'];
        $note = $validated['note'] ?? '';

        // Get current status history
        $history = $order->status_history;
        if (!is_array($history)) {
            $history = [];
        }

        if (empty($history)) {
            $history[] = [
                'status' => $order->status ?: 'pending',
                'timestamp' => $order->created_at ? \Carbon\Carbon::parse($order->created_at)->toIso8601String() : now()->toIso8601String(),
                'note' => 'تم إنشاء الطلب بنجاح',
            ];
        }

        // Add new history entry
        $history[] = [
            'status' => $status,
            'timestamp' => now()->toIso8601String(),
            'note' => $note ?: ('تحديث حالة الطلب إلى: ' . $status),
        ];

        $order->update([
            'status' => $status,
            'status_history' => $history,
        ]);

        return response()->json([
            'success' => true,
            'status'  => 'success',
            'message' => 'Order status updated successfully',
            'data'    => $order->fresh('orderItems.product'),
        ]);
    }
}

