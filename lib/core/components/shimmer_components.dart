import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

/// Premium Shimmer Loading Component
/// Provides beautiful shimmer effect for loading states
class PremiumShimmer extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final ShimmerDirection direction;
  final Duration period;
  final LinearGradient? gradient;
  final Color? baseColor;
  final Color? highlightColor;
  final double? shimmerWidth;
  final double? shimmerHeight;

  const PremiumShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.direction = ShimmerDirection.ltr,
    this.period = const Duration(milliseconds: 1500),
    this.gradient,
    this.baseColor,
    this.highlightColor,
    this.shimmerWidth,
    this.shimmerHeight,
  });

  @override
  State<PremiumShimmer> createState() => _PremiumShimmerState();
}

class _PremiumShimmerState extends State<PremiumShimmer> {
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Shimmer.fromColors(
      direction: widget.direction,
      period: widget.period,
      baseColor: widget.baseColor ?? Colors.grey[300]!,
      highlightColor: widget.highlightColor ?? Colors.grey[100]!,
      child: widget.child,
    );
  }
}

/// Shimmer Container for rectangular loading areas
class ShimmerContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxDecoration? decoration;

  const ShimmerContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration:
          decoration ??
          BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
    );
  }
}

/// Shimmer Card for loading cards
class ShimmerCard extends StatelessWidget {
  final double borderRadius;
  final EdgeInsets? margin;
  final List<Widget> children;

  const ShimmerCard({
    super.key,
    this.borderRadius = 16,
    this.margin,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// Skeleton Loading for Product Card
class ProductCardSkeleton extends StatelessWidget {
  final bool showRating;
  final double borderRadius;

  const ProductCardSkeleton({
    super.key,
    this.showRating = true,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerCard(
      borderRadius: borderRadius,
      children: [
        // Product Image
        SizedBox(
          height: 140,
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(borderRadius - 4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Brand
        Container(
          height: 12,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        // Product Name
        Container(
          height: 16,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 16,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 12),
        // Price Row
        Row(
          children: [
            Container(
              height: 20,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Spacer(),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Skeleton Loading for Category Card
class CategoryCardSkeleton extends StatelessWidget {
  final double borderRadius;

  const CategoryCardSkeleton({super.key, this.borderRadius = 18});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton Loading for List Item
class ListItemSkeleton extends StatelessWidget {
  final bool showAvatar;
  final bool showTrailing;
  final int lineCount;

  const ListItemSkeleton({
    super.key,
    this.showAvatar = true,
    this.showTrailing = true,
    this.lineCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (showAvatar)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          if (showAvatar) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(lineCount, (index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < lineCount - 1 ? 8 : 0,
                  ),
                  child: Container(
                    height: 12,
                    width: index == lineCount - 1 ? 100.0 : double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              }),
            ),
          ),
          if (showTrailing) const SizedBox(width: 12),
          if (showTrailing)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
        ],
      ),
    );
  }
}

/// Skeleton Loading for Banner/Hero
class BannerSkeleton extends StatelessWidget {
  final double height;
  final double borderRadius;

  const BannerSkeleton({super.key, this.height = 180, this.borderRadius = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton Loading for Profile Header
class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerCard(
      children: [
        Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Skeleton Loading for Grid
class GridSkeleton extends StatelessWidget {
  final int itemCount;
  final double borderRadius;
  final int crossAxisCount;

  const GridSkeleton({
    super.key,
    this.itemCount = 4,
    this.borderRadius = 16,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: itemCount,
      itemBuilder: (context, index) =>
          ProductCardSkeleton(borderRadius: borderRadius),
    );
  }
}

/// Loading Overlay with Shimmer
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color? backgroundColor;
  final double opacity;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.backgroundColor,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: (backgroundColor ?? Colors.grey[200]!).withValues(
                alpha: opacity,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLoadingIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'جاري التحميل...',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 50,
      height: 50,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        backgroundColor: AppColors.primary.withOpacity(0.1),
      ),
    );
  }
}

/// Custom Loading Spinner
class LoadingSpinner extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;

  const LoadingSpinner({
    super.key,
    this.size = 40,
    this.strokeWidth = 3,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
        backgroundColor:
            backgroundColor ?? AppColors.primary.withOpacity(0.1),
      ),
    );
  }
}

/// Pulsing Loading Indicator
class PulsingDot extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;

  const PulsingDot({
    super.key,
    this.size = 12,
    this.color,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: widget.size * _controller.value + widget.size,
            height: widget.size * _controller.value + widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (widget.color ?? AppColors.primary).withValues(
                alpha: 1 - _controller.value,
              ),
            ),
          );
        },
      ),
    );
  }
}
