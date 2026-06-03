import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:auto_lube/core/theme/colors.dart';

/// بطاقات منتجات مصممة بأسلوب Apple Minimalist
class ProductCardWidget extends StatelessWidget {
  final dynamic product;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onAddToCartTap;
  final bool isFavorite;
  final bool isFavoriteLoading;
  final bool inStock;
  final bool isHorizontal;
  final String Function(int price) formatPrice;
  final String? heroTag;

  const ProductCardWidget({
    super.key,
    required this.product,
    this.onTap,
    this.onFavoriteTap,
    this.onAddToCartTap,
    this.isFavorite = false,
    this.isFavoriteLoading = false,
    this.inStock = true,
    this.isHorizontal = false,
    required this.formatPrice,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return _buildHorizontalCard().animate().fadeIn(duration: 400.ms).slideX(begin: 0.05);
    }
    return _buildGridCard().animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.98, 0.98), curve: Curves.easeOutBack);
  }

  Widget _buildHorizontalCard() {
    final price = (product['price'] ?? 0).toDouble();
    final oldPrice = (product['old_price'] ?? product['oldPrice'] ?? 0).toDouble();
    final hasDiscount = oldPrice > price;
    final discountPercent = hasDiscount ? '${((1 - price / oldPrice) * 100).round()}%-' : '';
    final imageUrl = _getImageUrl();
    final productId = product['id'] ?? product['productId'] ?? product['item_id'];
    final rating = (product['rating'] ?? 0).toDouble();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.divider.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image Section with modern proportions
            Container(
              width: 125,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                color: AppColors.background,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Hero(
                        tag: heroTag ?? 'product_image_${productId}_h',
                        child: AppNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            color: AppColors.surfaceVariant.withOpacity(0.5),
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    ),
                    if (hasDiscount)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: _buildBadge(discountPercent, AppColors.error, Colors.white),
                      ),
                  ],
                ),
              ),
            ),
            
            // Info Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product['brand'] ?? '',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildRating(rating, size: 12),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        product['name_ar'] ?? product['name'] ?? '',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: _buildPriceDisplay(price, oldPrice, hasDiscount)),
                        _buildAddButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard() {
    final price = (product['price'] ?? 0).toDouble();
    final oldPrice = (product['old_price'] ?? product['oldPrice'] ?? 0).toDouble();
    final hasDiscount = oldPrice > price;
    final discountPercent = hasDiscount ? '${((1 - price / oldPrice) * 100).round()}%-' : '';
    final imageUrl = _getImageUrl();
    final isNew = product['is_new'] == 1 || product['is_new'] == true;
    final productId = product['id'] ?? product['productId'] ?? product['item_id'];
    final rating = (product['rating'] ?? 0).toDouble();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.divider.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern Image Section
            Expanded(
              flex: 12,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Hero(
                          tag: heroTag ?? 'product_image_${productId}_g',
                          child: AppNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            borderRadius: 20,
                            errorWidget: Container(
                              color: AppColors.surfaceVariant.withOpacity(0.3),
                              child: const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Floating Badges
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (hasDiscount)
                          _buildBadge(discountPercent, Colors.white, AppColors.error),
                        if (isNew && !hasDiscount)
                          _buildBadge('جديد', Colors.white, AppColors.primary),
                      ],
                    ),
                  ),
                  // Premium Favorite Toggle
                  Positioned(
                    top: 14,
                    left: 14,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.glassBackground,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                          color: isFavorite ? AppColors.favorite : AppColors.textSecondary,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  // Out of stock overlay
                  if (!inStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                                color: AppColors.textPrimary.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              'نفذت الكمية',
                              style: GoogleFonts.cairo(
                                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Expanded Info Section
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product['brand'] ?? '',
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildRating(rating, size: 10),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Text(
                        product['name_ar'] ?? product['name'] ?? '',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: _buildPriceDisplay(price, oldPrice, hasDiscount)),
                        const SizedBox(width: 4),
                        _buildAddButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDisplay(double price, double oldPrice, bool hasDiscount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasDiscount)
          Text(
            formatPrice(oldPrice.toInt()),
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
              height: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        Text(
          formatPrice(price.toInt()),
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: AppColors.priceColor,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildRating(double rating, {double size = 12}) {
    if (rating <= 0) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.ratingStar, size: size + 2),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: GoogleFonts.cairo(
            fontSize: size,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: inStock ? onAddToCartTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: inStock ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          boxShadow: inStock ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Icon(
          Icons.add_shopping_cart_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    ).animate(target: inStock ? 1 : 0).shimmer(delay: 2.seconds, duration: 1200.ms);
  }

  Widget _buildBadge(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }

  String _getImageUrl() {
    // Check for the new full URL field from Laravel first
    if (product['image_url'] != null && product['image_url'].toString().isNotEmpty) {
      return product['image_url'].toString();
    }
    // Fallback to legacy field names
    if (product['image'] != null && product['image'].toString().isNotEmpty) {
      return product['image'].toString();
    }
    if (product['images'] != null && product['images'] is List) {
      final images = product['images'] as List;
      if (images.isNotEmpty && images.first.toString().isNotEmpty) {
        return images.first.toString();
      }
    }
    return 'https://images.unsplash.com/photo-1585719181211-45c1c71df8ae?w=400&h=400&fit=crop';
  }
}


/// مكون هيكل تحميل بطاقات المنتجات
class ProductCardSkeleton extends StatelessWidget {
  final bool isHorizontal;

  const ProductCardSkeleton({super.key, this.isHorizontal = false});

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return _buildHorizontalSkeleton();
    }
    return _buildGridSkeleton();
  }

  Widget _buildHorizontalSkeleton() {
    return Container(
      height: 140,
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 125,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
              color: AppColors.surfaceVariant.withOpacity(0.3),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 80,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 12,
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.surfaceVariant.withOpacity(0.3),
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 60,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
