import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Text Styles for AutoLube Premium App
/// Using Google Fonts: Cairo for headings, Tajawal for body text

class AppTextStyles {
  // Headlines - Cairo Font
  static TextStyle get displayLarge {
    return GoogleFonts.cairo(
      fontSize: 57,
      fontWeight: FontWeight.bold,
      height: 1.12,
      letterSpacing: -0.25,
    );
  }

  static TextStyle get displayMedium {
    return GoogleFonts.cairo(
      fontSize: 45,
      fontWeight: FontWeight.bold,
      height: 1.16,
    );
  }

  static TextStyle get displaySmall {
    return GoogleFonts.cairo(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      height: 1.22,
    );
  }

  static TextStyle get headlineLarge {
    return GoogleFonts.cairo(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      height: 1.25,
    );
  }

  static TextStyle get headlineMedium {
    return GoogleFonts.cairo(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      height: 1.29,
    );
  }

  static TextStyle get headlineSmall {
    return GoogleFonts.cairo(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      height: 1.33,
    );
  }

  // Titles - Cairo Font
  static TextStyle get titleLarge {
    return GoogleFonts.cairo(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      height: 1.27,
    );
  }

  static TextStyle get titleMedium {
    return GoogleFonts.cairo(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.33,
    );
  }

  static TextStyle get titleSmall {
    return GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.38,
    );
  }

  // Body - Tajawal Font
  static TextStyle get bodyLarge {
    return GoogleFonts.tajawal(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.5,
    );
  }

  static TextStyle get bodyMedium {
    return GoogleFonts.tajawal(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.43,
    );
  }

  static TextStyle get bodySmall {
    return GoogleFonts.tajawal(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      height: 1.33,
    );
  }

  // Labels - Tajawal Font
  static TextStyle get labelLarge {
    return GoogleFonts.tajawal(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.43,
    );
  }

  static TextStyle get labelMedium {
    return GoogleFonts.tajawal(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.33,
    );
  }

  static TextStyle get labelSmall {
    return GoogleFonts.tajawal(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.45,
    );
  }

  // Custom Styles
  static TextStyle get priceLarge {
    return GoogleFonts.cairo(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      height: 1.25,
    );
  }

  static TextStyle get priceMedium {
    return GoogleFonts.cairo(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      height: 1.3,
    );
  }

  static TextStyle get priceSmall {
    return GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      height: 1.38,
    );
  }

  static TextStyle get oldPrice {
    return GoogleFonts.cairo(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.43,
      decoration: TextDecoration.lineThrough,
    );
  }

  static TextStyle get discountBadge {
    return GoogleFonts.cairo(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      height: 1.33,
    );
  }

  static TextStyle get buttonText {
    return GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      height: 1.38,
    );
  }

  static TextStyle get appBarTitle {
    return GoogleFonts.cairo(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      height: 1.3,
    );
  }

  static TextStyle get sectionTitle {
    return GoogleFonts.cairo(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      height: 1.33,
    );
  }

  static TextStyle get cardTitle {
    return GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.38,
    );
  }

  static TextStyle get ratingText {
    return GoogleFonts.tajawal(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.43,
    );
  }
}
