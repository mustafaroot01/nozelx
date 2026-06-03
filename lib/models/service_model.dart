import '../core/config/api_config.dart';

class ServiceOptionModel {
  final int id;
  final String name;
  final String? description;
  final double extraPrice;

  const ServiceOptionModel({
    required this.id,
    required this.name,
    this.description,
    required this.extraPrice,
  });

  factory ServiceOptionModel.fromJson(Map<String, dynamic> json) {
    return ServiceOptionModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      extraPrice: (json['extra_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ServiceModel {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> galleryUrls;
  final String? iconEmoji;
  final double basePrice;
  final String priceType;
  final String? category;
  final int durationMinutes;
  final bool isAvailable;
  final bool isFeatured;
  final double rating;
  final int reviewsCount;
  final Map<String, dynamic> workingHours;
  final int advanceBookingDays;
  final List<ServiceOptionModel> options;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.galleryUrls,
    required this.basePrice,
    this.iconEmoji,
    this.priceType = 'fixed',
    this.category,
    this.durationMinutes = 60,
    this.isAvailable = true,
    this.isFeatured = false,
    this.rating = 0,
    this.reviewsCount = 0,
    this.workingHours = const {},
    this.advanceBookingDays = 30,
    this.options = const [],
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id:   json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: ApiConfig.img(json['image_url'] as String?),
      galleryUrls: ((json['gallery_urls'] as List?) ?? [])
          .map((u) => ApiConfig.img(u?.toString()))
          .where((u) => u.isNotEmpty)
          .toList(),
      iconEmoji: json['icon_emoji'] as String?,
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      priceType: json['price_type'] as String? ?? 'fixed',
      category:   json['category'] as String?,
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      isAvailable: json['is_available'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      workingHours: json['working_hours'] is Map<String, dynamic>
          ? json['working_hours'] as Map<String, dynamic>
          : {},
      advanceBookingDays: json['advance_booking_days'] as int? ?? json['max_bookings_per_day'] as int? ?? 30,
      options: ((json['options'] as List?) ?? [])
          .map((e) => ServiceOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String get priceLabel {
    switch (priceType) {
      case 'from':       return 'يبدأ من';
      case 'negotiable': return 'حسب الاتفاق';
      default:           return 'السعر';
    }
  }

  String get durationText {
    if (durationMinutes < 60) {
      return '$durationMinutes دقيقة';
    }
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (m == 0) {
      return '$h ${h == 1 ? "ساعة" : "ساعات"}';
    }
    return '$h ساعة و$m دقيقة';
  }
}
