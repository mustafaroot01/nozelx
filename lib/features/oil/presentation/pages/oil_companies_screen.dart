import 'package:flutter/material.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/data/oil_data.dart';
import 'package:auto_lube/core/components/product_card.dart';
import 'package:auto_lube/core/services/api_service.dart';
import 'package:auto_lube/core/helpers/auth_helper.dart';
import 'package:auto_lube/providers/cart_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:auto_lube/features/products/presentation/pages/product_details_screen.dart';
import 'package:auto_lube/features/favorites/presentation/providers/favorites_provider.dart';

class OilCompaniesScreen extends StatefulWidget {
  const OilCompaniesScreen({super.key});

  @override
  State<OilCompaniesScreen> createState() => _OilCompaniesScreenState();
}

class _OilCompaniesScreenState extends State<OilCompaniesScreen>
    with TickerProviderStateMixin {
  String? selectedCompany;
  String? selectedViscosity;
  bool _isLoading = true;
  List<dynamic> _products = [];
  List<OilCompany> _dynamicOilCompanies = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await ApiService.getProducts();
      if (mounted) {
        setState(() {
          _products = products
              .where(
                (p) => p['category_name']?.toString().contains('زيت') ?? false,
              )
              .toList();
          _parseOilCompaniesAndViscosities();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _parseOilCompaniesAndViscosities() {
    final Map<String, Set<String>> companyViscositiesMap = {};

    for (var p in _products) {
      final name = p['name']?.toString() ?? '';
      String brand = p['brand']?.toString() ?? '';
      if (brand.isEmpty) {
        brand = _extractBrandFromName(name);
      }
      if (brand.isEmpty) continue;

      final regExp = RegExp(r'\b\d+W-\d+\b', caseSensitive: false);
      final match = regExp.firstMatch(name);
      final viscosity = match != null ? match.group(0) : null;

      if (!companyViscositiesMap.containsKey(brand)) {
        companyViscositiesMap[brand] = {};
      }
      if (viscosity != null) {
        companyViscositiesMap[brand]!.add(viscosity);
      }
    }

    final List<OilCompany> parsedCompanies = [];
    int companyIdx = 1;
    companyViscositiesMap.forEach((brand, viscosities) {
      final color = _getCompanyColor(brand);
      final nameEn = _getCompanyEnglishName(brand);
      
      final List<OilViscosity> parsedViscosities = [];
      int viscosityIdx = 1;
      for (var v in viscosities) {
        parsedViscosities.add(
          OilViscosity(
            id: '${companyIdx}_${viscosityIdx}',
            name: v,
            nameEn: v,
            grade: _determineGrade(v),
            icon: Icons.speed,
            description: _determineDescription(v),
          ),
        );
        viscosityIdx++;
      }

      parsedCompanies.add(
        OilCompany(
          id: companyIdx.toString(),
          name: brand,
          nameEn: nameEn,
          logoUrl: '',
          color: color,
          viscosities: parsedViscosities,
        ),
      );
      companyIdx++;
    });

    _dynamicOilCompanies = parsedCompanies;
  }

  String _extractBrandFromName(String name) {
    final knownBrands = [
      "موبيل 1", "موبيل", "كاسترول", "موتول", "يورل", "كيو", "امسويل", 
      "ليكوي مولي", "ليكويمولي", "فرام", "ميجوايرز", "تويوتا", "شل", "توتال"
    ];
    final nameLower = name.toLowerCase();
    for (var brand in knownBrands) {
      if (nameLower.contains(brand.toLowerCase())) {
        return brand;
      }
    }
    final words = name.split(' ');
    if (words.isNotEmpty) {
      final first = words[0];
      if (!['فلتر', 'سائل', 'شامبو', 'منظف', 'زيت'].contains(first)) {
        return first;
      }
      if (words.length > 2) return words[2];
      if (words.length > 1) return words[1];
    }
    return '';
  }

  Color _getCompanyColor(String companyName) {
    final name = companyName.toLowerCase();
    if (name.contains('موبيل') || name.contains('mobil')) {
      return const Color(0xFF0072CE);
    } else if (name.contains('كاسترول') || name.contains('castrol')) {
      return const Color(0xFFE53935);
    } else if (name.contains('موتول') || name.contains('motul')) {
      return const Color(0xFFD32F2F);
    } else if (name.contains('يورل') || name.contains('yurol')) {
      return const Color(0xFF1E3A5C);
    } else if (name.contains('كيو') || name.contains('keo')) {
      return const Color(0xFF1E88E5);
    } else if (name.contains('امسويل') || name.contains('amsoil')) {
      return const Color(0xFFFF6B35);
    } else if (name.contains('ليكويمولي') || name.contains('liqui')) {
      return const Color(0xFF1E88E5);
    }
    return const Color(0xFF1E4DB7);
  }

  String _getCompanyEnglishName(String companyName) {
    final name = companyName.toLowerCase();
    if (name.contains('موبيل') || name.contains('mobil')) return 'MOBIL';
    if (name.contains('كاسترول') || name.contains('castrol')) return 'CASTROL';
    if (name.contains('موتول') || name.contains('motul')) return 'MOTUL';
    if (name.contains('يورل') || name.contains('yurol')) return 'YUROL';
    if (name.contains('كيو') || name.contains('keo')) return 'KEO';
    if (name.contains('امسويل') || name.contains('amsoil')) return 'AMSOIL';
    if (name.contains('ليكويمولي') || name.contains('liqui')) return 'LIQUI MOLY';
    return companyName.toUpperCase();
  }

  String _determineGrade(String viscosity) {
    if (viscosity == '0W-20' || viscosity == '0W-30' || viscosity == '0W-40' || viscosity == '5W-30' || viscosity == '5W-40') {
      return 'Full Synthetic';
    } else if (viscosity == '10W-40') {
      return 'Semi-Synthetic';
    } else if (viscosity == '15W-40' || viscosity == '20W-50') {
      return 'Mineral';
    }
    return 'Premium';
  }

  String _determineDescription(String viscosity) {
    if (viscosity == '0W-20' || viscosity == '0W-30' || viscosity == '0W-40') {
      return 'حماية قصوى في البرد وتوفير وقود';
    } else if (viscosity == '5W-30' || viscosity == '5W-40') {
      return 'توفير وقود وحماية فائقة للمحرك';
    } else if (viscosity == '10W-40') {
      return 'أداء ممتاز للاستخدام العام اليومي';
    } else if (viscosity == '15W-40' || viscosity == '20W-50') {
      return 'مثالي للمحركات القديمة والعمل الشاق';
    }
    return 'زيت محرك متطور عالي الأداء';
  }

  List<dynamic> get filteredProducts {
    var products = _products;
    if (selectedCompany != null) {
      products = products.where((p) {
        final brand = (p['brand'] ?? '').toString().toLowerCase();
        return brand.contains(selectedCompany!.toLowerCase());
      }).toList();
    }
    if (selectedViscosity != null) {
      products = products.where((p) {
        final name = (p['name'] ?? '').toString().toLowerCase();
        return name.contains(selectedViscosity!.toLowerCase());
      }).toList();
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildOilFilters(),
            Expanded(child: _buildProductsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'زيوت المحرك',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${filteredProducts.length} منتج متاح',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOilFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _dynamicOilCompanies.length,
              itemBuilder: (context, index) =>
                  _buildCompanyChip(_dynamicOilCompanies[index]),
            ),
          ),
          if (selectedCompany != null && _dynamicOilCompanies.any((c) => c.name == selectedCompany)) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _dynamicOilCompanies
                    .firstWhere((c) => c.name == selectedCompany)
                    .viscosities
                    .length,
                itemBuilder: (context, index) => _buildViscosityChip(
                  _dynamicOilCompanies
                      .firstWhere((c) => c.name == selectedCompany)
                      .viscosities[index],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompanyChip(OilCompany company) {
    final isSelected = selectedCompany == company.name;
    return GestureDetector(
      onTap: () => _onCompanyTap(company),
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [company.color, company.color.withOpacity(0.8)],
                )
              : null,
          color: isSelected ? null : company.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? company.color
                : company.color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: company.color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : company.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  company.nameEn.substring(
                    0,
                    company.nameEn.length > 3 ? 3 : company.nameEn.length,
                  ),
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : company.color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              company.name,
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViscosityChip(OilViscosity viscosity) {
    final isSelected = selectedViscosity == viscosity.name;
    final company = _dynamicOilCompanies.firstWhere((c) => c.name == selectedCompany);
    return GestureDetector(
      onTap: () => _onViscosityTap(viscosity.name),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [company.color, company.color.withOpacity(0.8)],
                )
              : null,
          color: isSelected ? null : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? company.color : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.speed,
              size: 16,
              color: isSelected ? Colors.white : company.color,
            ),
            const SizedBox(width: 6),
            Text(
              viscosity.name,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCompanyTap(OilCompany company) {
    setState(() {
      if (selectedCompany == company.name) {
        selectedCompany = null;
        selectedViscosity = null;
      } else {
        selectedCompany = company.name;
        selectedViscosity = null;
      }
    });
  }

  void _onViscosityTap(String viscosity) {
    setState(() {
      if (selectedViscosity == viscosity) {
        selectedViscosity = null;
      } else {
        selectedViscosity = viscosity;
      }
    });
  }

  Widget _buildProductsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'لا توجد منتجات',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرب اختيار شركة أخرى',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) =>
          _buildProductCard(filteredProducts[index]),
    );
  }

  Widget _buildProductCard(dynamic product) {
    final inStock = product['in_stock'] == 1 || product['in_stock'] == true || (product['quantity'] != null && product['quantity'] > 0);
    final productId = product['id']?.toString() ?? '';
    
    return Consumer<FavoritesProvider>(
      builder: (context, provider, child) {
        final isFav = provider.isFavorite(productId);
        return ProductCardWidget(
          product: product,
          inStock: inStock,
          isFavorite: isFav,
          formatPrice: (price) =>
              '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} د.ع',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductDetailsScreen(productId: productId),
            ),
          ),
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
    }
  }

  Future<void> _addToCart(dynamic product) async {
    // Check if user is logged in first
    final isLoggedIn = await AuthHelper.checkAuthAndProceed(context);
    if (!isLoggedIn || !mounted) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(
      productId: product['id'].toString(),
      name: product['name'] ?? '',
      brand: product['brand'] ?? '',
      image: product['image'] ?? '',
      price: (product['price'] ?? 0).toDouble(),
      oldPrice: product['old_price'] != null && product['old_price'] > 0
          ? product['old_price'].toDouble()
          : null,
      quantity: 1,
    );
    _showAddToCartOptions(
      product['name'] ?? '',
      (product['price'] ?? 0).toDouble(),
    );
  }

  void _showAddToCartOptions(String productName, double productPrice) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'تمت إضافة المنتج للسلة',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              productName,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              '${productPrice.toInt()} د.ع',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/cart');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'إتمام الطلب',
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_back, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'متابعة التسوق',
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
