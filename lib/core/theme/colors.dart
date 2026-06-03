import 'package:flutter/material.dart';

class AppColors {
  // ── الأزرق الرئيسي ─────────────────────────
  static const Color primary        = Color(0xFF1565C0); // أزرق داكن رئيسي
  static const Color primaryLight   = Color(0xFF1976D2); // أزرق متوسط
  static const Color primaryMedium  = Color(0xFF1E88E5); // أزرق مشرق
  static const Color primarySoft    = Color(0xFF42A5F5); // أزرق فاتح
  static const Color primaryPale    = Color(0xFFBBDEFB); // أزرق شاحب
  static const Color primaryGhost   = Color(0xFFE3F2FD); // خلفية أزرق خفيفة جداً

  // ── ألوان الحالة ───────────────────────────
  static const Color success        = Color(0xFF1D9E75);
  static const Color successLight   = Color(0xFFE8F5E9);
  static const Color error          = Color(0xFFE24B4A);
  static const Color errorLight     = Color(0xFFFFEBEE);
  static const Color warning        = Color(0xFFFFA726);
  static const Color warningLight   = Color(0xFFFFF8E1);

  // ── النصوص ─────────────────────────────────
  static const Color textPrimary    = Color(0xFF0D1B2A); // أغمق نص
  static const Color textSecondary  = Color(0xFF4A6080); // نص ثانوي أزرق رمادي
  static const Color textHint       = Color(0xFF8AACCC); // hint أزرق فاتح
  static const Color textOnPrimary  = Color(0xFFFFFFFF); // نص على خلفية أزرق

  // ── الخلفيات ───────────────────────────────
  static const Color background     = Color(0xFFF0F4F8); // خلفية رئيسية أزرق فاتح جداً
  static const Color surface        = Color(0xFFFFFFFF); // بطاقات
  static const Color surfaceBlue    = Color(0xFFF0F7FF); // بطاقات بتدرج أزرق

  // ── الحدود ─────────────────────────────────
  static const Color border         = Color(0xFFD0E4F7); // حدود أزرق فاتح
  static const Color divider        = Color(0xFFE8F0F9); // فاصل

  // ── Gradient ───────────────────────────────
  static const Color gradientStart  = Color(0xFF1565C0);
  static const Color gradientEnd    = Color(0xFF1E88E5);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGhost, Color(0xFFFFFFFF)],
  );

  // ===========================================================================
  // Backward Compatibility Aliases to prevent compilation errors in old files
  // ===========================================================================
  static const Color primaryDark = primary;
  static const Color primaryAccent = primarySoft;
  static const Color secondary = primaryMedium;
  static const Color secondaryDark = primary;
  static const Color secondaryLight = primarySoft;
  static const Color surfaceVariant = border;
  static const Color textTertiary = textHint;
  static const Color info = primaryLight;
  static const Color shadowColor = Color(0x0F000000);
  static const Color overlay = Color(0x66000000);
  static const Color ratingStar = Color(0xFFFFCC00);
  static const Color discount = error;
  static const Color priceColor = textPrimary;
  static const Color favorite = error;
  static const Color wishlist = error;
  static const Color primaryContainer = primaryGhost;
  static const Color secondaryContainer = primaryGhost;
  static const Color tertiary = primary;
  static const Color tertiaryLight = primaryGhost;
  static const Color glassBackground = Color(0xCCFFFFFF);
  static const Color glassBorder = Color(0x33C7C7CC);

  // Category Colors mapped to Blue Theme
  static const Color categoryOil = primary;
  static const Color categoryTires = textPrimary;
  static const Color categoryBatteries = primaryMedium;
  static const Color categoryAccessories = textSecondary;
  static const Color categoryAdditives = warning;
  static const Color categoryCleaners = primarySoft;
  static const Color categoryRadiator = primaryLight;
  static const Color categoryAC = primarySoft;
  static const Color categoryTools = textSecondary;
  static const Color categoryFilters = primaryMedium;
  static const Color categoryBrakes = error;
  static const Color categoryFluids = primary;
  static const Color categoryCarCare = primaryMedium;

  // Gradient Lists
  static const List<Color> accentGradient = [primaryGhost, primaryPale];
  static const List<Color> secondaryGradient = [primaryLight, primaryMedium];
}
