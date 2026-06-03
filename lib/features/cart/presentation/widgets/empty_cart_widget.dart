import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/core/theme/colors.dart';

/// Empty Cart Widget - shown when cart is empty
class EmptyCartWidget extends StatelessWidget {
  final VoidCallback onBrowseProducts;

  const EmptyCartWidget({super.key, required this.onBrowseProducts});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty Cart Illustration
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.shopping_cart,
              size: 80,
              color: AppColors.primary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            'السلة فارغة',
            style: GoogleFonts.cairo(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            'أضف منتجاتك للسلة وابدأ التسوق',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // Hint
          Text(
            'سيتم حفظ منتجاتك في السلة',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 40),

          // Browse Products Button
          SizedBox(
            width: 220,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: onBrowseProducts,
              icon: const Icon(Icons.storefront, color: Colors.white, size: 22),
              label: Text(
                'تصفح المنتجات',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Or
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 40, height: 1, color: AppColors.divider),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'أو',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              Container(width: 40, height: 1, color: AppColors.divider),
            ],
          ),

          const SizedBox(height: 16),

          // Quick Categories
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuickCategory('الزيوت', Icons.oil_barrel),
              const SizedBox(width: 12),
              _buildQuickCategory('الفلاتر', Icons.filter_alt),
              const SizedBox(width: 12),
              _buildQuickCategory('إضافات', Icons.add_circle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCategory(String name, IconData icon) {
    return GestureDetector(
      onTap: onBrowseProducts,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              name,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mini Empty Cart - for compact spaces
class MiniEmptyCart extends StatelessWidget {
  final VoidCallback onBrowseProducts;

  const MiniEmptyCart({super.key, required this.onBrowseProducts});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 60,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'سلة التسوق فارغة',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onBrowseProducts,
            child: Text(
              'ابدأ التسوق',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
