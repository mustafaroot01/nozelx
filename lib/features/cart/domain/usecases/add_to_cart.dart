import '../entities/cart.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

/// Use case to add an item to the cart
class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<Cart> call(CartItem item) {
    return repository.addToCart(item);
  }
}
