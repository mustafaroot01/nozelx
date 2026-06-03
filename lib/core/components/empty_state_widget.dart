import 'package:flutter/material.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// Empty state widget with icon, title, description and action
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;
  final List<Color>? gradientColors;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionText,
    this.onAction,
    this.iconColor,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradientColors != null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors!,
                    )
                  : null,
              color: gradientColors == null ? AppColors.surfaceVariant : null,
              boxShadow: [
                BoxShadow(
                  color: (iconColor ?? AppColors.primary).withValues(
                    alpha: 0.2,
                  ),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gradientColors == null ? AppColors.surface : null,
              ),
              child: Icon(
                icon,
                size: 50,
                color: gradientColors == null
                    ? iconColor ?? AppColors.textTertiary
                    : Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          // Description
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                description!,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],

          // Action button
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionText!,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pre-defined empty states for common scenarios
class EmptyStates {
  /// Empty cart state
  static Widget emptyCart(BuildContext context, VoidCallback onBrowse) {
    return EmptyStateWidget(
      icon: Icons.shopping_cart,
      title: 'السلة فارغة',
      description: 'أضف منتجاتك للسلة وابدأ التسوق',
      actionText: 'تصفح المنتجات',
      onAction: onBrowse,
      iconColor: AppColors.textTertiary,
      gradientColors: null,
    );
  }

  /// Empty favorites state
  static Widget emptyFavorites(BuildContext context, VoidCallback onBrowse) {
    return EmptyStateWidget(
      icon: Icons.favorite_border,
      title: 'قائمة المفضلات فارغة',
      description: 'أضف منتجاتك المفضلة هنا',
      actionText: 'تصفح المنتجات',
      onAction: onBrowse,
      iconColor: AppColors.favorite,
      gradientColors: null,
    );
  }

  /// Empty orders state
  static Widget emptyOrders(BuildContext context, VoidCallback onBrowse) {
    return EmptyStateWidget(
      icon: Icons.receipt_long,
      title: 'لا توجد طلبات',
      description: 'لم تقم بأي طلبات حتى الآن',
      actionText: 'تسوق الآن',
      onAction: onBrowse,
      iconColor: AppColors.primary,
      gradientColors: null,
    );
  }

  /// Empty search results state
  static Widget emptySearch(
    BuildContext context,
    String query,
    VoidCallback onClear,
  ) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'لا توجد نتائج',
      description: 'لم يتم العثور على نتائج لـ "$query"',
      actionText: 'مسح البحث',
      onAction: onClear,
      iconColor: AppColors.warning,
      gradientColors: null,
    );
  }

  /// No internet state
  static Widget noInternet(BuildContext context, VoidCallback onRetry) {
    return EmptyStateWidget(
      icon: Icons.wifi_off,
      title: 'لا يوجد اتصال',
      description: 'يرجى التحقق من اتصالك بالإنترنت',
      actionText: 'إعادة المحاولة',
      onAction: onRetry,
      iconColor: AppColors.error,
      gradientColors: null,
    );
  }

  /// Under maintenance state
  static Widget maintenance(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.construction,
      title: 'صيانة',
      description: 'نحن نقوم ببعض التحسينات\nيرجى المحاولة لاحقاً',
      iconColor: AppColors.warning,
      gradientColors: [
        AppColors.warning.withOpacity(0.1),
        AppColors.warning.withOpacity(0.2),
      ],
    );
  }
}
