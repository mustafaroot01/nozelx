import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:auto_lube/core/services/api_service.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/theme/dimensions.dart';
import 'package:auto_lube/core/components/product_card.dart';
import 'package:auto_lube/core/data/categories_data.dart';
import 'package:auto_lube/core/services/category_service.dart';
import 'package:auto_lube/features/products/presentation/pages/product_details_screen.dart';
import 'package:auto_lube/features/products/presentation/pages/products_list_screen.dart';
import 'package:auto_lube/features/categories/presentation/pages/categories_screen.dart';
import 'package:auto_lube/features/categories/presentation/pages/sub_categories_screen.dart';
import 'package:provider/provider.dart';
import 'package:auto_lube/providers/cart_provider.dart';
import 'package:auto_lube/providers/auth_provider.dart';
import 'package:auto_lube/features/cart/presentation/pages/cart_screen.dart';
import 'package:auto_lube/features/profile/presentation/pages/profile_screen.dart';
import 'package:auto_lube/features/home/presentation/components/hero_slider.dart';
import 'package:auto_lube/core/helpers/auth_helper.dart';
import 'package:auto_lube/providers/service_provider.dart';
import 'package:auto_lube/features/services/presentation/widgets/service_detail_sheet.dart';
import 'package:auto_lube/features/services/data/models/service_model.dart';
import 'package:auto_lube/screens/services/services_screen.dart';
import 'package:auto_lube/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:auto_lube/models/banner_model.dart';
import 'package:auto_lube/core/widgets/banner_slider.dart';
import 'package:flutter/services.dart';
import 'package:auto_lube/core/components/index.dart';
import 'package:auto_lube/core/utils/responsive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedBottomNav = 0;
  bool _isLoading = true;
  bool _hasError = false;
  List<dynamic> _products = [];
  List<dynamic> _heroBanners = [];
  List<dynamic> _rawHeroBanners = [];
  List<BannerModel> _parsedHeroBanners = [];
  List<dynamic> _specialOffers = [];
  List<dynamic> _categoryBanners = [];
  List<Category> _categories = [];
  Category? _selectedHomeCategory;

  // For category banners auto-scroll
  late PageController _categoryBannerController;
  final int _currentBannerPage = 0;



  late PageController _pageController;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _defaultHeroBanners = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTap() {
    final query = _searchController.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductsListScreen(
          searchFilter: query.isNotEmpty ? query : null,
          autoFocusSearch: true,
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Load all data in parallel for faster loading - explicitly forcing refresh from server
      final productsFuture = ApiService.getProducts(forceRefresh: true);
      final bannersFuture = ApiService.getHeroBanners(forceRefresh: true);
      final offersFuture = ApiService.getSpecialOffers(forceRefresh: true);
      final categoriesFuture = CategoryService.getCategories(forceRefresh: true);
      final categoryBannersFuture = ApiService.getCategoryBanners(forceRefresh: true);
      final servicesFuture = Provider.of<ServiceProvider>(context, listen: false).loadServices();

      // Wait for all to complete
      final products = await productsFuture;
      final banners = await bannersFuture;
      final offers = await offersFuture;
      final categoriesResult = await categoriesFuture;
      final categoryBanners = await categoryBannersFuture;
      await servicesFuture;

      if (mounted) {
        setState(() {
          // Randomize product ordering on the home screen so they are dynamic and change always
          final shuffled = List<dynamic>.from(products)..shuffle();
          _products = shuffled;
          _rawHeroBanners = banners;
          _parsedHeroBanners = banners
              .map((b) => BannerModel.fromJson(Map<String, dynamic>.from(b as Map)))
              .toList();
          _heroBanners = banners.map((banner) {
            return {
              'title': banner['title'] ?? '',
              'subtitle': banner['subtitle'] ?? '',
              'image': banner['image_url'] ?? banner['image'] ?? '',
              'link': banner['link'] ?? '',
            };
          }).toList();

          _specialOffers = offers.map((offer) {
            return {
              'title': offer['title'] ?? '',
              'subtitle': offer['subtitle'] ?? '',
              'description': offer['description'] ?? '',
              'gradient': [
                _parseColor(offer['gradient_start'] ?? '#0F172A'),
                _parseColor(offer['gradient_end'] ?? '#1E3A5C'),
              ],
              'image': offer['image'] ?? offer['image_url'] ?? '',
              'buttonText': offer['button_text'] ?? '',
              'discount_percent': offer['discount_percent'] ?? 0,
              'product_id': offer['product_id'],
            };
          }).toList();

          _categories = categoriesResult;
          _categoryBanners = categoryBanners;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading home data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(
              text: 'فشل تحميل البيانات. يرجى التحقق من اتصالك بالإنترنت.',
              color: Colors.white,
              size: AppTextSize.sm,
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }



  Color _parseColor(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('FF$hexColor', radix: 16));
      }
    } catch (e) {
      debugPrint('Error parsing color: $e');
    }
    return const Color(0xFF0F172A);
  }

  List<Map<String, dynamic>> get _activeBanners {
    // Return only server data - no fallback
    return _heroBanners.cast<Map<String, dynamic>>();
  }

  List<Map<String, dynamic>> get _activeOffers {
    // Return only server data - no fallback
    return _specialOffers.cast<Map<String, dynamic>>();
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} د.ع';
  }

  void _navigateToProduct(String productId, {String? heroTag}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(productId: productId, heroTag: heroTag),
      ),
    );
    _loadData();
  }

  void _onBottomNavTap(int index) {
    if (index == _selectedBottomNav) return;
    
    // Intercept Cart (index 2) and Profile (index 4) tabs for guest users
    if (index == 2 || index == 4) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (!auth.isLoggedIn) {
        Navigator.pushNamed(context, '/login');
        return;
      }
    }
    
    setState(() => _selectedBottomNav = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildHomeContent(),
            const CategoriesScreen(),
            const CartScreen(),
            const ServicesScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeContent() {
    if (_hasError && !_isLoading) {
      return RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: AppColors.error,
                  size: 64,
                ),
                const SizedBox(height: 16),
                AppText(
                  text: 'عذراً، فشل الاتصال بالخادم',
                  size: AppTextSize.lg,
                  weight: AppTextWeight.bold,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: 8),
                AppText(
                  text: 'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
                  size: AppTextSize.sm,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'إعادة المحاولة',
                  onTap: _loadData,
                  width: 160,
                  height: 48,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildSearchBar(),
            const SizedBox(height: 8),
            _buildHeroBanner(),
            const SizedBox(height: 16),
            _buildCategories(),
            _buildServicesSection(),
            _buildProductSections(),
            _buildAllProducts(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: _onSearchTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ما الذي تبحث عنه؟',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: BannerSlider(
        banners: _parsedHeroBanners,
        isLoading: _isLoading,
      ),
    );
  }

  Widget _buildCategories() {
    final displayCategories = _categories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التصنيفات',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => _onBottomNavTap(1),
                child: Text(
                  'إظهار الكل',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: displayCategories.isEmpty
              ? const SizedBox.shrink()
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayCategories.length,
                  itemBuilder: (context, index) =>
                      _buildCategoryCircle(displayCategories[index]),
                ),
        ),
        if (_selectedHomeCategory != null &&
            _selectedHomeCategory!.subCategories != null &&
            _selectedHomeCategory!.subCategories!.isNotEmpty)
          _buildHomeSubcategoriesRow(_selectedHomeCategory!),
        if (_categoryBanners.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildCategoryBanners(),
        ],
      ],
    );
  }

  Widget _buildHomeSubcategoriesRow(Category parentCategory) {
    final subs = parentCategory.subCategories ?? [];
    if (subs.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 6),
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: subs.length + 1, // +1 for "View All"
        itemBuilder: (context, index) {
          if (index == 0) {
            // "View All" rectangle
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductsListScreen(
                      categoryFilter: parentCategory.name,
                      categoryId: parentCategory.id,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: parentCategory.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: parentCategory.color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    'كل منتجات ${parentCategory.name}',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: parentCategory.color,
                    ),
                  ),
                ),
              ),
            );
          }

          final sub = subs[index - 1];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductsListScreen(
                    categoryFilter: sub.name,
                    categoryId: sub.id,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withOpacity(0.6),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  sub.name,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.1, end: 0);
  }

  // Category Banners Widget - Carousel under categories with auto-scroll
  Widget _buildCategoryBanners() {
    if (_categoryBanners.isEmpty) return const SizedBox.shrink();

    return StatefulBuilder(
      builder: (context, setState) {
        final PageController pageController = PageController();
        int currentPage = 0;

        // Auto-scroll with timer for continuous movement
        // We'll use a simpler approach that works better
        return Column(
          children: [
            SizedBox(
              height: 90, // Smaller banner height
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (page) => setState(() => currentPage = page),
                itemCount: _categoryBanners.length,
                itemBuilder: (context, index) {
                  final banner = _categoryBanners[index];
                  final imageUrl = banner['image_url'] ?? banner['image'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        final linkUrl = banner['link_url'] ?? '';
                        if (linkUrl.isNotEmpty) {
                          // Handle link tap
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AppNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              borderRadius: 12,
                              errorWidget: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withOpacity(0.8),
                                      AppColors.primary,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Page indicator
            if (_categoryBanners.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_categoryBanners.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: currentPage == index ? 20 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: currentPage == index
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    );
                  }),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryCircle(Category category) {
    final isSelected = _selectedHomeCategory?.id == category.id;
    return GestureDetector(
      onTap: () {
        if (category.hasSubCategories) {
          setState(() {
            if (_selectedHomeCategory?.id == category.id) {
              _selectedHomeCategory = null; // Toggle off
            } else {
              _selectedHomeCategory = category; // Select
            }
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductsListScreen(
                categoryFilter: category.name,
                categoryId: category.id,
              ),
            ),
          );
        }
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? category.color : Colors.transparent,
                  width: isSelected ? 2.5 : 0.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? category.color.withOpacity(0.3)
                        : AppColors.shadowColor,
                    blurRadius: isSelected ? 12 : 10,
                    offset: isSelected ? const Offset(0, 5) : const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: category.imageUrl != null && category.imageUrl!.isNotEmpty
                    ? const EdgeInsets.all(6)
                    : const EdgeInsets.all(12),
                child: category.imageUrl != null && category.imageUrl!.isNotEmpty
                    ? AppNetworkImage(
                        imageUrl: category.imageUrl!,
                        fit: BoxFit.contain,
                        borderRadius: 32,
                        placeholder: Icon(category.icon, color: AppColors.textTertiary, size: 24),
                        errorWidget: Icon(category.icon, color: category.color, size: 24),
                      )
                    : Icon(category.icon, color: category.color, size: 28),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? category.color : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    return const SizedBox.shrink();
  }


  Widget _buildCategoryIconFallback(Category category) {
    return Container(
      color: category.color.withOpacity(0.15),
      child: Icon(category.icon, color: category.color, size: 24),
    );
  }

  Widget _buildProductSections() {
    if (_isLoading) return _buildHorizontalSkeletonSection();

    final featured = _products.where((p) => p['home_section'] == 'featured' || p['is_featured'] == true || p['is_featured'] == 1).toList();
    final bestSellers = _products.where((p) => p['home_section'] == 'best_seller').toList();
    final newArrivals = _products.where((p) => p['home_section'] == 'new_arrival').toList();

    return Column(
      children: [
        if (featured.isNotEmpty) _buildSection('المنتجات المميزة', featured),
        if (bestSellers.isNotEmpty) _buildSection('الأكثر مبيعاً', bestSellers),
        if (newArrivals.isNotEmpty) _buildSection('وصل حديثاً', newArrivals),
      ],
    );
  }

  Widget _buildSection(String title, List<dynamic> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: products.length,
            itemBuilder: (context, index) => _buildProductCard(products[index], prefix: 'main'),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalSkeletonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Container(width: 150, height: 20, color: AppColors.surfaceVariant),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: 165,
                child: ProductCardSkeleton(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(dynamic product, {String? prefix}) {
    final inStock = product['in_stock'] == 1 || product['in_stock'] == true || (product['quantity'] != null && product['quantity'] > 0);
    final productId = product['id']?.toString() ?? '';
    final computedHeroTag = prefix != null ? '${prefix}_${productId}_h' : 'product_image_${productId}_h';

    return Consumer<FavoritesProvider>(
      builder: (context, provider, child) {
        final isFav = provider.isFavorite(productId);
        return SizedBox(
          width: 165,
          child: ProductCardWidget(
            product: product,
            inStock: inStock,
            isFavorite: isFav,
            formatPrice: _formatPrice,
            heroTag: computedHeroTag,
            onTap: () => _navigateToProduct(productId, heroTag: computedHeroTag),
            onFavoriteTap: () => _toggleFavorite(product),
            onAddToCartTap: inStock ? () => _addToCart(product) : null,
          ),
        );
      },
    );
  }

  /// Toggle favorite status for a product - calls API via Provider
  Future<void> _toggleFavorite(dynamic product) async {
    // Check if user is logged in first
    final isLoggedIn = await AuthHelper.checkAuthAndProceed(context);
    if (!isLoggedIn || !mounted) return;

    final provider = Provider.of<FavoritesProvider>(context, listen: false);
    final isFav = provider.isFavorite(product['id'].toString());
    
    HapticFeedback.mediumImpact();
    final success = await provider.toggleFavorite(product);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFav ? 'تم إزالة المنتج من المفضلة' : 'تمت إضافة المنتج للمفضلة',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: isFav ? AppColors.textSecondary : AppColors.favorite,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ، يرجى المحاولة مرة أخرى', style: GoogleFonts.cairo()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _addToCart(dynamic product) async {
    // Check if user is logged in first
    final isLoggedIn = await AuthHelper.checkAuthAndProceed(context);
    if (!isLoggedIn || !mounted) return;

    final cartProvider = context.read<CartProvider>();
    cartProvider.addItem(
      productId: product['id'].toString(),
      name: product['name'] ?? '',
      brand: product['brand'] ?? '',
      price: (product['price'] ?? 0).toDouble(),
      oldPrice: product['old_price'] != null
          ? (product['old_price'] ?? 0).toDouble()
          : null,
      image: product['image'] ?? '',
      quantity: 1,
    );
    if (mounted) {
      _showAddToCartOptions(
        product['name'] ?? '',
        (product['price'] ?? 0).toDouble(),
      );
    }
  }

  void _showAddToCartOptions(String productName, double productPrice) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 36,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'تمت إضافة المنتج للسلة',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              productName,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              '${productPrice.toInt()} د.ع',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _onBottomNavTap(2);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'إتمام الطلب',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_back, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'متابعة التسوق',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildAllProducts() {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              width: 80,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: AppDimensions.productCardAspectRatio,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: 6,
            itemBuilder: (context, index) => const ProductCardSkeleton(),
          ),
        ],
      );
    }

    if (_products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.inventory_2,
                size: 56,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 12),
              Text(
                'لا توجد منتجات حالياً',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sortedBySales = List<dynamic>.from(_products);
    sortedBySales.sort((a, b) => (b['sales'] ?? 0).compareTo(a['sales'] ?? 0));
    final bestSellers = sortedBySales.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'الأكثر مبيعاً',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: bestSellers.length,
            itemBuilder: (context, index) =>
                _buildProductCard(bestSellers[index], prefix: 'best'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'كل المنتجات',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_products.length} منتج',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: AppDimensions.productCardAspectRatio,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) =>
                _buildGridProductCard(_products[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildGridProductCard(dynamic product) {
    final inStock = product['in_stock'] == 1 || product['in_stock'] == true || (product['quantity'] != null && product['quantity'] > 0);
    final productId = product['id']?.toString() ?? '';
    final computedHeroTag = 'product_image_${productId}_g';
    
    return Consumer<FavoritesProvider>(
      builder: (context, provider, child) {
        final isFav = provider.isFavorite(productId);
        return ProductCardWidget(
          product: product,
          inStock: inStock,
          isFavorite: isFav,
          formatPrice: _formatPrice,
          heroTag: computedHeroTag,
          onTap: () => _navigateToProduct(productId, heroTag: computedHeroTag),
          onFavoriteTap: () => _toggleFavorite(product),
          onAddToCartTap: inStock ? () => _addToCart(product) : null,
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              _buildNavItem(0, 'الرئيسية', Icons.home_rounded),
              _buildNavItem(1, 'التصنيفات', Icons.dashboard_rounded),
              _buildNavItemWithBadge(2, 'السلة', Icons.shopping_bag_rounded),
              _buildNavItem(3, 'خدماتنا', Icons.build_circle_rounded),
              _buildNavItem(4, 'حسابي', Icons.account_circle_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _selectedBottomNav == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onBottomNavTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 9.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge(int index, String label, IconData icon) {
    final isSelected = _selectedBottomNav == index;
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartCount = cartProvider.totalItems;
        return Expanded(
          child: GestureDetector(
            onTap: () => _onBottomNavTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          icon,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          size: 22,
                        ),
                        if (cartCount > 0)
                          Positioned(
                            top: -3,
                            right: -5,
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 15,
                                minHeight: 15,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  cartCount > 9 ? '9+' : '$cartCount',
                                  style: GoogleFonts.cairo(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: 9.5,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
