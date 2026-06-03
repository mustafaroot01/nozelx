import 'package:flutter/material.dart';
import 'colors.dart';
import 'dark_colors.dart';

/// Theme Helper - Provides easy access to theme colors
/// Automatically switches between light and dark colors based on context

class ThemeHelper {
  ThemeHelper._();

  /// Get current brightness
  static Brightness getBrightness(BuildContext context) {
    return Theme.of(context).brightness;
  }

  /// Check if dark mode is active
  static bool isDarkMode(BuildContext context) {
    return getBrightness(context) == Brightness.dark;
  }

  /// Get primary color based on theme
  static Color getPrimaryColor(BuildContext context) {
    return isDarkMode(context) ? DarkAppColors.primary : AppColors.primary;
  }

  /// Get background color based on theme
  static Color getBackgroundColor(BuildContext context) {
    return isDarkMode(context)
        ? DarkAppColors.background
        : AppColors.background;
  }

  /// Get surface color based on theme
  static Color getSurfaceColor(BuildContext context) {
    return isDarkMode(context) ? DarkAppColors.surface : AppColors.surface;
  }

  /// Get text primary color based on theme
  static Color getTextPrimaryColor(BuildContext context) {
    return isDarkMode(context)
        ? DarkAppColors.textPrimary
        : AppColors.textPrimary;
  }

  /// Get text secondary color based on theme
  static Color getTextSecondaryColor(BuildContext context) {
    return isDarkMode(context)
        ? DarkAppColors.textSecondary
        : AppColors.textSecondary;
  }

  /// Get divider color based on theme
  static Color getDividerColor(BuildContext context) {
    return isDarkMode(context) ? DarkAppColors.divider : AppColors.divider;
  }

  /// Get border color based on theme
  static Color getBorderColor(BuildContext context) {
    return isDarkMode(context) ? DarkAppColors.border : AppColors.border;
  }

  /// Get error color based on theme
  static Color getErrorColor(BuildContext context) {
    return isDarkMode(context) ? DarkAppColors.error : AppColors.error;
  }

  /// Get success color based on theme
  static Color getSuccessColor(BuildContext context) {
    return isDarkMode(context) ? DarkAppColors.success : AppColors.success;
  }

  /// Get warning color based on theme
  static Color getWarningColor(BuildContext context) {
    return isDarkMode(context) ? DarkAppColors.warning : AppColors.warning;
  }

  /// Get surface variant color based on theme
  static Color getSurfaceVariantColor(BuildContext context) {
    return isDarkMode(context)
        ? DarkAppColors.surfaceVariant
        : AppColors.surfaceVariant;
  }

  /// Get card background color based on theme
  static Color getCardBackgroundColor(BuildContext context) {
    return isDarkMode(context)
        ? DarkAppColors.cardBackground
        : AppColors.surface;
  }

  /// Get input background color based on theme
  static Color getInputBackgroundColor(BuildContext context) {
    return isDarkMode(context)
        ? DarkAppColors.inputBackground
        : AppColors.surfaceVariant.withOpacity(0.5);
  }

  /// Get primary gradient based on theme
  static List<Color> getPrimaryGradient(BuildContext context) {
    return isDarkMode(context)
        ? DarkAppColors.primaryGradient
        : const [AppColors.gradientStart, AppColors.gradientEnd];
  }

  /// Get category oil color based on theme
  static Color getCategoryOilColor(BuildContext context) {
    return isDarkMode(context)
        ? DarkAppColors.categoryOil
        : AppColors.categoryOil;
  }

  /// Get category filters color based on theme
  static Color getCategoryFiltersColor(BuildContext context) {
    return isDarkMode(context)
        ? DarkAppColors.categoryFilters
        : AppColors.categoryFilters;
  }

  /// Get category fluids color based on theme
  static Color getCategoryFluidsColor(BuildContext context) {
    return isDarkMode(context)
        ? DarkAppColors.categoryFluids
        : AppColors.categoryFluids;
  }

  /// Get category additives color based on theme
  static Color getCategoryAdditivesColor(BuildContext context) {
    return isDarkMode(context)
        ? DarkAppColors.categoryAdditives
        : AppColors.categoryAdditives;
  }

  /// Get category car care color based on theme
  static Color getCategoryCarCareColor(BuildContext context) {
    return isDarkMode(context)
        ? DarkAppColors.categoryCarCare
        : AppColors.categoryCarCare;
  }

  /// Get category brakes color based on theme
  static Color getCategoryBrakesColor(BuildContext context) {
    return isDarkMode(context)
        ? DarkAppColors.categoryBrakes
        : AppColors.categoryBrakes;
  }

  /// Get price color based on theme
  static Color getPriceColor(BuildContext context) {
    return isDarkMode(context)
        ? DarkAppColors.priceColor
        : AppColors.priceColor;
  }

  /// Get discount color based on theme
  static Color getDiscountColor(BuildContext context) {
    return isDarkMode(context) ? DarkAppColors.discount : AppColors.discount;
  }

  /// Get favorite/wishlist color based on theme
  static Color getFavoriteColor(BuildContext context) {
    return isDarkMode(context) ? DarkAppColors.favorite : AppColors.favorite;
  }

  /// Get glass background color based on theme
  static Color getGlassBackgroundColor(BuildContext context) {
    return isDarkMode(context)
        ? DarkAppColors.glassBackground
        : AppColors.glassBackground;
  }

  /// Get glass border color based on theme
  static Color getGlassBorderColor(BuildContext context) {
    return isDarkMode(context)
        ? DarkAppColors.glassBorder
        : AppColors.glassBorder;
  }
}

/// Extension methods on BuildContext for easy theme access
extension ThemeExtension on BuildContext {
  /// Get primary color
  Color get primaryColor => ThemeHelper.getPrimaryColor(this);

  /// Get background color
  Color get backgroundColor => ThemeHelper.getBackgroundColor(this);

  /// Get surface color
  Color get surfaceColor => ThemeHelper.getSurfaceColor(this);

  /// Get text primary color
  Color get textPrimaryColor => ThemeHelper.getTextPrimaryColor(this);

  /// Get text secondary color
  Color get textSecondaryColor => ThemeHelper.getTextSecondaryColor(this);

  /// Get divider color
  Color get dividerColor => ThemeHelper.getDividerColor(this);

  /// Get border color
  Color get borderColor => ThemeHelper.getBorderColor(this);

  /// Get error color
  Color get errorColor => ThemeHelper.getErrorColor(this);

  /// Get success color
  Color get successColor => ThemeHelper.getSuccessColor(this);

  /// Get warning color
  Color get warningColor => ThemeHelper.getWarningColor(this);

  /// Get surface variant color
  Color get surfaceVariantColor => ThemeHelper.getSurfaceVariantColor(this);

  /// Get card background color
  Color get cardBackgroundColor => ThemeHelper.getCardBackgroundColor(this);

  /// Get input background color
  Color get inputBackgroundColor => ThemeHelper.getInputBackgroundColor(this);

  /// Get primary gradient
  List<Color> get primaryGradient => ThemeHelper.getPrimaryGradient(this);

  /// Check if dark mode
  bool get isDarkMode => ThemeHelper.isDarkMode(this);
}
