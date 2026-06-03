import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_lube/features/profile/data/models/discount_model.dart';

class DiscountService {
  static const String _baseUrl = ApiService.baseUrl;
  static const String _tokenKey = 'user_token';

  /// Get token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get all discounts for the current user (based on their orders/points)
  static Future<List<DiscountModel>> getUserDiscounts() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/discounts.php?action=user_discounts&token=$token'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> discountsJson = data['data'];
          return discountsJson
              .map((json) => DiscountModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching user discounts: $e');
      return [];
    }
  }

  /// Get all active discounts
  static Future<List<DiscountModel>> getActiveDiscounts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/discounts.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> discountsJson = data['data'];
          return discountsJson
              .map((json) => DiscountModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching active discounts: $e');
      return [];
    }
  }

  /// Claim a discount (get the coupon code)
  static Future<Map<String, dynamic>> claimDiscount(int discountId) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'error': 'يجب تسجيل الدخول أولاً'};
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/discounts.php?action=claim'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'discount_id': discountId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }
      return {'success': false, 'error': 'فشل في الاتصال بالخادم'};
    } catch (e) {
      print('Error claiming discount: $e');
      return {'success': false, 'error': 'حدث خطأ: $e'};
    }
  }

  /// Get claimed discounts by user
  static Future<List<DiscountModel>> getClaimedDiscounts() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/discounts.php?action=claimed&token=$token'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> discountsJson = data['data'];
          return discountsJson
              .map((json) => DiscountModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching claimed discounts: $e');
      return [];
    }
  }
}
