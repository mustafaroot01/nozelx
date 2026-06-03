import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/theme/dimensions.dart';
import 'package:auto_lube/core/utils/currency_formatter.dart';
import 'package:auto_lube/features/cart/domain/entities/cart.dart';

/// Cart Summary Widget - shows order totals and checkout button
class CartSummary extends StatelessWidget {
  final Cart cart;
  final VoidCallback onCheckout;
  final bool isLoading;

  const CartSummary({
    super.key,
    required this.cart,
    required this.onCheckout,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('المجموع الفرعي', cart.subtotal),
                  const SizedBox(height: 8),

                  if (cart.itemDiscount > 0) ...[
                    _buildSummaryRow(
                      'خصم المنتجات',
                      -cart.itemDiscount,
                      isDiscount: true,
                    ),
                    const SizedBox(height: 8),
                  ],

                  if (cart.appliedCoupon != null) ...[
                    _buildSummaryRow(
                      'كود الخصم (${cart.appliedCoupon!.code})',
                      -cart.couponDiscount,
                      isDiscount: true,
                      showRemove: true,
                    ),
                    const SizedBox(height: 8),
                  ],

                  _buildSummaryRow(
                    'رسوم التوصيل',
                    cart.deliveryFee,
                    isHighlighted: cart.deliveryFee == 0,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Total Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الإجمالي',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.formatIQD(cart.total),
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Checkout Button
                SizedBox(
                  width: 180,
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.buttonBorderRadius,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.shopping_bag,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'إتمام الشراء',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double value, {
    bool isDiscount = false,
    bool isHighlighted = false,
    bool showRemove = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isHighlighted)
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'مجاناً',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: isHighlighted
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDiscount)
              const Icon(Icons.remove, size: 16, color: AppColors.error),
            Text(
              isDiscount
                  ? '-${CurrencyFormatter.formatIQD(value)}'
                  : CurrencyFormatter.formatIQD(value),
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDiscount
                    ? AppColors.error
                    : (isHighlighted
                          ? AppColors.success
                          : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Compact Cart Summary - for bottom sheets
class CompactCartSummary extends StatelessWidget {
  final Cart cart;
  final VoidCallback onCheckout;

  const CompactCartSummary({
    super.key,
    required this.cart,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtotal
          _buildRow('المجموع الفرعي', cart.subtotal),
          const SizedBox(height: 8),

          // Delivery
          _buildRow('التوصيل', cart.deliveryFee),
          const SizedBox(height: 12),

          // Divider
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Text(
                    CurrencyFormatter.formatIQD(cart.total),
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'إتمام الشراء',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          CurrencyFormatter.formatIQD(value),
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
