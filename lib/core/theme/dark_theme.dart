import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dark_colors.dart';
import 'text_styles.dart';
import 'dimensions.dart';

/// Dark Theme for AutoLube App
/// Provides a comfortable dark mode experience following Material 3 guidelines

class DarkAppTheme {
  DarkAppTheme._();

  // Main Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,

      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: DarkAppColors.primary,
        primary: DarkAppColors.primary,
        onPrimary: DarkAppColors.textOnPrimary,
        primaryContainer: DarkAppColors.primaryContainer,
        onPrimaryContainer: DarkAppColors.textPrimary,
        secondary: DarkAppColors.secondary,
        onSecondary: DarkAppColors.textOnPrimary,
        secondaryContainer: DarkAppColors.secondaryContainer,
        onSecondaryContainer: DarkAppColors.textPrimary,
        tertiary: DarkAppColors.tertiary,
        onTertiary: DarkAppColors.textOnPrimary,
        tertiaryContainer: DarkAppColors.tertiary.withOpacity(0.15),
        onTertiaryContainer: DarkAppColors.tertiary,
        background: DarkAppColors.background,
        onBackground: DarkAppColors.textPrimary,
        surface: DarkAppColors.surface,
        onSurface: DarkAppColors.textPrimary,
        surfaceVariant: DarkAppColors.surfaceVariant,
        onSurfaceVariant: DarkAppColors.textSecondary,
        error: DarkAppColors.error,
        onError: DarkAppColors.textOnPrimary,
        errorContainer: DarkAppColors.error.withOpacity(0.15),
        onErrorContainer: DarkAppColors.error,
        outline: DarkAppColors.border,
        outlineVariant: DarkAppColors.divider,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: DarkAppColors.background,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: DarkAppColors.surface,
        foregroundColor: DarkAppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: DarkAppColors.surface,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: AppTextStyles.appBarTitle.copyWith(
          color: DarkAppColors.textPrimary,
        ),
        toolbarHeight: AppDimensions.appBarHeight,
        iconTheme: IconThemeData(
          size: AppDimensions.iconMedium,
          color: DarkAppColors.textPrimary,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DarkAppColors.navBackground.withOpacity(0.95),
        selectedItemColor: DarkAppColors.navSelected,
        unselectedItemColor: DarkAppColors.navUnselected,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: DarkAppColors.navSelected,
        ),
        unselectedLabelStyle: AppTextStyles.labelSmall,
        type: BottomNavigationBarType.fixed,
        enableFeedback: true,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: DarkAppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.largeBorderRadius),
          side: const BorderSide(color: DarkAppColors.cardBorder, width: 0.5),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: DarkAppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.dialogBorderRadius),
        ),
        elevation: 8,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: DarkAppColors.textPrimary,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: DarkAppColors.textSecondary,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: DarkAppColors.surface.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.bottomSheetBorderRadius),
          ),
        ),
        elevation: 8,
        dragHandleColor: DarkAppColors.textTertiary,
        dragHandleSize: Size(
          AppDimensions.bottomSheetHandleWidth,
          AppDimensions.bottomSheetHandleHeight,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.mediumPadding,
            vertical: AppDimensions.smallPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonBorderRadius,
            ),
          ),
          textStyle: AppTextStyles.buttonText,
          foregroundColor: DarkAppColors.primary,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, AppDimensions.buttonHeight),
          backgroundColor: DarkAppColors.primary,
          foregroundColor: DarkAppColors.textOnPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.buttonPaddingHorizontal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonBorderRadius,
            ),
          ),
          textStyle: AppTextStyles.buttonText,
          enableFeedback: true,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, AppDimensions.buttonHeight),
          backgroundColor: Colors.transparent,
          foregroundColor: DarkAppColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.buttonPaddingHorizontal,
          ),
          side: const BorderSide(color: DarkAppColors.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonBorderRadius,
            ),
          ),
          textStyle: AppTextStyles.buttonText,
          enableFeedback: true,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkAppColors.inputBackground,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.mediumPadding,
          vertical: AppDimensions.defaultPadding,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: DarkAppColors.textTertiary,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: DarkAppColors.textSecondary,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: DarkAppColors.error,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.inputFieldBorderRadius,
          ),
          borderSide: const BorderSide(color: DarkAppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.inputFieldBorderRadius,
          ),
          borderSide: const BorderSide(color: DarkAppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.inputFieldBorderRadius,
          ),
          borderSide: const BorderSide(
            color: DarkAppColors.inputFocused,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.inputFieldBorderRadius,
          ),
          borderSide: const BorderSide(color: DarkAppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.inputFieldBorderRadius,
          ),
          borderSide: const BorderSide(color: DarkAppColors.error, width: 2),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: DarkAppColors.surfaceVariant,
        selectedColor: DarkAppColors.primary,
        secondarySelectedColor: DarkAppColors.primary.withOpacity(0.15),
        disabledColor: DarkAppColors.surfaceVariant,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: DarkAppColors.textPrimary,
        ),
        secondaryLabelStyle: AppTextStyles.labelMedium,
        brightness: Brightness.dark,
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.smallPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.chipBorderRadius),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: DarkAppColors.divider,
        thickness: 1,
        space: AppDimensions.spacingMedium,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: DarkAppColors.primary,
        unselectedLabelColor: DarkAppColors.textTertiary,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelMedium,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: DarkAppColors.primary,
            width: AppDimensions.tabBarIndicatorWeight,
          ),
          insets: EdgeInsets.symmetric(horizontal: AppDimensions.mediumPadding),
        ),
        dividerColor: DarkAppColors.divider,
        tabAlignment: TabAlignment.center,
        labelPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.mediumPadding,
          vertical: AppDimensions.smallPadding,
        ),
      ),

      // Scrollbar Theme
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(DarkAppColors.textTertiary),
        trackColor: WidgetStateProperty.all(DarkAppColors.surfaceVariant),
        thickness: WidgetStateProperty.all(4),
        radius: Radius.circular(AppDimensions.smallBorderRadius),
        interactive: true,
        minThumbLength: 40,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DarkAppColors.surface,
        contentTextStyle: AppTextStyles.bodyLarge.copyWith(
          color: DarkAppColors.textPrimary,
        ),
        actionTextColor: DarkAppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.mediumBorderRadius),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DarkAppColors.primary,
        foregroundColor: DarkAppColors.textOnPrimary,
        splashColor: DarkAppColors.primaryLight.withOpacity(0.3),
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.largeBorderRadius),
        ),
        iconSize: AppDimensions.iconMedium,
        sizeConstraints: const BoxConstraints.tightFor(width: 56, height: 56),
      ),

      // Navigation Bar Theme (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DarkAppColors.navBackground.withOpacity(0.95),
        indicatorColor: DarkAppColors.primary.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelMedium;
          }
          return AppTextStyles.labelSmall;
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              size: AppDimensions.iconMedium,
              color: DarkAppColors.primary,
            );
          }
          return IconThemeData(
            size: AppDimensions.iconMedium,
            color: DarkAppColors.textTertiary,
          );
        }),
      ),

      // Text Selection Theme
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: DarkAppColors.primary,
        selectionColor: DarkAppColors.primary.withOpacity(0.3),
        selectionHandleColor: DarkAppColors.primary,
      ),
    );
  }
}
