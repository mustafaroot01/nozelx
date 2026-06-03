import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:auto_lube/core/services/cart_service.dart';
import 'package:auto_lube/core/services/api_service.dart';
import 'package:auto_lube/core/config/app_settings.dart';

/// Cart Item Model
class CartItemModel {
  final String id;
  final String productId;
  final String name;
  final String brand;
  final String image;
  final double price;
  final double? oldPrice;
  int quantity;
  final bool isAvailable;
  final int? maxQuantity;

  CartItemModel({
    String? id,
    required this.productId,
    required this.name,
    required this.brand,
    required this.image,
    required this.price,
    this.oldPrice,
    required this.quantity,
    this.isAvailable = true,
    this.maxQuantity,
  }) : id = id ?? const Uuid().v4();

  double get totalPrice => price * quantity;

  int? get discountPercentage {
    if (oldPrice != null && oldPrice! > price) {
      return ((1 - price / oldPrice!) * 100).round();
    }
    return null;
  }

  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'brand': brand,
      'image': image,
      'price': price,
      'oldPrice': oldPrice,
      'quantity': quantity,
      'isAvailable': isAvailable,
      'maxQuantity': maxQuantity,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] as String,
      productId: map['productId'] as String,
      name: map['name'] as String,
      brand: map['brand'] as String,
      image: map['image'] as String,
      price: (map['price'] as num).toDouble(),
      oldPrice: map['oldPrice'] != null
          ? (map['oldPrice'] as num).toDouble()
          : null,
      quantity: map['quantity'] as int,
      isAvailable: map['isAvailable'] as bool? ?? true,
      maxQuantity: map['maxQuantity'] as int?,
    );
  }
}

/// Coupon Model
class CouponModel {
  final String code;
  final String type; // 'percentage' or 'fixed'
  final double value;
  final double? minimumOrder;
  final double? maximumDiscount;
  final String? expiryDate;

  CouponModel({
    required this.code,
    required this.type,
    required this.value,
    this.minimumOrder,
    this.maximumDiscount,
    this.expiryDate,
  });

  bool get isValid {
    if (expiryDate != null) {
      final expiry = DateTime.tryParse(expiryDate!);
      if (expiry != null && DateTime.now().isAfter(expiry)) {
        return false;
      }
    }
    return true;
  }

  double calculateDiscount(double orderAmount) {
    if (!isValid) return 0;
    if (minimumOrder != null && orderAmount < minimumOrder!) return 0;

    double discount;
    if (type == 'percentage') {
      discount = orderAmount * (value / 100);
    } else {
      discount = value;
    }

    if (maximumDiscount != null && discount > maximumDiscount!) {
      return maximumDiscount!;
    }

    return discount;
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'type': type,
      'value': value,
      'minimumOrder': minimumOrder,
      'maximumDiscount': maximumDiscount,
      'expiryDate': expiryDate,
    };
  }

  factory CouponModel.fromMap(Map<String, dynamic> map) {
    return CouponModel(
      code: map['code'] as String,
      type: map['type'] as String,
      value: (map['value'] as num).toDouble(),
      minimumOrder: map['minimumOrder'] != null
          ? (map['minimumOrder'] as num).toDouble()
          : null,
      maximumDiscount: map['maximumDiscount'] != null
          ? (map['maximumDiscount'] as num).toDouble()
          : null,
      expiryDate: map['expiryDate'] as String?,
    );
  }
}

/// Cart Manager - Singleton for cart state management
class CartManager extends ChangeNotifier {
  static final CartManager _instance = CartManager._internal();

  factory CartManager() {
    return _instance;
  }

  CartManager._internal();

  List<CartItemModel> _items = [];
  CouponModel? _appliedCoupon;
  bool _isLoading = false;

  List<CartItemModel> get items => _items;
  CouponModel? get appliedCoupon => _appliedCoupon;
  bool get isLoading => _isLoading;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  double get itemDiscount {
    return _items.fold(0, (sum, item) {
      if (item.hasDiscount && item.oldPrice != null) {
        return sum + ((item.oldPrice! - item.price) * item.quantity);
      }
      return sum;
    });
  }

  double get couponDiscount {
    return _appliedCoupon?.calculateDiscount(subtotal) ?? 0;
  }

