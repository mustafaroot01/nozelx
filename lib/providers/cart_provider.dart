import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_lube/models/cart_item_model.dart';
import 'package:auto_lube/models/coupon_model.dart';
import 'package:auto_lube/models/cart_summary_model.dart';
import 'package:auto_lube/services/cart_service.dart';
import 'package:auto_lube/services/coupon_service.dart';
import 'package:auto_lube/core/exceptions/app_exception.dart';
import 'package:auto_lube/core/utils/currency_formatter.dart';
import 'package:auto_lube/core/config/app_settings.dart';
import 'package:auto_lube/providers/app_settings_provider.dart';

class CartProvider extends ChangeNotifier {
  static final CartProvider _instance = CartProvider._internal();

  factory CartProvider() {
    return _instance;
  }

  CartProvider._internal();

  // ── State ──────────────────────────────────
  List<CartItemModel> _items = [];
  CouponModel? _appliedCoupon;
  double _couponDiscount = 0.0;
  bool _isLoading = false;
  bool _isValidatingCoupon = false;
  bool _isPlacingOrder = false;
  String? _error;
  String? _couponError;
  String? _couponSuccess;
  // Delivery fee is loaded dynamically from AppSettings

  // ── Getters ────────────────────────────────
  List<CartItemModel> get items => _items;
  CouponModel? get appliedCoupon => _appliedCoupon;
  bool get isLoading => _isLoading;
  bool get isValidatingCoupon => _isValidatingCoupon;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get error => _error;
  String? get couponError => _couponError;
  String? get couponSuccess => _couponSuccess;
  bool get isEmpty => _items.isEmpty;
  int get itemsCount => _items.fold(0, (sum, item) => sum + item.quantity);
  int get totalItems => itemsCount;

