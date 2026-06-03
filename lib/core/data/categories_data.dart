import 'package:flutter/material.dart';
import 'package:auto_lube/core/services/api_service.dart';

// ========== Models ==========

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  final int productCount;
  final String description;
  final String? imageUrl;
  final bool hasSubCategories;
  final List<SubCategory>? subCategories;
  final List<String>? features;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.productCount,
    required this.description,
    this.imageUrl,
    this.hasSubCategories = false,
    this.subCategories,
    this.features,
  });

  /// Create Category from API JSON response
  factory Category.fromJson(Map<String, dynamic> json) {
    final color = _parseColor(json['color']?.toString() ?? '#1E4DB7');
    final subs = (json['sub_categories'] as List<dynamic>? ?? json['subcategories'] as List<dynamic>? ?? [])
        .map((s) => SubCategory.fromJson(s as Map<String, dynamic>))
        .toList();

    // Fix: Use image_url from API and ensure it's absolute, fallback to icon_url if missing
    String? imageUrl = json['image_url']?.toString() ?? 
                       json['icon_url']?.toString() ?? 
                       json['image']?.toString();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      imageUrl = ApiService.fixImageUrl(imageUrl);
    }

    return Category(
      id: json['id'].toString(),
      name: json['name_ar']?.toString() ?? json['name']?.toString() ?? '',
      icon: _parseIcon(json['icon']?.toString() ?? 'folder'),
      color: color,
      gradient: [color.withOpacity(0.15), color.withOpacity(0.02)],
      productCount:
          int.tryParse(json['products_count']?.toString() ?? json['product_count']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString() ?? '',
      imageUrl: (imageUrl?.isNotEmpty == true) ? imageUrl : null,
      hasSubCategories: subs.isNotEmpty || (json['has_subcategories'] == true),
      subCategories: subs.isNotEmpty ? subs : null,
    );
  }

  static Color _parseColor(String hex) {
    try {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}
    return const Color(0xFF1E4DB7);
  }

  static IconData _parseIcon(String iconName) {
    const iconMap = <String, IconData>{
      'oil_barrel': Icons.oil_barrel,
      'filter_alt': Icons.filter_alt,
      'water_drop': Icons.water_drop,
      'battery_charging_full': Icons.battery_charging_full,
      'tire_repair': Icons.tire_repair,
      'build': Icons.build,
      'cleaning_services': Icons.cleaning_services,
      'ac_unit': Icons.ac_unit,
      'thermostat': Icons.thermostat,
      'dashboard': Icons.dashboard,
      'add_circle': Icons.add_circle,
      'car_repair': Icons.car_repair,
      'settings': Icons.settings,
      'local_gas_station': Icons.local_gas_station,
      'engineering': Icons.engineering,
      'handyman': Icons.handyman,
      'electric_bolt': Icons.electric_bolt,
      'directions_car': Icons.directions_car,
      'inventory_2': Icons.inventory_2,
      'folder': Icons.folder,
    };
    return iconMap[iconName] ?? Icons.folder;
  }
}

class SubCategory {
  final String id;
  final String name;
  final String parentId;
  final int productCount;
  final IconData? icon;
  final String? imageUrl;
  final Color? color;

  SubCategory({
    required this.id,
    required this.name,
    required this.parentId,
    required this.productCount,
    this.icon,
    this.imageUrl,
    this.color,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    // Fix: Use image_url from API and ensure it's absolute, fallback to icon_url if missing
    String? imageUrl = json['image_url']?.toString() ?? 
                       json['icon_url']?.toString() ?? 
                       json['image']?.toString();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      imageUrl = ApiService.fixImageUrl(imageUrl);
    }

    return SubCategory(
      id: json['id'].toString(),
      name: json['name_ar']?.toString() ?? json['name']?.toString() ?? '',
      parentId: json['parent_id']?.toString() ?? '0',
      productCount:
          int.tryParse(json['products_count']?.toString() ?? json['product_count']?.toString() ?? '0') ?? 0,
      icon: Category._parseIcon(json['icon']?.toString() ?? 'folder'),
      imageUrl: (imageUrl?.isNotEmpty == true) ? imageUrl : null,
      color: json['color'] != null
          ? Category._parseColor(json['color'].toString())
          : null,
    );
  }
}

// ========== Data ==========

final List<Category> mainCategories = [];
