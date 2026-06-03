import 'package:flutter/material.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// Error snackbar with animated appearance and recovery action
class ErrorSnackbar {
  static void show({
    required BuildContext context,
    required String title,
    String? subtitle,
    String? actionText,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _ErrorSnackbarContent(title: title, subtitle: subtitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: duration,
        action: SnackBarAction(
          label: actionText ?? 'حسناً',
          textColor: AppColors.error,
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
                color: AppColors.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                color: AppColors.error,
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

class _ErrorSnackbarContent extends StatefulWidget {
  final String title;
  final String? subtitle;

  const _ErrorSnackbarContent({required this.title, this.subtitle});

  @override
  State<_ErrorSnackbarContent> createState() => __ErrorSnackbarContentState();
}

class __ErrorSnackbarContentState extends State<_ErrorSnackbarContent>
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
                      color: AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
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

/// Error message helpers
class ErrorMessage {
  static void networkError(BuildContext context) {
    ErrorSnackbar.show(
      context: context,
      title: 'خطأ في الاتصال',
      subtitle: 'يرجى التحقق من اتصالك بالإنترنت',
      actionText: 'إعادة المحاولة',
    );
  }

  static void serverError(BuildContext context) {
    ErrorSnackbar.show(
      context: context,
      title: 'خطأ في الخادم',
      subtitle: 'حدث خطأ ما، يرجى المحاولة لاحقاً',
      actionText: 'إعادة المحاولة',
    );
  }

  static void validationError(BuildContext context, String message) {
    ErrorSnackbar.show(
      context: context,
      title: 'خطأ في البيانات',
      subtitle: message,
    );
  }

  static void unauthorizedError(BuildContext context) {
    ErrorSnackbar.show(
      context: context,
      title: 'غير مصرح',
      subtitle: 'يرجى تسجيل الدخول أولاً',
      actionText: 'تسجيل دخول',
    );
  }

  static void notFoundError(BuildContext context) {
    ErrorSnackbar.show(
      context: context,
      title: 'غير موجود',
      subtitle: 'لم يتم العثور على العنصر المطلوب',
    );
  }
}
