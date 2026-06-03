import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';

class CouponService {
  static const String baseUrl = ApiService.baseUrl;

  /// Validate a coupon code via V1 POST endpoint
  static Future<Map<String, dynamic>> validateCoupon(String code, double total) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try to read user ID
      int? userId;
      final userJson = prefs.getString('current_user');
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        userId = int.tryParse(userData['id']?.toString() ?? '');
      }

      // Try to read bearer token for authorization header
      final token = prefs.getString('user_token') ?? '';
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/v1/coupons/validate'),
        headers: headers,
        body: json.encode({
          'code': code,
          'order_value': total,
          'user_id': userId,
          'items': [], // Backend expects a list, empty is allowed by schema
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      
      final errorData = json.decode(response.body);
      return {
        'success': false,
        'message': errorData['detail'] ?? 'فشل التحقق من الكوبون'
      };
    } catch (e) {
      print('Error validating coupon: $e');
      return {
        'success': false,
        'message': 'حدث خطأ في التحقق من الكوبون'
      };
    }
  }
}
