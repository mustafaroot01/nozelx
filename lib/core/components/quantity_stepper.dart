import 'package:flutter/material.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

/// Quantity stepper with animated +/- buttons
class QuantityStepper extends StatefulWidget {
  final int initialQuantity;
  final int minQuantity;
  final int maxQuantity;
  final ValueChanged<int> onQuantityChanged;
  final bool enabled;

  const QuantityStepper({
    super.key,
    this.initialQuantity = 1,
    this.minQuantity = 1,
    this.maxQuantity = 99,
    required this.onQuantityChanged,
    this.enabled = true,
  });

  @override
  State<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<QuantityStepper> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  void _decrement() {
    if (_quantity > widget.minQuantity && widget.enabled) {
      HapticFeedback.lightImpact();
      setState(() {
        _quantity--;
      });
      widget.onQuantityChanged(_quantity);
    } else if (_quantity == widget.minQuantity) {
      HapticFeedback.vibrate();
    }
  }

  void _increment() {
    if (_quantity < widget.maxQuantity && widget.enabled) {
      HapticFeedback.lightImpact();
      setState(() {
        _quantity++;
      });
      widget.onQuantityChanged(_quantity);
    } else if (_quantity == widget.maxQuantity) {
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: widget.enabled ? AppColors.surfaceVariant : Colors.grey[200],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.enabled ? AppColors.border : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus button
          GestureDetector(
            onTap: _decrement,
            child: Container(
              width: 44,
              height: double.infinity,
              decoration: BoxDecoration(
                color: _quantity <= widget.minQuantity
                    ? Colors.transparent
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
              ),
              child: Icon(
                Icons.remove,
                size: 20,
                color: _quantity <= widget.minQuantity
                    ? AppColors.textTertiary
                    : AppColors.primary,
              ),
            ),
          ),

          // Quantity display
          SizedBox(
            width: 50,
            child: Text(
              '$_quantity',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.enabled
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
            ),
          ),

          // Plus button
          GestureDetector(
            onTap: _increment,
            child: Container(
              width: 44,
              height: double.infinity,
              decoration: BoxDecoration(
                color: _quantity >= widget.maxQuantity
                    ? Colors.transparent
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(14),
                ),
              ),
              child: Icon(
                Icons.add,
                size: 20,
                color: _quantity >= widget.maxQuantity
                    ? AppColors.textTertiary
                    : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Large quantity stepper for cart screen
class CartQuantityStepper extends StatelessWidget {
  final int quantity;
  final Function(int) onQuantityChanged;
  final bool enabled;

  const CartQuantityStepper({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return QuantityStepper(
      initialQuantity: quantity,
      minQuantity: 1,
      maxQuantity: 99,
      onQuantityChanged: onQuantityChanged,
      enabled: enabled,
    );
  }
}

/// Small compact quantity stepper
class CompactQuantityStepper extends StatefulWidget {
  final int initialQuantity;
  final Function(int) onQuantityChanged;

  const CompactQuantityStepper({
    super.key,
    required this.initialQuantity,
    required this.onQuantityChanged,
  });

  @override
  State<CompactQuantityStepper> createState() => _CompactQuantityStepperState();
}

class _CompactQuantityStepperState extends State<CompactQuantityStepper> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus
          GestureDetector(
            onTap: () {
              if (_quantity > 1) {
                HapticFeedback.lightImpact();
                setState(() {
                  _quantity--;
                });
                widget.onQuantityChanged(_quantity);
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.remove, size: 14, color: AppColors.textPrimary),
            ),
          ),

          // Quantity
          SizedBox(
            width: 24,
            child: Text(
              '$_quantity',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Plus
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _quantity++;
              });
              widget.onQuantityChanged(_quantity);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.add, size: 14, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
