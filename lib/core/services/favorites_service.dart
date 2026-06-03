import 'package:auto_lube/core/network/dio_client.dart';
import '../../core/services/api_service.dart';

/// Service for managing user favorites from database (V1 API)
class FavoritesService {
  /// Get all favorites for current user from server
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final response = await apiClient.get('/favorites');
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        final rawData = data['data'];
        final List favoritesList = rawData is List 
            ? rawData 
            : (rawData is Map ? (rawData['favorites'] ?? []) : []);
        return favoritesList
            .map((fav) {
              final product = fav['product'];
              if (product != null) {
                final productId = product['id']?.toString() ?? '';
                final price = double.tryParse(product['price']?.toString() ?? '0') ?? 0.0;
                final salePrice = product['sale_price'] != null 
                    ? double.tryParse(product['sale_price']?.toString() ?? '') 
                    : null;

                return {
                  'id': productId, // Product ID as main ID for the card
                  'favorite_id': fav['id']?.toString() ?? '',
                  'product_id': productId,
                  'name': product['name'] ?? '',
                  'brand': product['brand'] ?? '',
                  'price': salePrice ?? price,
                  'oldPrice': salePrice != null ? price : null,
                  'image': ApiService.fixImageUrl(product['image_url']?.toString()),
                  'rating': 4.5,
                  'reviews': 12,
                  'inStock': product['in_stock'] ?? (product['quantity'] ?? 0) > 0,
                };
              }
              return null;
            })
            .whereType<Map<String, dynamic>>()
            .toList();
      }
    } catch (e) {
      print('Error fetching favorites: $e');
    }
    return [];
  }

  /// Add product to favorites
  static Future<bool> addToFavorites(int productId) async {
    try {
      final response = await apiClient.post(
        '/favorites',
        data: {
          'product_id': productId,
        },
      );
      final data = response.data;
      return data['success'] == true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  /// Remove product from favorites
  static Future<bool> removeFromFavorites(int productId) async {
    try {
      final response = await apiClient.delete(
        '/favorites/$productId',
      );
      final data = response.data;
      return data['success'] == true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  /// Check if product is favorite
  static Future<bool> isFavorite(int productId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((fav) => fav['product_id'] == productId.toString());
    } catch (e) {
      return false;
    }
  }
}
