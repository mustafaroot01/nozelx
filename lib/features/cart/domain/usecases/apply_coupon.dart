import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

/// Use case to apply a coupon to the cart
class ApplyCouponUseCase {
  final CartRepository repository;

  ApplyCouponUseCase(this.repository);

  Future<Cart> call(String couponCode) {
    return repository.applyCoupon(couponCode);
  }
}
