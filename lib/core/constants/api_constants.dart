import '../services/api_service.dart';

/// API Configuration Constants
class ApiConstants {
  static const String baseUrl = ApiService.baseUrl;

  // Endpoints
  static const String products = '/products';
  static const String categories = '/categories';
  static const String orders = '/orders';
  static const String users = '/users';
  static const String vehicles = '/vehicles';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String coupons = '/coupons';
  static const String reviews = '/reviews';
  static const String auth = '/auth';

  // Query Parameters
  static const String paramPage = 'page';
  static const String paramLimit = 'limit';
  static const String paramSearch = 'search';
  static const String paramCategory = 'category';
  static const String paramBrand = 'brand';
  static const String paramMinPrice = 'min_price';
  static const String paramMaxPrice = 'max_price';
  static const String paramSort = 'sort';
  static const String paramViscosity = 'viscosity';
  static const String paramType = 'type';
  static const String paramCapacity = 'capacity';

  // Sort Options
  static const String sortNewest = 'newest';
  static const String sortBestSeller = 'best_seller';
  static const String sortPriceLow = 'price_asc';
  static const String sortPriceHigh = 'price_desc';
  static const String sortRating = 'rating';

  // Headers
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}
