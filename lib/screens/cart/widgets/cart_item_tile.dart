import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:provider/provider.dart';
import 'package:auto_lube/core/utils/currency_formatter.dart';
import 'package:auto_lube/models/cart_item_model.dart';
import 'package:auto_lube/providers/cart_provider.dart';
import 'quantity_widget.dart';

class CartItemTile extends StatefulWidget {
  final CartItemModel item;
  final int index; // للـ Staggered animation

  const CartItemTile({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  State<CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<CartItemTile>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + (widget.index * 80)), // Staggered
    );
    _slideAnim = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _showDeleteConfirm(BuildContext context) async {
    HapticFeedback.vibrate();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف المنتج', textDirection: TextDirection.rtl, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا المنتج من السلة؟', textDirection: TextDirection.rtl, style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE24B4A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (ctx, child) => Transform.translate(
        offset: Offset(0, _slideAnim.value),
        child: FadeTransition(opacity: _fadeAnim, child: child),
      ),
      child: Dismissible(
        key: Key('cart_${widget.item.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFE24B4A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, color: Colors.white, size: 28),
              SizedBox(height: 4),
              Text('حذف', style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
        confirmDismiss: (_) async {
          return await _showDeleteConfirm(context);
        },
        onDismissed: (_) {
          context.read<CartProvider>().removeItem(widget.item.id);
        },
        child: _buildTileContent(),
      ),
    );
  }

  Widget _buildTileContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // صورة المنتج مع شارة "نفذت الكمية"
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppNetworkImage(
                  imageUrl: widget.item.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color: const Color(0xFFF3F4F6),
                    width: 80,
                    height: 80,
                    child: const Icon(Icons.image_outlined, color: Color(0xFFD1D5DB)),
                  ),
                  errorWidget: Container(
                    color: const Color(0xFFF3F4F6),
                    width: 80,
                    height: 80,
                    child: const Icon(Icons.broken_image_outlined, color: Color(0xFFD1D5DB)),
                  ),
                ),
              ),
              if (widget.item.isOutOfStock)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'نفذت الكمية',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // التفاصيل
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                if (widget.item.selectedSize != null || widget.item.selectedColor != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      [
                        if (widget.item.selectedSize != null) 'المقاس: ${widget.item.selectedSize}',
                        if (widget.item.selectedColor != null) 'اللون: ${widget.item.selectedColor}',
                      ].join(' | '),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // السعر
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.item.originalPrice != null)
                          Text(
                            CurrencyFormatter.format(widget.item.originalPrice!),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          CurrencyFormatter.format(widget.item.price),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D9E75),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // QuantityWidget
                    QuantityWidget(item: widget.item),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
