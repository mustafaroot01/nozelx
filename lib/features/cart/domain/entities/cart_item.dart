import 'package:equatable/equatable.dart';

/// Cart Item Entity - represents an item in the shopping cart
class CartItem extends Equatable {
  final String id;
  final String productId;
  final String name;
  final String brand;
  final String image;
  final double price;
  final double? oldPrice;
  final int quantity;
  final bool isAvailable;
  final int? maxQuantity;

  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.brand,
    required this.image,
    required this.price,
    this.oldPrice,
    required this.quantity,
    this.isAvailable = true,
    this.maxQuantity,
  });

  /// Calculate total price for this item
  double get totalPrice => price * quantity;

  /// Calculate discount percentage if old price exists
  int? get discountPercentage {
    if (oldPrice != null && oldPrice! > price) {
      return ((1 - price / oldPrice!) * 100).round();
    }
    return null;
  }

  /// Check if item has discount
  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  /// Create a copy with modified quantity
  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    String? brand,
    String? image,
    double? price,
    double? oldPrice,
    int? quantity,
    bool? isAvailable,
    int? maxQuantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      image: image ?? this.image,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      quantity: quantity ?? this.quantity,
      isAvailable: isAvailable ?? this.isAvailable,
      maxQuantity: maxQuantity ?? this.maxQuantity,
    );
  }

  /// Convert to map for storage
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

  /// Create from map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
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

  @override
  List<Object?> get props => [
    id,
    productId,
    name,
    brand,
    image,
    price,
    oldPrice,
    quantity,
    isAvailable,
    maxQuantity,
  ];
}
