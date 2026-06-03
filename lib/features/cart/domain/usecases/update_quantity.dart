import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

/// Use case to update item quantity in the cart
class UpdateCartItemQuantityUseCase {
  final CartRepository repository;

  UpdateCartItemQuantityUseCase(this.repository);

  Future<Cart> call(String itemId, int quantity) {
    return repository.updateItemQuantity(itemId, quantity);
  }
}
