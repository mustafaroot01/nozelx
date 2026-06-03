import 'package:flutter/material.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/theme/dimensions.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:auto_lube/features/products/presentation/pages/products_list_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:auto_lube/core/services/category_service.dart';
import 'package:auto_lube/core/data/categories_data.dart';

class SubCategoriesScreen extends StatefulWidget {
  final String parentCategoryId;
  final String parentCategoryName;

  const SubCategoriesScreen({
    super.key,
    required this.parentCategoryId,
    required this.parentCategoryName,
  });

  @override
  State<SubCategoriesScreen> createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> {
  bool _isLoading = true;
  List<Category> _subCategories = [];

  @override
  void initState() {
    super.initState();
    _loadSubCategories();
  }

  Future<void> _loadSubCategories() async {
    setState(() => _isLoading = true);
    try {
      final subs = await CategoryService.getSubCategories(widget.parentCategoryId);
      if (mounted) {
        setState(() {
          _subCategories = subs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.parentCategoryName,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _subCategories.isEmpty
              ? _buildEmptyState()
              : _buildSubCategoriesGrid(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'لا توجد أقسام فرعية حالياً',
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoriesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.defaultPadding,
        mainAxisSpacing: AppDimensions.defaultPadding,
        childAspectRatio: 0.85,
      ),
      itemCount: _subCategories.length,
      itemBuilder: (context, index) {
        final category = _subCategories[index];
        final name = category.name;
        final imageUrl = category.imageUrl ?? '';
        
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductsListScreen(
                  categoryFilter: name,
                  categoryId: category.id,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.defaultBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.smallPadding),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.mediumBorderRadius),
                      child: imageUrl.isNotEmpty
                          ? AppNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.contain,
                              errorWidget: const Center(
                                child: Icon(Icons.category, color: Colors.grey, size: 40),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.category, color: Colors.grey, size: 40),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(AppDimensions.defaultBorderRadius),
                        bottomRight: Radius.circular(AppDimensions.defaultBorderRadius),
                      ),
                    ),
                    child: Text(
                      name,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
        );
      },
    );
  }
}
