import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_lube/core/services/favorites_service.dart';

class FavoritesProvider with ChangeNotifier {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = false;
  final Map<String, bool> _favoriteStatus = {};

  List<Map<String, dynamic>> get favorites => _favorites;
  bool get isLoading => _isLoading;

  FavoritesProvider() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      // مستخدم زائر: لا توجد مفضلة على السيرفر لتفادي خطأ 401
      _favorites = [];
      _favoriteStatus.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final data = await FavoritesService.getFavorites();
      _favorites = data;
      
      // Update status map
      _favoriteStatus.clear();
      for (var item in _favorites) {
        final productId = item['id']?.toString() ?? '';
        if (productId.isNotEmpty) {
          _favoriteStatus[productId] = true;
        }
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(String productId) {
    return _favoriteStatus[productId] ?? false;
  }

  Future<bool> toggleFavorite(Map<String, dynamic> product) async {
    final productIdStr = product['id']?.toString() ?? '';
    final productId = int.tryParse(productIdStr) ?? 0;
    if (productId <= 0) return false;

    final currentlyFavorite = isFavorite(productIdStr);
    
    bool success;
    if (currentlyFavorite) {
      success = await FavoritesService.removeFromFavorites(productId);
      if (success) {
        _favoriteStatus[productIdStr] = false;
        _favorites.removeWhere((item) => item['id']?.toString() == productIdStr);
      }
    } else {
      success = await FavoritesService.addToFavorites(productId);
      if (success) {
        _favoriteStatus[productIdStr] = true;
        // We might want to reload or manually add the product to the list
        // For simplicity, let's reload to get the full product data from server structure
        await loadFavorites();
      }
    }

    notifyListeners();
    return success;
  }

  Future<void> clearAll() async {
    // Currently FavoritesService doesn't have clearAll, so we'd have to loop or add it to backend
    // For now, let's just clear local and assume backend would be updated or user does it one by one
    for (var item in _favorites) {
       final id = int.tryParse(item['id']?.toString() ?? '0') ?? 0;
       if (id > 0) await FavoritesService.removeFromFavorites(id);
    }
    _favorites.clear();
    _favoriteStatus.clear();
    notifyListeners();
  }

  Future<void> fetchFavorites([String? phone]) async {
    await loadFavorites();
  }

  void clearForLogout() {
    _favorites.clear();
    _favoriteStatus.clear();
    notifyListeners();
  }
}