  double get totalDiscount => itemDiscount + couponDiscount;

  double get deliveryFee {
    final priceAfterDiscount = subtotal - couponDiscount;
    if (priceAfterDiscount >= AppSettings().freeShippingThreshold) return 0;
    return AppSettings().shippingFee;
  }

  double get total => (subtotal - couponDiscount) + deliveryFee;

  bool get isEmpty => _items.isEmpty;
  bool get hasUnavailableItems => _items.any((item) => !item.isAvailable);
  int get unavailableItemsCount =>
      _items.where((item) => !item.isAvailable).length;

  /// Initialize cart from shared preferences & backend
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart_data');

      if (cartJson != null && cartJson.isNotEmpty) {
        final List<dynamic> itemsList = _parseJsonList(cartJson);
        _items = itemsList.map((item) => CartItemModel.fromMap(item)).toList();
      } else {
        _items = [];
      }
    } catch (e) {
      debugPrint('Error loading local cart: $e');
    }

    _isLoading = false;
    notifyListeners();

    // Sync with server in background
    await syncWithServer();
  }

  /// Synchronize cart items with FastAPI backend
  Future<void> syncWithServer() async {
    try {
      final serverCart = await CartService.getCart();
      if (serverCart != null) {
        final List<dynamic> serverItems = serverCart['items'] ?? [];
        _items = serverItems.map((item) {
          final prod = item['product'];
          final productId = prod['id']?.toString() ?? '';
          final price = double.tryParse(prod['price']?.toString() ?? '0') ?? 0.0;
          final salePrice = prod['sale_price'] != null 
              ? double.tryParse(prod['sale_price']?.toString() ?? '') 
              : null;
          
          return CartItemModel(
            id: item['id']?.toString(), // Use database cart item ID
            productId: productId,
            name: prod['name'] ?? '',
            brand: prod['brand'] ?? '',
            image: ApiService.fixImageUrl(prod['image_url']?.toString()),
            price: salePrice ?? price,
            oldPrice: salePrice != null ? price : null,
            quantity: item['quantity'] ?? 1,
            isAvailable: (prod['stock'] ?? 0) > 0,
            maxQuantity: prod['stock'],
          );
        }).toList();
        
        await _saveCart();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error syncing cart with server: $e');
    }
  }

  /// Simple JSON list parser
  List<dynamic> _parseJsonList(String jsonString) {
    try {
      final decoded = json.decode(jsonString);
      if (decoded is List) {
        return decoded;
      }
      return [];
    } catch (e) {
      debugPrint('Error parsing JSON: $e');
      return [];
    }
  }

  /// Add item to cart
  Future<void> addItem({
    required String productId,
    required String name,
    required String brand,
    required String image,
    required double price,
    double? oldPrice,
    int quantity = 1,
    int? maxQuantity,
  }) async {
    // 1. Update locally for instant response
    final existingIndex = _items.indexWhere(
      (item) => item.productId == productId,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItemModel(
          productId: productId,
          name: name,
          brand: brand,
          image: image,
          price: price,
          oldPrice: oldPrice,
          quantity: quantity,
          maxQuantity: maxQuantity,
        ),
      );
    }

    _saveCart();
    notifyListeners();

    // 2. Push to backend
    try {
      final prodIdInt = int.tryParse(productId) ?? 0;
      if (prodIdInt > 0) {
        await CartService.addToCart(
          productId: prodIdInt,
          quantity: quantity,
        );
        await syncWithServer();
      }
    } catch (e) {
      debugPrint('Error pushing add item to server: $e');
    }
  }

  /// Remove item from cart
  Future<void> removeItem(String itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index < 0) return;
    
    final item = _items[index];
    _items.removeAt(index);
    _saveCart();
    notifyListeners();

    try {
      final backendItemId = int.tryParse(item.id);
      if (backendItemId != null && backendItemId > 0) {
        await CartService.removeFromCart(backendItemId);
      }
      await syncWithServer();
    } catch (e) {
      debugPrint('Error removing item on server: $e');
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(String itemId, int quantity) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index < 0) return;
    
    _items[index].quantity = quantity;
    _saveCart();
    notifyListeners();

    try {
      final backendItemId = int.tryParse(itemId);
      if (backendItemId != null && backendItemId > 0) {
        await CartService.updateCartItem(itemId: backendItemId, quantity: quantity);
      }
      await syncWithServer();
    } catch (e) {
      debugPrint('Error updating quantity on server: $e');
    }
  }

  /// Increment item quantity
  Future<void> incrementQuantity(String itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index < 0) return;
    final item = _items[index];

    if (item.maxQuantity == null || item.quantity < item.maxQuantity!) {
      item.quantity++;
      _saveCart();
      notifyListeners();

      try {
        final backendItemId = int.tryParse(itemId);
        if (backendItemId != null && backendItemId > 0) {
          await CartService.updateCartItem(itemId: backendItemId, quantity: item.quantity);
        }
        await syncWithServer();
      } catch (e) {
        debugPrint('Error incrementing quantity on server: $e');
      }
    }
  }

  /// Decrement item quantity
  Future<void> decrementQuantity(String itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index < 0) return;
    final item = _items[index];

    if (item.quantity > 1) {
      item.quantity--;
      _saveCart();
      notifyListeners();

      try {
        final backendItemId = int.tryParse(itemId);
        if (backendItemId != null && backendItemId > 0) {
          await CartService.updateCartItem(itemId: backendItemId, quantity: item.quantity);
        }
        await syncWithServer();
      } catch (e) {
        debugPrint('Error decrementing quantity on server: $e');
      }
    }
  }

  /// Clear all items from cart
  Future<void> clearCart() async {
    _items.clear();
    _appliedCoupon = null;
    _saveCart();
    notifyListeners();

    try {
      await CartService.clearCart();
    } catch (e) {
      debugPrint('Error clearing cart on server: $e');
    }
  }

  /// Clear cart after successful order (public method)
  void clearCartAfterOrder() {
    clearCart();
  }

  /// Apply coupon code
  void applyCoupon(CouponModel coupon) {
    _appliedCoupon = coupon;
    _saveCart();
    notifyListeners();
  }

  /// Remove applied coupon
  void removeCoupon() {
    _appliedCoupon = null;
    _saveCart();
    notifyListeners();
  }

  /// Save cart to shared preferences
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = json.encode(
        _items.map((item) => item.toMap()).toList(),
      );
      await prefs.setString('cart_data', itemsJson);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  /// Check if product is in cart
  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  /// Get quantity of a product in cart
  int getItemQuantity(String productId) {
    try {
      return _items.firstWhere((item) => item.productId == productId).quantity;
    } catch (e) {
      return 0;
    }
  }

  /// Real-time stock update from WebSocket event
  void updateStockFromWebSocket(String? productId, int newQty) {
    if (productId == null) return;
    
    bool updated = false;
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].productId == productId) {
        final item = _items[i];
        final bool isAvail = newQty > 0;
        
        // If current quantity exceeds new stock, clamp it
        int adjustedQuantity = item.quantity;
        if (adjustedQuantity > newQty && newQty >= 0) {
          adjustedQuantity = newQty;
        }

        _items[i] = CartItemModel(
          id: item.id,
          productId: item.productId,
          name: item.name,
          brand: item.brand,
          image: item.image,
          price: item.price,
          oldPrice: item.oldPrice,
          quantity: adjustedQuantity,
          isAvailable: isAvail,
          maxQuantity: newQty,
        );
        updated = true;
      }
    }
    
    if (updated) {
      _saveCart();
      notifyListeners();
    }
  }
}

/// Available coupons
class AvailableCoupons {
  static final List<CouponModel> coupons = [
    CouponModel(
      code: 'WELCOME10',
      type: 'percentage',
      value: 10,
      minimumOrder: 50000,
      maximumDiscount: 15000,
    ),
    CouponModel(
      code: 'SAVE5000',
      type: 'fixed',
      value: 5000,
      minimumOrder: 30000,
    ),
    CouponModel(
      code: 'SUMMER20',
      type: 'percentage',
      value: 20,
      minimumOrder: 100000,
      maximumDiscount: 25000,
      expiryDate: '2025-08-31T23:59:59',
    ),
  ];

  static CouponModel? validateCoupon(String code) {
    try {
      return coupons.firstWhere(
        (coupon) =>
            coupon.code.toLowerCase() == code.toLowerCase() && coupon.isValid,
      );
    } catch (e) {
      return null;
    }
  }
}
