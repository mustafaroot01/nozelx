import 'package:flutter/material.dart';
import 'package:auto_lube/providers/auth_provider.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/app_network_image.dart';
import '../../providers/service_provider.dart';
import '../../models/service_model.dart';
import 'service_detail_screen.dart';
import 'service_request_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    // ── جلب الخدمات من السيرفر عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (ctx, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0F4F8),
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1565C0),
                    Color(0xFF1E88E5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: Text(
              'خدماتنا',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: provider.isLoading
              ? _buildSkeleton()
              : provider.hasError
                  ? _buildError(provider)
                  : provider.isEmpty
                      ? _buildEmpty(provider)
                      : Stack(
                          children: [
                            Column(
                              children: [
                                // فلترة الفئات
                                if (provider.categories.length > 2)
                                  _CategoryBar(
                                    categories: provider.categories,
                                    selected: provider.selectedCategory,
                                    onSelect: provider.selectCategory,
                                  ),
                                // قائمة الخدمات
                                Expanded(
                                  child: RefreshIndicator(
                                    color: const Color(0xFF1565C0),
                                    onRefresh: () => provider.fetchServices(forceRefresh: true),
                                    child: provider.services.isEmpty
                                        ? ListView(
                                            children: [
                                              const SizedBox(height: 120),
                                              Center(
                                                child: Text(
                                                  'لا توجد خدمات\nفي هذه الفئة حالياً',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 14,
                                                    color: const Color(0xFF4A6080),
                                                    height: 1.7,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : ListView.builder(
                                            physics: const AlwaysScrollableScrollPhysics(),
                                            padding: EdgeInsets.only(
                                              left: 16,
                                              right: 16,
                                              top: 16,
                                              bottom: provider.selectedServices.isEmpty ? 120.0 : 220.0,
                                            ),
                                            itemCount: provider.services.length,
                                            itemBuilder: (_, i) {
                                              final service = provider.services[i];
                                              return _ServiceCard(
                                                key: ValueKey(service.id),
                                                service: service,
                                                index: i,
                                                isSelected: provider.isServiceSelected(service),
                                              );
                                            },
                                          ),
                                  ),
                                ),
                              ],
                            ),
                            if (provider.selectedServices.isNotEmpty)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: _buildBottomPanel(provider),
                              ),
                          ],
                        ),
        );
      },
    );
  }

  Widget _buildBottomPanel(ServiceProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الخدمات المحددة: ${provider.selectedServices.length}',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(provider.selectedServicesTotalPrice),
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1D9E75),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                if (!auth.isLoggedIn) {
                  Navigator.pushNamed(context, '/login');
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceRequestScreen(
                      services: provider.selectedServices.toList(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'حجز الخدمات المحددة',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Shimmer.fromColors(
          baseColor: const Color(0xFFD0E4F7),
          highlightColor: const Color(0xFFE3F2FD),
          child: Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(ServiceProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: Color(0xFF90CAF9),
            ),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: const Color(0xFF4A6080),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: provider.refresh,
              icon: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
              ),
              label: Text(
                'إعادة المحاولة',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ServiceProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.handyman_outlined,
            size: 64,
            color: Color(0xFF90CAF9),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد خدمات متاحة حالياً',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0D1B2A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم إضافة خدمات قريباً',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: const Color(0xFF4A6080),
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: provider.refresh,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF1565C0),
            ),
            label: Text(
              'تحديث',
              style: GoogleFonts.cairo(
                color: const Color(0xFF1565C0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _CategoryBar ──────────────────────────────────
class _CategoryBar extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryBar({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final cat = categories[i];
          final isSel = cat == selected;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFF1565C0) : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cat,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  color: isSel ? Colors.white : const Color(0xFF1565C0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── _ServiceCard ──────────────────────────────────
class _ServiceCard extends StatefulWidget {
  final ServiceModel service;
  final int index;
  final bool isSelected;
  const _ServiceCard({
    super.key,
    required this.service,
    required this.index,
    required this.isSelected,
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
      duration: Duration(milliseconds: 250 + (widget.index * 50)),
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
    final provider = context.read<ServiceProvider>();
    final isSelected = widget.isSelected;

    return FadeTransition(
      opacity: _ctrl,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic)),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF1D9E75) : const Color(0xFFD0E4F7),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected 
                    ? const Color(0xFF1D9E75).withOpacity(0.12)
                    : const Color(0xFF1565C0).withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cover Image ────────────────────────
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceDetailScreen(service: widget.service),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    children: [
                      AppNetworkImage(
                        imageUrl: widget.service.imageUrl,
                        width: double.infinity,
                        height: 165,
                        fit: BoxFit.cover,
                      ),
                      // Gradient shader overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 65,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.45),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Category badge
                      if (widget.service.category != null)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.service.category!,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      // Rating display
                      if (widget.service.reviewsCount > 0)
                        Positioned(
                          bottom: 10,
                          right: 12,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFBBF24),
                                size: 14,
                              ),
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
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Featured Badge
                      if (widget.service.isFeatured)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFA726),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.white, size: 11),
                                const SizedBox(width: 3),
                                Text(
                                  'مميزة',
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // ── Service Details ─────────────────────
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ServiceDetailScreen(service: widget.service),
                        ),
                      ),
                      child: Container(
                        color: Colors.transparent, // Ensures entire text column captures click
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.service.name,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0D1B2A),
                              ),
                            ),
                            if (widget.service.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.service.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: const Color(0xFF4A6080),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        // Row 1: Price and Expected duration
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Price info
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.service.priceLabel,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: const Color(0xFF8AACCC),
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(widget.service.basePrice),
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1D9E75),
                                  ),
                                ),
                              ],
                            ),
                            // Expected duration
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: Color(0xFF8AACCC),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.service.durationText,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: const Color(0xFF8AACCC),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Row 2: Action Buttons
                        Row(
                          children: [
                            // Selection Toggle (multi-booking)
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  provider.toggleServiceSelection(widget.service);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF1D9E75).withOpacity(0.12) : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF1D9E75) : Colors.transparent,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                                        size: 14,
                                        color: isSelected ? const Color(0xFF1D9E75) : const Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isSelected ? 'محددة' : 'تحديد متعدد',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? const Color(0xFF1D9E75) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Book Now button
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  final auth = Provider.of<AuthProvider>(context, listen: false);
                                  if (!auth.isLoggedIn) {
                                    Navigator.pushNamed(context, '/login');
                                    return;
                                  }
                                  provider.clearServiceSelection();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ServiceRequestScreen(services: [widget.service]),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF1565C0).withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'احجز الآن',
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
