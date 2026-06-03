import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/core/utils/currency_formatter.dart';
import 'package:auto_lube/models/cart_item_model.dart';
import 'package:auto_lube/providers/cart_provider.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:auto_lube/core/utils/image_url_helper.dart';
import 'package:auto_lube/core/widgets/shimmer_widget.dart';
import 'package:auto_lube/core/theme/colors.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<CartProvider>(
        builder: (ctx, cart, _) {
          if (cart.isLoading) return const _CartLoadingSkeleton();
          if (cart.isEmpty) return const _EmptyCartView();

          return Column(
            children: [
              _QuickSummaryBar(cart: cart),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, i) => _CartItemCard(
                    key: ValueKey(cart.items[i].id),
                    item: cart.items[i],
                    index: i,
                  ),
                ),
              ),
              _CartBottomSheet(cart: cart),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
      ),
      elevation: 0,
      centerTitle: true,
      title: Consumer<CartProvider>(
        builder: (_, cart, __) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'السلة',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textOnPrimary,
              ),
            ),
            if (!cart.isEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${cart.itemsCount}',
                  style: GoogleFonts.cairo(
                    color: AppColors.textOnPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        Consumer<CartProvider>(
          builder: (_, cart, __) => cart.isEmpty
              ? const SizedBox.shrink()
              : TextButton(
                  onPressed: () => _showClearConfirm(context),
                  child: Text(
                    'مسح الكل',
                    style: GoogleFonts.cairo(
                      color: AppColors.textOnPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
      ],
      iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
    );
  }

  void _showClearConfirm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ClearCartSheet(
        onConfirm: () => context.read<CartProvider>().clearCart(),
      ),
    );
  }
}

class _QuickSummaryBar extends StatelessWidget {
  final CartProvider cart;
  const _QuickSummaryBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${cart.itemsCount} ${cart.itemsCount == 1 ? "منتج" : "منتجات"}',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: cart.subtotal),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (_, val, __) => Text(
              CurrencyFormatter.format(val),
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatefulWidget {
  final CartItemModel item;
  final int index;
  const _CartItemCard({super.key, required this.item, required this.index});

  @override
  State<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<_CartItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterController;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250 + (widget.index * 60)),
    );
    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic),
    );
    _fadeAnim = CurvedAnimation(parent: _enterController, curve: Curves.easeIn);
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _enterController,
      builder: (ctx, child) => Transform.translate(
        offset: Offset(0, _slideAnim.value),
        child: FadeTransition(opacity: _fadeAnim, child: child),
      ),
      child: Dismissible(
        key: widget.key!,
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          HapticFeedback.mediumImpact();
          return true;
        },
        onDismissed: (_) {
          final cart = context.read<CartProvider>();
          final item = widget.item;
          cart.removeItem(item.id);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف "${item.name}"'),
              backgroundColor: AppColors.textPrimary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              action: SnackBarAction(
                label: 'تراجع',
                textColor: AppColors.primarySoft,
                onPressed: () => cart.undoRemove(item),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        },
        background: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
              SizedBox(height: 4),
              Text('حذف', style: TextStyle(color: Colors.white, fontSize: 11)),
            ],
          ),
        ),
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppNetworkImage(
                imageUrl: ImageUrlHelper.productCard(widget.item.imageUrl),
                width: 85,
                height: 85,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  if (widget.item.selectedSize != null ||
                      widget.item.selectedColor != null) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        if (widget.item.selectedSize != null)
                          _OptionChip(
                            label: widget.item.selectedSize!,
                            icon: Icons.straighten_rounded,
                          ),
                        if (widget.item.selectedColor != null)
                          _OptionChip(
                            label: widget.item.selectedColor!,
                            icon: Icons.circle,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.item.originalPrice != null)
                            Text(
                              CurrencyFormatter.format(
                                  widget.item.originalPrice!),
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: AppColors.textHint,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            CurrencyFormatter.format(widget.item.price),
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _QuantityControls(item: widget.item),
                    ],
                  ),
                  if (widget.item.isMaxQuantity) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 13,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'أقصى كمية متاحة: ${widget.item.stockQuantity}',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _OptionChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryGhost,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 11, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _QuantityControls extends StatefulWidget {
  final CartItemModel item;
  const _QuantityControls({required this.item});

  @override
  State<_QuantityControls> createState() => _QuantityControlsState();
}

