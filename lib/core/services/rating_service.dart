import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';

class RatingService {
  static const String baseUrl = ApiService.baseUrl;

  /// Get headers with bearer token if logged in
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

  /// Get ratings for a product
  static Future<Map<String, dynamic>?> getRatings(int productId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/v1/ratings/$productId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
    } catch (e) {
      print('Error fetching ratings: $e');
    }
    return null;
  }

  /// Submit a product rating
  static Future<Map<String, dynamic>> submitRating({
    required int productId,
    required int rating,
    String? comment,
    int? orderId,
  }) async {
    try {
      final headers = await _getHeaders();
      // Check if user is logged in
      if (!headers.containsKey('Authorization')) {
        return {
          'success': false,
          'message': 'الرجاء تسجيل الدخول أولاً لتتمكن من كتابة تقييم'
        };
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/v1/ratings'),
            headers: headers,
            body: json.encode({
              'product_id': productId,
              'rating': rating,
              'comment': comment,
              'order_id': orderId,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);
      if (response.statusCode == 200 || data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم تقديم التقييم بنجاح'
        };
      }
      return {
        'success': false,
        'message': data['detail'] ?? 'فشل تقديم التقييم'
      };
    } catch (e) {
      print('Error submitting rating: $e');
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الاتصال بالسيرفر'
      };
    }
  }
}
