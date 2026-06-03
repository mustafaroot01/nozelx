import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/utils/currency_formatter.dart';
import 'package:auto_lube/features/cart/presentation/providers/cart_manager.dart';
import 'package:auto_lube/features/cart/presentation/widgets/quantity_stepper.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:auto_lube/core/utils/image_url_helper.dart';

/// Cart Item Card Widget
class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onRemove;
  final VoidCallback onQuantityChange;
  final bool showQuantityControls;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChange,
    this.showQuantityControls = true,
  });

  @override
  Widget build(BuildContext context) {
    final total = item.totalPrice;
    final hasDiscount = item.hasDiscount;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.isAvailable
            ? AppColors.surface
            : AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with Discount Badge
          _buildImage(hasDiscount),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand & Remove Button
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.brand,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: item.isAvailable
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Product Name
                Text(
                  item.name,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: item.isAvailable
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Unavailable Warning
                if (!item.isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'غير متوفر حالياً',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),

                // Price Section
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasDiscount)
                          Text(
                            CurrencyFormatter.formatIQD((item.oldPrice ?? 0)),
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.formatIQD(item.price),
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: item.isAvailable
                                    ? AppColors.secondary
                                    : AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'د.ع',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: item.isAvailable
                                    ? AppColors.secondary
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Quantity Controls
                    if (showQuantityControls && item.isAvailable)
                      QuantityStepper(
                        quantity: item.quantity,
                        onIncrement: onQuantityChange,
                        onDecrement: onQuantityChange,
                        maxQuantity: item.maxQuantity,
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Item Total
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'الإجمالي: ',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatIQD(total),
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(bool hasDiscount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Product Image
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: AppNetworkImage(
            imageUrl: ImageUrlHelper.productThumb(item.image),
            width: 88,
            height: 88,
            borderRadius: 11,
            fit: BoxFit.cover,
          ),
        ),

        // Discount Badge
        if (hasDiscount)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '-${item.discountPercentage}%',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Compact Cart Item Card - for recommendations
class CompactCartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onRemove;

  const CompactCartItemCard({
    super.key,
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Image
          AppNetworkImage(
            imageUrl: ImageUrlHelper.productThumb(item.image),
            width: 60,
            height: 60,
            borderRadius: 8,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 10),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      CurrencyFormatter.formatIQD(item.price),
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '×${item.quantity}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Remove Button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.close, size: 14, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
