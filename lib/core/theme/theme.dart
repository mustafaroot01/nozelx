import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'text_styles.dart';
import 'dimensions.dart';
import 'colors.dart';

/// Modern Arabic eCommerce App Theme with Material 3
/// Primary Color: Deep Blue (#1E4DB7)

class AppTheme {
  AppTheme._();

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface.withOpacity(0.8),
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      titleTextStyle: AppTextStyles.appBarTitle.copyWith(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      toolbarHeight: AppDimensions.appBarHeight,
      iconTheme: const IconThemeData(size: 22, color: AppColors.textPrimary),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 10,
      ),
      unselectedLabelStyle: AppTextStyles.labelSmall.copyWith(fontSize: 10),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      enableFeedback: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.surfaceVariant, width: 1),
      ),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 12,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      modalBarrierColor: AppColors.overlay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      elevation: 12,
      dragHandleColor: AppColors.divider,
      dragHandleSize: const Size(36, 5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: AppTextStyles.buttonText.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        enableFeedback: true,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: AppTextStyles.buttonText.copyWith(fontWeight: FontWeight.w600),
        enableFeedback: true,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.error, width: 1),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
    ),
  );


  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4A7DD1),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0D1117),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF161B22),
      foregroundColor: const Color(0xFFF0F6FC),
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF161B22),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      titleTextStyle: AppTextStyles.appBarTitle.copyWith(
        color: const Color(0xFFF0F6FC),
      ),
      toolbarHeight: AppDimensions.appBarHeight,
      iconTheme: const IconThemeData(size: 24, color: Color(0xFFF0F6FC)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF161B22),
      selectedItemColor: const Color(0xFF4A7DD1),
      unselectedItemColor: const Color(0xFF8B949E),
      selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF4A7DD1),
      ),
      unselectedLabelStyle: AppTextStyles.labelSmall,
      type: BottomNavigationBarType.fixed,
      enableFeedback: true,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF161B22),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF30363D), width: 0.5),
      ),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF161B22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: const Color(0xFFF0F6FC),
      ),
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: const Color(0xFF8B949E),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      elevation: 8,
      dragHandleColor: const Color(0xFF8B949E),
      dragHandleSize: const Size(32, 4),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.buttonText,
        foregroundColor: const Color(0xFF4A7DD1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: const Color(0xFF4A7DD1),
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.buttonText,
        enableFeedback: true,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF4A7DD1),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        side: const BorderSide(color: Color(0xFF30363D), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.buttonText,
        enableFeedback: true,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF161B22),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: const Color(0xFF8B949E),
      ),
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: const Color(0xFF8B949E),
      ),
      errorStyle: AppTextStyles.bodySmall.copyWith(
        color: const Color(0xFFF85149),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF30363D)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF30363D)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4A7DD1), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF85149), width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF85149), width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF21262D),
      selectedColor: const Color(0xFF4A7DD1),
      secondarySelectedColor: const Color(0xFF4A7DD1).withOpacity(0.15),
      disabledColor: const Color(0xFF21262D),
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: const Color(0xFFF0F6FC),
      ),
      secondaryLabelStyle: AppTextStyles.labelMedium,
      brightness: Brightness.dark,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF30363D),
      thickness: 1,
      space: 16,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: const Color(0xFF4A7DD1),
      unselectedLabelColor: const Color(0xFF8B949E),
      labelStyle: AppTextStyles.labelLarge,
      unselectedLabelStyle: AppTextStyles.labelMedium,
      indicator: UnderlineTabIndicator(
        borderSide: const BorderSide(color: Color(0xFF4A7DD1), width: 2),
        insets: const EdgeInsets.symmetric(horizontal: 16),
      ),
      dividerColor: const Color(0xFF30363D),
      tabAlignment: TabAlignment.center,
      labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: const WidgetStatePropertyAll(Color(0xFF8B949E)),
      trackColor: const WidgetStatePropertyAll(Color(0xFF21262D)),
      thickness: const WidgetStatePropertyAll(4),
      radius: const Radius.circular(2),
      interactive: true,
      minThumbLength: 40,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF161B22),
      contentTextStyle: AppTextStyles.bodyLarge.copyWith(
        color: const Color(0xFFF0F6FC),
      ),
      actionTextColor: const Color(0xFF4A7DD1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF4A7DD1),
      foregroundColor: const Color(0xFFFFFFFF),
      splashColor: const Color(0xFF4A7DD1).withOpacity(0.3),
      elevation: 6,
      focusElevation: 8,
      hoverElevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      iconSize: 24,
      sizeConstraints: const BoxConstraints.tightFor(width: 56, height: 56),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF161B22),
      indicatorColor: const Color(0xFF4A7DD1).withOpacity(0.15),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTextStyles.labelMedium;
        }
        return AppTextStyles.labelSmall;
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(size: 24, color: Color(0xFF4A7DD1));
        }
        return const IconThemeData(size: 24, color: Color(0xFF8B949E));
      }),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xFF4A7DD1),
      selectionColor: Color(0xFF4A7DD1),
      selectionHandleColor: Color(0xFF4A7DD1),
    ),
  );
}
