import 'package:auto_lube/core/services/api_service.dart';

class BannerModel {
  final int id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? mobileImageUrl;
  final String linkType; // product, category, external, none
  final int? productId;
  final int? categoryId;
  final String? externalUrl;
  final String textAlignment; // top_left, top_center, top_right, center_left, center, center_right, bottom_left, bottom_center, bottom_right
  final String textColor;
  final String overlayColor;
  final double overlayOpacity;
  final String? buttonText;
  final int sortOrder;

  BannerModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.mobileImageUrl,
    required this.linkType,
    this.productId,
    this.categoryId,
    this.externalUrl,
    required this.textAlignment,
    required this.textColor,
    required this.overlayColor,
    required this.overlayOpacity,
    this.buttonText,
    required this.sortOrder,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      imageUrl: ApiService.fixImageUrl(json['image_url'] ?? json['image']),
      mobileImageUrl: json['mobile_image_url'] != null && json['mobile_image_url'].toString().isNotEmpty
          ? ApiService.fixImageUrl(json['mobile_image_url'])
          : null,
      linkType: json['link_type'] ?? 'none',
      productId: json['product_id'],
      categoryId: json['category_id'],
      externalUrl: json['external_url'],
      textAlignment: json['text_alignment'] ?? 'center',
      textColor: json['text_color'] ?? '#ffffff',
      overlayColor: json['overlay_color'] ?? '#000000',
      overlayOpacity: json['overlay_opacity'] is double
          ? json['overlay_opacity']
          : (double.tryParse(json['overlay_opacity']?.toString() ?? '0.4') ?? 0.4),
      buttonText: json['button_text'],
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'mobile_image_url': mobileImageUrl,
      'link_type': linkType,
      'product_id': productId,
      'category_id': categoryId,
      'external_url': externalUrl,
      'text_alignment': textAlignment,
      'text_color': textColor,
      'overlay_color': overlayColor,
      'overlay_opacity': overlayOpacity,
      'button_text': buttonText,
      'sort_order': sortOrder,
    };
  }
}
