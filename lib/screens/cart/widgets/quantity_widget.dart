import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:auto_lube/models/cart_item_model.dart';
import 'package:auto_lube/providers/cart_provider.dart';

class QuantityWidget extends StatefulWidget {
  final CartItemModel item;

  const QuantityWidget({super.key, required this.item});

  @override
  State<QuantityWidget> createState() => _QuantityWidgetState();
}

class _QuantityWidgetState extends State<QuantityWidget>
    with SingleTickerProviderStateMixin {

  late AnimationController _numController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _numController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.8,
      upperBound: 1.2,
      value: 1.0,
    );
    _scaleAnim = _numController;
  }

  @override
  void dispose() {
    _numController.dispose();
    super.dispose();
  }

  // عند تغيير الكمية: انيميشن bounce للرقم
  void _animateBounce() {
    _numController.forward().then((_) => _numController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر ناقص
          _QuantityButton(
            icon: widget.item.quantity == 1 ? Icons.delete_outline : Icons.remove,
            color: widget.item.quantity == 1 ? const Color(0xFFE24B4A) : const Color(0xFF6B7280),
            onTap: () {
              HapticFeedback.lightImpact();
              _animateBounce();
              if (widget.item.quantity == 1) {
                context.read<CartProvider>().removeItem(widget.item.id);
              } else {
                context.read<CartProvider>()
                    .updateQuantity(widget.item.productId, widget.item.quantity - 1);
              }
            },
          ),
          // الرقم مع انيميشن
          ScaleTransition(
            scale: _scaleAnim,
            child: SizedBox(
              width: 32,
              child: Text(
                widget.item.quantity.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
          ),
          // زر زائد (معطّل إذا وصل للحد الأقصى)
          _QuantityButton(
            icon: Icons.add,
            color: widget.item.isMaxQuantity
                ? const Color(0xFFD1D5DB)
                : const Color(0xFF7F77DD),
            onTap: widget.item.isMaxQuantity ? null : () {
              HapticFeedback.lightImpact();
              _animateBounce();
              context.read<CartProvider>()
                  .updateQuantity(widget.item.productId, widget.item.quantity + 1);
            },
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _QuantityButton({
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          size: 18,
          color: color,
        ),
      ),
    );
  }
}
