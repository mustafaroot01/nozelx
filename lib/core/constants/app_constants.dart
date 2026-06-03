import '../services/api_service.dart';

/// App Constants - Global configuration values
class AppConstants {
  // App Info
  static const String appName = 'AutoLube';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // API
  static const String baseUrl = ApiService.baseUrl;
  static const int apiTimeoutSeconds = 30;

  // Pagination
  static const int pageSize = 20;
  static const int initialPage = 1;

  // Cache
  static const String cacheProductsKey = 'cached_products';
  static const String cacheCategoriesKey = 'cached_categories';
  static const String selectedVehicleKey = 'selected_vehicle';
  static const int cacheExpirationHours = 24;

  // Local Storage Keys
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String cartKey = 'cart_items';
  static const String recentSearchesKey = 'recent_searches';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPhoneLength = 10;
  static const int minVehicleYear = 1990;
  static const int currentYear = 2025;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // UI
  static const double defaultBorderRadius = 16.0;
  static const double smallBorderRadius = 8.0;
  static const double cardElevation = 4.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 24.0;
  static const double largePadding = 32.0;
}
