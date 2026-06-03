import 'package:flutter/material.dart';

/// Dark Theme Colors for AutoLube App
/// Provides a comfortable dark mode experience

class DarkAppColors {
  // Primary Colors - Deep Blue (Lighter for dark mode)
  static const Color primary = Color(0xFF4A7DD1);
  static const Color primaryDark = Color(0xFF2E5A96);
  static const Color primaryLight = Color(0xFF6B9FE0);
  static const Color primaryAccent = Color(0xFF8BB4E8);

  // Secondary Colors
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color secondaryDark = Color(0xFFE05555);
  static const Color secondaryLight = Color(0xFFFF8585);

  // Background Colors - Dark Theme
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceVariant = Color(0xFF21262D);
  static const Color surfaceElevated = Color(0xFF1C2128);
  static const Color divider = Color(0xFF30363D);

  // Text Colors - Dark Theme
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textTertiary = Color(0xFF6E7681);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF3FB950);
  static const Color warning = Color(0xFFD29922);
  static const Color error = Color(0xFFF85149);
  static const Color info = Color(0xFF58A6FF);

  // UI Colors
  static const Color border = Color(0xFF30363D);
  static const Color shadowColor = Color(0x80000000);
  static const Color overlay = Color(0xB3000000);

  // Rating & Discount
  static const Color ratingStar = Color(0xFFFCC419);
  static const Color discount = Color(0xFFF85149);
  static const Color priceColor = Color(0xFF4A7DD1);

  // Category Colors
  static const Color categoryOil = Color(0xFF4A7DD1);
  static const Color categoryFilters = Color(0xFF3FB950);
  static const Color categoryFluids = Color(0xFF58A6FF);
  static const Color categoryAdditives = Color(0xFFD29922);
  static const Color categoryCarCare = Color(0xFFA371F7);
  static const Color categoryBrakes = Color(0xFFF85149);

  // Gradients - Dark Theme
  static const List<Color> primaryGradient = [
    Color(0xFF4A7DD1),
    Color(0xFF6B9FE0),
  ];
  static const List<Color> accentGradient = [
    Color(0xFF4A7DD1),
    Color(0xFF3FB950),
  ];
  static const List<Color> secondaryGradient = [
    Color(0xFFFF6B6B),
    Color(0xFFFF8585),
  ];
  static const List<Color> surfaceGradient = [
    Color(0xFF1C2128),
    Color(0xFF161B22),
  ];

  // Additional Colors
  static const Color favorite = Color(0xFFFF6B9D);
  static const Color wishlist = Color(0xFFFF6B9D);
  static const Color errorLight = Color(0x40F85149);
  static const Color primaryContainer = Color(0xFF2E5A96);
  static const Color secondaryContainer = Color(0xFF1C4A6A);
  static const Color tertiary = Color(0xFFA371F7);
  static const Color tertiaryLight = Color(0xFFC6A8FF);

  // Glassmorphism - Dark Theme
  static const Color glassBackground = Color(0x80161B22);
  static const Color glassBorder = Color(0x4045464A);

  // Special Colors
  static const Color muted = Color(0xFF484F58);
  static const Color highlight = Color(0xFF1F6AEB);

  // Form Colors - Dark Theme
  static const Color inputBackground = Color(0xFF0D1117);
  static const Color inputBorder = Color(0xFF30363D);
  static const Color inputFocused = Color(0xFF4A7DD1);

  // Navigation Colors - Dark Theme
  static const Color navBackground = Color(0xFF161B22);
  static const Color navSelected = Color(0xFF4A7DD1);
  static const Color navUnselected = Color(0xFF6E7681);

  // Card Colors - Dark Theme
  static const Color cardBackground = Color(0xFF1C2128);
  static const Color cardBorder = Color(0xFF30363D);

  // Tooltip Colors - Dark Theme
  static const Color tooltipBackground = Color(0xFF21262D);
  static const Color tooltipText = Color(0xFFF0F6FC);
}
