import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_lube/core/services/api_service.dart';
import 'package:auto_lube/core/exceptions/app_exception.dart';
import 'package:auto_lube/models/coupon_model.dart';

class CouponResult {
  final CouponModel coupon;
  final double discountAmount;   // بالدينار العراقي
  final double newTotal;

  CouponResult({
    required this.coupon,
    required this.discountAmount,
    required this.newTotal,
  });
}

class CouponService {
  static const String baseUrl = ApiService.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token') ?? '';
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<CouponResult> validateCoupon({
    required String code,
    required double cartTotal,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/v1/coupons/validate'),
            headers: headers,
            body: json.encode({
              'code': code,
              'order_value': cartTotal,
              'items': [], // Backend accepts empty items list for general coupons
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final couponData = data['data'] ?? data;
          
          final coupon = CouponModel(
            code: couponData['code'] as String? ?? code.toUpperCase(),
            type: couponData['type'] as String? ?? 'fixed',
            value: (couponData['value'] as num? ?? couponData['discount_amount'] as num? ?? 0.0).toDouble(),
            minOrderAmount: (couponData['min_order_amount'] as num? ?? 0.0).toDouble(),
            maxDiscountAmount: couponData['max_discount_amount'] != null
                ? (couponData['max_discount_amount'] as num).toDouble()
                : null,
            expiresAt: couponData['expires_at'] != null
                ? DateTime.parse(couponData['expires_at'] as String)
                : DateTime.now().add(const Duration(days: 30)),
            isActive: couponData['is_active'] as bool? ?? true,
          );

          final double discountAmount = (couponData['discount_amount'] as num? ?? 0.0).toDouble();
          final double newTotal = (couponData['new_total'] as num? ?? (cartTotal - discountAmount)).toDouble();

          return CouponResult(
            coupon: coupon,
            discountAmount: discountAmount,
            newTotal: newTotal,
          );
        } else {
          throw AppException(data['message'] ?? 'كود الخصم غير صحيح أو غير موجود');
        }
      } else {
        throw AppException(data['detail'] ?? 'حدث خطأ أثناء التحقق من كود الخصم');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      print('Error validateCoupon Service: $e');
      throw AppException('كود الخصم غير صحيح أو غير موجود');
    }
  }
}
