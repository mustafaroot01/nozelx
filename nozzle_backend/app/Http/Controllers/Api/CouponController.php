<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Coupon;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class CouponController extends Controller
{
    /**
     * List all coupons for the admin panel.
     */
    public function index(): JsonResponse
    {
        $coupons = Coupon::all()->map(function ($c) {
            return [
                'id' => $c->id,
                'code' => $c->code,
                'discount_type' => $c->discount_type,
                'value' => (double)$c->value,
                'min_order_value' => $c->min_order_value ? (double)$c->min_order_value : null,
                'max_discount_value' => $c->max_discount_value ? (double)$c->max_discount_value : null,
                'usage_limit' => $c->usage_limit,
                'usage_count' => $c->usage_count ?? 0,
                'start_date' => $c->start_date ? $c->start_date->toIso8601String() : null,
                'end_date' => $c->end_date ? $c->end_date->toIso8601String() : null,
                'product_ids' => $c->product_ids ?? [],
                'category_ids' => $c->category_ids ?? [],
                'buy_x' => $c->buy_x,
                'get_y' => $c->get_y,
                'get_y_discount' => $c->get_y_discount ? (double)$c->get_y_discount : 100.0,
                'is_active' => (bool)$c->is_active,
            ];
        });

        return response()->json([
            'status' => 'success',
            'data' => $coupons
        ]);
    }

    /**
     * Store a newly created coupon.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'code' => 'required|string|unique:coupons,code',
            'discount_type' => 'required|string',
            'value' => 'nullable|numeric',
            'min_order_value' => 'nullable|numeric',
            'max_discount_value' => 'nullable|numeric',
            'usage_limit' => 'nullable|integer',
            'start_date' => 'nullable|string',
            'end_date' => 'nullable|string',
            'product_ids' => 'nullable|array',
            'category_ids' => 'nullable|array',
            'buy_x' => 'nullable|integer',
            'get_y' => 'nullable|integer',
            'get_y_discount' => 'nullable|numeric',
            'is_active' => 'boolean'
        ]);

        if (isset($validated['start_date'])) {
            $validated['start_date'] = $validated['start_date'] ? \Carbon\Carbon::parse($validated['start_date']) : null;
        }
        if (isset($validated['end_date'])) {
            $validated['end_date'] = $validated['end_date'] ? \Carbon\Carbon::parse($validated['end_date']) : null;
        }

        $validated['usage_count'] = 0;

        $coupon = Coupon::create($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Coupon created successfully',
            'data' => $coupon
        ]);
    }

    /**
     * Update an existing coupon.
     */
    public function update(Request $request, $id): JsonResponse
    {
        $coupon = Coupon::find($id);
        if (!$coupon) {
            return response()->json(['detail' => 'Coupon not found'], 404);
        }

        $validated = $request->validate([
            'code' => 'required|string|unique:coupons,code,' . $id,
            'discount_type' => 'required|string',
            'value' => 'nullable|numeric',
            'min_order_value' => 'nullable|numeric',
            'max_discount_value' => 'nullable|numeric',
            'usage_limit' => 'nullable|integer',
            'start_date' => 'nullable|string',
            'end_date' => 'nullable|string',
            'product_ids' => 'nullable|array',
            'category_ids' => 'nullable|array',
            'buy_x' => 'nullable|integer',
            'get_y' => 'nullable|integer',
            'get_y_discount' => 'nullable|numeric',
            'is_active' => 'boolean'
        ]);

        if (isset($validated['start_date'])) {
            $validated['start_date'] = $validated['start_date'] ? \Carbon\Carbon::parse($validated['start_date']) : null;
        }
        if (isset($validated['end_date'])) {
            $validated['end_date'] = $validated['end_date'] ? \Carbon\Carbon::parse($validated['end_date']) : null;
        }

        $coupon->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Coupon updated successfully',
            'data' => $coupon
        ]);
    }

    /**
     * Delete a coupon.
     */
    public function destroy($id): JsonResponse
    {
        $coupon = Coupon::find($id);
        if (!$coupon) {
            return response()->json(['detail' => 'Coupon not found'], 404);
        }

        $coupon->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Coupon deleted successfully'
        ]);
    }

    /**
     * Validate a coupon code for orders.
     */
    public function validateCoupon(Request $request): JsonResponse
    {
        $code = $request->query('code');
        $total = $request->query('total', 0);

        if (!$code) {
            return response()->json([
                'success' => false,
                'message' => 'يرجى إدخال كود الكوبون'
            ]);
        }

        $coupon = Coupon::where('code', strtoupper($code))
            ->where('is_active', true)
            ->where(function ($query) {
                $query->whereNull('start_date')->orWhere('start_date', '<=', now());
            })
            ->where(function ($query) {
                $query->whereNull('end_date')->orWhere('end_date', '>=', now());
            })
            ->first();

        if (!$coupon) {
            return response()->json([
                'success' => false,
                'message' => 'كوبون الخصم غير موجود أو منتهي الصلاحية'
            ]);
        }

        // Check usage limit
        if ($coupon->usage_limit !== null && ($coupon->usage_count ?? 0) >= $coupon->usage_limit) {
            return response()->json([
                'success' => false,
                'message' => 'تم استنفاد مرات استخدام هذا الكوبون'
            ]);
        }

        // Validate min order amount
        if ($coupon->min_order_value !== null && $total < $coupon->min_order_value) {
            return response()->json([
                'success' => false,
                'message' => 'الحد الأدنى لاستخدام الكوبون هو ' . number_format($coupon->min_order_value) . ' د.ع'
            ]);
        }

        // Calculate discount amount for preview
        $discountAmount = 0;
        if ($coupon->discount_type === 'percentage') {
            $discountAmount = ($total * $coupon->value) / 100;
            if ($coupon->max_discount_value !== null && $discountAmount > $coupon->max_discount_value) {
                $discountAmount = $coupon->max_discount_value;
            }
        } else {
            $discountAmount = $coupon->value;
        }

        return response()->json([
            'success' => true,
            'data' => [
                'valid' => true,
                'code' => $coupon->code,
                'type' => $coupon->discount_type,
                'value' => $coupon->value,
                'discount_amount' => $discountAmount,
                'min_cart_value' => $coupon->min_order_value,
            ]
        ]);
    }

    /**
     * Validate a coupon code for orders via POST (JSON payload).
     */
    public function validateCouponPost(Request $request): JsonResponse
    {
        $code = $request->input('code');
        $total = (double)$request->input('order_value', 0);

        if (!$code) {
            return response()->json([
                'success' => false,
                'message' => 'يرجى إدخال كود الكوبون'
            ]);
        }

        $coupon = Coupon::where('code', strtoupper(trim($code)))
            ->where('is_active', true)
            ->where(function ($query) {
                $query->whereNull('start_date')->orWhere('start_date', '<=', now());
            })
            ->where(function ($query) {
                $query->whereNull('end_date')->orWhere('end_date', '>=', now());
            })
            ->first();

        if (!$coupon) {
            return response()->json([
                'success' => false,
                'message' => 'كوبون الخصم غير صحيح أو منتهي الصلاحية'
            ]);
        }

        // Check expiration date
        if ($coupon->end_date && $coupon->end_date->isPast()) {
            return response()->json([
                'success' => false,
                'message' => 'كوبون الخصم منتهي الصلاحية'
            ]);
        }

        // Check usage limit
        if ($coupon->usage_limit !== null && ($coupon->usage_count ?? 0) >= $coupon->usage_limit) {
            return response()->json([
                'success' => false,
                'message' => 'تم استنفاد مرات استخدام هذا الكوبون'
            ]);
        }

        // Validate min order amount
        if ($coupon->min_order_value !== null && $total < $coupon->min_order_value) {
            return response()->json([
                'success' => false,
                'message' => 'الحد الأدنى لاستخدام الكوبون هو ' . number_format($coupon->min_order_value) . ' د.ع'
            ]);
        }

        // Calculate discount amount for preview
        $discountAmount = 0;
        if ($coupon->discount_type === 'percentage') {
            $discountAmount = ($total * $coupon->value) / 100;
            if ($coupon->max_discount_value !== null && $discountAmount > $coupon->max_discount_value) {
                $discountAmount = $coupon->max_discount_value;
            }
        } else {
            $discountAmount = $coupon->value;
        }

        $discountAmount = min($discountAmount, $total);
        $newTotal = max(0.0, $total - $discountAmount);

        return response()->json([
            'success' => true,
            'data' => [
                'code' => $coupon->code,
                'type' => $coupon->discount_type,
                'value' => (double)$coupon->value,
                'min_order_amount' => (double)($coupon->min_order_value ?? 0.0),
                'max_discount_amount' => $coupon->max_discount_value ? (double)$coupon->max_discount_value : null,
                'expires_at' => $coupon->end_date ? $coupon->end_date->toIso8601String() : null,
                'is_active' => (bool)$coupon->is_active,
                'discount_amount' => (double)$discountAmount,
                'new_total' => (double)$newTotal,
            ]
        ]);
    }
}
