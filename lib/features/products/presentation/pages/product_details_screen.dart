import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/services/api_service.dart';
import 'package:auto_lube/core/helpers/auth_helper.dart';
import 'package:auto_lube/providers/cart_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:auto_lube/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:auto_lube/core/services/rating_service.dart';
import 'package:auto_lube/core/services/live_update_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final String? heroTag;
  const ProductDetailsScreen({super.key, required this.productId, this.heroTag});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;

  bool _isFavoriteLoading = false;
  int selectedImageIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic>? _product;
  String _error = '';
  List<dynamic> _relatedProducts = [];
  bool _isRelatedLoading = false;

  late bool hasDiscount;
  late String discount;
  StreamSubscription? _stockSubscription;

  @override
  void initState() {
    super.initState();
    _loadProduct();
    _stockSubscription = LiveUpdateService.stockUpdates.listen((data) {
      if (!mounted || _product == null) return;
      final eventProductId = data['product_id']?.toString();
      if (eventProductId == widget.productId) {
        final newQty = data['new_qty'] ?? data['stock_quantity'] ?? 0;
        final bool isAvail = data['is_available'] ?? (newQty > 0);
        final String stockStatus = data['stock_status'] ?? (newQty > 0 ? "in_stock" : "out_of_stock");
        
        setState(() {
          _product!['stock_quantity'] = newQty;
          _product!['stock'] = newQty;
          _product!['quantity'] = newQty;
          _product!['is_available'] = isAvail;
          _product!['in_stock'] = isAvail ? 1 : 0;
          _product!['stock_status'] = stockStatus;
          _initDiscount();
        });
      }
    });
  }

  @override
  void dispose() {
    _stockSubscription?.cancel();
    super.dispose();
  }



  Future<void> _loadProduct() async {
    print('Loading product with ID: ${widget.productId}');

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      print('Calling ApiService.getProduct...');
      final product = await ApiService.getProduct(widget.productId);
      print('Got product: $product');

      if (product != null) {
        print('Product name: ${product['name']}');
        print('Product price: ${product['price']}');
        setState(() {
          _product = product;
          _isLoading = false;
          _initDiscount();
        });
        print('State updated successfully');
        _loadRelatedProducts();
      } else {
        print('Product is null!');
        setState(() {
          _error = 'لم يتم العثور على المنتج';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error loading product: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _error = 'خطأ في تحميل المنتج: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRelatedProducts() async {
    if (_product == null) return;
    setState(() => _isRelatedLoading = true);
    try {
      final categoryId = _product!['category_id']?.toString();
      if (categoryId != null) {
        final products = await ApiService.getProducts(categoryId: categoryId);
        if (mounted) {
          setState(() {
            // Filter out current product
            _relatedProducts = products
                .where((p) => p['id']?.toString() != widget.productId)
                .toList();
            _isRelatedLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isRelatedLoading = false);
      }
    } catch (e) {
      print('Error loading related products: $e');
      if (mounted) setState(() => _isRelatedLoading = false);
    }
  }

  void _showWriteReviewDialog() {
    int selectedRating = 5;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'اكتب تقييمك للمنتج',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starVal = index + 1;
                      return IconButton(
                        icon: Icon(
                          selectedRating >= starVal
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFFFCC00),
                          size: 36,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            selectedRating = starVal;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    style: GoogleFonts.cairo(fontSize: 14, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'اكتب رأيك بالتفصيل هنا...',
                      hintStyle: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setDialogState(() {
                                isSubmitting = true;
                              });

                              final prodId = int.tryParse(widget.productId) ?? 0;
                              final res = await RatingService.submitRating(
                                productId: prodId,
                                rating: selectedRating,
                                comment: commentController.text.trim(),
                              );

                              setDialogState(() {
                                isSubmitting = false;
                              });

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      res['message'],
                                      style: GoogleFonts.cairo(),
                                    ),
                                    backgroundColor: res['success'] == true
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                );
                                if (res['success'] == true) {
                                  _loadProduct();
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'إرسال التقييم',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _initDiscount() {
    if (_product == null) return;
    final price = (_product!['price'] ?? 0).toDouble();
    final oldPrice = (_product!['old_price'] ?? 0).toDouble();
    hasDiscount = oldPrice > 0 && oldPrice > price;
    discount = hasDiscount
        ? '-${((oldPrice - price) / oldPrice * 100).round()}%'
        : '';
  }

  List<String> get productImages {
    if (_product == null) return [];

    // Handle images array
    if (_product!['images'] != null && _product!['images'] is List) {
      final images = List<String>.from(_product!['images']);
      if (images.isNotEmpty) return images;
    }

    // Handle single image
    if (_product!['image'] != null &&
        _product!['image'].toString().isNotEmpty) {
      return [_product!['image'].toString()];
    }

    // Return empty if no image found
    return [];
  }

  String get productName => _product?['name_ar'] ?? _product?['name'] ?? 'منتج';
  String get productBrand => _product?['brand'] ?? 'ماركة';
  double get productPrice => (_product?['price'] ?? 0).toDouble();
  double get productOldPrice => (_product?['old_price'] ?? 0).toDouble();
  String get productDescription => _product?['description_ar'] ?? _product?['description'] ?? '';
  bool get productInStock {
    final avail = _product?['is_available'];
    if (avail is bool) return avail;
    if (avail is num) return avail == 1;

    final inStock = _product?['in_stock'];
    if (inStock is bool) return inStock;
    if (inStock is num) return inStock == 1;

    final qty = _product?['quantity'] ?? _product?['stock_quantity'] ?? _product?['stock'];
    if (qty is num) return qty > 0;

    return false;
  }
  int get productRating => (_product?['rating'] ?? 0).toInt();
  int get productReviewsCount => (_product?['reviews_count'] ?? 0).toInt();
  String get productCategory => _product?['category_name'] ?? '';

  // Compatibility getter for product (used in some places)
  Map<String, dynamic> get product => _product ?? {};

  // Get features list
  List<String> get productFeatures {
    if (_product == null) return [];
    if (_product!['features'] is List) {
      return List<String>.from(_product!['features']);
    }
    return [];
  }

  // Get specifications map
  Map<String, String> get productSpecifications {
    if (_product == null) return {};
    if (_product!['specifications'] is Map) {
      return Map<String, String>.from(_product!['specifications']);
    }
    return {};
  }

  void _incrementQuantity() {
    HapticFeedback.lightImpact();
    setState(() {
      quantity++;
    });
  }

  void _decrementQuantity() {
    if (quantity > 1) {
      HapticFeedback.lightImpact();
      setState(() {
        quantity--;
      });
    }
  }

  /// Toggle favorite status - calls API via Provider
  Future<void> _toggleFavorite() async {
    // Check if user is logged in first
    final isLoggedIn = await AuthHelper.checkAuthAndProceed(context);
    if (!isLoggedIn || !mounted) return;

    if (_product == null) return;

    // Show loading feedback
    HapticFeedback.mediumImpact();
    setState(() {
      _isFavoriteLoading = true;
    });

    final provider = Provider.of<FavoritesProvider>(context, listen: false);
    final isFav = provider.isFavorite(widget.productId);
    
    final success = await provider.toggleFavorite(_product!);

    setState(() {
      _isFavoriteLoading = false;
    });

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
          content: Text(
            'حدث خطأ، يرجى المحاولة مرة أخرى',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _addToCart() async {
    if (_product == null) return;

    // Check if user is logged in first
    final isLoggedIn = await AuthHelper.checkAuthAndProceed(context);
    if (!isLoggedIn || !mounted) return;

    // Add product to CartProvider
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(
      productId: widget.productId,
      name: productName,
      brand: productBrand,
      image: productImages.isNotEmpty ? productImages[0] : '',
      price: productPrice,
      oldPrice: productOldPrice > 0 ? productOldPrice : null,
      quantity: quantity,
    );

    // Show BottomSheet with options
    _showAddToCartOptions();
  }

  void _showAddToCartOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Success icon
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

            // Title
            Text(
              'تمت إضافة المنتج للسلة',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Product name
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

            // Price
            Text(
              '${productPrice.toInt() * quantity} د.ع',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 28),

            // Button 1: إتمام الطلب
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close bottom sheet
                  Navigator.pushNamed(context, '/cart'); // Go to cart
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

            // Button 2: متابعة التسوق
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context); // Close bottom sheet
                  Navigator.pop(context); // Go back to previous page
                },
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

  @override
  Widget build(BuildContext context) {
    // Show loading or error state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'جاري تحميل المنتج...',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'عذراً، حدث خطأ',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _loadProduct,
                  icon: const Icon(Icons.refresh),
                  label: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: BackButton(
              onPressed: () => Navigator.of(context).pop(),
              color: AppColors.textPrimary,
            ),
            actions: [
              Consumer<FavoritesProvider>(
                builder: (context, provider, child) {
                  final isFav = provider.isFavorite(widget.productId);
                  return IconButton(
                    onPressed: _isFavoriteLoading ? null : _toggleFavorite,
                    icon: _isFavoriteLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.favorite,
                            ),
                          )
                        : Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                            color: isFav ? AppColors.favorite : AppColors.textPrimary,
                            size: 22,
                          ),
                  );
                },
              ).animate().scale(delay: 200.ms),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share_rounded, color: AppColors.textPrimary, size: 22),
              ).animate().scale(delay: 300.ms),
              const SizedBox(width: 8),
            ],
            expandedHeight: 400,
            collapsedHeight: 60,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1,
              titlePadding: EdgeInsets.zero,
              background: _buildProductImage(),
            ),
          ),
          SliverToBoxAdapter(child: _buildProductInfo()),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildProductImage() {
    final images = productImages;
    final productId = widget.productId;
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      child: Stack(
        children: [
          // Main Image PageView
          PageView.builder(
            onPageChanged: (index) => setState(() => selectedImageIndex = index),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final child = AppNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                errorWidget: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textTertiary,
                ),
              );

              // Only wrap the first image in Hero for smooth transition from card
              if (index == 0) {
                return Hero(
                  tag: widget.heroTag ?? 'product_image_$productId',
                  child: child,
                );
              }
              return child;
            },
          ),
          
          // Minimalist Badges
          if (hasDiscount || productInStock)
            Positioned(
              top: 110,
              right: 20,
              left: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (hasDiscount) _buildDiscountBadge(),
                  if (productInStock) _buildStockBadge(),
                ],
              ),
            ),

          // Refined Image Indicators
          if (images.length > 1)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: _buildImageIndicators(images),
            ),
        ],
      ),
    );
  }


  Widget _buildDiscountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.error, Color(0xFFFF7043)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        discount,
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStockBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.95),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'متوفر',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageIndicators(List<String> images) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: images.asMap().entries.map((entry) {
            final isSelected = selectedImageIndex == entry.key;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isSelected ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textTertiary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand & Category Row
          Row(
            children: [
              _buildBrandBadge(),
              const SizedBox(width: 8),
              _buildCategoryBadge(),
            ],
          ),
          const SizedBox(height: 16),

          // Product Name
          Text(
            productName,
            style: GoogleFonts.cairo(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
          
          const SizedBox(height: 24),

          // Price Section - Minimalist
          _buildPriceSection(),
          
          const SizedBox(height: 32),
          _buildDivider(),
          const SizedBox(height: 32),

          _buildSectionHeader('الوصف'),
          const SizedBox(height: 12),
          _buildDescriptionSection(),
          
          const SizedBox(height: 32),
          _buildSectionHeader('المميزات'),
          const SizedBox(height: 12),
          _buildFeaturesSection(),
          
          const SizedBox(height: 32),
          _buildSectionHeader('المواصفات'),
          const SizedBox(height: 12),
          _buildSpecificationsSection(),

          const SizedBox(height: 32),
          _buildRelatedProductsSection(),
          
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildBrandBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        productBrand,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        productCategory,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    if (productDescription.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        child: Text(
          'لا يوجد وصف متاح',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        productDescription,
        style: GoogleFonts.cairo(
          fontSize: 15,
          color: AppColors.textPrimary,
          height: 1.8,
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 400));
  }

  Widget _buildTagsRow() {
    return Row(
      children: [
        // Brand Tag
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    productBrand,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Category Tag
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category, color: AppColors.secondary, size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    productCategory,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: const Duration(milliseconds: 300));
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildCategoryTag(String text, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: accentColor,
        ),
      ),
    );
  }

  Widget _buildRatingRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large Rating Display
              Column(
                children: [
                  Text(
                    '$productRating',
                    style: GoogleFonts.cairo(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStarRating(productRating.toDouble(), size: 18),
                  const SizedBox(height: 6),
                  Text(
                    '$productReviewsCount تقييم',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Rating Bars
              Expanded(
                child: Column(
                  children: List.generate(5, (index) {
                    final star = 5 - index;
                    // Mock distribution - in real app, get from API
                    final percentage = _getRatingPercentage(star);
                    return _buildRatingBar(star, percentage);
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Write Review Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _showWriteReviewDialog,
              icon: const Icon(Icons.edit, size: 18),
              label: Text(
                'اكتب تقييماً',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 400),
      delay: const Duration(milliseconds: 100),
    );
  }

  // Get rating percentage (mock data - replaced with 0 for now as per previous cleanup)
  double _getRatingPercentage(int star) {
    // In real app, this should come from API. For now, returning 0 to avoid fake data
    return 0;
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            '$stars',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, color: AppColors.ratingStar, size: 12),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.ratingStar, Color(0xFFFFD54F)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 35,
            child: Text(
              '${(percentage * 100).toInt()}%',
              textAlign: TextAlign.end,
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

  Widget _buildStarRating(double rating, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        IconData icon;
        Color color;

        if (rating >= starValue) {
          icon = Icons.star;
          color = AppColors.ratingStar;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half;
          color = AppColors.ratingStar;
        } else {
          icon = Icons.star_border;
          color = AppColors.textTertiary;
        }

        return Icon(icon, size: size, color: color);
      }),
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ratingStar.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: AppColors.ratingStar, size: 16),
          const SizedBox(width: 6),
          Text(
            '$productRating',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${productPrice.toInt()}',
              style: GoogleFonts.cairo(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'د.ع',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            if (hasDiscount)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.errorLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'وفر ${(productOldPrice - productPrice).toInt()} د.ع',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ),
          ],
        ),
        if (hasDiscount) ...[
          const SizedBox(height: 8),
          Text(
            '${productOldPrice.toInt()} د.ع',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: AppColors.textTertiary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.divider.withOpacity(0.5),
            AppColors.divider.withOpacity(0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    final features = productFeatures;
    if (features.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        child: Text(
          'لا توجد مميزات متاحة',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: features.asMap().entries.map((entry) {
          final index = entry.key;
          final feature = entry.value;
          final colors = [
            AppColors.primary,
            AppColors.success,
            AppColors.secondary,
            AppColors.info,
            AppColors.tertiary,
          ];
          final color = colors[index % colors.length];

          return Container(
            margin: EdgeInsets.only(
              bottom: index < features.length - 1 ? 16 : 0,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    feature,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 400));
  }

  Widget _buildSpecificationsSection() {
    final specs = productSpecifications;
    if (specs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        child: Text(
          'لا توجد مواصفات متاحة',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: specs.entries.map((entry) {
          return Container(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSpecIcon(entry.key),
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.key,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 400));
  }

  IconData _getSpecIcon(String key) {
    final keyLower = key.toLowerCase();
    if (keyLower.contains('وزن') || keyLower.contains('weight')) {
      return Icons.scale;
    }
    if (keyLower.contains('حجم') || keyLower.contains('size')) {
      return Icons.straighten;
    }
    if (keyLower.contains('لون') || keyLower.contains('color')) {
      return Icons.palette;
    }
    if (keyLower.contains('ضمان') || keyLower.contains('warranty')) {
      return Icons.verified_user;
    }
    if (keyLower.contains('صنع') || keyLower.contains('made')) {
      return Icons.factory;
    }
    if (keyLower.contains('طراز') || keyLower.contains('model')) {
      return Icons.devices;
    }
    return Icons.info_outline;
  }

  Widget _buildShippingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('معلومات الشحن'),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildShippingRow(
                Icons.store,
                'التوفر في المخزن',
                productInStock ? 'متوفر' : 'غير متوفر',
                productInStock ? AppColors.success : AppColors.error,
              ),
              const SizedBox(height: 16),
              _buildShippingRow(
                Icons.local_shipping,
                'وقت الشحن',
                '2-4 أيام عمل',
                AppColors.primary,
              ),
              const SizedBox(height: 16),
              _buildShippingRow(
                Icons.location_on,
                'الشحن إلى',
                'جميع محافظات العراق',
                AppColors.secondary,
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: const Duration(milliseconds: 400));
  }

  Widget _buildShippingRow(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedProductsSection() {
    final related = _relatedProducts;
    if (related.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDivider(),
        const SizedBox(height: 24),
        _buildSectionTitle('منتجات مشابهة'),
        const SizedBox(height: 16),
        SizedBox(
          height: 270,
          child: _isRelatedLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: related.length,
                  itemBuilder: (context, index) {
                    final item = related[index];
                    return _buildRelatedProductCard(item, index);
                  },
                ),
        ),
      ],
    ).animate().fadeIn(duration: const Duration(milliseconds: 400));
  }

  Widget _buildRelatedProductCard(dynamic item, int index) {
    // Safely parse double price and oldPrice
    final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
    final oldPrice = item['old_price'] != null ? double.tryParse(item['old_price'].toString()) : null;
    final hasDiscount = oldPrice != null && oldPrice > price;

    final id = item['id']?.toString() ?? '';
    final brand = (item['brand_ar'] ?? item['brand'] ?? '').toString();
    final name = (item['name_ar'] ?? item['name'] ?? '').toString();

    // Safely fetch imageUrl
    String imageUrl = '';
    if (item['images'] != null && (item['images'] as List).isNotEmpty) {
      imageUrl = (item['images'] as List).first.toString();
    } else {
      imageUrl = item['image_url'] ?? item['image'] ?? '';
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailsScreen(productId: id),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border.withOpacity(0.6),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  color: AppColors.surfaceBlue,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: AppNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: const Icon(
                      Icons.image_not_supported,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (brand.isNotEmpty)
                      Text(
                        brand,
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasDiscount)
                              Text(
                                '${oldPrice.toInt()} د.ع',
                                style: GoogleFonts.cairo(
                                  fontSize: 9,
                                  color: AppColors.textTertiary,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              '${price.toInt()} د.ع',
                              style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            // Add related product directly to cart
                            final cartProvider = context.read<CartProvider>();
                            cartProvider.addItem(
                              productId: id,
                              name: name,
                              price: price,
                              image: imageUrl,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تمت إضافة $name إلى السلة',
                                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: AppColors.success,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
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
      ),
    )
    .animate()
    .fadeIn(
      duration: const Duration(milliseconds: 400),
      delay: Duration(milliseconds: 50 * index),
    )
    .slideX(
      begin: 0.1,
      duration: const Duration(milliseconds: 400),
      delay: Duration(milliseconds: 50 * index),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            _buildQuantitySelector(),
            const SizedBox(width: 16),
            Expanded(child: _buildAddToCartButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _decrementQuantity,
            icon: Icon(
              Icons.remove_rounded,
              size: 20,
              color: quantity > 1 ? AppColors.textPrimary : AppColors.textTertiary,
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: _incrementQuantity,
            icon: const Icon(
              Icons.add_rounded,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _addToCart,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'أضف للسلة',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
