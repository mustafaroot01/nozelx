import '../entities/cart.dart';
import '../entities/cart_item.dart';

/// Repository interface for cart operations
/// Follows the Repository Pattern from Clean Architecture
abstract class CartRepository {
  /// Get the current cart
  Future<Cart> getCart();

  /// Add an item to the cart
  /// Returns the updated cart
  Future<Cart> addToCart(CartItem item);

  /// Remove an item from the cart by item ID
  /// Returns the updated cart
  Future<Cart> removeFromCart(String itemId);

  /// Update the quantity of an item in the cart
  /// Returns the updated cart
  Future<Cart> updateItemQuantity(String itemId, int quantity);

  /// Increment quantity of an item
  Future<Cart> incrementQuantity(String itemId);

  /// Decrement quantity of an item (minimum 1)
  Future<Cart> decrementQuantity(String itemId);

  /// Clear all items from the cart
  /// Returns an empty cart
  Future<Cart> clearCart();

  /// Apply a coupon code to the cart
  Future<Cart> applyCoupon(String couponCode);

  /// Remove the applied coupon
  Future<Cart> removeCoupon();

  /// Check if an item is already in the cart
  Future<bool> isInCart(String productId);

  /// Get the quantity of a specific product in the cart
  Future<int> getItemQuantity(String productId);

  /// Save cart to local storage
  Future<void> saveCart(Cart cart);

  /// Load cart from local storage
  Future<Cart> loadCart();
}
