import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

/// Use case to remove an item from the cart
class RemoveFromCartUseCase {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  Future<Cart> call(String itemId) {
    return repository.removeFromCart(itemId);
  }
}
