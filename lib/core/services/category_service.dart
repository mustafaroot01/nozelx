import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_lube/core/data/categories_data.dart';
import 'package:auto_lube/core/services/api_service.dart';

/// Service for fetching categories from API with fallback to static data
class CategoryService {
  static List<Category>? _cachedCategories;
  static List<Category>? get cachedCategories => _cachedCategories;
  static DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Base URL for converting relative image paths to absolute
  static String get _imageBaseUrl => ApiService.storageUrl;

  /// Helper to convert relative image path to absolute URL
  static String _fixImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    // For Laravel storage, we usually just need the filename if it's already in the storage path
    // or the relative path from storage/
    return '$_imageBaseUrl/${imageUrl.replaceFirst('^/', '')}';
  }

  /// Get all main categories (with sub-categories)
  static Future<List<Category>> getCategories({
    bool forceRefresh = false,
  }) async {
    // Return cache if valid
    if (!forceRefresh &&
        _cachedCategories != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cachedCategories!;
    }

    try {
      print('Fetching categories from: ${ApiService.baseUrl}/categories?include_children=1');
      final response = await http
          .get(Uri.parse('${ApiService.baseUrl}/categories?include_children=1'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'success' && data['data'] != null) {
          final categoriesJson = data['data'] as List<dynamic>;

          if (categoriesJson.isNotEmpty) {
            final categories = categoriesJson.map((c) {
              return Category.fromJson(c as Map<String, dynamic>);
            }).toList();

            // Cache the result
            _cachedCategories = categories;
            _cacheTime = DateTime.now();
            return categories;
          }
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }

    return [];
  }

  /// Clear cache (call after admin updates)
  static void clearCache() {
    _cachedCategories = null;
    _cacheTime = null;
  }

  /// Get sub-categories for a specific parent
  static Future<List<Category>> getSubCategories(String parentId) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiService.baseUrl}/categories?parent_id=$parentId&include_children=1',
            ),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'success' && data['data'] != null) {
          final subsJson = data['data'] as List<dynamic>;
          return subsJson
              .map((s) => Category.fromJson(s as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching subcategories: $e');
    }

    return [];
  }

}
