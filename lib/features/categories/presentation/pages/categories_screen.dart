import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/data/categories_data.dart';
import 'package:auto_lube/core/services/category_service.dart';
import 'package:auto_lube/features/products/presentation/pages/products_list_screen.dart';
import 'package:auto_lube/features/categories/presentation/widgets/category_banner_widget.dart';
import 'package:auto_lube/features/oil/presentation/pages/oil_companies_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with TickerProviderStateMixin {
  List<Category> _categories = [];
  bool _isLoading = true;
  Category? _selectedCategory;
  
  final Map<String, List<Category>> _subCategoriesCache = {};
  bool _isLoadingSubs = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final cats = await CategoryService.getCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _isLoading = false;
          if (_categories.isNotEmpty) {
            _selectedCategory = _categories.first;
            _loadSubCategoriesFor(_selectedCategory!);
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _categories = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSubCategoriesFor(Category category) async {
    if (_subCategoriesCache.containsKey(category.id)) return;
    if (!category.hasSubCategories) return;

    setState(() => _isLoadingSubs = true);
    final subs = await CategoryService.getSubCategories(category.id);
    if (mounted) {
      setState(() {
        _subCategoriesCache[category.id] = subs;
        _isLoadingSubs = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الأقسام',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsListScreen(autoFocusSearch: true)));
            },
          ),
          const SizedBox(width: 8),
        ],
        leading: IconButton(
          icon: const Icon(Icons.support_agent_rounded, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.divider.withOpacity(0.2),
            height: 1,
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _categories.isEmpty
              ? _buildEmptyState()
              : Row(
                  children: [
                    _buildMainContent(),
                    _buildSidebar(),
                  ],
                ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 95,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory?.id == cat.id;

          return GestureDetector(
            onTap: () {
              if (_selectedCategory?.id != cat.id) {
                setState(() {
                  _selectedCategory = cat;
                  if (cat.hasSubCategories) {
                    _loadSubCategoriesFor(cat);
                  }
                });
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected 
                    ? cat.color.withOpacity(0.1) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    Positioned(
                      right: -8,
                      top: 10,
                      bottom: 10,
                      child: Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: cat.color,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 44,
                        height: 44,
                        padding: cat.imageUrl != null && cat.imageUrl!.isNotEmpty
                            ? const EdgeInsets.all(4)
                            : const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          shape: BoxShape.circle,
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: cat.color.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ] : [],
                        ),
                        child: cat.imageUrl != null && cat.imageUrl!.isNotEmpty
                            ? AppNetworkImage(
                                imageUrl: cat.imageUrl!,
                                fit: BoxFit.contain,
                                borderRadius: 20,
                                errorWidget: Icon(
                                  cat.icon,
                                  color: isSelected ? cat.color : AppColors.textSecondary,
                                  size: 20,
                                ),
                              )
                            : Icon(
                                cat.icon,
                                color: isSelected ? cat.color : AppColors.textSecondary,
                                size: 24,
                              ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? cat.color : AppColors.textSecondary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent() {
    return Expanded(
      child: Container(
        color: AppColors.background,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _selectedCategory == null
              ? const SizedBox.shrink()
              : KeyedSubtree(
                  key: ValueKey(_selectedCategory!.id),
                  child: _buildCategoryDetails(_selectedCategory!),
                ),
        ),
      ),
    );
  }

  Widget _buildCategoryDetails(Category category) {
    final subSections = _subCategoriesCache[category.id] ?? [];

    // Separate sub-categories into those with children (sections) and those without (grid items)
    final sections = subSections.where((s) => s.subCategories != null && s.subCategories!.isNotEmpty).toList();
    final directItems = subSections.where((s) => s.subCategories == null || s.subCategories!.isEmpty).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        CategoryBannerWidget(category: category),
        const SizedBox(height: 24),
        
        if (_isLoadingSubs)
          _buildSubsLoadingState()
        else if (subSections.isNotEmpty) ...[
          // Show direct items in a grid first
          if (directItems.isNotEmpty) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: directItems.length,
              itemBuilder: (ctx, i) {
                final item = directItems[i];
                // Convert Category to SubCategory-like display
                return _buildCategoryGridItem(SubCategory(
                  id: item.id,
                  name: item.name,
                  parentId: category.id,
                  productCount: item.productCount,
                  icon: item.icon,
                  imageUrl: item.imageUrl,
                ));
              },
            ),
            const SizedBox(height: 24),
          ],

          // Show sections with their children
          ...sections.map((section) {
            final children = section.subCategories!;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      section.name,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ProductsListScreen(categoryId: section.id, categoryFilter: section.name),
                        ));
                      },
                      child: Text(
                        'عرض الكل',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: category.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: children.length,
                  itemBuilder: (ctx, i) {
                    final item = children[i];
                    return _buildCategoryGridItem(item);
                  },
                ),
                const SizedBox(height: 32),
              ],
            );
          }),
        ] else
          _buildFallbackMessage(category),
      ],
    );
  }

  Widget _buildCategoryGridItem(SubCategory sub) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ProductsListScreen(categoryId: sub.id, categoryFilter: sub.name),
        ));
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Center(
                child: sub.imageUrl != null
                    ? AppNetworkImage(
                        imageUrl: sub.imageUrl!,
                        fit: BoxFit.contain,
                        placeholder: _buildImageShimmer(),
                        errorWidget: const Icon(Icons.broken_image_outlined, color: AppColors.textTertiary, size: 28),
                      )
                    : Icon(
                        sub.icon ?? Icons.category_rounded, 
                        color: AppColors.textTertiary, 
                        size: 28
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sub.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageShimmer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildSubsLoadingState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_selectedCategory?.color ?? AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildFallbackMessage(Category category) {
     final isOil = category.name.contains('زيت') || category.name.contains('زيوت');
     return Center(
       child: Padding(
         padding: const EdgeInsets.only(top: 60),
         child: Column(
           children: [
             Container(
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(
                 color: category.color.withOpacity(0.05),
                 shape: BoxShape.circle,
               ),
               child: Icon(isOil ? Icons.oil_barrel_outlined : Icons.inventory_2_outlined, size: 40, color: category.color.withOpacity(0.5)),
             ),
             const SizedBox(height: 16),
             Text(
               isOil ? 'تصفح زيوت المحركات حسب الشركة واللزوجة' : 'قريباً.. تصنيفات ${category.name}',
               style: GoogleFonts.cairo(
                 fontWeight: FontWeight.bold,
                 color: AppColors.textSecondary
               ),
               textAlign: TextAlign.center,
             ),
             if (isOil) ...[
               const SizedBox(height: 24),
               ElevatedButton.icon(
                 onPressed: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (_) => const OilCompaniesScreen()),
                   );
                 },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: category.color,
                   foregroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 ),
                 icon: const Icon(Icons.search),
                 label: Text(
                   'تصفح الشركات واللزوجة',
                   style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                 ),
               ),
             ],
           ],
         ),
       ),
     );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.category_outlined, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'لا توجد تصنيفات حالياً',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
