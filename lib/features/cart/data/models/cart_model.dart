import '../../domain/entities/cart.dart';
import 'cart_item_model.dart';

/// Data model for Cart
class CartModel {
  final String id;
  final List<CartItemModel> items;
  final CouponModel? appliedCoupon;
  final String? createdAt;
  final String? updatedAt;

  const CartModel({
    this.id = '',
    this.items = const [],
    this.appliedCoupon,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert entity to model
  Cart toEntity() {
    return Cart(
      id: id,
      items: CartItemModel.toEntityList(items),
      appliedCoupon: appliedCoupon?.toEntity(),
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }

  /// Convert model to entity
  factory CartModel.fromEntity(Cart entity) {
    return CartModel(
      id: entity.id,
      items: CartItemModel.fromEntityList(entity.items),
      appliedCoupon: entity.appliedCoupon != null
          ? CouponModel.fromEntity(entity.appliedCoupon!)
          : null,
      createdAt: entity.createdAt?.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'appliedCoupon': appliedCoupon?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Create from JSON map
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] as String? ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (item) => CartItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      appliedCoupon: json['appliedCoupon'] != null
          ? CouponModel.fromJson(json['appliedCoupon'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

/// Data model for Coupon
class CouponModel {
  final String code;
  final String type;
  final double value;
  final double? minimumOrder;
  final double? maximumDiscount;
  final String? expiryDate;

  const CouponModel({
    required this.code,
    required this.type,
    required this.value,
    this.minimumOrder,
    this.maximumDiscount,
    this.expiryDate,
  });

  /// Convert entity to model
  Coupon toEntity() {
    return Coupon(
      code: code,
      type: type,
      value: value,
      minimumOrder: minimumOrder,
      maximumDiscount: maximumDiscount,
      expiryDate: expiryDate != null ? DateTime.parse(expiryDate!) : null,
    );
  }

  /// Convert model to entity
  factory CouponModel.fromEntity(Coupon entity) {
    return CouponModel(
      code: entity.code,
      type: entity.type,
      value: entity.value,
      minimumOrder: entity.minimumOrder,
      maximumDiscount: entity.maximumDiscount,
      expiryDate: entity.expiryDate?.toIso8601String(),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'type': type,
      'value': value,
      'minimumOrder': minimumOrder,
      'maximumDiscount': maximumDiscount,
      'expiryDate': expiryDate,
    };
  }

  /// Create from JSON map
  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      code: json['code'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      minimumOrder: json['minimumOrder'] != null
          ? (json['minimumOrder'] as num).toDouble()
          : null,
      maximumDiscount: json['maximumDiscount'] != null
          ? (json['maximumDiscount'] as num).toDouble()
          : null,
      expiryDate: json['expiryDate'] as String?,
    );
  }
}
