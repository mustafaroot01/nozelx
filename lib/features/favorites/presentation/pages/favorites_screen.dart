import 'package:flutter/material.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/components/product_card.dart';
import 'package:auto_lube/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:auto_lube/providers/cart_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")} د.ع';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<FavoritesProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              // Main Content
              RefreshIndicator(
                onRefresh: provider.loadFavorites,
                color: AppColors.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Header Padding
                    const SliverToBoxAdapter(child: SizedBox(height: 110)),

                    if (provider.isLoading && provider.favorites.isEmpty)
                      _buildLoadingGrid()
                    else if (provider.favorites.isEmpty)
                      _buildEmptyState(context)
                    else
                      _buildFavoritesGrid(context, provider),
                    
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
              ),

              // Glassmorphic Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildHeader(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FavoritesProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withOpacity(0.9),
            AppColors.background.withOpacity(0.0),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.glassBorder, width: 1),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المفضلة',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${provider.favorites.length} منتج',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (provider.favorites.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showClearDialog(context, provider),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.delete_sweep_rounded, color: AppColors.error, size: 22),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2);
  }

  Widget _buildFavoritesGrid(BuildContext context, FavoritesProvider provider) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = provider.favorites[index];
            return ProductCardWidget(
              product: product,
              formatPrice: _formatPrice,
              isFavorite: true,
              inStock: product['inStock'] ?? true,
              onTap: () => Navigator.pushNamed(context, '/product', arguments: {'productId': product['id']}),
              onFavoriteTap: () => provider.toggleFavorite(product),
              onAddToCartTap: (product['inStock'] ?? true) ? () => _addToCart(context, product) : null,
            );
          },
          childCount: provider.favorites.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite_border_rounded, size: 80, color: AppColors.textTertiary),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 32),
            Text(
              'لا توجد مفضلات بعد',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'المنتجات التي تعجبك ستظهر هنا لتصل إليها لاحقاً بكل سهولة',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 220,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: Text(
                  'تصفح المنتجات',
                  style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24),
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms),
          childCount: 4,
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, Map<String, dynamic> item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(
      productId: item['id'].toString(),
      name: item['name'] ?? '',
      brand: item['brand'] ?? '',
      image: item['image'] ?? '',
      price: (item['price'] ?? 0).toDouble(),
      quantity: 1,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة ${item["name"]} إلى السلة', style: GoogleFonts.cairo()),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showClearDialog(BuildContext context, FavoritesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text('حذف الكل؟', style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
          content: Text('هل أنت متأكد من رغبتك في حذف جميع المنتجات من المفضلة؟', style: GoogleFonts.cairo()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                provider.clearAll();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('حذف الكل', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
