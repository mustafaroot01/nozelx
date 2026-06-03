import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/config/api_config.dart';

class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    this.placeholder,
    this.errorWidget,
  });

  // ① نظّف الـ URL:
  String? _resolveUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final resolved = ApiConfig.img(raw);
    return resolved.isEmpty ? null : resolved;
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _resolveUrl(imageUrl);

    Widget child;

    if (resolved == null) {
      // لا يوجد URL — أظهر placeholder
      child = errorWidget ?? _buildPlaceholder();
    } else {
      // تنظيف الفراغات إن وجدت في الرابط لضمان التحميل الصحيح
      final cleanedUrl = resolved.replaceAll(' ', '%20');
      
      child = CachedNetworkImage(
        imageUrl: cleanedUrl,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.medium,
        // Shimmer أو الـ placeholder المخصص أثناء التحميل
        placeholder: (_, __) => placeholder ?? _buildShimmer(),
        // Placeholder المخصص أو الافتراضي إذا فشل التحميل
        errorWidget: (_, url, error) {
          debugPrint('Image load error: $url → $error');
          return errorWidget ?? _buildPlaceholder();
        },
        // Cache settings
        maxWidthDiskCache: 800,
        maxHeightDiskCache: 800,
        memCacheWidth: (width != null && width!.isFinite)
            ? (width! * MediaQuery.of(context).devicePixelRatio).round().clamp(300, 1200)
            : null,
        memCacheHeight: (height != null && height!.isFinite)
            ? (height! * MediaQuery.of(context).devicePixelRatio).round().clamp(300, 1200)
            : null,
      );
    }

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(width: width, height: height, child: child),
      );
    }
    return SizedBox(width: width, height: height, child: child);
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: shimmerBaseColor ?? AppColors.primaryPale,
      highlightColor: shimmerHighlightColor ?? AppColors.primaryGhost,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        color: Colors.white,
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      color: AppColors.primaryGhost,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.primarySoft,
          size: 32,
        ),
      ),
    );
  }
}
