class UserStatsModel {
  final int ordersCount;
  final int completedOrders;
  final int cancelledOrders;
  final int serviceRequestsCount;
  final int favoritesCount;
  final int couponsUsedCount;
  final double totalSavings;

  const UserStatsModel({
    this.ordersCount = 0,
    this.completedOrders = 0,
    this.cancelledOrders = 0,
    this.serviceRequestsCount = 0,
    this.favoritesCount = 0,
    this.couponsUsedCount = 0,
    this.totalSavings = 0,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> j) => UserStatsModel(
        ordersCount: j['orders_count'] as int? ?? 0,
        completedOrders: j['completed_orders'] as int? ?? 0,
        cancelledOrders: j['cancelled_orders'] as int? ?? 0,
        serviceRequestsCount: j['service_requests_count'] as int? ?? 0,
        favoritesCount: j['favorites_count'] as int? ?? 0,
        couponsUsedCount: j['coupons_used_count'] as int? ?? 0,
        totalSavings: (j['total_savings'] as num?)?.toDouble() ?? 0.0,
      );

  static const empty = UserStatsModel();
}

class UserModel {
  final int id;
  final String name;
  final String phone;
  final String? avatarUrl;
  final String token;
  final int totalOrders;
  final double totalSpent;
  final UserStatsModel stats;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.token,
    this.avatarUrl,
    this.totalOrders = 0,
    this.totalSpent = 0,
    this.stats = UserStatsModel.empty,
    required this.createdAt,
    this.lastLoginAt,
  });

  String get initials {
    final p = name.trim().split(' ');
    if (p.length >= 2) {
      return '${p[0][0]}${p[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'م';
  }

  factory UserModel.fromJson(Map<String, dynamic> j) {
    // Robust parsing to prevent crash if backend returns strings/ints differently
    final rawId = j['id'];
    final parsedId = rawId is int ? rawId : (int.tryParse(rawId.toString()) ?? 0);
    
    return UserModel(
      id: parsedId,
      name: (j['name'] ?? j['full_name'])?.toString() ?? '',
      phone: j['phone']?.toString() ?? '',
      token: j['token']?.toString() ?? '',
      avatarUrl: j['avatar_url']?.toString(),
      totalOrders: j['total_orders'] as int? ?? 0,
      totalSpent: (j['total_spent'] as num?)?.toDouble() ?? 0.0,
      stats: j['stats'] != null
          ? UserStatsModel.fromJson(j['stats'] as Map<String, dynamic>)
          : UserStatsModel.empty,
      createdAt: j['created_at'] != null
          ? (DateTime.tryParse(j['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
      lastLoginAt: j['last_login_at'] != null
          ? DateTime.tryParse(j['last_login_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'token': token,
        'avatar_url': avatarUrl,
        'total_orders': totalOrders,
        'total_spent': totalSpent,
        'created_at': createdAt.toIso8601String(),
        'last_login_at': lastLoginAt?.toIso8601String(),
      };

  UserModel copyWith({
    String? name,
    String? avatarUrl,
    UserStatsModel? stats,
  }) =>
      UserModel(
        id: id,
        phone: phone,
        token: token,
        name: name ?? this.name,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        totalOrders: totalOrders,
        totalSpent: totalSpent,
        stats: stats ?? this.stats,
        createdAt: createdAt,
        lastLoginAt: lastLoginAt,
      );
}
