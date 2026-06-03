import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/core/utils/currency_formatter.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:auto_lube/core/widgets/shimmer_widget.dart';
import 'package:auto_lube/core/utils/image_url_helper.dart';
import 'package:auto_lube/core/theme/colors.dart';
import '../providers/service_provider.dart';
import '../../data/models/service_model.dart';
import '../../data/services_data.dart';
import 'booking_screen.dart';
import '../widgets/service_details_sheet.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with SingleTickerProviderStateMixin {

  String _selectedCategory = 'الكل';
  late AnimationController _filterCtrl;
  final List<CenterService> _selectedServices = [];

  @override
  void initState() {
    super.initState();
    _filterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServices();
    });
  }

  @override
  void dispose() {
    _filterCtrl.dispose();
    super.dispose();
  }

  void _addServiceToSelection(CenterService service) {
    setState(() {
      if (!_selectedServices.any((s) => s.id == service.id)) {
        _selectedServices.add(service);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تمت إضافة ${service.name}',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1D9E75),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'حجز',
          textColor: Colors.white,
          onPressed: () => _navigateToBooking(service),
        ),
      ),
    );
  }

  void _navigateToBooking(CenterService service) {
    if (!_selectedServices.any((s) => s.id == service.id)) {
      setState(() {
        _selectedServices.add(service);
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingScreen(
          service: service,
          selectedServices: _selectedServices,
        ),
      ),
    );
  }

  void _showBookingOptionsDialog(CenterService service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Indicator
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Icon & Title
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGhost,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'تم تحديد خدمة: ${service.name}',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'هل تريد إتمام حجز هذه الخدمة الآن، أم تريد إضافة المزيد من الخدمات وحجزها معاً؟',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Book Now Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx); // Close option sheet
                          _navigateToBooking(service);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'حجز الآن',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add Another Service Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx); // Close option sheet
                          _addServiceToSelection(service);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'إضافة خدمة أخرى',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [

          // ── SliverAppBar ────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'خدماتنا',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: _CategoryFilterBar(
                selected: _selectedCategory,
                onSelected: (cat) {
                  setState(() => _selectedCategory = cat);
                  HapticFeedback.selectionClick();
                },
              ),
            ),
          ),

          // ── قائمة الخدمات ───────────────────────
          Consumer<ServiceProvider>(
            builder: (ctx, provider, _) {
              if (provider.isLoading) {
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const _ServiceCardSkeleton(),
                      childCount: 4,
                    ),
                  ),
                );
              }

              if (provider.error != null) {
                return SliverFillRemaining(
                  child: _ErrorView(
                    message: provider.error!,
                    onRetry: provider.fetchServices,
                  ),
                );
              }

              final filtered = _selectedCategory == 'الكل'
                  ? provider.services
                  : provider.services
                      .where((s) => s.category == _selectedCategory)
                      .toList();

              if (filtered.isEmpty) {
                return const SliverFillRemaining(
                  child: _EmptyServicesView(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _ServiceCard(
                      key: ValueKey(filtered[i].id),
                      service: filtered[i],
                      index: i,
                      selectedServices: _selectedServices,
                      onAddService: _addServiceToSelection,
                      onBookNow: _showBookingOptionsDialog,
                    ),
                    childCount: filtered.length,
                  ),
                ),
              );
            },
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
      bottomNavigationBar: _selectedServices.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الخدمات المختارة: ${_selectedServices.length}',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${_selectedServices.fold<int>(0, (sum, s) => sum + s.price).toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")} د.ع',
                            style: GoogleFonts.cairo(
                              fontSize: 17,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to booking with all selected services
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(
                              service: _selectedServices.first,
                              selectedServices: _selectedServices,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'حجز الآن',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Clear Selection Button
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                      onPressed: () {
                        setState(() {
                          _selectedServices.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _CategoryFilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final categories = ['الكل', 'صيانة', 'توصيل', 'تنظيف', 'تركيب', 'أخرى'];

    return Container(
      height: 48,
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final cat = categories[i];
          final isSelected = cat == selected;
          return GestureDetector(
            onTap: () => onSelected(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cat,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF6B7280),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final ServiceModel service;
  final int index;
  final List<CenterService> selectedServices;
  final Function(CenterService) onAddService;
  final Function(CenterService) onBookNow;

  const _ServiceCard({
    super.key,
    required this.service,
    required this.index,
    required this.selectedServices,
    required this.onAddService,
    required this.onBookNow,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + (widget.index * 60)),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, child) => Transform.translate(
        offset: Offset(0, Tween<double>(begin: 40.0, end: 0.0)
            .animate(CurvedAnimation(
                parent: _ctrl, curve: Curves.easeOutCubic))
            .value),
        child: FadeTransition(
          opacity: _ctrl,
          child: child,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          final centerService = widget.service.toCenterService();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => ServiceDetailsSheet(
              service: centerService,
              selectedServices: widget.selectedServices,
              onAddService: widget.onAddService,
              onBookNow: () => widget.onBookNow(centerService),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── صورة الخدمة ─────────────────────
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
                child: Stack(
                  children: [
                    AppNetworkImage(
                      imageUrl: ImageUrlHelper.service(widget.service.imageUrl),
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                    // Gradient overlay في الأسفل
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Badge الفئة في الزاوية
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.service.category,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // التقييم في الأسفل
                    Positioned(
                      bottom: 10,
                      right: 12,
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFFBBF24), size: 14),
                          const SizedBox(width: 3),
                          Text(
                            '${widget.service.rating}',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            ' (${widget.service.reviewsCount})',
                            style: GoogleFonts.cairo(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── المعلومات ───────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.service.titleAr.isNotEmpty
                                ? widget.service.titleAr
                                : widget.service.title,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        Text(
                          widget.service.price != null
                              ? CurrencyFormatter.format(widget.service.price!)
                              : 'مجاني',
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1D9E75),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (widget.service.descriptionAr != null || widget.service.description != null)
                      Text(
                        widget.service.descriptionAr ?? widget.service.description ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'الوقت المتوقع: ${widget.service.durationMinutes} دقيقة',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            final centerService = widget.service.toCenterService();
                            widget.onBookNow(centerService);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'حجز الآن',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCardSkeleton extends StatelessWidget {
  const _ServiceCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          const ShimmerBox(width: double.infinity, height: 160, borderRadius: 20),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ShimmerBox(width: 140, height: 16),
                    const ShimmerBox(width: 80, height: 16),
                  ],
                ),
                const SizedBox(height: 10),
                const ShimmerBox(width: double.infinity, height: 12),
                const SizedBox(height: 6),
                const ShimmerBox(width: 200, height: 12),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ShimmerBox(width: 120, height: 14),
                    const ShimmerBox(width: 80, height: 32, borderRadius: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFE24B4A),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: const Color(0xFF1A1A2E),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'إعادة المحاولة',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyServicesView extends StatelessWidget {
  const _EmptyServicesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.build_circle_outlined,
                size: 40,
                color: Color(0xFFD1D5DB),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'لا توجد خدمات متاحة',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم يتم العثور على خدمات في هذه الفئة حالياً.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
