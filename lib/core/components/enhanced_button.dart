import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

/// Enhanced Premium Button Component
/// Supports multiple variants: primary, secondary, glass, gradient, outline
class PremiumButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final ButtonVariant variant;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool fullWidth;
  final double height;
  final double borderRadius;
  final List<Color>? gradientColors;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? elevation;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsets? padding;
  final bool enableHaptic;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = true,
    this.height = 56,
    this.borderRadius = 16,
    this.gradientColors,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.elevation,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.enableHaptic = true,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final Widget buttonContent = _buildButtonContent();
    final Widget button = SizedBox(
      width: widget.fullWidth ? double.infinity : null,
      height: widget.height,
      child: GestureDetector(
        onTapDown: widget.onPressed != null ? _handleTapDown : null,
        onTapUp: widget.onPressed != null ? _handleTapUp : null,
        onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            decoration: _buildDecoration(),
            padding:
                widget.padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: buttonContent,
          ),
        ),
      ),
    );

    if (widget.variant == ButtonVariant.glass) {
      return button.animate().shimmer(duration: 3000.ms, delay: 500.ms);
    }

    return button;
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: widget.textColor ?? Colors.white,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.leadingIcon != null) ...[
          Icon(widget.leadingIcon, color: _getTextColor(), size: 22),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            widget.text,
            style: GoogleFonts.cairo(
              fontSize: widget.fontSize ?? 16,
              fontWeight: widget.fontWeight ?? FontWeight.bold,
              color: _getTextColor(),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: 10),
          Icon(widget.trailingIcon, color: _getTextColor(), size: 22),
        ],
      ],
    );
  }

  BoxDecoration _buildDecoration() {
    final scale = _isPressed ? 0.98 : 1.0;
    final elevation = _isPressed
        ? (widget.elevation ?? 2)
        : (widget.elevation ?? 6);

    switch (widget.variant) {
      case ButtonVariant.primary:
        return BoxDecoration(
          color: widget.backgroundColor ?? AppColors.primary,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: widget.gradientColors != null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradientColors!,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: (widget.backgroundColor ?? AppColors.primary).withValues(
                alpha: 0.3,
              ),
              blurRadius: elevation * 2,
              offset: Offset(0, elevation),
            ),
          ],
        );

      case ButtonVariant.secondary:
        return BoxDecoration(
          color: widget.backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor ?? AppColors.border,
            width: 1.5,
          ),
        );

      case ButtonVariant.glass:
        return BoxDecoration(
          color: AppColors.glassBackground.withOpacity(0.7),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: AppColors.glassBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case ButtonVariant.gradient:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                widget.gradientColors ??
                const [Color(0xFF1E4DB7), Color(0xFF3B6BD0)],
          ),
          boxShadow: [
            BoxShadow(
              color: (widget.gradientColors?.first ?? const Color(0xFF1E4DB7))
                  .withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        );

      case ButtonVariant.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor ?? AppColors.primary,
            width: 2,
          ),
        );

      case ButtonVariant.danger:
        return BoxDecoration(
          color: widget.backgroundColor ?? AppColors.error,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case ButtonVariant.success:
        return BoxDecoration(
          color: widget.backgroundColor ?? AppColors.success,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
    }
  }

  Color _getTextColor() {
    if (widget.textColor != null) return widget.textColor!;

    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.gradient:
      case ButtonVariant.danger:
      case ButtonVariant.success:
        return AppColors.textOnPrimary;

      case ButtonVariant.secondary:
      case ButtonVariant.glass:
      case ButtonVariant.outline:
        return widget.backgroundColor ?? AppColors.primary;
    }
  }
}

/// Button Variants Enum
enum ButtonVariant {
  primary,
  secondary,
  glass,
  gradient,
  outline,
  danger,
  success,
}

/// Gradient Button with Animated Effects
class GradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final List<Color> colors;
  final List<Color>? shadowColors;
  final IconData? icon;
  final double borderRadius;
  final double height;
  final bool isLoading;
  final double? fontSize;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    required this.colors,
    this.icon,
    this.borderRadius = 16,
    this.height = 56,
    this.isLoading = false,
    this.fontSize,
    this.shadowColors,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.colors,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.shadowColors ?? widget.colors).first.withValues(
              alpha: 0.4,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.text,
                        style: GoogleFonts.cairo(
                          fontSize: widget.fontSize ?? 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
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

/// Glassmorphism Button
class GlassButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final double borderRadius;
  final double height;
  final bool isLoading;
  final Color? borderColor;
  final Color? textColor;

  const GlassButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.borderRadius = 16,
    this.height = 56,
    this.isLoading = false,
    this.borderColor,
    this.textColor,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.glassBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: widget.borderColor ?? Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: widget.textColor ?? Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.text,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.textColor ?? Colors.white,
                          letterSpacing: 0.5,
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

/// Icon Button with Background
class IconButtonPremium extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final double borderRadius;
  final List<Color>? gradientColors;
  final bool isGradient;
  final BoxShadow? boxShadow;
  final String? tooltip;

  const IconButtonPremium({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 56,
    this.iconSize = 24,
    this.borderRadius = 14,
    this.gradientColors,
    this.isGradient = false,
    this.boxShadow,
    this.tooltip,
  });

  @override
  State<IconButtonPremium> createState() => _IconButtonPremiumState();
}

class _IconButtonPremiumState extends State<IconButtonPremium> {
  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: widget.isGradient
            ? (widget.gradientColors != null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.gradientColors!,
                  )
                : AppColors.primaryGradient)
            : null,
        boxShadow: widget.boxShadow != null ? [widget.boxShadow!] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Center(
            child: Icon(
              widget.icon,
              color: widget.iconColor ?? Colors.white,
              size: widget.iconSize,
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}
