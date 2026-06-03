import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/models/banner_model.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';

class BannerWidget extends StatelessWidget {
  final BannerModel banner;
  final double height;
  final double borderRadius;

  const BannerWidget({
    super.key,
    required this.banner,
    this.height = 180.0,
    this.borderRadius = 24.0,
  });

  Color _parseHexColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.white; // Fallback
    }
  }

  Alignment _getAlignment(String alignmentStr) {
    switch (alignmentStr) {
      case 'top_left':
        return Alignment.topLeft;
      case 'top_center':
        return Alignment.topCenter;
      case 'top_right':
        return Alignment.topRight;
      case 'center_left':
        return Alignment.centerLeft;
      case 'center_right':
        return Alignment.centerRight;
      case 'bottom_left':
        return Alignment.bottomLeft;
      case 'bottom_center':
        return Alignment.bottomCenter;
      case 'bottom_right':
        return Alignment.bottomRight;
      case 'center':
      default:
        return Alignment.center;
    }
  }

  TextAlign _getTextAlign(String alignmentStr) {
    if (alignmentStr.contains('left')) return TextAlign.left;
    if (alignmentStr.contains('right')) return TextAlign.right;
    return TextAlign.center;
  }

  CrossAxisAlignment _getCrossAxis(String alignmentStr) {
    if (alignmentStr.contains('left')) return CrossAxisAlignment.start;
    if (alignmentStr.contains('right')) return CrossAxisAlignment.end;
    return CrossAxisAlignment.center;
  }

  // Dynamic gradient based on text alignment to keep text readable
  Decoration _getOverlayDecoration(String alignmentStr, Color overlayColor, double opacity) {
    if (alignmentStr.contains('top')) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            overlayColor.withOpacity(opacity),
            overlayColor.withOpacity(0.0),
          ],
          stops: const [0.0, 0.8],
        ),
      );
    } else if (alignmentStr.contains('bottom')) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            overlayColor.withOpacity(opacity),
            overlayColor.withOpacity(0.0),
          ],
          stops: const [0.0, 0.8],
        ),
      );
    } else {
      // Center alignments - solid overlay
      return BoxDecoration(
        color: overlayColor.withOpacity(opacity),
      );
    }
  }

  void _handleNavigation(BuildContext context) {
    switch (banner.linkType) {
      case 'product':
        if (banner.productId != null) {
          Navigator.pushNamed(
            context,
            '/product',
            arguments: {'productId': banner.productId.toString()},
          );
        }
        break;
      case 'category':
        if (banner.categoryId != null) {
          Navigator.pushNamed(
            context,
            '/products',
            arguments: {'categoryId': banner.categoryId},
          );
        }
        break;
      case 'external':
        if (banner.externalUrl != null && banner.externalUrl!.isNotEmpty) {
          // Launch external web page or show popup
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'سيتم فتح الرابط الخارجي: ${banner.externalUrl}',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        break;
      case 'none':
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsedTextColor = _parseHexColor(banner.textColor);
    final parsedOverlayColor = _parseHexColor(banner.overlayColor);
    final alignment = _getAlignment(banner.textAlignment);
    final textAlign = _getTextAlign(banner.textAlignment);
    final crossAxis = _getCrossAxis(banner.textAlignment);

    return GestureDetector(
      onTap: () => _handleNavigation(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background Image
              AppNetworkImage(
                imageUrl: banner.imageUrl,
                fit: BoxFit.cover,
                borderRadius: borderRadius,
              ),

              // 2. Dynamic Gradient Overlay
              Container(
                decoration: _getOverlayDecoration(
                  banner.textAlignment,
                  parsedOverlayColor,
                  banner.overlayOpacity,
                ),
              ),

              // 3. Text content layout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Align(
                  alignment: alignment,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: crossAxis,
                    children: [
                      Text(
                        banner.title,
                        style: GoogleFonts.cairo(
                          color: parsedTextColor,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                        textAlign: textAlign,
                      ),
                      if (banner.subtitle != null && banner.subtitle!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6.0),
                        Text(
                          banner.subtitle!,
                          style: GoogleFonts.cairo(
                            color: parsedTextColor.withOpacity(0.85),
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          textAlign: textAlign,
                        ),
                      ],
                      if (banner.buttonText != null && banner.buttonText!.trim().isNotEmpty) ...[
                        const SizedBox(height: 12.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: parsedTextColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            banner.buttonText!,
                            style: GoogleFonts.cairo(
                              color: parsedOverlayColor.withOpacity(0.9),
                              fontSize: 11.0,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