class _QuantityControlsState extends State<_QuantityControls>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _scaleAnim;

  void _bounce() {
    _bounceCtrl
        .forward()
        .then((_) => _bounceCtrl.reverse());
  }

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: widget.item.quantity == 1
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            color: widget.item.quantity == 1
                ? AppColors.error
                : AppColors.primarySoft,
            onTap: () {
              HapticFeedback.lightImpact();
              _bounce();
              final cart = context.read<CartProvider>();
              if (widget.item.quantity == 1) {
                cart.removeItem(widget.item.id);
              } else {
                cart.updateQuantity(
                  widget.item.productId,
                  widget.item.quantity - 1,
                );
              }
            },
          ),
          ScaleTransition(
            scale: _scaleAnim,
            child: SizedBox(
              width: 36,
              child: Text(
                '${widget.item.quantity}',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          _QtyButton(
            icon: Icons.add_rounded,
            color: widget.item.isMaxQuantity
                ? AppColors.border
                : AppColors.primary,
            onTap: widget.item.isMaxQuantity
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    _bounce();
                    context.read<CartProvider>().updateQuantity(
                          widget.item.productId,
                          widget.item.quantity + 1,
                        );
                  },
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _QtyButton({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _CartBottomSheet extends StatelessWidget {
  final CartProvider cart;
  const _CartBottomSheet({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20, 16, 20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (cart.couponDiscount > 0)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryGhost,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.primaryPale),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.savings_outlined,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'وفّرت ${CurrencyFormatter.format(cart.couponDiscount)}',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const _InlineCouponField(),
          const SizedBox(height: 14),
          _AmountRow(
            label: 'المجموع الفرعي',
            value: CurrencyFormatter.format(cart.subtotal),
          ),
          const SizedBox(height: 6),
          _AmountRow(
            label: 'رسوم التوصيل',
            value: CurrencyFormatter.format(cart.deliveryFee),
          ),
          if (cart.couponDiscount > 0) ...[
            const SizedBox(height: 6),
            _AmountRow(
              label: 'كود الخصم ${cart.appliedCoupon?.code ?? ""}',
              value: '- ${CurrencyFormatter.format(cart.couponDiscount)}',
              valueColor: AppColors.primary,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الإجمالي',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: cart.total),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    builder: (_, val, __) => Text(
                      CurrencyFormatter.format(val),
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(
                        context, '/checkout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_bag_outlined,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'إتمام الطلب',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _AmountRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.cairo(
                fontSize: 13, color: AppColors.textSecondary)),
        Text(value,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            )),
      ],
    );
  }
}

class _InlineCouponField extends StatefulWidget {
  const _InlineCouponField();

  @override
  State<_InlineCouponField> createState() => _InlineCouponFieldState();
}

class _InlineCouponFieldState extends State<_InlineCouponField>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _shake() {
    _shakeCtrl.forward().then((_) => _shakeCtrl.reset());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (ctx, cart, _) {
        if (cart.appliedCoupon != null) {
          return _buildAppliedState(cart);
        }
        return _buildInputState(cart);
      },
    );
  }

  Widget _buildAppliedState(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryGhost,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primaryPale),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${cart.appliedCoupon!.code} — ${cart.appliedCoupon!.displayText}',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              cart.removeCoupon();
              _ctrl.clear();
            },
            child: const Icon(Icons.close_rounded,
                size: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildInputState(CartProvider cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _shakeAnim,
          builder: (_, child) =>
              Transform.translate(
                offset: Offset(_shakeAnim.value, 0),
                child: child,
              ),
          child: TextField(
            controller: _ctrl,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'كود الخصم (اختياري)',
              hintStyle: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.textHint,
                fontWeight: FontWeight.normal,
                letterSpacing: 0,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: cart.couponError != null
                      ? AppColors.error
                      : AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5),
              ),
              suffixIcon: cart.isValidatingCoupon
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: _ctrl.text.trim().isEmpty
                          ? null
                          : () async {
                              await cart.applyCoupon(_ctrl.text);
                              if (cart.couponError != null) _shake();
                            },
                      child: Text(
                        'تطبيق',
                        style: GoogleFonts.cairo(
                          color: _ctrl.text.trim().isEmpty
                              ? AppColors.border
                              : AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: cart.couponError != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 6, right: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 13, color: AppColors.error),
                      const SizedBox(width: 5),
                      Text(
                        cart.couponError!,
                        style: GoogleFonts.cairo(
                            fontSize: 12, color: AppColors.error),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ClearCartSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  const _ClearCartSheet({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: AppColors.errorLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_sweep_rounded,
              color: AppColors.error,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'مسح السلة بالكامل؟',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'هل أنت متأكد من رغبتك في حذف جميع المنتجات من السلة؟',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.cairo(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'مسح الكل',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyCartView extends StatefulWidget {
  const _EmptyCartView();

  @override
  State<_EmptyCartView> createState() => _EmptyCartViewState();
}

class _EmptyCartViewState extends State<_EmptyCartView>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGhost,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    size: 48,
                    color: AppColors.primarySoft,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'سلتك فارغة',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'أضف منتجات من المتجر\nوستظهر هنا',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 180,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'تصفح المنتجات',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartLoadingSkeleton extends StatelessWidget {
  const _CartLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const ShimmerBox(width: double.infinity, height: 40, borderRadius: 8),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const ShimmerBox(width: 85, height: 85, borderRadius: 12),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(
                              width: double.infinity,
                              height: 14,
                              borderRadius: 6),
                          SizedBox(height: 8),
                          ShimmerBox(width: 120, height: 12, borderRadius: 6),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              ShimmerBox(
                                  width: 80, height: 18, borderRadius: 6),
                              ShimmerBox(
                                  width: 90, height: 36, borderRadius: 12),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
