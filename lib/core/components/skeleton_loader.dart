import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loader for loading states
/// Provides a shimmer effect to indicate loading
class SkeletonLoader extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const SkeletonLoader({
    super.key,
    required this.height,
    required this.width,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
          shape: shape,
        ),
      ),
    );
  }
}

/// Skeleton loader for product cards
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          SkeletonLoader(
            height: 130,
            width: double.infinity,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          // Content placeholder
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand placeholder
                SkeletonLoader(
                  height: 12,
                  width: 60,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 8),
                // Name placeholder
                SkeletonLoader(
                  height: 16,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 6),
                // Second line of name
                SkeletonLoader(
                  height: 12,
                  width: 80,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 12),
                // Rating row
                Row(
                  children: [
                    SkeletonLoader(
                      height: 20,
                      width: 50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const Spacer(),
                    SkeletonLoader(
                      height: 20,
                      width: 60,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Price row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLoader(
                      height: 20,
                      width: 70,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    SkeletonLoader(
                      height: 36,
                      width: 36,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for category cards
class CategoryCardSkeleton extends StatelessWidget {
  const CategoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          SkeletonLoader(
            height: 70,
            width: 70,
            borderRadius: BorderRadius.circular(18),
          ),
          const SizedBox(height: 8),
          SkeletonLoader(
            height: 12,
            width: 60,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 4),
          SkeletonLoader(
            height: 16,
            width: 20,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for list items
class ListItemSkeleton extends StatelessWidget {
  const ListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Image placeholder
          SkeletonLoader(
            height: 110,
            width: 110,
            borderRadius: BorderRadius.circular(14),
          ),
          const SizedBox(width: 14),
          // Content placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  height: 14,
                  width: 80,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  height: 18,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 6),
                SkeletonLoader(
                  height: 14,
                  width: 100,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLoader(
                      height: 20,
                      width: 80,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    SkeletonLoader(
                      height: 44,
                      width: 44,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for cart items
class CartItemSkeleton extends StatelessWidget {
  const CartItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Image placeholder
          SkeletonLoader(
            height: 100,
            width: 100,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 12),
          // Content placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SkeletonLoader(
                        height: 14,
                        width: 60,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    SkeletonLoader(
                      height: 18,
                      width: 18,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  height: 16,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SkeletonLoader(
                      height: 20,
                      width: 100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const Spacer(),
                    SkeletonLoader(
                      height: 36,
                      width: 100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Multi-item skeleton loader grid
class SkeletonGridLoader extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const SkeletonGridLoader({
    super.key,
    required this.itemCount,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.7,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => const ProductCardSkeleton(),
      ),
    );
  }
}

/// Multi-item skeleton loader horizontal list
class SkeletonHorizontalLoader extends StatelessWidget {
  final int itemCount;
  final double itemWidth;
  final double itemHeight;

  const SkeletonHorizontalLoader({
    super.key,
    required this.itemCount,
    this.itemWidth = 180,
    this.itemHeight = 260,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        itemBuilder: (context, index) =>
            SizedBox(width: itemWidth, child: const ProductCardSkeleton()),
      ),
    );
  }
}
