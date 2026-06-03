import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

/// Use case to clear all items from the cart
class ClearCartUseCase {
  final CartRepository repository;

  ClearCartUseCase(this.repository);

  Future<Cart> call() {
    return repository.clearCart();
  }
}
