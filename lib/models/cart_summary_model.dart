import 'coupon_model.dart';

class CartSummaryModel {
  final double subtotal;
  final double deliveryFee;
  final double couponDiscount;
  final double tax;
  final double total;
  final int itemsCount;
  final CouponModel? appliedCoupon;

  CartSummaryModel({
    required this.subtotal,
    required this.deliveryFee,
    required this.couponDiscount,
    required this.tax,
    required this.total,
    required this.itemsCount,
    this.appliedCoupon,
  });
}
