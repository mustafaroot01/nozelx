import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

/// Use case to get the current cart
class GetCartUseCase {
  final CartRepository repository;

  GetCartUseCase(this.repository);

  Future<Cart> call() {
    return repository.getCart();
  }
}
