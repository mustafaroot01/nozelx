import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:auto_lube/core/utils/image_url_helper.dart';
import 'package:auto_lube/models/product_tag_model.dart';
import 'package:auto_lube/providers/product_tags_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductTagsRow extends StatefulWidget {
  final int subcategoryId;
  final ValueChanged<int?>? onTagSelected; // null = كل المنتجات

  const ProductTagsRow({
    super.key,
    required this.subcategoryId,
    this.onTagSelected,
  });

  @override
  State<ProductTagsRow> createState() => _ProductTagsRowState();
}

class _ProductTagsRowState extends State<ProductTagsRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterCtrl;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    // جلب التصنيفات عند أول ظهور
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ProductTagsProvider>()
          .fetchTags(widget.subcategoryId)
          .then((_) {
        if (mounted) _enterCtrl.forward();
      });
    });
  }

  @override
  void didUpdateWidget(ProductTagsRow old) {
    super.didUpdateWidget(old);
    // إذا تغير القسم الثانوي أعد التحميل
    if (old.subcategoryId != widget.subcategoryId) {
      _enterCtrl.reset();
      context
          .read<ProductTagsProvider>()
          .fetchTags(widget.subcategoryId)
          .then((_) {
        if (mounted) _enterCtrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductTagsProvider>(
      builder: (ctx, provider, _) {
        final tags = provider.getTagsForSubcategory(widget.subcategoryId);
        final selectedId = provider.getSelectedTag(widget.subcategoryId);
        final subTags = provider.getSubTagsForSelected(widget.subcategoryId);
        final selectedSubId = provider.getSelectedSubTag(widget.subcategoryId);

        // لا تظهر الصف إذا لا توجد تصنيفات
        if (!provider.isLoading && tags.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── قائمة التصنيفات الأفقية (الرئيسية الدائرية) ──────────
              SizedBox(
                height: 120, // ارتفاع ثابت مع هامش أمان إضافي لضمان عدم حدوث تجاوز بعد تكبير الأيقونة
                child: provider.isLoading
                    ? _buildSkeletonRow()
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        itemCount: tags.length,
                        itemBuilder: (ctx, i) {
                          final tag = tags[i];
                          return _TagCircleItem(
                            key: ValueKey(tag.id),
                            label: tag.name,
                            imageUrl: tag.imageUrl,
                            emoji: tag.iconEmoji,
                            isSelected: selectedId == tag.id,
                            index: i,
                            enterController: _enterCtrl,
                            onTap: () {
                               provider.selectTag(widget.subcategoryId, tag.id);
                               widget.onTagSelected?.call(
                                 selectedId == tag.id ? null : tag.id,
                               );
                            },
                          );
                        },
                      ),
              ),

              // ── قائمة التصنيفات الفرعية المساعدة (المستطيلة) ──────────
              if (selectedId != null && subTags.isNotEmpty)
                _buildSubTagsRectRow(provider, subTags, selectedSubId),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubTagsRectRow(
      ProductTagsProvider provider, List<ProductTagModel> subTags, int? selectedSubId) {
    return Container(
      height: 48,
      padding: const EdgeInsets.only(bottom: 12, top: 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: subTags.length,
        itemBuilder: (ctx, i) {
          final tag = subTags[i];
          final isSelected = selectedSubId == tag.id;

          return GestureDetector(
            onTap: () {
              provider.selectSubTag(widget.subcategoryId, tag.id);
              final activeSubId = isSelected ? null : tag.id;
              // إذا ألغينا اختيار الفرعي، نرجع لتصفية الأب
              widget.onTagSelected?.call(activeSubId ?? provider.getSelectedTag(widget.subcategoryId));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.primaryGhost,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.primaryPale,
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  tag.name,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.08, end: 0);
  }

  Widget _buildSkeletonRow() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: 6,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Column(
          children: [
            // دائرة skeleton
            Shimmer.fromColors(
              baseColor: AppColors.primaryPale,
              highlightColor: AppColors.primaryGhost,
              child: Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 5),
            // نص skeleton
            Shimmer.fromColors(
              baseColor: AppColors.primaryPale,
              highlightColor: AppColors.primaryGhost,
              child: Container(
                width: 40,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagCircleItem extends StatefulWidget {
  final String label;
  final String? imageUrl;
  final String? emoji;
  final bool isSelected;
  final int index;
  final AnimationController enterController;
  final VoidCallback onTap;

  const _TagCircleItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.index,
    required this.enterController,
    required this.onTap,
    this.imageUrl,
    this.emoji,
  });

  @override
  State<_TagCircleItem> createState() => _TagCircleItemState();
}

class _TagCircleItemState extends State<_TagCircleItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressAnim;

  // Staggered enter animation
  late Animation<double> _enterSlide;
  late Animation<double> _enterFade;

  @override
  void initState() {
    super.initState();

    // انيميشن الضغط
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeIn),
    );

    // Staggered enter — كل دائرة تتأخر قليلاً
    final delay = (widget.index * 0.06).clamp(0.0, 0.6);
    final start = delay;
    final end = (delay + 0.4).clamp(0.0, 1.0);

    _enterSlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: widget.enterController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
    _enterFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: widget.enterController,
        curve: Interval(start, end, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.enterController,
        _pressCtrl,
      ]),
      builder: (ctx, _) => Transform.translate(
        offset: Offset(0, _enterSlide.value),
        child: FadeTransition(
          opacity: _enterFade,
          child: ScaleTransition(
            scale: _pressAnim,
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 2),
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── الدائرة ─────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected
                      ? AppColors.primary
                      : Colors.white,
                  border: Border.all(
                    color: widget.isSelected
                        ? AppColors.primary
                        : Colors.white,
                    width: widget.isSelected ? 3.0 : 1.5,
                  ),
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: ClipOval(
                  child: _buildCircleContent(),
                ),
              ),

              const SizedBox(height: 6),

              // ── الاسم ───────────────────────────
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w600,
                  color: widget.isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleContent() {
    // ① إذا يوجد URL صورة
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return AppNetworkImage(
        imageUrl: ImageUrlHelper.resolve(widget.imageUrl) ?? '',
        width: 62,
        height: 62,
        fit: BoxFit.cover,
      );
    }

    // ② إذا يوجد emoji
    if (widget.emoji != null && widget.emoji!.isNotEmpty) {
      return Center(
        child: Text(
          widget.emoji!,
          style: TextStyle(
            fontSize: widget.isSelected ? 22 : 20,
          ),
        ),
      );
    }

    // ③ fallback — حرف أول من الاسم
    return Center(
      child: Text(
        widget.label.isNotEmpty ? widget.label[0] : '?',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: widget.isSelected ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }
}
