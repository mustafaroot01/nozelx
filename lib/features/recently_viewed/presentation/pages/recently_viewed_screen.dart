import 'package:flutter/material.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/utils/currency_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:auto_lube/core/utils/image_url_helper.dart';

class RecentlyViewedScreen extends StatefulWidget {
  const RecentlyViewedScreen({super.key});

  @override
  State<RecentlyViewedScreen> createState() => _RecentlyViewedScreenState();
}

class _RecentlyViewedScreenState extends State<RecentlyViewedScreen> {
  List<Map<String, dynamic>> recentlyViewed = [
    {
      'id': '1',
      'name': 'Mobil 1 ESP 5W-30',
      'brand': 'Mobil',
      'price': 45000,
      'oldPrice': 55000,
      'image':
          'https://images.unsplash.com/photo-1585719181211-45c1c71df8ae?w=200&h=200&fit=crop',
      'rating': 4.8,
      'reviews': 245,
      'viewedAt': 'منذ ساعة',
    },
    {
      'id': '2',
      'name': 'Castrol Edge 5W-30',
      'brand': 'Castrol',
      'price': 42000,
      'oldPrice': null,
      'image':
          'https://images.unsplash.com/photo-1563293722-1510c5f3c83b?w=200&h=200&fit=crop',
      'rating': 4.6,
      'reviews': 189,
      'viewedAt': 'منذ 3 ساعات',
    },
    {
      'id': '3',
      'name': 'Bosch Air Filter',
      'brand': 'Bosch',
      'price': 15000,
      'oldPrice': null,
      'image':
          'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=200&h=200&fit=crop',
      'rating': 4.5,
      'reviews': 98,
      'viewedAt': 'أمس',
    },
    {
      'id': '4',
      'name': 'Shell Helix Ultra',
      'brand': 'Shell',
      'price': 48000,
      'oldPrice': 55000,
      'image':
          'https://images.unsplash.com/photo-1506368249639-73a05d6f6488?w=200&h=200&fit=crop',
      'rating': 4.9,
      'reviews': 312,
      'viewedAt': 'أمس',
    },
    {
      'id': '5',
      'name': 'NGK Iridium Spark Plug',
      'brand': 'NGK',
      'price': 8000,
      'oldPrice': null,
      'image':
          'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=200&h=200&fit=crop',
      'rating': 4.7,
      'reviews': 156,
      'viewedAt': 'منذ يومين',
    },
  ];

  String _sortBy = 'الأحدث';

  @override
  Widget build(BuildContext context) {
    if (recentlyViewed.isEmpty) {
      return _buildEmptyState();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        title: Text(
          'المشاهدة الأخيرة',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: AppColors.textPrimary),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'الأحدث',
                child: Text('الأحدث', style: GoogleFonts.cairo()),
              ),
              PopupMenuItem(
                value: 'السعر: منخفض',
                child: Text('السعر: منخفض لأعلى', style: GoogleFonts.cairo()),
              ),
              PopupMenuItem(
                value: 'السعر: مرتفع',
                child: Text(
                  'السعر: مرتفع لمنخفض',
                  style: GoogleFonts.cairo(),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _clearHistory,
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.history, color: AppColors.textTertiary, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${recentlyViewed.length} منتجات',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  'فرز: $_sortBy',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // Products
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recentlyViewed.length,
              itemBuilder: (context, index) => _buildProductItem(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(int index) {
    final item = recentlyViewed[index];
    final hasDiscount = item['oldPrice'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Image
          AppNetworkImage(
            imageUrl: ImageUrlHelper.productThumb(item['image'] as String),
            width: 90,
            height: 90,
            borderRadius: 16,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['brand'] as String,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['name'] as String,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasDiscount)
                          Text(
                            CurrencyFormatter.formatIQD(
                              (item['oldPrice'] as int).toDouble(),
                            ),
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          CurrencyFormatter.formatIQD(
                            (item['price'] as int).toDouble(),
                          ),
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item['viewedAt'] as String,
              style: GoogleFonts.cairo(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        title: Text(
          'المشاهدة الأخيرة',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(70),
              ),
              child: const Icon(
                Icons.history,
                size: 70,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد مشاهدة أخيرة',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تصفح المنتجات وستظهر هنا',
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/products'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'تصفح المنتجات',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'حذف السجل',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'هل تريد حذف جميع سجل المشاهدة؟',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => recentlyViewed.clear());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'حذف',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
