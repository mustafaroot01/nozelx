import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_lube/widgets/product_tags/product_tags_row.dart';
import 'package:auto_lube/providers/product_tags_provider.dart';
import 'dart:ui';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/components/product_card.dart';
import 'package:auto_lube/core/services/api_service.dart';
import 'package:auto_lube/core/data/categories_data.dart';
import 'package:auto_lube/core/helpers/auth_helper.dart';
import 'package:auto_lube/providers/cart_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:auto_lube/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:auto_lube/core/services/live_update_service.dart';
import 'product_details_screen.dart';

class ProductsListScreen extends StatefulWidget {
  final String? categoryFilter;
  final String? categoryId; // ← ID التصنيف من قاعدة البيانات
  final String? companyFilter;
  final String? viscosityFilter;
  final String? searchFilter;
  final bool autoFocusSearch;
  final String? brandId;
  final String? brandName;

  const ProductsListScreen({
    super.key,
    this.categoryFilter,
    this.categoryId,
    this.companyFilter,
    this.viscosityFilter,
    this.searchFilter,
    this.autoFocusSearch = false,
    this.brandId,
    this.brandName,
  });

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen>
    with TickerProviderStateMixin {
  String selectedCategory = 'الكل';
  String? selectedCompany;
  String? selectedViscosity;
  String? selectedOilType;
  String sortBy = 'الأكثر مبيعاً';
  String searchQuery = '';
  bool isGridView = true;
  bool _isLoading = true;
  final bool _showFilters = false;
  List<dynamic> _products = [];
  
  List<dynamic> _brands = [];
  List<dynamic> _tags = [];
  dynamic _selectedBrand;
  dynamic _selectedTag;
  final bool _isLoadingFilters = false;
  StreamSubscription? _stockSubscription;



  
  // Dynamic Categories Hierarchy
  final List<Category> _subCategories = [];
  final List<Category> _subSubCategories = [];
  Category? _selectedSubCategory;
  Category? _selectedSubSubCategory;
  final bool _isLoadingCategoriesBar = false;

  double minPrice = 0;
  double maxPrice = 1000000;
  double selectedMinPrice = 0;
  double selectedMaxPrice = 1000000;
  double minRating = 0;

  final bool _isFetchingProducts = false;

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    'الكل',
    'زيوت',
    'فلاتر',
    'سوائل',
    'إضافات',
    'العناية',
    'قطع غيار',
  ];

  final List<String> sortOptions = [
    'الافتراضي',
    'الأكثر مبيعاً',
    'الأعلى سعراً',
    'الأقل سعراً',
    'الأحدث',
    'الأعلى تقييماً',
  ];

