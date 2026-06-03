import 'package:auto_lube/core/utils/currency_formatter.dart';

class CouponModel {
  final String code;
  final String type;               // "percentage" أو "fixed"
  final double value;              // 10 تعني 10% أو 10,000 د.ع
  final double minOrderAmount;     // الحد الأدنى للطلب بالدينار
  final double? maxDiscountAmount; // سقف الخصم للنسبة المئوية
  final DateTime expiresAt;
  final bool isActive;

  CouponModel({
    required this.code,
    required this.type,
    required this.value,
    required this.minOrderAmount,
    this.maxDiscountAmount,
    required this.expiresAt,
    required this.isActive,
  });

  // حساب مبلغ الخصم الفعلي
  double calculateDiscount(double cartTotal) {
    if (type == 'percentage') {
      final discount = cartTotal * (value / 100);
      return maxDiscountAmount != null
          ? discount.clamp(0, maxDiscountAmount!)
          : discount;
    }
    return value.clamp(0, cartTotal);
  }

  // نص وصفي: "خصم 10%" أو "خصم 10,000 د.ع"
  String get displayText => type == 'percentage'
      ? 'خصم ${value.toInt()}%'
      : 'خصم ${CurrencyFormatter.format(value)}';

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      code: json['code'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      minOrderAmount: (json['min_order_amount'] as num? ?? json['min_order_value'] as num? ?? 0.0).toDouble(),
      maxDiscountAmount: json['max_discount_amount'] != null
          ? (json['max_discount_amount'] as num).toDouble()
          : json['max_discount_value'] != null
              ? (json['max_discount_value'] as num).toDouble()
              : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : json['end_date'] != null
              ? DateTime.parse(json['end_date'] as String)
              : DateTime.now().add(const Duration(days: 30)),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'type': type,
      'value': value,
      'min_order_amount': minOrderAmount,
      'max_discount_amount': maxDiscountAmount,
      'expires_at': expiresAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}
