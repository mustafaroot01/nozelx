import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/features/home/data/offers_data.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';

class OffersBannersWidget extends StatefulWidget {
  final List<OfferBanner> offers;
  final Function(OfferBanner)? onOfferTap;

  const OffersBannersWidget({
    super.key,
    this.offers = const [],
    this.onOfferTap,
  });

  @override
  State<OffersBannersWidget> createState() => _OffersBannersWidgetState();
}

class _OffersBannersWidgetState extends State<OffersBannersWidget> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_offer,
                  color: Colors.red,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'العروض الخاصة',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 130,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
            },
            itemCount: widget.offers.length,
            itemBuilder: (context, index) {
              final offer = widget.offers[index];
              return _buildOfferCard(offer);
            },
          ),
        ),
        // Page indicator
        if (widget.offers.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.offers.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildOfferCard(OfferBanner offer) {
    final gradientStart = _parseColor(offer.gradientStart);
    final gradientEnd = _parseColor(offer.gradientEnd);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: () {
          if (widget.onOfferTap != null) {
            widget.onOfferTap!(offer);
          }
        },
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradientStart.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [gradientStart, gradientEnd],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                ),
                // Image overlay
                if (offer.imageUrl.isNotEmpty)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.3,
                      child: AppNetworkImage(
                        imageUrl: offer.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (offer.discountPercent > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${offer.discountPercent}% خصم',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              offer.title,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (offer.subtitle.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                offer.subtitle,
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          offer.buttonText,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: gradientStart,
                          ),
                        ),
                      ),
                    ],
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
