import 'package:flutter/material.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/services/api_service.dart';
import 'package:auto_lube/features/products/presentation/pages/product_details_screen.dart';
import 'package:auto_lube/features/products/presentation/pages/products_list_screen.dart';
import 'package:auto_lube/features/categories/presentation/pages/sub_categories_screen.dart';
import 'package:auto_lube/core/services/category_service.dart';
import 'package:auto_lube/core/data/categories_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:auto_lube/core/utils/image_url_helper.dart';

class HeroSlider extends StatefulWidget {
  /// Optional: pass banners from parent (home screen).
  /// If null, the widget fetches its own data from the API.
  final List<Map<String, dynamic>>? banners;

  const HeroSlider({super.key, this.banners});

  @override
  State<HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<HeroSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _autoScrollDuration = 5; // seconds

  List<Map<String, dynamic>> _heroSlides = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initBanners();
  }

  @override
  void didUpdateWidget(HeroSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When parent passes new banners, update the slides
    if (widget.banners != null &&
        widget.banners != oldWidget.banners &&
        widget.banners!.isNotEmpty) {
      setState(() {
        _heroSlides = widget.banners!;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _initBanners() {
    if (widget.banners != null && widget.banners!.isNotEmpty) {
      // Use banners passed from parent
      setState(() {
        _heroSlides = widget.banners!;
        _isLoading = false;
      });
      _startAutoScroll();
    } else {
      // Fetch independently from API
      _loadHeroBanners();
    }
  }

  Future<void> _loadHeroBanners({bool forceRefresh = false}) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final banners = await ApiService.getHeroBanners(
        forceRefresh: forceRefresh,
      );

      if (mounted) {
        final List<Map<String, dynamic>> convertedBanners = [];
        for (var banner in banners) {
          if (banner is Map) {
            convertedBanners.add(Map<String, dynamic>.from(banner));
          }
        }

        setState(() {
          _heroSlides = convertedBanners.isNotEmpty
              ? convertedBanners
              : []; // No fallback - empty list
          _isLoading = false;
        });
        _startAutoScroll();
      }
    } catch (e) {
      print('Error loading hero banners: $e');
      if (mounted) {
        setState(() {
          _heroSlides = []; // No fallback - empty list
          _isLoading = false;
          _errorMessage = 'حدث خطأ في تحميل البانرات';
        });
        _startAutoScroll();
      }
    }
  }

  Future<void> _refreshBanners() async {
    await _loadHeroBanners(forceRefresh: true);
  }

  void _startAutoScroll() {
    if (!mounted) return;

    Future.delayed(Duration(seconds: _autoScrollDuration), () {
      if (!mounted) return;

      if (_heroSlides.isNotEmpty) {
        if (_currentPage < _heroSlides.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        _startAutoScroll();
      }
    });
  }

  Color _hexToColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return const Color(0xFF0F172A);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_heroSlides.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                color: AppColors.textTertiary,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'لا توجد بانرات متاحة',
                style: GoogleFonts.cairo(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshBanners,
      color: AppColors.primary,
      child: Column(
        children: [
          SizedBox(
            height: 230,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _heroSlides.length,
              itemBuilder: (context, index) {
                return _buildHeroSlide(index);
              },
            ),
          ),

          // Page Indicator
          if (_heroSlides.length > 1)
            Container(
              margin: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _heroSlides.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _pageController.animateToPage(
                      entry.key,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentPage == entry.key ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == entry.key
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroSlide(int index) {
    if (index >= _heroSlides.length) {
      return const SizedBox.shrink();
    }

    final slide = _heroSlides[index];

    // Get colors from API or use defaults
    final gradientStart = slide['gradient_start'] != null
        ? _hexToColor(slide['gradient_start'].toString())
        : const Color(0xFF0A1929);
    final gradientEnd = slide['gradient_end'] != null
        ? _hexToColor(slide['gradient_end'].toString())
        : const Color(0xFF1A3A5C);

    final gradient = [gradientStart, gradientEnd];
    final imageUrl = slide['image'] ?? slide['image_url'] ?? '';
    String fullImageUrl = imageUrl.toString();
    final bool isLocalImage = fullImageUrl.startsWith('assets/');

    final String title = slide['title']?.toString() ?? '';
    final String subtitle = slide['subtitle']?.toString() ?? '';
    final String description = slide['description']?.toString() ?? '';
    final bool hasText = title.isNotEmpty || subtitle.isNotEmpty || description.isNotEmpty;

    return GestureDetector(
      onTap: () {
        // 1. Check product_id
        if (slide['product_id'] != null) {
          final prodId = slide['product_id'].toString();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(
                productId: prodId,
              ),
            ),
          );
          return;
        }

        // 2. Check subcategory_id
        if (slide['subcategory_id'] != null) {
          final subcatId = slide['subcategory_id'].toString();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductsListScreen(
                categoryFilter: slide['title']?.toString() ?? 'القسم الفرعي',
                categoryId: subcatId,
              ),
            ),
          );
          return;
        }

        // 3. Check category_id
        if (slide['category_id'] != null) {
          final catId = slide['category_id'].toString();
          
          final cached = CategoryService.cachedCategories;
          Category? matchedCategory;
          if (cached != null) {
            for (var c in cached) {
              if (c.id.toString() == catId) {
                matchedCategory = c;
                break;
              }
            }
          }

          if (matchedCategory != null && matchedCategory.hasSubCategories) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SubCategoriesScreen(
                  parentCategoryId: matchedCategory!.id,
                  parentCategoryName: matchedCategory.name,
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductsListScreen(
                  categoryFilter: slide['title']?.toString() ?? matchedCategory?.name ?? 'القسم',
                  categoryId: catId,
                ),
              ),
            );
          }
          return;
        }

        // 4. Check brand_id
        if (slide['brand_id'] != null) {
          final brandId = slide['brand_id'].toString();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductsListScreen(
                brandId: brandId,
                brandName: slide['title']?.toString() ?? 'الماركة',
              ),
            ),
          );
          return;
        }

        // 5. Check link_url
        if (slide['link_url'] != null && slide['link_url'].toString().isNotEmpty) {
          _launchUrl(slide['link_url'].toString());
          return;
        }

        // Legacy compatibility
        final link = slide['link']?.toString() ?? '';
        if (link.isEmpty) return;

        print('Navigating to legacy banner link: $link');

        if (link.startsWith('products/')) {
          final productIdStr = link.replaceFirst('products/', '');
          final productId = int.tryParse(productIdStr);
          if (productId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(
                  productId: productId.toString(),
                ),
              ),
            );
          }
        } else if (link.startsWith('categories/')) {
          final categoryIdStr = link.replaceFirst('categories/', '');
          final categoryId = int.tryParse(categoryIdStr);
          if (categoryId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductsListScreen(
                  categoryFilter: slide['title'] ?? 'Category',
                  categoryId: categoryId.toString(),
                ),
              ),
            );
          }
        } else if (link.startsWith('http')) {
          _launchUrl(link);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: hasText ? null : Colors.transparent,
          gradient: hasText
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                )
              : null,
          boxShadow: hasText
              ? [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Image - support both local and network images
              if (fullImageUrl.isNotEmpty)
                Positioned.fill(
                  child: isLocalImage
                      ? Image.asset(
                          fullImageUrl,
                          fit: BoxFit.cover,
                        )
                      : AppNetworkImage(
                          imageUrl: ImageUrlHelper.banner(fullImageUrl),
                          fit: BoxFit.cover,
                        ),
                ),

              // Gradient overlay
              if (hasText)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        gradient[0].withOpacity(0.85),
                        gradient[0].withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

              // Content
              if (hasText)
                Positioned(
                  right: 20,
                  top: 50,
                  bottom: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        slide['title']?.toString() ?? '',
                        style: GoogleFonts.cairo(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        slide['subtitle']?.toString() ?? '',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        slide['description']?.toString() ?? '',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.75),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (slide['button_text'] != null &&
                          slide['button_text'].toString().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            slide['button_text']?.toString() ?? '',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: gradient[0],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              // Decorative circle
              if (hasText)
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch link')),
        );
      }
    }
  }
}
