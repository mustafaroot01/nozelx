import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:auto_lube/features/services/data/service_banners_data.dart';

class ServiceBannersWidget extends StatefulWidget {
  final List<ServiceBanner> banners;
  final Function(ServiceBanner)? onBannerTap;

  const ServiceBannersWidget({
    super.key,
    this.banners = const [],
    this.onBannerTap,
  });

  @override
  State<ServiceBannersWidget> createState() => _ServiceBannersWidgetState();
}

class _ServiceBannersWidgetState extends State<ServiceBannersWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show as grid of square boxes (multiple banners at once)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grid of banner boxes
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: widget.banners.length,
          itemBuilder: (context, index) {
            final banner = widget.banners[index];
            return _buildBannerBox(banner);
          },
        ),
      ],
    );
  }

  Widget _buildBannerBox(ServiceBanner banner) {
    final gradientStart = _parseColor(banner.gradientStart);
    final gradientEnd = _parseColor(banner.gradientEnd);

    return GestureDetector(
      onTap: () {
        if (widget.onBannerTap != null) {
          widget.onBannerTap!(banner);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientStart.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
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
              if (banner.imageUrl.isNotEmpty)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.2,
                    child: AppNetworkImage(
                      imageUrl: banner.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      banner.title,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (banner.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        banner.subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        banner.buttonText,
                        style: GoogleFonts.cairo(
                          fontSize: 10,
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
    );
  }
}
