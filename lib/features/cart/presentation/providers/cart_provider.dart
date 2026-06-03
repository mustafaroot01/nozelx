import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/get_cart.dart';
import '../../domain/usecases/add_to_cart.dart';
import '../../domain/usecases/remove_from_cart.dart';
import '../../domain/usecases/update_quantity.dart';
import '../../domain/usecases/clear_cart.dart';
import '../../domain/usecases/apply_coupon.dart';
import '../../data/repositories/cart_repository_impl.dart';

/// Cart State
class CartState {
  final Cart cart;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const CartState({
    this.cart = const Cart(),
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  CartState copyWith({
    Cart? cart,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Cart Provider using Riverpod
class CartProvider extends StateNotifier<CartState> {
  final GetCartUseCase _getCartUseCase;
  final AddToCartUseCase _addToCartUseCase;
  final RemoveFromCartUseCase _removeFromCartUseCase;
  final UpdateCartItemQuantityUseCase _updateQuantityUseCase;
  final ClearCartUseCase _clearCartUseCase;
  final ApplyCouponUseCase _applyCouponUseCase;

  CartProvider({
    required GetCartUseCase getCartUseCase,
    required AddToCartUseCase addToCartUseCase,
    required RemoveFromCartUseCase removeFromCartUseCase,
    required UpdateCartItemQuantityUseCase updateQuantityUseCase,
    required ClearCartUseCase clearCartUseCase,
    required ApplyCouponUseCase applyCouponUseCase,
  }) : _getCartUseCase = getCartUseCase,
       _addToCartUseCase = addToCartUseCase,
       _removeFromCartUseCase = removeFromCartUseCase,
       _updateQuantityUseCase = updateQuantityUseCase,
       _clearCartUseCase = clearCartUseCase,
       _applyCouponUseCase = applyCouponUseCase,
       super(const CartState());

  /// Initialize cart
  Future<void> initCart() async {
    state = state.copyWith(isLoading: true);
    try {
      final cart = await _getCartUseCase();
      state = state.copyWith(cart: cart, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
    state = state.copyWith(isLoading: true);
    try {
      final cartItem = CartItem(
        id: const Uuid().v4(),
        productId: productId,
        name: name,
        brand: brand,
        image: image,
        price: price,
        oldPrice: oldPrice,
        quantity: quantity,
        maxQuantity: maxQuantity,
      );
      final cart = await _addToCartUseCase(cartItem);
      state = state.copyWith(
        cart: cart,
        isLoading: false,
        successMessage: 'تم إضافة المنتج للسلة',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Remove item from cart
  Future<void> removeItem(String itemId) async {
    state = state.copyWith(isLoading: true);
    try {
      final cart = await _removeFromCartUseCase(itemId);
      state = state.copyWith(
        cart: cart,
        isLoading: false,
        successMessage: 'تم إزالة المنتج من السلة',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity < 1) return;

    state = state.copyWith(isLoading: true);
    try {
      final cart = await _updateQuantityUseCase(itemId, quantity);
      state = state.copyWith(cart: cart, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Increment item quantity
  Future<void> incrementQuantity(String itemId) async {
    state = state.copyWith(isLoading: true);
    try {
      final item = state.cart.items.firstWhere((item) => item.id == itemId);
      if (item.maxQuantity != null && item.quantity >= item.maxQuantity!) {
        state = state.copyWith(
          isLoading: false,
          error: 'الكمية المتاحة محدودة',
        );
        return;
      }
      final cart = await _updateQuantityUseCase(itemId, item.quantity + 1);
      state = state.copyWith(cart: cart, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Decrement item quantity
  Future<void> decrementQuantity(String itemId) async {
    state = state.copyWith(isLoading: true);
    try {
      final item = state.cart.items.firstWhere((item) => item.id == itemId);
      if (item.quantity > 1) {
        final cart = await _updateQuantityUseCase(itemId, item.quantity - 1);
        state = state.copyWith(cart: cart, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Clear all items from cart
  Future<void> clearCart() async {
    state = state.copyWith(isLoading: true);
    try {
      final cart = await _clearCartUseCase();
      state = state.copyWith(
        cart: cart,
        isLoading: false,
        successMessage: 'تم تفريغ السلة',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Apply coupon code
  Future<void> applyCoupon(String couponCode) async {
    state = state.copyWith(isLoading: true);
    try {
      final cart = await _applyCouponUseCase(couponCode);
      state = state.copyWith(
        cart: cart,
        isLoading: false,
        successMessage: 'تم تطبيق الخصم بنجاح',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Remove applied coupon
  Future<void> removeCoupon() async {
    state = state.copyWith(isLoading: true);
    try {
      final cart = await _applyCouponUseCase('');
      state = state.copyWith(
        cart: cart,
        isLoading: false,
        successMessage: 'تم إزالة الخصم',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear success message
  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }
}

/// Cart provider instance - created with repository passed from main.dart
final cartProvider = StateNotifierProvider<CartProvider, CartState>((ref) {
  throw UnsupportedError(
    'CartProvider not initialized. Call initializeCartProvider first.',
  );
});

/// Initialize cart provider with repository
Future<StateNotifierProvider<CartProvider, CartState>> initializeCartProvider(
  CartRepositoryImpl repository,
) async {
  return StateNotifierProvider<CartProvider, CartState>((ref) {
    return CartProvider(
      getCartUseCase: GetCartUseCase(repository),
      addToCartUseCase: AddToCartUseCase(repository),
      removeFromCartUseCase: RemoveFromCartUseCase(repository),
      updateQuantityUseCase: UpdateCartItemQuantityUseCase(repository),
      clearCartUseCase: ClearCartUseCase(repository),
      applyCouponUseCase: ApplyCouponUseCase(repository),
    );
  });
}

/// Total items provider
final cartTotalItemsProvider = Provider<int>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.cart.totalItems;
});

/// Cart total provider
final cartTotalProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.cart.total;
});

/// Cart subtotal provider
final cartSubtotalProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.cart.subtotal;
});

/// Cart item count provider
final cartItemCountProvider = Provider<int>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.cart.items.length;
});
