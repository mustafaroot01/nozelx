import 'package:flutter/material.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/theme/dimensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

/// Animated button with press effect
class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadow;
  final bool isLoading;
  final bool enabled;
  final double scaleFactor;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.shadow,
    this.isLoading = false,
    this.enabled = true,
    this.scaleFactor = 0.02,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled && !widget.isLoading) {
      _controller.value = 1.0 - widget.scaleFactor;
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled && !widget.isLoading) {
      _controller.reverse();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.enabled && !widget.isLoading ? widget.onPressed : null,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? 56,
          decoration: BoxDecoration(
            gradient: widget.backgroundColor == null
                ? AppColors.primaryGradient
                : null,
            color: widget.backgroundColor,
            borderRadius:
                widget.borderRadius ??
                BorderRadius.circular(AppDimensions.buttonBorderRadius),
            boxShadow:
                widget.shadow ??
                [
                  if (widget.backgroundColor == null)
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      offset: const Offset(0, 6),
                      blurRadius: 12,
                    ),
                ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.foregroundColor ?? Colors.white,
                      ),
                    ),
                  )
                : widget.child,
          ),
        ),
      ),
    );
  }
}

/// Gradient animated button
class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final List<Color> gradientColors;
  final Color? textColor;
  final double? width;
  final double height;
  final List<BoxShadow>? shadow;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.gradientColors = const [AppColors.gradientStart, AppColors.gradientEnd],
    this.textColor,
    this.width,
    this.height = 56,
    this.shadow,
    this.borderRadius,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onPressed,
      width: width,
      height: height,
      shadow: shadow,
      isLoading: isLoading,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor ?? Colors.white, size: 22),
            const SizedBox(width: 10),
          ],
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Outline button with animated border
class OutlineButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double height;
  final bool isLoading;
  final IconData? icon;
  final BorderRadius? borderRadius;

  const OutlineButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.borderColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.isLoading = false,
    this.icon,
    this.borderRadius,
  });

  @override
  State<OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<OutlineButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onPressed,
        onTapDown: (_) {
          if (!widget.isLoading) _controller.forward();
        },
        onTapUp: (_) {
          if (!widget.isLoading) {
            _controller.reverse();
            HapticFeedback.lightImpact();
          }
        },
        onTapCancel: () {
          if (!widget.isLoading) _controller.reverse();
        },
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius:
                widget.borderRadius ??
                BorderRadius.circular(AppDimensions.buttonBorderRadius),
            border: Border.all(
              color: widget.borderColor ?? AppColors.border,
              width: 1,
            ),
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.textColor ?? AppColors.primary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: widget.textColor ?? AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.text,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.textColor ?? AppColors.primary,
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

/// Icon button with badge
class BadgeIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final int badgeCount;
  final Color? badgeColor;
  final Color? iconColor;
  final double? size;

  const BadgeIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.badgeCount = 0,
    this.badgeColor,
    this.iconColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: size ?? 48,
        height: size ?? 48,
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                color: iconColor ?? AppColors.textPrimary,
                size: (size ?? 48) * 0.6,
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor ?? AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: Text(
                    badgeCount > 9 ? '9+' : '$badgeCount',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
