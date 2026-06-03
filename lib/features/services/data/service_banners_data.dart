import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_lube/core/services/api_service.dart';

class ServiceBanner {
  final int id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String linkType;
  final String linkValue;
  final String buttonText;
  final String gradientStart;
  final String gradientEnd;

  ServiceBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.linkType,
    required this.linkValue,
    required this.buttonText,
    required this.gradientStart,
    required this.gradientEnd,
  });

  factory ServiceBanner.fromJson(Map<String, dynamic> json) {
    return ServiceBanner(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      imageUrl: json['image_url'] ?? '',
      linkType: json['link_type'] ?? 'none',
      linkValue: json['link_value'] ?? '',
      buttonText: json['button_text'] ?? 'احجز الآن',
      gradientStart: json['gradient_start'] ?? '#1E4DB7',
      gradientEnd: json['gradient_end'] ?? '#3B6BD0',
    );
  }

  /// Get the navigation action based on link type
  String? get navigationAction {
    switch (linkType) {
      case 'service':
        return '/service/$linkValue';
      case 'booking':
        return '/booking';
      case 'page':
        return '/$linkValue';
      case 'external':
        return linkValue;
      default:
        return null;
    }
  }
}

class ServiceBannersApi {
  static const String _baseUrl = ApiService.baseUrl;

  /// Get all active service banners from the server
  static Future<List<ServiceBanner>> getBanners() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/services'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          final List services = data['data'] as List;
          return services.map((s) {
            // Map Service to ServiceBanner
            return ServiceBanner(
              id: s['id'] ?? 0,
              title: s['title_ar'] ?? s['title'] ?? '',
              subtitle: s['description_ar'] ?? s['description'] ?? '',
              imageUrl: s['image'] != null 
                ? (s['image'].toString().startsWith('http') 
                    ? s['image'] 
                    : '${ApiService.directBaseUrl}/storage/${s['image']}')
                : '',
              linkType: 'service',
              linkValue: s['id']?.toString() ?? '',
              buttonText: 'احجز الآن',
              gradientStart: '#1E4DB7', // Default or can be added to DB
              gradientEnd: '#3B6BD0',
            );
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching service banners: $e');
      return [];
    }
  }
}
