import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/core/theme/colors.dart';

/// Quantity Stepper Widget - for incrementing/decrementing quantities
class QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int? maxQuantity;
  final bool enabled;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.maxQuantity,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final canIncrement = maxQuantity == null || quantity < maxQuantity!;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: enabled
            ? AppColors.surfaceVariant
            : AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement Button
          GestureDetector(
            onTap: enabled && quantity > 1 ? onDecrement : null,
            child: Container(
              width: 32,
              height: 36,
              alignment: Alignment.center,
              child: Icon(
                Icons.remove,
                size: 16,
                color: (enabled && quantity > 1)
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
            ),
          ),

          // Quantity Display
          SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Text(
                '$quantity',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: enabled
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
              ),
            ),
          ),

          // Increment Button
          GestureDetector(
            onTap: enabled && canIncrement ? onIncrement : null,
            child: Container(
              width: 32,
              height: 36,
              alignment: Alignment.center,
              child: Icon(
                Icons.add,
                size: 16,
                color: (enabled && canIncrement)
                    ? AppColors.primary
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small Quantity Stepper - compact version for cards
class SmallQuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int? maxQuantity;

  const SmallQuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.maxQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final canIncrement = maxQuantity == null || quantity < maxQuantity!;

    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: quantity > 1 ? onDecrement : null,
            child: Container(
              width: 24,
              height: 28,
              alignment: Alignment.center,
              child: Icon(
                Icons.remove,
                size: 12,
                color: quantity > 1
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
            ),
          ),
          SizedBox(
            width: 24,
            height: 28,
            child: Center(
              child: Text(
                '$quantity',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: canIncrement ? onIncrement : null,
            child: Container(
              width: 24,
              height: 28,
              alignment: Alignment.center,
              child: Icon(
                Icons.add,
                size: 12,
                color: canIncrement
                    ? AppColors.primary
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
