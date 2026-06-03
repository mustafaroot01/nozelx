import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/utils/currency_formatter.dart';

/// Coupon Bottom Sheet - for applying discount codes
class CouponBottomSheet extends StatefulWidget {
  final Function(String couponCode) onApplyCoupon;
  final VoidCallback onClose;

  const CouponBottomSheet({
    super.key,
    required this.onApplyCoupon,
    required this.onClose,
  });

  @override
  State<CouponBottomSheet> createState() => _CouponBottomSheetState();
}

class _CouponBottomSheetState extends State<CouponBottomSheet> {
  final TextEditingController _couponController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorMessage;
  bool _isLoading = false;

  // Available coupons for demo
  final List<Map<String, dynamic>> _availableCoupons = [
    {
      'code': 'WELCOME10',
      'title': 'خصم 10%',
      'description': 'خصم 10% على أول طلب',
      'minOrder': 50000,
    },
    {
      'code': 'SAVE5000',
      'title': 'خصم 5000 د.ع',
      'description': 'خصم فوري بقيمة 5000 دينار',
      'minOrder': 30000,
    },
    {
      'code': 'SUMMER20',
      'title': 'خصم صيفي 20%',
      'description': 'خصم 20% بحد أقصى 25000',
      'minOrder': 100000,
      'expiry': '2025-08-31',
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'كود الخصم',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Coupon Input
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _errorMessage != null
                    ? AppColors.error
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    focusNode: _focusNode,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'أدخل كود الخصم',
                      hintStyle: GoogleFonts.cairo(
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      errorBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() {
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                ),
                GestureDetector(
                  onTap: _applyCoupon,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'تطبيق',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Error Message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 16,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _errorMessage!,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Available Coupons
          Text(
            'أكود خصم متاحة',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Coupons List
          ..._availableCoupons.map((coupon) => _buildCouponTile(coupon)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCouponTile(Map<String, dynamic> coupon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.discount,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      coupon['title'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (coupon['expiry'] != null)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ينتهي ${coupon['expiry']}',
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  coupon['description'] as String,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الحد الأدنى: ${CurrencyFormatter.formatIQD((coupon['minOrder'] as int).toDouble())}',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Copy Button
          GestureDetector(
            onTap: () {
              _couponController.text = coupon['code'] as String;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'نسخ',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _applyCoupon() {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'يرجى إدخال كود الخصم';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        widget.onApplyCoupon(code);
      }
    });
  }
}
