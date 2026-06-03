import 'package:uuid/uuid.dart';
import '../local/cart_local_data_source.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

/// Implementation of CartRepository
/// Uses local data source for persistence
class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl(this.localDataSource);

  @override
  Future<Cart> getCart() async {
    return localDataSource.loadCart();
  }

  @override
  Future<Cart> addToCart(CartItem item) async {
    final cart = await localDataSource.loadCart();

    // Check if item already exists
    final existingIndex = cart.items.indexWhere(
      (cartItem) => cartItem.productId == item.productId,
    );

    final now = DateTime.now();
    List<CartItem> updatedItems;

    if (existingIndex >= 0) {
      // Update existing item quantity
      updatedItems = List<CartItem>.from(cart.items);
      final existingItem = updatedItems[existingIndex];
      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + item.quantity,
        price: item.price, // Update price in case it changed
        oldPrice: item.oldPrice,
      );
    } else {
      // Add new item with unique ID
      final newItem = item.copyWith(id: const Uuid().v4());
      updatedItems = [...cart.items, newItem];
    }

    final updatedCart = cart.copyWith(items: updatedItems, updatedAt: now);

    await localDataSource.saveCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<Cart> removeFromCart(String itemId) async {
    final cart = await localDataSource.loadCart();
    final updatedItems = cart.items.where((item) => item.id != itemId).toList();

    final updatedCart = cart.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    await localDataSource.saveCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<Cart> updateItemQuantity(String itemId, int quantity) async {
    final cart = await localDataSource.loadCart();

    final updatedItems = cart.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    final updatedCart = cart.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    await localDataSource.saveCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<Cart> incrementQuantity(String itemId) async {
    final cart = await localDataSource.loadCart();

    final updatedItems = cart.items.map((item) {
      if (item.id == itemId) {
        final newQuantity = item.quantity + 1;
        // Check max quantity if set
        if (item.maxQuantity != null && newQuantity > item.maxQuantity!) {
          return item;
        }
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    final updatedCart = cart.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    await localDataSource.saveCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<Cart> decrementQuantity(String itemId) async {
    final cart = await localDataSource.loadCart();

    final updatedItems = cart.items.map((item) {
      if (item.id == itemId && item.quantity > 1) {
        return item.copyWith(quantity: item.quantity - 1);
      }
      return item;
    }).toList();

    final updatedCart = cart.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    await localDataSource.saveCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<Cart> clearCart() async {
    final emptyCart = const Cart();
    await localDataSource.saveCart(emptyCart);
    return emptyCart;
  }

  @override
  Future<Cart> applyCoupon(String couponCode) async {
    final cart = await localDataSource.loadCart();

    // Validate coupon
    final coupon = await localDataSource.validateCoupon(couponCode);
    if (coupon == null) {
      throw Exception('كود الخصم غير صالح أو منتهي');
    }

    // Check minimum order requirement
    if (coupon.minimumOrder != null && cart.subtotal < coupon.minimumOrder!) {
      throw Exception(
        'الحد الأدنى للطلب هو ${coupon.minimumOrder!.round()} د.ع',
      );
    }

    final couponEntity = coupon.toEntity();
    final updatedCart = cart.copyWith(
      appliedCoupon: couponEntity,
      updatedAt: DateTime.now(),
    );

    await localDataSource.saveCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<Cart> removeCoupon() async {
    final cart = await localDataSource.loadCart();
    final updatedCart = cart.copyWith(
      appliedCoupon: null,
      updatedAt: DateTime.now(),
    );

    await localDataSource.saveCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<bool> isInCart(String productId) async {
    final cart = await localDataSource.loadCart();
    return cart.items.any((item) => item.productId == productId);
  }

  @override
  Future<int> getItemQuantity(String productId) async {
    final cart = await localDataSource.loadCart();
    try {
      return cart.items
          .firstWhere((item) => item.productId == productId)
          .quantity;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<void> saveCart(Cart cart) async {
    await localDataSource.saveCart(cart);
  }

  @override
  Future<Cart> loadCart() async {
    return localDataSource.loadCart();
  }
}
