import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/cart.dart';
import '../models/cart_model.dart';

/// Local data source for cart operations using shared_preferences
class CartLocalDataSource {
  static const String _cartKey = 'cart_data';
  static const String _couponsKey = 'available_coupons';

  final SharedPreferences prefs;

  CartLocalDataSource(this.prefs);

  /// Save cart to local storage
  Future<void> saveCart(Cart cart) async {
    final cartModel = CartModel.fromEntity(cart);
    final cartJson = cartModel.toJson();
    await prefs.setString(_cartKey, jsonEncode(cartJson));
  }

  /// Load cart from local storage
  Future<Cart> loadCart() async {
    final cartJsonString = prefs.getString(_cartKey);
    if (cartJsonString == null) {
      return const Cart();
    }
    try {
      final cartJson = jsonDecode(cartJsonString) as Map<String, dynamic>;
      final cartModel = CartModel.fromJson(cartJson);
      return cartModel.toEntity();
    } catch (e) {
      return const Cart();
    }
  }

  /// Clear cart from local storage
  Future<void> clearCart() async {
    await prefs.remove(_cartKey);
  }

  /// Get available coupons (for demo purposes)
  Future<List<CouponModel>> getAvailableCoupons() async {
    final couponsJsonString = prefs.getString(_couponsKey);
    if (couponsJsonString == null) {
      // Return default coupons
      return _getDefaultCoupons();
    }
    try {
      final couponsJson = jsonDecode(couponsJsonString) as List<dynamic>;
      return couponsJson
          .map((c) => CouponModel.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _getDefaultCoupons();
    }
  }

  /// Initialize default coupons
  Future<void> initDefaultCoupons() async {
    final coupons = _getDefaultCoupons();
    final couponsJson = coupons.map((c) => c.toJson()).toList();
    await prefs.setString(_couponsKey, jsonEncode(couponsJson));
  }

  /// Default coupon list for demo
  List<CouponModel> _getDefaultCoupons() {
    return [
      const CouponModel(
        code: 'WELCOME10',
        type: 'percentage',
        value: 10,
        minimumOrder: 50000,
        maximumDiscount: 15000,
      ),
      const CouponModel(
        code: 'SAVE5000',
        type: 'fixed',
        value: 5000,
        minimumOrder: 30000,
      ),
      const CouponModel(
        code: 'FREEDELIVERY',
        type: 'fixed',
        value: 5000,
        minimumOrder: 25000,
      ),
      const CouponModel(
        code: 'SUMMER20',
        type: 'percentage',
        value: 20,
        minimumOrder: 100000,
        maximumDiscount: 25000,
        expiryDate: '2025-08-31T23:59:59',
      ),
    ];
  }

  /// Validate a coupon code
  Future<CouponModel?> validateCoupon(String code) async {
    final coupons = await getAvailableCoupons();
    try {
      return coupons.firstWhere(
        (coupon) =>
            coupon.code.toLowerCase() == code.toLowerCase() &&
            _isCouponValid(coupon),
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if coupon is valid
  bool _isCouponValid(CouponModel coupon) {
    if (coupon.expiryDate != null) {
      final expiryDate = DateTime.parse(coupon.expiryDate!);
      if (DateTime.now().isAfter(expiryDate)) {
        return false;
      }
    }
    return true;
  }
}
