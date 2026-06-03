import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/api_service.dart';

class CartService {
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

  /// Get or create a unique guest session ID
  static Future<String> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    var sessionId = prefs.getString('visitor_session_id');
    if (sessionId == null || sessionId.isEmpty) {
      sessionId = const Uuid().v4();
      await prefs.setString('visitor_session_id', sessionId);
    }
    return sessionId;
  }

  /// Get user or visitor cart from server
  static Future<Map<String, dynamic>?> getCart() async {
    try {
      final headers = await _getHeaders();
      final sessionId = await getSessionId();

      final response = await http
          .get(
            Uri.parse('$baseUrl/v1/cart?session_id=$sessionId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'];
      }
    } catch (e) {
      print('Error fetching cart: $e');
    }
    return null;
  }

  /// Add item to cart on server
  static Future<Map<String, dynamic>?> addToCart({
    required int productId,
    required int quantity,
    Map<String, dynamic>? options,
  }) async {
    try {
      final headers = await _getHeaders();
      final sessionId = await getSessionId();

      final response = await http
          .post(
            Uri.parse('$baseUrl/v1/cart/add'),
            headers: headers,
            body: json.encode({
              'product_id': productId,
              'quantity': quantity,
              'session_id': sessionId,
              'options': options ?? {},
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['detail'] ?? 'فشل إضافة المنتج');
      }
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }

  /// Update item quantity on server
  static Future<bool> updateCartItem({
    required int itemId,
    required int quantity,
    Map<String, dynamic>? options,
  }) async {
    try {
      final headers = await _getHeaders();

      final response = await http
          .put(
            Uri.parse('$baseUrl/v1/cart/update?item_id=$itemId'),
            headers: headers,
            body: json.encode({
              'quantity': quantity,
              'options': options ?? {},
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('Error updating cart: $e');
      return false;
    }
  }

  /// Remove item from cart on server
  static Future<bool> removeFromCart(int itemId) async {
    try {
      final headers = await _getHeaders();

      final response = await http
          .delete(
            Uri.parse('$baseUrl/v1/cart/remove/$itemId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  /// Clear cart on server
  static Future<bool> clearCart() async {
    try {
      final headers = await _getHeaders();
      final sessionId = await getSessionId();

      final response = await http
          .post(
            Uri.parse('$baseUrl/v1/cart/clear?session_id=$sessionId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }
}
