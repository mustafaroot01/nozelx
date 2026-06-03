import 'package:flutter/material.dart';
import 'package:auto_lube/core/utils/currency_formatter.dart';
import 'package:auto_lube/models/cart_summary_model.dart';

class CartSummaryWidget extends StatelessWidget {
  final CartSummaryModel summary;
  const CartSummaryWidget({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          _row('المجموع الفرعي', CurrencyFormatter.format(summary.subtotal)),
          const SizedBox(height: 12),
          _row('رسوم التوصيل', CurrencyFormatter.format(summary.deliveryFee)),
          // سطر الخصم — يظهر فقط إذا كوبون مطبق
          if (summary.couponDiscount > 0) ...[
            const SizedBox(height: 12),
            _row(
              'خصم ${summary.appliedCoupon?.code ?? ""}',
              '- ${CurrencyFormatter.format(summary.couponDiscount)}',
              valueColor: const Color(0xFF1D9E75),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF3F4F6), thickness: 1.5),
          const SizedBox(height: 16),
          // الإجمالي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الإجمالي',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              // الإجمالي يتحدث مع انيميشن
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: summary.total),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                builder: (_, val, __) => Text(
                  CurrencyFormatter.format(val),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7F77DD),
                  ),
                ),
              ),
            ],
          ),
          // توفير إجمالي
          if (summary.couponDiscount > 0) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '🎉 ${CurrencyFormatter.savedText(summary.couponDiscount)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1D9E75),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}
