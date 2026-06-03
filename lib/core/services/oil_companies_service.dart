import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'api_service.dart';

/// Oil Company Model
class OilCompany {
  final int id;
  final String name;
  final String nameEn;
  final String logoUrl;
  final Color color;
  final List<OilViscosity> viscosities;

  OilCompany({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.logoUrl,
    required this.color,
    required this.viscosities,
  });

  factory OilCompany.fromJson(Map<String, dynamic> json) {
    return OilCompany(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      color: _parseColor(json['color'] ?? '#1E88E5'),
      viscosities:
          (json['viscosities'] as List<dynamic>?)
              ?.map((v) => OilViscosity.fromJson(v))
              .toList() ??
          [],
    );
  }

  static Color _parseColor(String colorHex) {
    try {
      String hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return const Color(0xFF1E88E5);
    }
  }
}

/// Oil Viscosity Model
class OilViscosity {
  final int id;
  final String name;
  final String nameEn;
  final String grade;
  final String description;

  OilViscosity({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.grade,
    required this.description,
  });

  factory OilViscosity.fromJson(Map<String, dynamic> json) {
    return OilViscosity(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      grade: json['grade'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

/// Oil Types (Classification)
class OilType {
  final String name;
  final IconData icon;
  final Color color;

  const OilType({required this.name, required this.icon, required this.color});
}

/// Default oil types
const List<OilType> defaultOilTypes = [
  OilType(name: 'اصطناعي', icon: Icons.bolt, color: Color(0xFF4CAF50)),
  OilType(name: 'شبه اصطناعي', icon: Icons.opacity, color: Color(0xFFFF9800)),
  OilType(name: 'معدني', icon: Icons.water_drop, color: Color(0xFF9E9E9E)),
];

/// Oil Companies Service
class OilCompaniesService {
  static const String _baseUrl = ApiService.baseUrl;

  static List<OilCompany> _cachedCompanies = [];
  static DateTime? _lastFetch;
  static const Duration _cacheDuration = Duration(minutes: 30);

  /// Get oil companies from server or cache
  static Future<List<OilCompany>> getCompanies({
    bool forceRefresh = false,
  }) async {
    // Check if cache is valid
    if (!forceRefresh &&
        _cachedCompanies.isNotEmpty &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheDuration) {
      return _cachedCompanies;
    }

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/oil_companies.php'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final companiesList = data['data']['companies'] as List<dynamic>;
          _cachedCompanies = companiesList
              .map((c) => OilCompany.fromJson(c))
              .toList();
          _lastFetch = DateTime.now();
          return _cachedCompanies;
        }
      }
    } catch (e) {
      debugPrint('Error fetching oil companies: $e');
    }

    // Return cached data if available, otherwise return empty list
    return _cachedCompanies;
  }

  /// Get default companies for offline/fallback
  static List<OilCompany> getDefaultCompanies() {
    return [];
  }
}
