import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:auto_lube/core/utils/currency_formatter.dart';
import 'package:auto_lube/providers/cart_provider.dart';

class CouponWidget extends StatefulWidget {
  const CouponWidget({super.key});

  @override
  State<CouponWidget> createState() => _CouponWidgetState();
}

class _CouponWidgetState extends State<CouponWidget>
    with SingleTickerProviderStateMixin {

  final _controller = TextEditingController();
  late AnimationController _shakeController;  // انيميشن اهتزاز عند الخطأ
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 375),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // انيميشن اهتزاز الحقل عند الخطأ
  void _shake() {
    _shakeController.forward().then((_) => _shakeController.reset());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (ctx, cart, _) {
        // إذا كوبون مطبق — أظهر بطاقة النجاح
        if (cart.appliedCoupon != null) {
          return _buildAppliedCoupon(cart);
        }
        // حقل الإدخال
        return _buildCouponInput(cart);
      },
    );
  }

  Widget _buildCouponInput(CartProvider cart) {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (ctx, child) => Transform.translate(
        offset: Offset(_shakeAnim.value, 0),
        child: child,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.local_offer_outlined, size: 18, color: Color(0xFF7F77DD)),
                SizedBox(width: 8),
                Text(
                  'كود الخصم',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: Color(0xFF1A1A2E),
                    ),
                    decoration: InputDecoration(
                      hintText: 'أدخل الكود هنا',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.normal,
                        letterSpacing: 0,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: cart.couponError != null
                              ? const Color(0xFFE24B4A)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: cart.couponError != null
                              ? const Color(0xFFE24B4A)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF7F77DD), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: cart.isValidatingCoupon || _controller.text.trim().isEmpty
                        ? null
                        : () async {
                            await cart.applyCoupon(_controller.text);
                            if (cart.couponError != null) _shake();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7F77DD),
                      disabledBackgroundColor: const Color(0xFFD1D5DB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: cart.isValidatingCoupon
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'تطبيق',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
            // رسالة الخطأ بانيميشن
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: cart.couponError != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 14, color: Color(0xFFE24B4A)),
                          const SizedBox(width: 6),
                          Text(
                            cart.couponError!,
                            style: const TextStyle(fontSize: 12, color: Color(0xFFE24B4A)),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // بطاقة الكوبون المطبّق (خضراء)
  Widget _buildAppliedCoupon(CartProvider cart) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1D9E75).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1D9E75).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle_outline, color: Color(0xFF1D9E75), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      cart.appliedCoupon!.code,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D9E75),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D9E75),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cart.appliedCoupon!.displayText,
                        style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.savedText(cart.couponDiscount),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1D9E75)),
                ),
              ],
            ),
          ),
          // زر إزالة الكوبون
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              cart.removeCoupon();
              _controller.clear();
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE24B4A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close, size: 16, color: Color(0xFFE24B4A)),
            ),
          ),
        ],
      ),
    );
  }
}
