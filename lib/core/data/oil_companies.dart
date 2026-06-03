import 'package:flutter/material.dart';

// ========== Oil Company Model ==========

class OilCompany {
  final String id;
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
}

class OilViscosity {
  final String id;
  final String name;
  final String nameEn;
  final String grade;
  final IconData icon;
  final String description;

  OilViscosity({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.grade,
    required this.icon,
    required this.description,
  });
}

// ========== Oil Type/Grade Filter ==========
// تصنيفات الزيت (نوع التوليف)

class OilType {
  final String id;
  final String name;
  final String nameEn;
  final Color color;
  final IconData icon;

  OilType({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.color,
    required this.icon,
  });
}

// قائمة تصنيفات الزيت (أضف أو احذف حسب الرغبة)
final List<OilType> oilTypes = [
  OilType(
    id: '1',
    name: 'اصطناعي',
    nameEn: 'Full Synthetic',
    color: const Color(0xFF4CAF50),
    icon: Icons.stars,
  ),
  OilType(
    id: '2',
    name: 'شبه اصطناعي',
    nameEn: 'Semi-Synthetic',
    color: const Color(0xFF2196F3),
    icon: Icons.timeline,
  ),
  OilType(
    id: '3',
    name: 'معدني',
    nameEn: 'Mineral',
    color: const Color(0xFFFF9800),
    icon: Icons.opacity,
  ),
];

// ========== Oil Companies Data ==========
// أضف أو احذف الشركات حسب رغبتك
// أضف أو احذف اللزوجات لكل شركة حسب رغبتك

