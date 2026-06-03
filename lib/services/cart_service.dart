import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:auto_lube/core/network/dio_client.dart';
import 'package:auto_lube/models/cart_item_model.dart';

class CartService {
  static Future<String> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    var sessionId = prefs.getString('visitor_session_id');
    if (sessionId == null || sessionId.isEmpty) {
      sessionId = const Uuid().v4();
      await prefs.setString('visitor_session_id', sessionId);
    }
    return sessionId;
  }

  Future<List<CartItemModel>> getCart() async {
    try {
      final sessionId = await getSessionId();
      final response = await apiClient.get(
        '/cart',
        queryParameters: {'session_id': sessionId},
      );

      final data = response.data;
      if (data['success'] == true) {
        final List<dynamic> itemsList = data['data']['items'] ?? [];
        return itemsList.map((item) => CartItemModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Error getCart Service: $e');
    }
    return [];
  }

  Future<CartItemModel> addToCart({
    required int productId,
    required int qty,
    String? size,
    String? color,
  }) async {
    try {
      final sessionId = await getSessionId();
      final options = <String, dynamic>{};
      if (size != null) options['size'] = size;
      if (color != null) options['color'] = color;

      final response = await apiClient.post(
        '/cart/add',
        data: {
          'product_id': productId,
          'quantity': qty,
          'session_id': sessionId,
          'options': options,
        },
      );

      final data = response.data;
      if (data['success'] == true) {
        final responseData = data['data'];
        return CartItemModel(
          id: responseData['id'] as int,
          productId: responseData['product_id'] as int,
          name: '',
          imageUrl: '',
          price: 0,
          quantity: responseData['quantity'] as int,
          stockQuantity: 999,
          isAvailable: true,
        );
      } else {
        throw Exception(data['detail'] ?? 'فشل إضافة المنتج');
      }
    } catch (e) {
      print('Error addToCart Service: $e');
      rethrow;
    }
  }

  Future<void> updateItem({required int itemId, required int qty}) async {
    try {
      final response = await apiClient.put(
        '/cart/update',
        queryParameters: {'item_id': itemId},
        data: {
          'quantity': qty,
        },
      );

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['detail'] ?? 'فشل تحديث الكمية');
      }
    } catch (e) {
      print('Error updateItem Service: $e');
      rethrow;
    }
  }

  Future<void> removeItem({required int itemId}) async {
    try {
      final response = await apiClient.delete(
        '/cart/remove/$itemId',
      );

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['detail'] ?? 'فشل إزالة المنتج');
      }
    } catch (e) {
      print('Error removeItem Service: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      final sessionId = await getSessionId();
      final response = await apiClient.post(
        '/cart/clear',
        queryParameters: {'session_id': sessionId},
      );

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['detail'] ?? 'فشل تفريغ السلة');
      }
    } catch (e) {
      print('Error clearCart Service: $e');
      rethrow;
    }
  }
}
