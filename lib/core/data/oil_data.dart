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

// ========== Oil Companies Data ==========

final List<OilCompany> oilCompanies = [
  OilCompany(
    id: '1',
    name: 'كيو',
    nameEn: 'KEO',
    logoUrl: 'https://via.placeholder.com/100x100/1E88E5/FFFFFF?text=KEO',
    color: const Color(0xFF1E88E5),
    viscosities: [
      OilViscosity(
        id: '1_1',
        name: '0W-40',
        nameEn: '0W-40',
        grade: 'Full Synthetic',
        icon: Icons.speed,
        description: 'مناسب للمناخ البارد',
      ),
      OilViscosity(
        id: '1_2',
        name: '5W-30',
        nameEn: '5W-30',
        grade: 'Full Synthetic',
        icon: Icons.speed,
        description: 'توفير الوقود',
      ),
      OilViscosity(
        id: '1_3',
        name: '5W-40',
        nameEn: '5W-40',
        grade: 'Full Synthetic',
        icon: Icons.speed,
        description: 'أداء عالي',
      ),
      OilViscosity(
        id: '1_4',
        name: '10W-40',
        nameEn: '10W-40',
        grade: 'Semi-Synthetic',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '1_5',
        name: '15W-40',
        nameEn: '15W-40',
        grade: 'Mineral',
        icon: Icons.speed,
        description: 'Heavy Duty',
      ),
    ],
  ),
  OilCompany(
    id: '2',
    name: 'موتول',
    nameEn: 'MOTUL',
    logoUrl: 'https://via.placeholder.com/100x100/E53935/FFFFFF?text=MOTUL',
    color: const Color(0xFFE53935),
    viscosities: [
      OilViscosity(
        id: '2_1',
        name: '0W-20',
        nameEn: '0W-20',
        grade: '8100 X-CESS',
        icon: Icons.speed,
        description: 'توفير الوقود الأقصى',
      ),
      OilViscosity(
        id: '2_2',
        name: '5W-30',
        nameEn: '5W-30',
        grade: '8100 X-CESS',
        icon: Icons.speed,
        description: 'محركات البنزين',
      ),
      OilViscosity(
        id: '2_3',
        name: '5W-40',
        nameEn: '5W-40',
        grade: '8100 X-MAX',
        icon: Icons.speed,
        description: 'أداء عالي',
      ),
      OilViscosity(
        id: '2_4',
        name: '10W-40',
        nameEn: '10W-40',
        grade: '6100 SYNERGIE',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '2_5',
        name: '20W-50',
        nameEn: '20W-50',
        grade: 'MEDIUM',
        icon: Icons.speed,
        description: 'محركات قديمة',
      ),
    ],
  ),
  OilCompany(
    id: '3',
    name: 'يورل',
    nameEn: 'YUROL',
    logoUrl: 'https://via.placeholder.com/100x100/1E3A5C/FFFFFF?text=YUROL',
    color: const Color(0xFF1E3A5C),
    viscosities: [
      OilViscosity(
        id: '3_1',
        name: '0W-30',
        nameEn: '0W-30',
        grade: 'Super Synthetic',
        icon: Icons.speed,
        description: 'أفضل حماية',
      ),
      OilViscosity(
        id: '3_2',
        name: '5W-30',
        nameEn: '5W-30',
        grade: 'Super Synthetic',
        icon: Icons.speed,
        description: 'توفير الوقود',
      ),
      OilViscosity(
        id: '3_3',
        name: '5W-40',
        nameEn: '5W-40',
        grade: 'Super Synthetic',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '3_4',
        name: '10W-40',
        nameEn: '10W-40',
        grade: 'Semi-Synthetic',
        icon: Icons.speed,
        description: 'محركات轿车',
      ),
      OilViscosity(
        id: '3_5',
        name: '15W-40',
        nameEn: '15W-40',
        grade: 'Mineral',
        icon: Icons.speed,
        description: 'Heavy Duty',
      ),
    ],
  ),
  OilCompany(
    id: '4',
    name: 'موبيل',
    nameEn: 'MOBIL',
    logoUrl: 'https://via.placeholder.com/100x100/0072CE/FFFFFF?text=MOBIL',
    color: const Color(0xFF0072CE),
    viscosities: [
      OilViscosity(
        id: '4_1',
        name: '0W-20',
        nameEn: '0W-20',
        grade: 'Super Mobility',
        icon: Icons.speed,
        description: 'توفير الوقود',
      ),
      OilViscosity(
        id: '4_2',
        name: '0W-40',
        nameEn: '0W-40',
        grade: 'Super Mobility',
        icon: Icons.speed,
        description: 'أداء عالي',
      ),
      OilViscosity(
        id: '4_3',
        name: '5W-30',
        nameEn: '5W-30',
        grade: 'Super Mobility',
        icon: Icons.speed,
        description: 'توفير الوقود',
      ),
      OilViscosity(
        id: '4_4',
        name: '5W-40',
        nameEn: '5W-40',
        grade: 'Super Mobility',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '4_5',
        name: '10W-40',
        nameEn: '10W-40',
        grade: 'Mobility',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
    ],
  ),
  OilCompany(
    id: '5',
    name: 'مول',
    nameEn: 'MUL',
    logoUrl: 'https://via.placeholder.com/100x100/FF6B35/FFFFFF?text=MUL',
    color: const Color(0xFFFF6B35),
    viscosities: [
      OilViscosity(
        id: '5_1',
        name: '5W-30',
        nameEn: '5W-30',
        grade: 'Premium',
        icon: Icons.speed,
        description: 'توفير الوقود',
      ),
      OilViscosity(
        id: '5_2',
        name: '5W-40',
        nameEn: '5W-40',
        grade: 'Premium',
        icon: Icons.speed,
        description: 'أداء عالي',
      ),
      OilViscosity(
        id: '5_3',
        name: '10W-40',
        nameEn: '10W-40',
        grade: 'Standard',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
      OilViscosity(
        id: '5_4',
        name: '15W-40',
        nameEn: '15W-40',
        grade: 'Standard',
        icon: Icons.speed,
        description: 'Heavy Duty',
      ),
      OilViscosity(
        id: '5_5',
        name: '20W-50',
        nameEn: '20W-50',
        grade: 'Heavy Duty',
        icon: Icons.speed,
        description: 'محركات قديمة',
      ),
    ],
  ),
  OilCompany(
    id: '6',
    name: 'امسويل',
    nameEn: 'AMSOIL',
    logoUrl: 'https://via.placeholder.com/100x100/FF6B35/FFFFFF?text=AMSOIL',
    color: const Color(0xFFFF6B35),
    viscosities: [
      OilViscosity(
        id: '6_1',
        name: '0W-40',
        nameEn: '0W-40',
        grade: 'Signature Series',
        icon: Icons.speed,
        description: 'أداء عالي',
      ),
      OilViscosity(
        id: '6_2',
        name: '5W-30',
        nameEn: '5W-30',
        grade: 'Signature Series',
        icon: Icons.speed,
        description: 'توفير الوقود',
      ),
      OilViscosity(
        id: '6_3',
        name: '5W-40',
        nameEn: '5W-40',
        grade: 'Signature Series',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
    ],
  ),
  OilCompany(
    id: '7',
    name: 'ليكويمولي',
    nameEn: 'LIQUI MOLY',
    logoUrl:
        'https://via.placeholder.com/100x100/1E88E5/FFFFFF?text=LIQUI MOLY',
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
    ],
  ),
  OilCompany(
    id: '8',
    name: 'كاسترول',
    nameEn: 'CASTROL',
    logoUrl: 'https://via.placeholder.com/100x100/E53935/FFFFFF?text=CASTROL',
    color: const Color(0xFFE53935),
    viscosities: [
      OilViscosity(
        id: '8_1',
        name: '0W-20',
        nameEn: '0W-20',
        grade: 'EDGE',
        icon: Icons.speed,
        description: 'توفير الوقود',
      ),
      OilViscosity(
        id: '8_2',
        name: '5W-30',
        nameEn: '5W-30',
        grade: 'EDGE',
        icon: Icons.speed,
        description: 'أداء عالي',
      ),
      OilViscosity(
        id: '8_3',
        name: '5W-40',
        nameEn: '5W-40',
        grade: 'EDGE',
        icon: Icons.speed,
        description: 'استخدام عام',
      ),
    ],
  ),
];