  final List<String> quickFilters = ['خصومات', 'جديد', '4 نجوم فأكثر'];

  
  // Filter context resolver
  String? get currentFilterCategoryId => _selectedSubSubCategory?.id ?? _selectedSubCategory?.id ?? widget.categoryId;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);

    if (widget.categoryFilter != null) {
      selectedCategory = widget.categoryFilter!;
    }
    // If categoryId provided, use it for API filtering
    if (widget.companyFilter != null) {
      selectedCompany = widget.companyFilter;
    }
    if (widget.viscosityFilter != null) {
      selectedViscosity = widget.viscosityFilter;
    }
    if (widget.searchFilter != null) {
      searchQuery = widget.searchFilter!;
      _searchController.text = widget.searchFilter!;
    }
    if (widget.brandId != null) {
      _selectedBrand = {
        'id': int.tryParse(widget.brandId!) ?? widget.brandId,
        'name': widget.brandName ?? 'الماركة',
      };
    }

    // Load filters and data
    _loadData();

    _stockSubscription = LiveUpdateService.stockUpdates.listen((data) {
      if (!mounted) return;
      final eventProductId = data['product_id']?.toString();
      if (eventProductId == null) return;
      
      final newQty = data['new_qty'] ?? data['stock_quantity'] ?? 0;
      final bool isAvail = data['is_available'] ?? (newQty > 0);
      final String stockStatus = data['stock_status'] ?? (newQty > 0 ? "in_stock" : "out_of_stock");

      bool updated = false;
      final updatedProducts = List<dynamic>.from(_products);
      for (int i = 0; i < updatedProducts.length; i++) {
        final p = updatedProducts[i];
        if (p['id']?.toString() == eventProductId) {
          final updatedProduct = Map<String, dynamic>.from(p);
          updatedProduct['stock_quantity'] = newQty;
          updatedProduct['stock'] = newQty;
          updatedProduct['quantity'] = newQty;
          updatedProduct['is_available'] = isAvail;
          updatedProduct['in_stock'] = isAvail ? 1 : 0;
          updatedProduct['stock_status'] = stockStatus;
          updatedProducts[i] = updatedProduct;
          updated = true;
        }
      }
      
      if (updated) {
        setState(() {
          _products = updatedProducts;
        });
      }
    });
  }

  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Fetch Brands and Tags if not loaded
      if (_brands.isEmpty) {
        final brands = await ApiService.getBrands();
        setState(() => _brands = brands);
      }
      
      // Fetch Tags (Viscosity by default)
      if (_tags.isEmpty) {
        final tags = await ApiService.getProductTags(type: 'viscosity');
        setState(() => _tags = tags);
      }

      // Pass categoryId, brandId, and tagId to API
      final products = await ApiService.getProducts(
        categoryId: widget.categoryId,
        brandId: _selectedBrand?['id']?.toString(),
        tagId: _selectedTag?['id']?.toString(),
        forceRefresh: true,
      );
      
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  
  Future<void> _onRefresh() async {
    // Explicitly clear local state and reload
    await _loadData();
      }

  @override
  void dispose() {
    _stockSubscription?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

    List<dynamic> get filteredProducts {
    return _products.where((p) {
      final price = double.tryParse(p['price']?.toString() ?? '0') ?? 0.0;
      if (price < selectedMinPrice || price > selectedMaxPrice) return false;
      
      final rating = double.tryParse(p['rating']?.toString() ?? '0') ?? 0.0;
      if (rating < minRating) return false;
      
      if (searchQuery.isNotEmpty) {
        final name = (p['name_ar'] ?? p['name'])?.toString().toLowerCase() ?? '';
        final brand = (p['brand'] ?? '').toString().toLowerCase();
        final query = searchQuery.toLowerCase();
        if (!name.contains(query) && !brand.contains(query)) return false;
      }
      return true;
    }).toList();
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} د.ع';
  }

  
  void _clearFilters() {
    setState(() {
      selectedCategory = 'الكل';
      _selectedBrand = null;
      _selectedTag = null;
      sortBy = 'الأكثر مبيعاً';
      searchQuery = '';
      _searchController.clear();
      selectedMinPrice = 0;
      selectedMaxPrice = 1000000;
      minRating = 0;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main Content
          RefreshIndicator(
            onRefresh: _onRefresh,
            edgeOffset: 100, // Account for floating search bar
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                // Top Padding for floating search bar
                const SliverToBoxAdapter(child: SizedBox(height: 100)),

                // Product Tags Row (Sub-Sub-Categories)
                if (widget.categoryId != null && int.tryParse(widget.categoryId!) != null)
                  SliverToBoxAdapter(
                    child: ProductTagsRow(
                      subcategoryId: int.parse(widget.categoryId!),
                      onTagSelected: (tagId) {
                        setState(() {
                          _selectedTag = tagId != null ? {'id': tagId} : null;
                        });
                        _loadData();
                      },
                    ),
                  ),

                // Brands and Tags Filter Bar
                SliverToBoxAdapter(
                  child: _buildProfessionalFilters(),
                ),

                // Products Container
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 30),
                  sliver: _isLoading
                      ? _buildLoadingGrid()
                      : filteredProducts.isEmpty
                          ? _buildEmptyState()
                          : isGridView
                              ? _buildGridView()
                              : _buildListView(),
                ),
              ],
            ),
          ),

          // Floating Glassmorphic Search Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildFloatingHeader(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withOpacity(0.8),
            AppColors.background.withOpacity(0.0),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 44, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: widget.autoFocusSearch,
                    onChanged: (val) => setState(() => searchQuery = val),
                    style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'ما الذي تبحث عنه؟',
                      hintStyle: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                VerticalDivider(width: 20, indent: 15, endIndent: 15, color: AppColors.border.withOpacity(0.5)),
                GestureDetector(
                  onTap: _showAdvancedFilterSheet,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.tune_rounded, size: 20, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2);
  }

  Widget _buildViewAndSortToggles() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleBtn(
            isSelected: isGridView,
            icon: Icons.grid_view_rounded,
            onTap: () => setState(() => isGridView = true),
          ),
          const SizedBox(width: 4),
          _buildToggleBtn(
            isSelected: !isGridView,
            icon: Icons.view_list_rounded,
            onTap: () => setState(() => isGridView = false),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn({required bool isSelected, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  )
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }

  
  Widget _buildProfessionalFilters() {
    return const SizedBox.shrink();
  }
  Widget _buildLoadingGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => Shimmer.fromColors(
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.white,
            child: const ProductCardSkeleton(),
          ),
          childCount: 6,
        ),
      ),
    );
  }

  void _showAdvancedFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
              )
            ],
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 12,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تصفية المنتجات',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _clearFilters();
                      setSheetState(() {});
                      setState(() {});
                    },
                    child: Text(
                      'إعادة تعيين',
                      style: GoogleFonts.cairo(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Sort Section
              Text(
                'الترتيب حسب',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: sortOptions.map((option) {
                  final isSelected = sortBy == option;
                  return GestureDetector(
                    onTap: () {
                      setSheetState(() => sortBy = option);
                      setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        option,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // Price Range Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'مدى السعر (د.ع)',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${_formatPrice(selectedMinPrice.toInt())} - ${_formatPrice(selectedMaxPrice.toInt())}',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              RangeSlider(
                values: RangeValues(selectedMinPrice, selectedMaxPrice),
                min: minPrice,
                max: maxPrice,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.surfaceVariant.withOpacity(0.5),
                onChanged: (values) {
                  setSheetState(() {
                    selectedMinPrice = values.start;
                    selectedMaxPrice = values.end;
                  });
                  setState(() {});
                },
              ),
              const SizedBox(height: 32),

              // Apply Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 8,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text(
                    'تطبيق الفلاتر',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded, size: 64, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 24),
            Text(
              'لم يتم العثور على نتائج',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرب تغيير خيارات الفلترة أو البحث',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.restart_alt_rounded),
              label: Text(
                'إعادة تعيين كافة الفلاتر',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ).animate().fadeIn().scale(duration: 400.ms),
    );
  }

  Widget _buildGridView() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildProductCard(filteredProducts[index]),
          childCount: filteredProducts.length,
        ),
      ),
    );
  }

  Widget _buildListView() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildProductCard(filteredProducts[index], isHorizontal: true),
          childCount: filteredProducts.length,
        ),
      ),
    );
  }

  bool _isProductInStock(dynamic product) {
    final avail = product['is_available'];
    if (avail is bool) return avail;
    if (avail is num) return avail == 1;

    final inStock = product['in_stock'];
    if (inStock is bool) return inStock;
    if (inStock is num) return inStock == 1;

    final qty = product['quantity'] ?? product['stock_quantity'] ?? product['stock'];
    if (qty is num) return qty > 0;

    return false;
  }

  Widget _buildProductCard(dynamic product, {bool isHorizontal = false}) {
    final inStock = _isProductInStock(product);
    final productId = product['id']?.toString() ?? '';
    
    return Consumer<FavoritesProvider>(
      builder: (context, provider, child) {
        final isFav = provider.isFavorite(productId);
        
        return ProductCardWidget(
          product: product,
          isHorizontal: isHorizontal,
          inStock: inStock,
          isFavorite: isFav,
          isFavoriteLoading: false, // Provider handles async state
          formatPrice: _formatPrice,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => ProductDetailsScreen(productId: productId)),
            );
            _loadData();
          },
          onFavoriteTap: () => _toggleFavorite(product),
          onAddToCartTap: inStock ? () => _addToCart(product) : null,
        );
      },
    );
  }

  Future<void> _toggleFavorite(dynamic product) async {
    final isLoggedIn = await AuthHelper.checkAuthAndProceed(context);
    if (!isLoggedIn || !mounted) return;

    final provider = Provider.of<FavoritesProvider>(context, listen: false);
    final isFav = provider.isFavorite(product['id'].toString());
    
    HapticFeedback.mediumImpact();
    final success = await provider.toggleFavorite(product);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFav ? 'تمت الإزالة من المفضلة' : 'تمت الإضافة للمفضلة', style: GoogleFonts.cairo()),
          backgroundColor: isFav ? AppColors.textSecondary : AppColors.favorite,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _addToCart(dynamic product) async {
    final isLoggedIn = await AuthHelper.checkAuthAndProceed(context);
    if (!isLoggedIn || !mounted) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(
      productId: product['id'].toString(),
      name: product['name'] ?? '',
      brand: product['brand'] ?? '',
      image: product['image'] ?? product['images']?.first ?? '',
      price: (product['price'] ?? 0).toDouble(),
      quantity: 1,
    );

    _showAddToCartOptions(product['name'] ?? '', (product['price'] ?? 0).toDouble());
  }

  void _showAddToCartOptions(String name, double price) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.shopping_bag_rounded, color: AppColors.success, size: 32),
            ),
            const SizedBox(height: 16),
            Text('أضيف للسلة بنجاح!', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(name, style: GoogleFonts.cairo(color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () { Navigator.pop(context); Navigator.pushNamed(context, '/cart'); },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text('إتمام الطلب', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text('متابعة التسوق', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ActiveFilterBar extends StatelessWidget {
  final int subcategoryId;
  final int tagId;
  final VoidCallback onClear;

  const _ActiveFilterBar({
    required this.subcategoryId,
    required this.tagId,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final tags = context
        .read<ProductTagsProvider>()
        .getTagsForSubcategory(subcategoryId);
    final tag = tags.where((t) => t.id == tagId).firstOrNull;
    if (tag == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.primaryGhost,
      child: Row(
        children: [
          const Icon(Icons.filter_list_rounded, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            'تصنيف: ${tag.name}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close_rounded, size: 12, color: Colors.white),
                  SizedBox(width: 3),
                  Text(
                    'مسح',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
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
