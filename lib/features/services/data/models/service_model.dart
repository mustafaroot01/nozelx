import 'package:auto_lube/core/services/api_service.dart';
import '../../data/services_data.dart';

class ServiceModel {
  final int? id;
  final String title;
  final String titleAr;
  final String? description;
  final String? descriptionAr;
  final String? image;
  final double? price;
  final bool isActive;
  final int sortOrder;

  ServiceModel({
    this.id,
    required this.title,
    required this.titleAr,
    this.description,
    this.descriptionAr,
    this.image,
    this.price,
    this.isActive = true,
    this.sortOrder = 0,
  });

  // Getters for the UI compatibility
  String get category {
    final titleLower = title.toLowerCase();
    final arTitle = titleAr;
    if (titleLower.contains('wash') || titleLower.contains('clean') || arTitle.contains('غسيل') || arTitle.contains('تنظيف')) {
      return 'تنظيف';
    } else if (titleLower.contains('oil') || titleLower.contains('filter') || arTitle.contains('زيت') || arTitle.contains('فلتر') || arTitle.contains('صيانة') || titleLower.contains('maintenance')) {
      return 'صيانة';
    } else if (titleLower.contains('ac') || titleLower.contains('cool') || arTitle.contains('تبريد') || arTitle.contains('تكييف')) {
      return 'صيانة';
    } else if (titleLower.contains('tire') || titleLower.contains('wheel') || arTitle.contains('إطار') || arTitle.contains('تواير')) {
      return 'تركيب';
    } else if (titleLower.contains('delivery') || arTitle.contains('توصيل')) {
      return 'توصيل';
    }
    return 'أخرى';
  }

  double get rating => 4.8; // default rating
  int get reviewsCount => 12 + ((id ?? 0) * 7) % 89;
  int get durationMinutes => 30 + ((id ?? 0) * 15) % 45;
  String get imageUrl => image ?? '';

  CenterService toCenterService() {
    return CenterService(
      id: id ?? 0,
      name: titleAr.isNotEmpty ? titleAr : title,
      nameEn: title,
      description: descriptionAr ?? description,
      icon: 'build',
      image: image,
      price: price?.toInt() ?? 0,
      durationMinutes: durationMinutes,
      isActive: isActive,
    );
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'],
      title: map['title'] ?? '',
      titleAr: map['title_ar'] ?? '',
      description: map['description'],
      descriptionAr: map['description_ar'],
      image: ApiService.fixImageUrl(map['image']),
      price: map['price'] != null ? double.tryParse(map['price'].toString()) : null,
      isActive: map['is_active'] == 1 || map['is_active'] == true,
      sortOrder: map['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'title_ar': titleAr,
      'description': description,
      'description_ar': descriptionAr,
      'image': image,
      'price': price,
      'is_active': isActive ? 1 : 0,
      'sort_order': sortOrder,
    };
  }
}

