import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/responsive.dart';
import 'app_text.dart';

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final String? accessibilityLabel;

  const AppButton({
    super.key,
    required this.text,
    this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.accessibilityLabel,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _controller.forward();
      HapticFeedback.lightImpact(); // Trigger haptic feedback instantly on touch down (<100ms)
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final defaultBg = widget.backgroundColor ?? theme.primaryColor;
    final defaultText = widget.textColor ?? Colors.white;
    
    final double buttonHeight = Responsive.vertScale(widget.height ?? 54.0);
    final double buttonWidth = widget.width != null ? Responsive.scale(widget.width!) : double.infinity;

    return Semantics(
      button: true,
      enabled: !widget.isDisabled && !widget.isLoading,
      label: widget.accessibilityLabel ?? widget.text,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: () {
          if (!widget.isDisabled && !widget.isLoading && widget.onTap != null) {
            widget.onTap!();
          }
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: buttonWidth,
            height: buttonHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.isDisabled 
                  ? (isDark ? Colors.grey[800] : Colors.grey[300])
                  : defaultBg,
              borderRadius: BorderRadius.circular(Responsive.scale(16.0)),
              boxShadow: (widget.isDisabled || widget.isLoading)
                  ? []
                  : [
                      BoxShadow(
                        color: defaultBg.withOpacity(0.25),
                        blurRadius: Responsive.scale(12),
                        offset: Offset(0, Responsive.vertScale(4)),
                      ),
                    ],
            ),
            child: widget.isLoading
                ? SizedBox(
                    width: Responsive.scale(24),
                    height: Responsive.scale(24),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(defaultText),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: defaultText, size: Responsive.scale(20)),
                        SizedBox(width: Responsive.scale(8)),
                      ],
                      AppText(
                        text: widget.text,
                        size: AppTextSize.md,
                        weight: AppTextWeight.bold,
                        color: widget.isDisabled
                            ? (isDark ? Colors.grey[600] : Colors.grey[500])
                            : defaultText,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
