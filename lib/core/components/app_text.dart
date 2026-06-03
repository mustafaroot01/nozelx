import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';

enum AppTextSize { xs, sm, md, lg, xl, xxl, xxxl }

enum AppTextWeight { regular, medium, semibold, bold }

class AppText extends StatelessWidget {
  final String text;
  final AppTextSize size;
  final AppTextWeight weight;
  final Color? color;
  final TextStyle? style;
  final int? numberOfLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;

  const AppText({
    super.key,
    required this.text,
    this.size = AppTextSize.md,
    this.weight = AppTextWeight.regular,
    this.color,
    this.style,
    this.numberOfLines,
    this.textAlign,
    this.overflow,
  });

  static final Map<AppTextSize, double> _sizes = {
    AppTextSize.xs: 10.0,
    AppTextSize.sm: 12.0,
    AppTextSize.md: 14.0,
    AppTextSize.lg: 16.0,
    AppTextSize.xl: 18.0,
    AppTextSize.xxl: 22.0,
    AppTextSize.xxxl: 28.0,
  };

  static final Map<AppTextWeight, FontWeight> _weights = {
    AppTextWeight.regular: FontWeight.w400,
    AppTextWeight.medium: FontWeight.w500,
    AppTextWeight.semibold: FontWeight.w600,
    AppTextWeight.bold: FontWeight.w700,
  };

  @override
  Widget build(BuildContext context) {
    final double rawSize = _sizes[size] ?? 14.0;
    final double scaledSize = Responsive.fontScale(rawSize);
    final FontWeight fontWeight = _weights[weight] ?? FontWeight.w400;

    return Text(
      text,
      maxLines: numberOfLines,
      textAlign: textAlign,
      overflow: overflow ?? (numberOfLines != null ? TextOverflow.ellipsis : null),
      semanticsLabel: text, // TalkBack & VoiceOver accessibility
      style: GoogleFonts.cairo(
        fontSize: scaledSize,
        fontWeight: fontWeight,
        color: color ?? Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF1A1A1A),
        height: 1.45,
      ).merge(style),
    );
  }
}
