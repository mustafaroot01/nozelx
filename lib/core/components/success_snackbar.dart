import 'package:flutter/material.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// Success snackbar with animated appearance
class SuccessSnackbar {
  static void show({
    required BuildContext context,
    required String title,
    String? subtitle,
    String? actionText,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _SuccessSnackbarContent(title: title, subtitle: subtitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: duration,
        action: SnackBarAction(
          label: actionText ?? 'حسناً',
          textColor: AppColors.primary,
          onPressed: onAction ?? () {},
        ),
      ),
    );
  }

  static SnackBar build({
    required String title,
    String? subtitle,
    IconData? icon,
  }) {
    return SnackBar(
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon ?? Icons.check_circle,
                color: AppColors.success,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
    );
  }
}

class _SuccessSnackbarContent extends StatefulWidget {
  final String title;
  final String? subtitle;

  const _SuccessSnackbarContent({required this.title, this.subtitle});

  @override
  State<_SuccessSnackbarContent> createState() =>
      __SuccessSnackbarContentState();
}

class __SuccessSnackbarContentState extends State<_SuccessSnackbarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (widget.subtitle != null &&
                            widget.subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle!,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Quick success message helper
class SuccessMessage {
  static void addedToCart(
    BuildContext context,
    String productName,
    int quantity,
  ) {
    SuccessSnackbar.show(
      context: context,
      title: 'تمت الإضافة للسلة',
      subtitle: '$productName (x$quantity)',
    );
  }

  static void orderPlaced(BuildContext context, String orderId) {
    SuccessSnackbar.show(
      context: context,
      title: 'تم الطلب بنجاح',
      subtitle: 'رقم الطلب: #$orderId',
    );
  }

  static void saved(BuildContext context, String item) {
    SuccessSnackbar.show(
      context: context,
      title: 'تم الحفظ',
      subtitle: '$item تم حفظه بنجاح',
    );
  }

  static void deleted(BuildContext context, String item) {
    SuccessSnackbar.show(
      context: context,
      title: 'تم الحذف',
      subtitle: '$item تم حذفه بنجاح',
    );
  }

  static void updated(BuildContext context, String item) {
    SuccessSnackbar.show(
      context: context,
      title: 'تم التحديث',
      subtitle: '$item تم تحديثه بنجاح',
    );
  }
}
