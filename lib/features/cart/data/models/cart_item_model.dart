import '../../domain/entities/cart_item.dart';

/// Data model for CartItem
class CartItemModel {
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

  const CartItemModel({
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

  /// Convert entity to model
  CartItem toEntity() {
    return CartItem(
      id: id,
      productId: productId,
      name: name,
      brand: brand,
      image: image,
      price: price,
      oldPrice: oldPrice,
      quantity: quantity,
      isAvailable: isAvailable,
      maxQuantity: maxQuantity,
    );
  }

  /// Convert model to entity
  factory CartItemModel.fromEntity(CartItem entity) {
    return CartItemModel(
      id: entity.id,
      productId: entity.productId,
      name: entity.name,
      brand: entity.brand,
      image: entity.image,
      price: entity.price,
      oldPrice: entity.oldPrice,
      quantity: entity.quantity,
      isAvailable: entity.isAvailable,
      maxQuantity: entity.maxQuantity,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
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

  /// Create from JSON map
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      image: json['image'] as String,
      price: (json['price'] as num).toDouble(),
      oldPrice: json['oldPrice'] != null
          ? (json['oldPrice'] as num).toDouble()
          : null,
      quantity: json['quantity'] as int,
      isAvailable: json['isAvailable'] as bool? ?? true,
      maxQuantity: json['maxQuantity'] as int?,
    );
  }

  /// Convert list of models to list of entities
  static List<CartItem> toEntityList(List<CartItemModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }

  /// Convert list of entities to list of models
  static List<CartItemModel> fromEntityList(List<CartItem> entities) {
    return entities.map((entity) => CartItemModel.fromEntity(entity)).toList();
  }
}