final List<OilCompany> oilCompanies = [
  // موبيل - Mobil
  OilCompany(
    id: '1',
    name: 'موبيل',
    nameEn: 'MOBIL',
    logoUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Mobil_Logo.svg/1200px-Mobil_Logo.svg.png',
    color: const Color(0xFF0072CE),
    viscosities: [
      OilViscosity(
        id: '1_1',
        name: '0W-20',
        nameEn: '0W-20',
        grade: 'Super Mobility',
        icon: Icons.speed,
        description: 'توفير الوقود',
      ),
      OilViscosity(
        id: '1_2',
        name: '0W-40',
        nameEn: '0W-40',
        grade: 'Super Mobility',
        icon: Icons.speed,
        description: 'أداء عالي',
      ),
      OilViscosity(
        id: '1_3',
        name: '5W-30',
        nameEn: '5W-30',
        grade: 'Super Mobility',
        icon: Icons.speed,
        description: 'توفير الوقود',
      ),
      OilViscosity(
        id: '1_4',
        name: '5W-40',
        nameEn: '5W-40',
        grade: 'Super Mobility',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '1_5',
        name: '10W-40',
        nameEn: '10W-40',
        grade: 'Mobility',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '1_6',
        name: '15W-40',
        nameEn: '15W-40',
        grade: 'Mobility',
        icon: Icons.speed,
        description: 'محركات diesel',
      ),
    ],
  ),

  // شل - Shell
  OilCompany(
    id: '2',
    name: 'شل',
    nameEn: 'SHELL',
    logoUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/Shelby_Company_logo.svg/1200px-Shelby_Company_logo.svg.png',
    color: const Color(0xFFFFCC00),
    viscosities: [
      OilViscosity(
        id: '2_1',
        name: '0W-20',
        nameEn: '0W-20',
        grade: 'Helix Ultra',
        icon: Icons.speed,
        description: 'توفير الوقود',
      ),
      OilViscosity(
        id: '2_2',
        name: '5W-30',
        nameEn: '5W-30',
        grade: 'Helix Ultra',
        icon: Icons.speed,
        description: 'أداء عالي',
      ),
      OilViscosity(
        id: '2_3',
        name: '5W-40',
        nameEn: '5W-40',
        grade: 'Helix HX7',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '2_4',
        name: '10W-40',
        nameEn: '10W-40',
        grade: 'Helix HX5',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '2_5',
        name: '15W-40',
        nameEn: '15W-40',
        grade: 'Helix HX3',
        icon: Icons.speed,
        description: 'محركات قديمة',
      ),
    ],
  ),

  // موتول - Motul
  OilCompany(
    id: '3',
    name: 'موتول',
    nameEn: 'MOTUL',
    logoUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Motul_Logo.svg/1200px-Motul_Logo.svg.png',
    color: const Color(0xFFE53935),
    viscosities: [
      OilViscosity(
        id: '3_1',
        name: '0W-20',
        nameEn: '0W-20',
        grade: '8100 X-CESS',
        icon: Icons.speed,
        description: 'توفير الوقود',
      ),
      OilViscosity(
        id: '3_2',
        name: '5W-30',
        nameEn: '5W-30',
        grade: '8100 X-CESS',
        icon: Icons.speed,
        description: 'محركات البنزين',
      ),
      OilViscosity(
        id: '3_3',
        name: '5W-40',
        nameEn: '5W-40',
        grade: '8100 X-MAX',
        icon: Icons.speed,
        description: 'أداء عالي',
      ),
      OilViscosity(
        id: '3_4',
        name: '10W-40',
        nameEn: '10W-40',
        grade: '6100 SYNERGIE',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '3_5',
        name: '20W-50',
        nameEn: '20W-50',
        grade: 'MEDIUM',
        icon: Icons.speed,
        description: 'محركات قديمة',
      ),
    ],
  ),

  // كاسترول - Castrol
  OilCompany(
    id: '4',
    name: 'كاسترول',
    nameEn: 'CASTROL',
    logoUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/61/Castrol_Logo.svg/1200px-Castrol_Logo.svg.png',
    color: const Color(0xFFE53935),
    viscosities: [
      OilViscosity(
        id: '4_1',
        name: '0W-20',
        nameEn: '0W-20',
        grade: 'EDGE',
        icon: Icons.speed,
        description: 'توفير الوقود',
      ),
      OilViscosity(
        id: '4_2',
        name: '5W-30',
        nameEn: '5W-30',
        grade: 'EDGE',
        icon: Icons.speed,
        description: 'أداء عالي',
      ),
      OilViscosity(
        id: '4_3',
        name: '5W-40',
        nameEn: '5W-40',
        grade: 'EDGE',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '4_4',
        name: '10W-40',
        nameEn: '10W-40',
        grade: 'Magnatec',
        icon: Icons.speed,
        description: 'حماية المحرك',
      ),
      OilViscosity(
        id: '4_5',
        name: '15W-40',
        nameEn: '15W-40',
        grade: 'GTX',
        icon: Icons.speed,
        description: 'محركات diesel',
      ),
    ],
  ),

  // توتال - Total
  OilCompany(
    id: '5',
    name: 'توتال',
    nameEn: 'TOTAL',
    logoUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/TotalEnergies_Logo.svg/1200px-TotalEnergies_Logo.svg.png',
    color: const Color(0xFF000000),
    viscosities: [
      OilViscosity(
        id: '5_1',
        name: '0W-30',
        nameEn: '0W-30',
        grade: 'Quartz Ineo',
        icon: Icons.speed,
        description: 'توفير الوقود',
      ),
      OilViscosity(
        id: '5_2',
        name: '5W-30',
        nameEn: '5W-30',
        grade: 'Quartz Ineo',
        icon: Icons.speed,
        description: 'أداء عالي',
      ),
      OilViscosity(
        id: '5_3',
        name: '5W-40',
        nameEn: '5W-40',
        grade: 'Quartz 9000',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '5_4',
        name: '10W-40',
        nameEn: '10W-40',
        grade: 'Quartz 7000',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '5_5',
        name: '15W-40',
        nameEn: '15W-40',
        grade: 'Quartz 5000',
        icon: Icons.speed,
        description: 'محركات diesel',
      ),
    ],
  ),

  // يورل - YUROL
  OilCompany(
    id: '6',
    name: 'يورل',
    nameEn: 'YUROL',
    logoUrl: 'https://via.placeholder.com/100x100/1E3A5C/FFFFFF?text=YUROL',
    color: const Color(0xFF1E3A5C),
    viscosities: [
      OilViscosity(
        id: '6_1',
        name: '0W-30',
        nameEn: '0W-30',
        grade: 'Super Synthetic',
        icon: Icons.speed,
        description: 'أفضل حماية',
      ),
      OilViscosity(
        id: '6_2',
        name: '5W-30',
        nameEn: '5W-30',
        grade: 'Super Synthetic',
        icon: Icons.speed,
        description: 'توفير الوقود',
      ),
      OilViscosity(
        id: '6_3',
        name: '5W-40',
        nameEn: '5W-40',
        grade: 'Super Synthetic',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '6_4',
        name: '10W-40',
        nameEn: '10W-40',
        grade: 'Semi-Synthetic',
        icon: Icons.speed,
        description: 'محركات轿车',
      ),
      OilViscosity(
        id: '6_5',
        name: '15W-40',
        nameEn: '15W-40',
        grade: 'Mineral',
        icon: Icons.speed,
        description: 'Heavy Duty',
      ),
    ],
  ),

  // ليكويمولي - Liqui Moly
  OilCompany(
    id: '7',
    name: 'ليكويمولي',
    nameEn: 'LIQUI MOLY',
    logoUrl:
        'https://via.placeholder.com/100x100/1E88E5/FFFFFF?text=LIQUI+ MOLY',
    color: const Color(0xFF1E88E5),
    viscosities: [
      OilViscosity(
        id: '7_1',
        name: '0W-30',
        nameEn: '0W-30',
        grade: 'Top Tec',
        icon: Icons.speed,
        description: 'توفير الوقود الأقصى',
      ),
      OilViscosity(
        id: '7_2',
        name: '5W-30',
        nameEn: '5W-30',
        grade: 'Top Tec',
        icon: Icons.speed,
        description: 'محركات البنزين',
      ),
      OilViscosity(
        id: '7_3',
        name: '5W-40',
        nameEn: '5W-40',
        grade: 'Top Tec',
        icon: Icons.speed,
        description: 'أداء عالي',
      ),
      OilViscosity(
        id: '7_4',
        name: '10W-40',
        nameEn: '10W-40',
        grade: 'Leichtlauf',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
    ],
  ),

  // امسويل - AMSOIL
  OilCompany(
    id: '8',
    name: 'امسويل',
    nameEn: 'AMSOIL',
    logoUrl: 'https://via.placeholder.com/100x100/FF6B35/FFFFFF?text=AMSOIL',
    color: const Color(0xFFFF6B35),
    viscosities: [
      OilViscosity(
        id: '8_1',
        name: '0W-40',
        nameEn: '0W-40',
        grade: 'Signature Series',
        icon: Icons.speed,
        description: 'أداء عالي',
      ),
      OilViscosity(
        id: '8_2',
        name: '5W-30',
        nameEn: '5W-30',
        grade: 'Signature Series',
        icon: Icons.speed,
        description: 'توفير الوقود',
      ),
      OilViscosity(
        id: '8_3',
        name: '5W-40',
        nameEn: '5W-40',
        grade: 'Signature Series',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '8_4',
        name: '10W-40',
        nameEn: '10W-40',
        grade: 'XL Series',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
    ],
  ),

  // بينزين - Pennzoil
  OilCompany(
    id: '9',
    name: 'بينزين',
    nameEn: 'PENNZOIL',
    logoUrl: 'https://via.placeholder.com/100x100/FF0000/FFFFFF?text=PENNZOIL',
    color: const Color(0xFFFF0000),
    viscosities: [
      OilViscosity(
        id: '9_1',
        name: '0W-20',
        nameEn: '0W-20',
        grade: 'Platinum',
        icon: Icons.speed,
        description: 'توفير الوقود',
      ),
      OilViscosity(
        id: '9_2',
        name: '5W-30',
        nameEn: '5W-30',
        grade: 'Platinum',
        icon: Icons.speed,
        description: 'أداء عالي',
      ),
      OilViscosity(
        id: '9_3',
        name: '5W-40',
        nameEn: '5W-40',
        grade: 'Platinum',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '9_4',
        name: '10W-40',
        nameEn: '10W-40',
        grade: 'Ultra',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
    ],
  ),

  // فالف - Valvoline
  OilCompany(
    id: '10',
    name: 'فالف',
    nameEn: 'VALVOLINE',
    logoUrl: 'https://via.placeholder.com/100x100/FF0000/FFFFFF?text=VALVOLINE',
    color: const Color(0xFFFF0000),
    viscosities: [
      OilViscosity(
        id: '10_1',
        name: '0W-20',
        nameEn: '0W-20',
        grade: 'MaxLife',
        icon: Icons.speed,
        description: 'توفير الوقود',
      ),
      OilViscosity(
        id: '10_2',
        name: '5W-30',
        nameEn: '5W-30',
        grade: 'MaxLife',
        icon: Icons.speed,
        description: 'محركات قديمة',
      ),
      OilViscosity(
        id: '10_3',
        name: '5W-40',
        nameEn: '5W-40',
        grade: 'Premium',
        icon: Icons.speed,
        description: 'أداء عالي',
      ),
      OilViscosity(
        id: '10_4',
        name: '10W-40',
        nameEn: '10W-40',
        grade: 'Premium',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '10_5',
        name: '20W-50',
        nameEn: '20W-50',
        grade: 'Heavy Duty',
        icon: Icons.speed,
        description: 'محركات diesel',
      ),
    ],
  ),

  // ريد_inline - Red Line
  OilCompany(
    id: '11',
    name: 'ريدلاين',
    nameEn: 'RED LINE',
    logoUrl: 'https://via.placeholder.com/100x100/FF0000/FFFFFF?text=RED+LINE',
    color: const Color(0xFFFF0000),
    viscosities: [
      OilViscosity(
        id: '11_1',
        name: '0W-20',
        nameEn: '0W-20',
        grade: 'Synthetic',
        icon: Icons.speed,
        description: 'أداء رياضي',
      ),
      OilViscosity(
        id: '11_2',
        name: '5W-30',
        nameEn: '5W-30',
        grade: 'Synthetic',
        icon: Icons.speed,
        description: 'أداء عالي',
      ),
      OilViscosity(
        id: '11_3',
        name: '10W-40',
        nameEn: '10W-40',
        grade: 'Synthetic',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '11_4',
        name: '20W-50',
        nameEn: '20W-50',
        grade: 'Synthetic',
        icon: Icons.speed,
        description: 'محركات رياضية',
      ),
    ],
  ),

  // كيو - KEO
  OilCompany(
    id: '12',
    name: 'كيو',
    nameEn: 'KEO',
    logoUrl: 'https://via.placeholder.com/100x100/1E88E5/FFFFFF?text=KEO',
    color: const Color(0xFF1E88E5),
    viscosities: [
      OilViscosity(
        id: '12_1',
        name: '0W-40',
        nameEn: '0W-40',
        grade: 'Full Synthetic',
        icon: Icons.speed,
        description: 'مناسب للمناخ البارد',
      ),
      OilViscosity(
        id: '12_2',
        name: '5W-30',
        nameEn: '5W-30',
        grade: 'Full Synthetic',
        icon: Icons.speed,
        description: 'توفير الوقود',
      ),
      OilViscosity(
        id: '12_3',
        name: '5W-40',
        nameEn: '5W-40',
        grade: 'Full Synthetic',
        icon: Icons.speed,
        description: 'أداء عالي',
      ),
      OilViscosity(
        id: '12_4',
        name: '10W-40',
        nameEn: '10W-40',
        grade: 'Semi-Synthetic',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '12_5',
        name: '15W-40',
        nameEn: '15W-40',
        grade: 'Mineral',
        icon: Icons.speed,
        description: 'Heavy Duty',
      ),
    ],
  ),
];