  double get subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);
  double get deliveryFee {
    if (isEmpty) return 0.0;
    final priceAfterDiscount = subtotal - _couponDiscount;
    if (priceAfterDiscount >= AppSettings().freeShippingThreshold) return 0.0;
    return AppSettings().shippingFee;
  }
  double get total => (subtotal + deliveryFee - _couponDiscount).clamp(0.0, double.infinity);

  double get itemDiscount {
    return _items.fold(0.0, (sum, item) {
      if (item.originalPrice != null && item.originalPrice! > item.price) {
        return sum + ((item.originalPrice! - item.price) * item.quantity);
      }
      return sum;
    });
  }

  double get couponDiscount => _couponDiscount;
  double get totalDiscount => itemDiscount + _couponDiscount;

  CartSummaryModel get summary => CartSummaryModel(
    subtotal: subtotal,
    deliveryFee: deliveryFee,
    couponDiscount: _couponDiscount,
    tax: 0,
    total: total,
    itemsCount: itemsCount,
    appliedCoupon: _appliedCoupon,
  );

  // ── Initialization ─────────────────────────
  Future<void> init() async {
    await loadFromLocal();
    await fetchCart();
  }

  // ── الوظائف ────────────────────────────────

  // جلب السلة من السيرفر
  Future<void> fetchCart() async {
    // Refresh settings dynamically for both guest and authenticated users
    try {
      await AppSettingsProvider().fetchSettings();
    } catch (e) {
      debugPrint('Error updating settings: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      // مستخدم زائر: لا توجد جلسة نشطة، السلة محلية فقط ولا نطلبها من السيرفر لتفادي خطأ 401
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final serverItems = await CartService().getCart();
      _items = serverItems;
      await _saveLocally();
      await _revalidateCoupon();
    } catch (e) {
      _error = 'فشل جلب بيانات السلة: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // إضافة منتج - يدعم كلاً من كائن CartItemModel أو المعاملات المسماة المتوافقة سابقاً
  Future<void> addItem({
    CartItemModel? item,
    String? productId,
    String? name,
    String? image,
    double? price,
    double? oldPrice,
    int? quantity,
    int? maxQuantity,
    String? brand,
  }) async {
    _error = null;
    
    CartItemModel actualItem;
    if (item != null) {
      actualItem = item;
    } else {
      final pId = int.tryParse(productId ?? '') ?? 0;
      actualItem = CartItemModel(
        id: DateTime.now().millisecondsSinceEpoch, // معرف مؤقت
        productId: pId,
        name: name ?? '',
        imageUrl: image ?? '',
        price: price ?? 0.0,
        originalPrice: oldPrice,
        quantity: quantity ?? 1,
        stockQuantity: maxQuantity ?? 999,
        isAvailable: true,
      );
    }

    final existingIndex = _items.indexWhere((e) => e.productId == actualItem.productId);
    
    // تحقق من المخزون أولاً
    if (existingIndex >= 0) {
      final existingItem = _items[existingIndex];
      if (existingItem.quantity + actualItem.quantity > existingItem.stockQuantity) {
        _error = 'الكمية المطلوبة تتجاوز المخزون المتوفر';
        notifyListeners();
        return;
      }
    } else {
      if (actualItem.isOutOfStock) {
        _error = 'المنتج نفذ من المخزون';
        notifyListeners();
        return;
      }
    }

    // حفظ الحالة السابقة للاسترجاع
    final oldItems = List<CartItemModel>.from(_items);
    
    // Optimistic Update
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += actualItem.quantity;
    } else {
      _items.add(actualItem);
    }
    
    await _saveLocally();
    await _revalidateCoupon();
    notifyListeners();

    // API call
    try {
      await CartService().addToCart(
        productId: actualItem.productId,
        qty: actualItem.quantity,
        size: actualItem.selectedSize,
        color: actualItem.selectedColor,
      );
      
      // مزامنة حقيقية لتحديث معرفات العناصر من السيرفر
      await fetchCart();
    } catch (e) {
      // إرجاع الحالة السابقة في حال الفشل
      _items = oldItems;
      _error = 'فشل إضافة المنتج للسلة: ${e.toString()}';
      await _saveLocally();
      await _revalidateCoupon();
      notifyListeners();
    }
  }

  // تحديث الكمية
  Future<void> updateQuantity(int productId, int newQty) async {
    _error = null;
    final index = _items.indexWhere((e) => e.productId == productId);
    if (index < 0) return;

    final item = _items[index];

    // إذا newQty == 0 احذف المنتج
    if (newQty <= 0) {
      await removeItem(item.id);
      return;
    }

    // تحقق newQty <= stockQuantity
    if (newQty > item.stockQuantity) {
      _error = 'الكمية المطلوبة تتجاوز المخزون المتوفر';
      notifyListeners();
      return;
    }

    // حفظ الحالة السابقة
    final oldItems = List<CartItemModel>.from(_items);

    // Optimistic Update
    _items[index].quantity = newQty;
    await _saveLocally();
    await _revalidateCoupon();
    notifyListeners();

    try {
      await CartService().updateItem(itemId: item.id, qty: newQty);
    } catch (e) {
      // إرجاع الحالة
      _items = oldItems;
      _error = 'فشل تحديث الكمية: ${e.toString()}';
      await _saveLocally();
      await _revalidateCoupon();
      notifyListeners();
    }
  }

  // حذف منتج
  Future<void> removeItem(int cartItemId) async {
    _error = null;
    final index = _items.indexWhere((e) => e.id == cartItemId);
    if (index < 0) return;

    final oldItems = List<CartItemModel>.from(_items);

    // Optimistic Update
    _items.removeAt(index);
    await _saveLocally();
    await _revalidateCoupon();
    notifyListeners();

    try {
      await CartService().removeItem(itemId: cartItemId);
    } catch (e) {
      // إرجاع الحالة
      _items = oldItems;
      _error = 'فشل إزالة المنتج: ${e.toString()}';
      await _saveLocally();
      await _revalidateCoupon();
      notifyListeners();
    }
  }

  // تراجع عن الحذف
  Future<void> undoRemove(CartItemModel item) async {
    _error = null;
    final existingIndex = _items.indexWhere((e) => e.productId == item.productId);
    if (existingIndex >= 0) return;

    _items.add(item);
    await _saveLocally();
    await _revalidateCoupon();
    notifyListeners();

    try {
      await CartService().addToCart(
        productId: item.productId,
        qty: item.quantity,
        size: item.selectedSize,
        color: item.selectedColor,
      );
      await fetchCart();
    } catch (e) {
      _items.removeWhere((e) => e.id == item.id);
      _error = 'فشل استعادة المنتج: ${e.toString()}';
      await _saveLocally();
      await _revalidateCoupon();
      notifyListeners();
    }
  }

  // تفريغ السلة
  Future<void> clearCart() async {
    _error = null;
    final oldItems = List<CartItemModel>.from(_items);
    final oldCoupon = _appliedCoupon;
    final oldDiscount = _couponDiscount;

    _items.clear();
    _appliedCoupon = null;
    _couponDiscount = 0.0;
    _couponError = null;
    _couponSuccess = null;
    await _saveLocally();
    notifyListeners();

    try {
      await CartService().clearCart();
    } catch (e) {
      _items = oldItems;
      _appliedCoupon = oldCoupon;
      _couponDiscount = oldDiscount;
      _error = 'فشل تفريغ السلة: ${e.toString()}';
      await _saveLocally();
      notifyListeners();
    }
  }

  // تطبيق كوبون الخصم
  Future<void> applyCoupon(String code) async {
    if (code.trim().isEmpty) return;
    _isValidatingCoupon = true;
    _couponError = null;
    _couponSuccess = null;
    notifyListeners();

    try {
      final result = await CouponService().validateCoupon(
        code: code.trim().toUpperCase(),
        cartTotal: subtotal,
      );
      _appliedCoupon = result.coupon;
      _couponDiscount = result.discountAmount;
      _couponSuccess = 'تم تطبيق الكود ✓ ${result.coupon.displayText}';
    } on AppException catch (e) {
      _couponError = e.message;
      _appliedCoupon = null;
      _couponDiscount = 0.0;
    } finally {
      _isValidatingCoupon = false;
      notifyListeners();
    }
  }

  // إزالة الكوبون
  void removeCoupon() {
    _appliedCoupon = null;
    _couponDiscount = 0.0;
    _couponError = null;
    _couponSuccess = null;
    _saveLocally();
    notifyListeners();
  }

  // إعادة التحقق من الكوبون بعد تغيير السلة
  Future<void> _revalidateCoupon() async {
    if (_appliedCoupon == null) return;
    if (subtotal < _appliedCoupon!.minOrderAmount) {
      _couponDiscount = 0.0;
      _couponSuccess = null;
      _couponError =
          'الكوبون يتطلب طلباً بقيمة ${CurrencyFormatter.format(_appliedCoupon!.minOrderAmount)} على الأقل';
      _appliedCoupon = null;
      notifyListeners();
      return;
    }
    _couponDiscount = _appliedCoupon!.calculateDiscount(subtotal);
    notifyListeners();
  }

  // حفظ السلة محلياً
  Future<void> _saveLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('cart_items_cache_v2', cartJson);
      if (_appliedCoupon != null) {
        await prefs.setString('applied_coupon_cache_v2', json.encode(_appliedCoupon!.toJson()));
        await prefs.setDouble('coupon_discount_cache_v2', _couponDiscount);
      } else {
        await prefs.remove('applied_coupon_cache_v2');
        await prefs.remove('coupon_discount_cache_v2');
      }
    } catch (e) {
      debugPrint('Error saving local cart: $e');
    }
  }

  // تحميل السلة من التخزين المحلي
  Future<void> loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart_items_cache_v2');
      if (cartJson != null && cartJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(cartJson) as List<dynamic>;
        _items = decoded.map((item) => CartItemModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      final couponJson = prefs.getString('applied_coupon_cache_v2');
      if (couponJson != null && couponJson.isNotEmpty) {
        _appliedCoupon = CouponModel.fromJson(json.decode(couponJson) as Map<String, dynamic>);
        _couponDiscount = prefs.getDouble('coupon_discount_cache_v2') ?? 0.0;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading local cart: $e');
    }
  }

  // ── Compatibility Getters & Methods ────────

  bool isInCart(String productId) {
    final idInt = int.tryParse(productId);
    if (idInt == null) return false;
    return _items.any((item) => item.productId == idInt);
  }

  int getItemQuantity(String productId) {
    final idInt = int.tryParse(productId);
    if (idInt == null) return 0;
    try {
      return _items.firstWhere((item) => item.productId == idInt).quantity;
    } catch (e) {
      return 0;
    }
  }

  void updateStockFromWebSocket(String? productId, int newQty) {
    if (productId == null) return;
    final prodIdInt = int.tryParse(productId);
    if (prodIdInt == null) return;
    
    bool updated = false;
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].productId == prodIdInt) {
        final item = _items[i];
        final bool isAvail = newQty > 0;
        
        int adjustedQuantity = item.quantity;
        if (adjustedQuantity > newQty && newQty >= 0) {
          adjustedQuantity = newQty;
        }

        _items[i] = item.copyWith(
          quantity: adjustedQuantity,
          stockQuantity: newQty,
          isAvailable: isAvail,
        );
        updated = true;
      }
    }
    
    if (updated) {
      _saveLocally();
      _revalidateCoupon();
      notifyListeners();
    }
  }

  // مزامنة السلة مع السيرفر بعد تسجيل الدخول
  Future<void> syncAfterLogin(String phone) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_items.isNotEmpty) {
        for (var item in _items) {
          try {
            await CartService().addToCart(
              productId: item.productId,
              qty: item.quantity,
            );
          } catch (e) {
            debugPrint('Failed to sync item ${item.productId}: $e');
          }
        }
      }
      await fetchCart();
    } catch (e) {
      debugPrint('Error syncing cart after login: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // مسح السلة محلياً عند تسجيل الخروج
  void clearForLogout() {
    _items.clear();
    _appliedCoupon = null;
    _couponDiscount = 0.0;
    _couponError = null;
    _couponSuccess = null;
    _saveLocally();
    notifyListeners();
  }
}
