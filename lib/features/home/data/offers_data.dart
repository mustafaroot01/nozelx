import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_lube/core/services/api_service.dart';

class OfferBanner {
  final int id;
  final String title;
  final String subtitle;
  final String? description;
  final String imageUrl;
  final String linkType;
  final String linkValue;
  final String buttonText;
  final String gradientStart;
  final String gradientEnd;
  final int discountPercent;

  OfferBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    this.description,
    required this.imageUrl,
    required this.linkType,
    required this.linkValue,
    required this.buttonText,
    required this.gradientStart,
    required this.gradientEnd,
    required this.discountPercent,
  });

  factory OfferBanner.fromJson(Map<String, dynamic> json) {
    return OfferBanner(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'] ?? '',
      linkType: json['link_type'] ?? 'none',
      linkValue: json['link_value'] ?? '',
      buttonText: json['button_text'] ?? 'اعرف المزيد',
      gradientStart: json['gradient_start'] ?? '#1E4DB7',
      gradientEnd: json['gradient_end'] ?? '#3B6BD0',
      discountPercent: json['discount_percent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'image_url': imageUrl,
      'link_type': linkType,
      'link_value': linkValue,
      'button_text': buttonText,
      'gradient_start': gradientStart,
      'gradient_end': gradientEnd,
      'discount_percent': discountPercent,
    };
  }

  /// Get the URL to navigate to based on link type
  String? get navigationUrl {
    switch (linkType) {
      case 'category':
        return '/category/$linkValue';
      case 'product':
        return '/product/$linkValue';
      case 'page':
        return '/$linkValue';
      case 'external':
        return linkValue;
      default:
        return null;
    }
  }
}

class OffersApi {
  static const String _baseUrl = ApiService.baseUrl;

  /// Get all active offers from the server
  static Future<List<OfferBanner>> getOffers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/offers.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['offers'] != null) {
          return (data['offers'] as List)
              .map((o) => OfferBanner.fromJson(o))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching offers: $e');
      return [];
    }
  }
}
