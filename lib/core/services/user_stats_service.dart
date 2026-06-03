import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_lube/core/services/api_service.dart';
import 'package:auto_lube/core/network/dio_client.dart';

/// Service to manage user statistics
class UserStatsService {
  static const String _baseUrl = ApiService.baseUrl;

  static int _currentUserId = 0;

  // ==================== USER ID MANAGEMENT ====================

  static Future<int> getCurrentUserId() async {
    if (_currentUserId > 0) return _currentUserId;

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson == null) {
      // try user_data fallback
      final userDataStr = prefs.getString('user_data');
      if (userDataStr != null) {
        try {
          final userData = jsonDecode(userDataStr);
          final id = int.tryParse(userData['id']?.toString() ?? '0') ?? 0;
          _currentUserId = id;
          return id;
        } catch (e) {
          return 0;
        }
      }
    }
    if (userJson != null) {
      try {
        final userData = jsonDecode(userJson);
        final id = int.tryParse(userData['id']?.toString() ?? '0') ?? 0;
        _currentUserId = id;
        return id;
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  static Future<void> setCurrentUserId(int userId) async {
    _currentUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cached_user_id', userId);
  }

  static Future<void> clearCurrentUserId() async {
    _currentUserId = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_user_id');
    await prefs.remove('current_user');
    await prefs.remove('user_data');
    await prefs.remove('isLoggedIn');
    await prefs.remove('user_token');
  }

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getInt('cached_user_id') ?? 0;
  }

  // ==================== FAVORITES STATS ====================

  static Future<void> incrementFavoritesCount({int? userId}) async {
    final id = userId ?? _currentUserId;
    final prefs = await SharedPreferences.getInstance();
    final key = 'fav_count_$id';
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }

  static Future<void> decrementFavoritesCount({int? userId}) async {
    final id = userId ?? _currentUserId;
    final prefs = await SharedPreferences.getInstance();
    final key = 'fav_count_$id';
    final current = prefs.getInt(key) ?? 0;
    if (current > 0) await prefs.setInt(key, current - 1);
  }

  static Future<int> getFavoritesCount({int? userId}) async {
    try {
      final response = await apiClient.get('/favorites');
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        final rawData = data['data'];
        final List favoritesList = rawData is List 
            ? rawData 
            : (rawData is Map ? (rawData['favorites'] ?? []) : []);
        final count = favoritesList.length;
        
        // cache count
        final id = userId ?? _currentUserId;
        if (id > 0) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('fav_count_$id', count);
        }
        return count;
      }
    } catch (e) {
      // Fallback to local cache
    }

    final id = userId ?? _currentUserId;
    if (id <= 0) return 0;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('fav_count_$id') ?? 0;
  }

  // ==================== COUPONS STATS ====================

  static Future<void> incrementCouponsCount({int? userId}) async {
    final id = userId ?? _currentUserId;
    final prefs = await SharedPreferences.getInstance();
    final key = 'coupon_count_$id';
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }

  static Future<void> decrementCouponsCount({int? userId}) async {
    final id = userId ?? _currentUserId;
    final prefs = await SharedPreferences.getInstance();
    final key = 'coupon_count_$id';
    final current = prefs.getInt(key) ?? 0;
    if (current > 0) await prefs.setInt(key, current - 1);
  }

  static Future<int> getCouponsCount({int? userId}) async {
    final id = userId ?? _currentUserId;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('coupon_count_$id') ?? 0;
  }

  // ==================== GET ALL STATS ====================

  static Future<Map<String, dynamic>> getAllStats({int? userId}) async {
    final favoritesCount = await getFavoritesCount(userId: userId);
    final couponsCount = await getCouponsCount(userId: userId);

    return {
      'favorites_count': favoritesCount,
      'coupons_count': couponsCount,
    };
  }
}
