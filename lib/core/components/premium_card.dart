import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';

/// Premium Card with Multiple Variants
/// Supports: flat, elevated, glass, gradient, bordered
class PremiumCard extends StatefulWidget {
  final Widget child;
  final CardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<Color>? gradientColors;
  final List<BoxShadow>? boxShadow;
  final double? elevation;
  final bool isClickable;
  final bool isAnimated;
  final Duration? animationDuration;

  const PremiumCard({
    super.key,
    required this.child,
    this.variant = CardVariant.flat,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.backgroundColor,
    this.borderColor,
    this.gradientColors,
    this.boxShadow,
    this.elevation,
    this.isClickable = true,
    this.isAnimated = true,
    this.animationDuration,
  });

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.isClickable && widget.onTap != null) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isClickable && widget.onTap != null) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (widget.isClickable && widget.onTap != null) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      width: widget.width,
      height: widget.height,
      margin:
          widget.margin ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: _buildDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isClickable ? widget.onTap : null,
            onTapDown: widget.isClickable ? _handleTapDown : null,
            onTapUp: widget.isClickable ? _handleTapUp : null,
            onTapCancel: widget.isClickable ? _handleTapCancel : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(16),
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    if (widget.isAnimated) {
      final duration =
          widget.animationDuration ?? const Duration(milliseconds: 200);
      if (widget.variant == CardVariant.glass) {
        card = card.animate().shimmer(duration: 3000.ms, delay: 500.ms);
      } else if (widget.variant == CardVariant.elevated) {
        card = card
            .animate()
            .fade(duration: duration)
            .scale(duration: duration);
      } else {
        card = card
            .animate()
            .fade(duration: duration)
            .slide(duration: duration, begin: const Offset(0, 0.05));
      }
    }

    return card;
  }

  BoxDecoration _buildDecoration() {
    final scale = _isPressed ? 0.98 : 1.0;
    final effectiveElevation = _isPressed
        ? (widget.elevation ?? 2)
        : (widget.elevation ?? 6);

    switch (widget.variant) {
      case CardVariant.flat:
        return BoxDecoration(
          color: widget.backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor ?? AppColors.border,
            width: 1,
          ),
        );

      case CardVariant.elevated:
        return BoxDecoration(
          color: widget.backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow:
              widget.boxShadow ??
              [
                BoxShadow(
                  color: AppColors.shadowColor.withOpacity(0.1),
                  blurRadius: effectiveElevation * 2,
                  offset: Offset(0, effectiveElevation),
                ),
              ],
        );

      case CardVariant.glass:
        return BoxDecoration(
          color: (widget.backgroundColor ?? AppColors.glassBackground)
              .withOpacity(0.7),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor ?? AppColors.glassBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case CardVariant.gradient:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: widget.gradientColors != null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradientColors!,
                )
              : AppColors.primaryGradient,
          boxShadow:
              widget.boxShadow ??
              [
                BoxShadow(
                  color: (widget.gradientColors?.first ?? AppColors.primary)
                      .withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
        );

      case CardVariant.bordered:
        return BoxDecoration(
          color: widget.backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor ?? AppColors.primary,
            width: 2,
          ),
        );

      case CardVariant.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor ?? AppColors.border,
            width: 1.5,
          ),
        );
    }
  }
}

/// Card Variants Enum
enum CardVariant { flat, elevated, glass, gradient, bordered, outlined }

/// Glassmorphism Container
class GlassContainer extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool isClickable;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderColor,
    this.backgroundColor,
    this.boxShadow,
    this.onTap,
    this.isClickable = true,
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> {
  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: (widget.backgroundColor ?? AppColors.glassBackground).withValues(
          alpha: 0.65,
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: widget.borderColor ?? Colors.white.withOpacity(0.25),
          width: 1,
        ),
        boxShadow:
            widget.boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: widget.isClickable
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: Padding(
                    padding: widget.padding ?? const EdgeInsets.all(16),
                    child: widget.child,
                  ),
                ),
              )
            : Padding(
                padding: widget.padding ?? const EdgeInsets.all(16),
                child: widget.child,
              ),
      ),
    );

    return container.animate().fade(
      duration: const Duration(milliseconds: 300),
    );
  }
}

/// Animated Card with Scale Effect
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final double scaleFactor;
  final Duration animationDuration;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 20,
    this.backgroundColor,
    this.borderColor,
    this.boxShadow,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.scaleFactor = 0.96,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? widget.scaleFactor : 1.0;

    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) => setState(() => _isPressed = false)
          : null,
      onTapCancel: widget.onTap != null
          ? () => setState(() => _isPressed = false)
          : null,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: widget.animationDuration,
        curve: Curves.easeInOut,
        width: widget.width,
        height: widget.height,
        margin:
            widget.margin ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        transform: Matrix4.identity()..scale(scale),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor ?? AppColors.border,
            width: 1,
          ),
          boxShadow:
              widget.boxShadow ??
              [
                BoxShadow(
                  color: AppColors.shadowColor.withOpacity(0.1),
                  blurRadius: _isPressed ? 4 : 10,
                  offset: Offset(0, _isPressed ? 2 : 5),
                ),
              ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(16),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Expandable Card
class ExpandableCard extends StatefulWidget {
  final Widget title;
  final Widget content;
  final Widget? trailing;
  final bool isInitiallyExpanded;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;

  const ExpandableCard({
    super.key,
    required this.title,
    required this.content,
    this.trailing,
    this.isInitiallyExpanded = false,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 16,
  });

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1, curve: Curves.easeIn),
      ),
    );

    if (_isExpanded) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: widget.borderColor ?? AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: widget.title),
                  if (widget.trailing != null) ...[
                    const SizedBox(width: 8),
                    widget.trailing!,
                  ],
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
                    child: Icon(
                      Icons.expand_more,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _sizeAnimation,
            axisAlignment: -1,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: widget.content,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
