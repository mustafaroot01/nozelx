import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ============================================
  // Server URL Configuration
  // ============================================
  static const String domain = '192.168.0.107:8080';
  static const String baseUrl = 'http://$domain/api';
  static const String adminBaseUrl = 'http://$domain/admin';
  static const String directBaseUrl = 'http://$domain';
  static const String storageUrl = 'http://$domain/storage';

  /*
  // PRODUCTION SERVER:
  static const String domain = 'nozzlecenter.center';
  static const String baseUrl = 'https://$domain/api';
  static const String adminBaseUrl = 'https://$domain/admin';
  static const String directBaseUrl = 'https://$domain';
  static const String storageUrl = 'https://$domain/storage';
  */


  // ============================================
  // Cache Keys
  // ============================================
  static const String _cacheProductsKey = 'cached_products';
  static const String _cacheBannersKey = 'cached_hero_banners';
  static const String _cacheOffersKey = 'cached_special_offers';
  static const String _cacheCategoryBannersKey = 'cached_category_banners';
  static const String _cacheTimeKey = 'cache_timestamp';

  // Cache duration: 1 second for fast dev sync
  static const Duration _productsCacheDuration = Duration(seconds: 1);
  static const Duration _bannersCacheDuration = Duration(seconds: 1);

  // ============================================
  // Cache Helper Methods
  // ============================================

  /// Check if cache is valid
  static Future<bool> _isCacheValid(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTime = prefs.getInt('${cacheKey}_time');
      if (cacheTime == null) return false;

      final cacheType = cacheKey == _cacheProductsKey
          ? _productsCacheDuration
          : _bannersCacheDuration;
      final diff = DateTime.now().millisecondsSinceEpoch - cacheTime;
      return diff < cacheType.inMilliseconds;
    } catch (e) {
      return false;
    }
  }

  /// Get cached data
  static Future<List<dynamic>?> _getCachedData(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        return json.decode(cached) as List<dynamic>;
      }
    } catch (e) {
      print('Error reading cache: $e');
    }
    return null;
  }

  /// Save data to cache
  static Future<void> _saveToCache(String cacheKey, List<dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, json.encode(data));
      await prefs.setInt(
        '${cacheKey}_time',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      print('Error saving cache: $e');
    }
  }
  // ============================================

  // Helper to convert relative image path to absolute URL
  static String fixImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    
    // Replace local loopback/localhost URLs with the active development domain/IP
    String fixedUrl = imageUrl;
    if (fixedUrl.contains('127.0.0.1:8000')) {
      fixedUrl = fixedUrl.replaceAll('127.0.0.1:8000', domain);
    } else if (fixedUrl.contains('localhost:8000')) {
      fixedUrl = fixedUrl.replaceAll('localhost:8000', domain);
    } else if (fixedUrl.contains('127.0.0.1:8080')) {
      fixedUrl = fixedUrl.replaceAll('127.0.0.1:8080', domain);
    } else if (fixedUrl.contains('localhost:8080')) {
      fixedUrl = fixedUrl.replaceAll('localhost:8080', domain);
    } else if (fixedUrl.contains('127.0.0.1')) {
      fixedUrl = fixedUrl.replaceAll('127.0.0.1', domain);
    } else if (fixedUrl.contains('localhost')) {
      fixedUrl = fixedUrl.replaceAll('localhost', domain);
    }

    if (fixedUrl.startsWith('http')) return fixedUrl;
    
    // Clean leading slash
    fixedUrl = fixedUrl.replaceFirst(RegExp(r'^/'), '');

    // If it doesn't start with storage/ but starts with typical asset folders, prepend storage/
    if (!fixedUrl.startsWith('storage/') && 
        (fixedUrl.startsWith('products/') || 
         fixedUrl.startsWith('categories/') || 
         fixedUrl.startsWith('services/') || 
         fixedUrl.startsWith('banners/'))) {
      fixedUrl = 'storage/$fixedUrl';
    }

    return '$directBaseUrl/$fixedUrl';
  }

  // ==================== PRODUCTS ====================

  /// Get all products from Laravel - with caching
  static Future<List<dynamic>> getProducts({
    String? categoryId,
    String? brandId,
    String? tagId,
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if ((categoryId == null || categoryId.isEmpty) && brandId == null && tagId == null) {
      if (!forceRefresh) {
        final isCacheValid = await _isCacheValid(_cacheProductsKey);
        if (isCacheValid) {
          final cached = await _getCachedData(_cacheProductsKey);
          if (cached != null && cached.isNotEmpty) return cached;
        }
      }
    }

    try {
      String url = '$baseUrl/products';
      List<String> params = [];
      if (categoryId != null && categoryId.isNotEmpty) params.add('category_id=$categoryId');
      if (brandId != null && brandId.isNotEmpty) params.add('brand_id=$brandId');
      if (tagId != null && tagId.isNotEmpty) params.add('tag_id=$tagId');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }
      
      print('Fetching products from: $url');
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          List products = data['data'] as List;
          
          if ((categoryId == null || categoryId.isEmpty) && brandId == null && tagId == null) {
            await _saveToCache(_cacheProductsKey, products);
          }

          // Fix image URLs
          for (var product in products) {
            product['image'] = fixImageUrl(product['image']?.toString());
            product['image_url'] = fixImageUrl(product['image_url']?.toString());
            if (product['images'] != null && product['images'] is List) {
              product['images'] = (product['images'] as List).map((img) {
                return fixImageUrl(img?.toString());
              }).toList();
            }
          }
          
          return products;
        }
      }
    } catch (e) {
      print('Error fetching products: $e');
    }

    final cached = await _getCachedData(_cacheProductsKey);
    return cached ?? [];
  }

  /// Get product by ID
  static Future<Map<String, dynamic>?> getProduct(String id) async {
    print('===== DEBUG getProduct =====');
    print('Product ID: "$id"');

    // Try local fallback first for fast loading
    print('Getting all products locally for fast loading...');
    try {
      final allProducts = await getProducts();
      final productIdNum = int.tryParse(id) ?? 0;

      // Find product by ID
      for (var product in allProducts) {
        if (product['id'] == productIdNum) {
          print('Found product locally: ${product['name']}');
          return Map<String, dynamic>.from(product);
        }
      }
    } catch (e) {
      print('Local fallback failed: $e');
    }

    return null;
  }

  // ==================== PRODUCT TAGS ====================

  /// Get product tags (with images) for a specific category or all tags
  static Future<List<dynamic>> getProductTags({String? brandId, String? type}) async {
    try {
      String url = '$baseUrl/products/tags';
      List<String> params = [];
      if (brandId != null && brandId.isNotEmpty) params.add('brand_id=$brandId');
      if (type != null && type.isNotEmpty) params.add('type=$type');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      print('Fetching product tags from: $url');
      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 8),
          );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data']['tags'] as List;
        }
      }
    } catch (e) {
      print('Error fetching product tags: $e');
    }
    return [];
  }

  /// Get all brands
  static Future<List<dynamic>> getBrands() async {
    try {
      print('Fetching brands from: $baseUrl/brands');
      final response = await http
          .get(Uri.parse('$baseUrl/brands'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] as List;
        }
      }
    } catch (e) {
      print('Error fetching brands: $e');
    }
    return [];
  }

  // ==================== CATEGORIES ====================

  /// Get all categories from Laravel
  static Future<List<dynamic>> getCategories() async {
    try {
      print('Fetching categories from: $baseUrl/categories?include_children=1');
      final response = await http
          .get(Uri.parse('$baseUrl/categories?include_children=1'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final categories = data['data'] as List;
          for (var category in categories) {
            category['image'] = fixImageUrl(category['image']?.toString());
            category['image_url'] = fixImageUrl(category['image_url']?.toString());
          }
          return categories;
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
    return [];
  }

  // ==================== ORDERS ====================

  /// Create new order in Laravel
  static Future<Map<String, dynamic>> createOrder({
    required int userId,
    required List<dynamic> items,
    required double subtotal,
    required double discount,
    required double deliveryFee,
    required double total,
    String paymentMethod = 'cash',
    String couponCode = '',
    String notes = '',
    // Customer info
    String customerName = '',
    String customerPhone = '',
    String customerAddress = '',
    String governorate = '',
  }) async {
    try {
      final address = governorate.isNotEmpty
          ? '$governorate - $customerAddress'
          : customerAddress;

      final response = await http
          .post(
            Uri.parse('$baseUrl/orders'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'user_id': userId > 0 ? userId : null,
              'customer_name': customerName,
              'customer_phone': customerPhone,
              'customer_address': address,
              'address': address,
              'items': items,
              'total_amount': total,
              'payment_method': paymentMethod,
              'coupon_code': couponCode.isNotEmpty ? couponCode : null,
              'notes': notes.isNotEmpty ? notes : null,
              'subtotal': subtotal,
              'coupon_discount': discount,
              'delivery_fee': deliveryFee,
            }),
          )
          .timeout(const Duration(seconds: 15));

      print('Create order response: ${response.statusCode} - ${response.body}');

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        return {'success': true, 'data': data['data'], 'message': data['message']};
      }
      return {'success': false, 'message': data['message'] ?? 'فشل إنشاء الطلب'};
    } catch (e) {
      print('Error creating order: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالسيرفر: $e'};
    }
  }

  /// Get user orders from FastAPI v1
  static Future<List<dynamic>> getUserOrders(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token') ?? '';
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      String? phone;
      final userJson = prefs.getString('current_user');
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        phone = userData['phone']?.toString();
      }

      String url = '$baseUrl/v1/orders';
      if (phone != null && phone.isNotEmpty) {
        url += '?phone_number=${Uri.encodeComponent(phone)}';
      }

      print('Fetching user orders from: $url');
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final ordersList = data['data'] as List;
          return ordersList.map((o) {
            final itemsCount = o['items_count'] ?? 0;
            return {
              'id': o['id'],
              'status': o['status'],
              'created_at': o['created_at'],
              'total_amount': o['total_amount'],
              'order_items': List.generate(itemsCount, (_) => {}), // Compatibility wrapper
            };
          }).toList();
        }
      }
    } catch (e) {
      print('Error fetching user orders: $e');
    }
    return [];
  }

  /// Get all orders (admin)
  static Future<List<dynamic>> getAllOrders() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/orders'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] ?? []) as List;
        }
      }
    } catch (e) {
      print('Error fetching all orders: $e');
    }
    return [];
  }

  // ==================== HERO BANNERS ====================

  /// Get hero banners from Laravel - with caching
  static Future<List<dynamic>> getHeroBanners({
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (!forceRefresh) {
      final isCacheValid = await _isCacheValid(_cacheBannersKey);
      if (isCacheValid) {
        final cached = await _getCachedData(_cacheBannersKey);
        if (cached != null && cached.isNotEmpty) return cached;
      }
    }

    try {
      print('Fetching hero banners from: $baseUrl/banners');
      final response = await http
          .get(Uri.parse('$baseUrl/banners'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          final banners = data['data'] as List;
          
          // Fix image URLs
          for (var banner in banners) {
            banner['image'] = fixImageUrl(banner['image']?.toString());
            banner['image_url'] = fixImageUrl(banner['image_url']?.toString());
          }

          await _saveToCache(_cacheBannersKey, banners);
          return banners;
        }
      }
    } catch (e) {
      print('Error fetching hero banners: $e');
    }

    final cached = await _getCachedData(_cacheBannersKey);
    return cached ?? [];
  }

  /// Default hero banners for fallback - empty list since banners should be managed from admin panel
  static List<dynamic> getDefaultHeroBanners() {
    return [];
  }

  // ==================== COUPONS ====================

  /// Validate coupon from MySQL
  static Future<Map<String, dynamic>?> validateCoupon(
    String code,
    double orderTotal,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/coupons/validate?code=$code&total=$orderTotal',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data']?['valid'] == true) {
          return Map<String, dynamic>.from(data['data']);
        }
      }
    } catch (e) {
      // Fallback
    }
    return null;
  }

  // ==================== SPECIAL OFFERS ====================

  /// Get special offers from MySQL - with caching
  static Future<List<dynamic>> getSpecialOffers({
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (!forceRefresh) {
      final isCacheValid = await _isCacheValid(_cacheOffersKey);
      if (isCacheValid) {
        final cached = await _getCachedData(_cacheOffersKey);
        if (cached != null && cached.isNotEmpty) {
          print('Returning cached special offers: ${cached.length} items');
          return cached;
        }
      }
    }

    try {
      print('Fetching special offers from: $baseUrl/special_offers.php');

      String url = '$baseUrl/special-offers?v=${DateTime.now().millisecondsSinceEpoch ~/ 1000}';
      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          if (data['data'] is Map && data['data']['offers'] != null) {
            final offers = data['data']['offers'] as List;
            if (offers.isNotEmpty) {
              print('Found ${offers.length} special offers from API');
              
              // Fix image URLs
              for (var offer in offers) {
                offer['image'] = fixImageUrl(offer['image']?.toString());
                offer['image_url'] = fixImageUrl(offer['image_url']?.toString());
              }

              // Cache the results
              await _saveToCache(_cacheOffersKey, offers);
              return offers;
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching special offers: $e');
    }

    // Try to return cached data even if expired
    final cached = await _getCachedData(_cacheOffersKey);
    if (cached != null && cached.isNotEmpty) {
      print('Returning expired cached special offers: ${cached.length} items');
      return cached;
    }

    // Return empty list
    return [];
  }

  /// Default special offers for fallback
  static List<dynamic> getDefaultSpecialOffers() {
    return [];
  }

  // ==================== DELETE PRODUCTS ====================

  /// Delete a product by ID
  static Future<bool> deleteProduct(String productId) async {
    try {
      print('Deleting product with ID: $productId');
      final response = await http
          .delete(
            Uri.parse('$baseUrl/products/$productId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('Delete request timeout');
              throw Exception('Request timeout');
            },
          );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('Product deleted successfully');
          return true;
        } else {
          print('Delete failed: ${data['message']}');
        }
      }
    } catch (e) {
      print('Error deleting product: $e');
    }
    return false;
  }

  /// Delete multiple products by IDs
  static Future<bool> deleteMultipleProducts(List<String> productIds) async {
    try {
      int successCount = 0;
      for (String productId in productIds) {
        bool success = await deleteProduct(productId);
        if (success) successCount++;
      }
      return successCount == productIds.length;
    } catch (e) {
      print('Error deleting multiple products: $e');
      return false;
    }
  }

  // ==================== CATEGORY BANNERS ====================

  /// Get category banners (banners under categories on home screen) - with caching
  static Future<List<dynamic>> getCategoryBanners({
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (!forceRefresh) {
      final isCacheValid = await _isCacheValid(_cacheCategoryBannersKey);
      if (isCacheValid) {
        final cached = await _getCachedData(_cacheCategoryBannersKey);
        if (cached != null && cached.isNotEmpty) {
          print('Returning cached category banners: ${cached.length} items');
          return cached;
        }
      }
    }

    try {
      String url = '$baseUrl/category-banners';
      if (forceRefresh) {
        url += '&t=${DateTime.now().millisecondsSinceEpoch}';
      }

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          if (data['data'] is Map && data['data']['banners'] != null) {
            final banners = data['data']['banners'] as List;
            if (banners.isNotEmpty) {
              // Fix image URLs
              for (var banner in banners) {
                banner['image'] = fixImageUrl(banner['image']?.toString());
                banner['image_url'] = fixImageUrl(banner['image_url']?.toString());
              }

              // Cache the results
              await _saveToCache(_cacheCategoryBannersKey, banners);
              return banners;
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching category banners: $e');
    }

    // Try to return cached data even if expired
    final cached = await _getCachedData(_cacheCategoryBannersKey);
    if (cached != null && cached.isNotEmpty) {
      print(
        'Returning expired cached category banners: ${cached.length} items',
      );
      return cached;
    }

    return [];
  }

  /// Default category banners - empty list (no fallback data)
  static List<dynamic> getDefaultCategoryBanners() {
    return [];
  }
}
