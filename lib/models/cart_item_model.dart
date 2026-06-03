class CartItemModel {
  final int id;                    // cart item id من السيرفر
  final int productId;
  final String name;
  final String imageUrl;
  final double price;              // بالدينار العراقي
  final double? originalPrice;     // السعر قبل الخصم إن وجد
  int quantity;
  final String? selectedSize;
  final String? selectedColor;
  final int stockQuantity;         // الكمية المتاحة في المخزون
  final bool isAvailable;          // من السيرفر مباشرة

  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
    required this.stockQuantity,
    required this.isAvailable,
  });

  double get subtotal => price * quantity;
  bool get isOutOfStock => stockQuantity <= 0 || !isAvailable;
  bool get isMaxQuantity => quantity >= stockQuantity;

  CartItemModel copyWith({
    int? id,
    int? productId,
    String? name,
    String? imageUrl,
    double? price,
    double? originalPrice,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
    int? stockQuantity,
    bool? isAvailable,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // Check if the response contains nested product data from backend
    final productJson = json['product'] as Map<String, dynamic>?;
    final options = json['options'] as Map<String, dynamic>? ?? {};

    if (productJson != null) {
      final double price = productJson['sale_price'] != null
          ? (productJson['sale_price'] as num).toDouble()
          : (productJson['price'] as num).toDouble();
      final double? originalPrice = productJson['sale_price'] != null
          ? (productJson['price'] as num).toDouble()
          : null;

      return CartItemModel(
        id: json['id'] as int,
        productId: json['product_id'] as int,
        name: productJson['name'] as String? ?? '',
        imageUrl: productJson['image_url'] as String? ?? '',
        price: price,
        originalPrice: originalPrice,
        quantity: json['quantity'] as int? ?? 1,
        selectedSize: options['size'] as String?,
        selectedColor: options['color'] as String?,
        stockQuantity: productJson['stock_quantity'] as int? ?? productJson['stock'] as int? ?? 0,
        isAvailable: productJson['is_available'] as bool? ?? true,
      );
    } else {
      return CartItemModel(
        id: json['id'] as int,
        productId: json['product_id'] as int,
        name: json['name'] as String? ?? '',
        imageUrl: json['image_url'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        originalPrice: json['original_price'] != null
            ? (json['original_price'] as num).toDouble()
            : null,
        quantity: json['quantity'] as int? ?? 1,
        selectedSize: json['selected_size'] as String?,
        selectedColor: json['selected_color'] as String?,
        stockQuantity: json['stock_quantity'] as int? ?? 0,
        isAvailable: json['is_available'] as bool? ?? true,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'image_url': imageUrl,
      'price': price,
      'original_price': originalPrice,
      'quantity': quantity,
      'selected_size': selectedSize,
      'selected_color': selectedColor,
      'stock_quantity': stockQuantity,
      'is_available': isAvailable,
    };
  }
}
