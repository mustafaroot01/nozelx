import 'package:equatable/equatable.dart';
import 'cart_item.dart';
import 'package:auto_lube/core/config/app_settings.dart';

/// Cart Entity - represents the complete shopping cart
class Cart extends Equatable {
  final String id;
  final List<CartItem> items;
  final Coupon? appliedCoupon;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Cart({
    this.id = '',
    this.items = const [],
    this.appliedCoupon,
    this.createdAt,
    this.updatedAt,
  });

  /// Get total number of items in cart
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Get subtotal price (before discounts and delivery)
  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);

  /// Get total discount from coupon
  double get couponDiscount => appliedCoupon?.calculateDiscount(subtotal) ?? 0;

  /// Get total discount from item prices
  double get itemDiscount {
    return items.fold(0, (sum, item) {
      if (item.hasDiscount && item.oldPrice != null) {
        return sum + ((item.oldPrice! - item.price) * item.quantity);
      }
      return sum;
    });
  }

  /// Get total discount (coupon + item discounts)
  double get totalDiscount => itemDiscount + couponDiscount;

  /// Get delivery fee based on subtotal
  /// Free delivery for orders over 100,000 IQD
  /// 2,500 IQD for orders 50,000 - 99,999 IQD
  /// 5,000 IQD for orders under 50,000 IQD
  double get deliveryFee {
    final priceAfterCouponDiscount = subtotal - couponDiscount;
    if (priceAfterCouponDiscount >= AppSettings().freeShippingThreshold) return 0;
    return AppSettings().shippingFee;
  }

  /// Get final total
  double get total => (subtotal - couponDiscount) + deliveryFee;

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has available items only
  bool get hasUnavailableItems => items.any((item) => !item.isAvailable);

  /// Get count of unavailable items
  int get unavailableItemsCount =>
      items.where((item) => !item.isAvailable).length;

  /// Create a copy with modified items
  Cart copyWith({
    String? id,
    List<CartItem>? items,
    Coupon? appliedCoupon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      items: items ?? this.items,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((item) => item.toMap()).toList(),
      'appliedCoupon': appliedCoupon?.toMap(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from map
  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      id: map['id'] as String? ?? '',
      items:
          (map['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      appliedCoupon: map['appliedCoupon'] != null
          ? Coupon.fromMap(map['appliedCoupon'] as Map<String, dynamic>)
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, items, appliedCoupon, createdAt, updatedAt];
}

/// Coupon Entity
class Coupon extends Equatable {
  final String code;
  final String type; // 'percentage' or 'fixed'
  final double value;
  final double? minimumOrder;
  final double? maximumDiscount;
  final DateTime? expiryDate;

  const Coupon({
    required this.code,
    required this.type,
    required this.value,
    this.minimumOrder,
    this.maximumDiscount,
    this.expiryDate,
  });

  /// Check if coupon is valid
  bool get isValid {
    if (expiryDate != null && DateTime.now().isAfter(expiryDate!)) {
      return false;
    }
    return true;
  }

  /// Calculate discount based on order amount
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

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'type': type,
      'value': value,
      'minimumOrder': minimumOrder,
      'maximumDiscount': maximumDiscount,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }

  /// Create from map
  factory Coupon.fromMap(Map<String, dynamic> map) {
    return Coupon(
      code: map['code'] as String,
      type: map['type'] as String,
      value: (map['value'] as num).toDouble(),
      minimumOrder: map['minimumOrder'] != null
          ? (map['minimumOrder'] as num).toDouble()
          : null,
      maximumDiscount: map['maximumDiscount'] != null
          ? (map['maximumDiscount'] as num).toDouble()
          : null,
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse(map['expiryDate'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    code,
    type,
    value,
    minimumOrder,
    maximumDiscount,
    expiryDate,
  ];
}
