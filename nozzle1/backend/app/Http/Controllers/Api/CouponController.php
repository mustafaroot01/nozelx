<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Coupon;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class CouponController extends Controller
{
    public function validateCoupon(Request $request): JsonResponse
    {
        $code = $request->query('code');
        $total = $request->query('total', 0);

        $coupon = Coupon::where('code', $code)
            ->where('is_active', true)
            ->where(function($query) {
                $query->whereNull('starts_at')->orWhere('starts_at', '<=', now());
            })
            ->where(function($query) {
                $query->whereNull('expires_at')->orWhere('expires_at', '>=', now());
            })
            ->first();

        if (!$coupon) {
            return response()->json([
                'success' => false,
                'message' => 'كوبون الخصم غير موجود أو منتهي الصلاحية'
            ]);
        }

        // Check usage limit
        if ($coupon->usage_limit !== null && $coupon->used_count >= $coupon->usage_limit) {
            return response()->json([
                'success' => false,
                'message' => 'تم استنفاد مرات استخدام هذا الكوبون'
            ]);
        }

        // Validate min amount
        if ($coupon->min_cart_value !== null && $total < $coupon->min_cart_value) {
            return response()->json([
                'success' => false,
                'message' => 'الحد الأدنى لاستخدام الكوبون هو ' . number_format($coupon->min_cart_value) . ' د.ع'
            ]);
        }

        // Calculate discount amount for preview
        $discountAmount = 0;
        if ($coupon->type === 'percentage') {
            $discountAmount = ($total * $coupon->value) / 100;
            if ($coupon->max_discount !== null && $discountAmount > $coupon->max_discount) {
                $discountAmount = $coupon->max_discount;
            }
        } else {
            $discountAmount = $coupon->value;
        }

        return response()->json([
            'success' => true,
            'data' => [
                'valid' => true,
                'code' => $coupon->code,
                'type' => $coupon->type,
                'value' => $coupon->value,
                'discount_amount' => $discountAmount,
                'min_cart_value' => $coupon->min_cart_value,
            ]
        ]);
    }
}
