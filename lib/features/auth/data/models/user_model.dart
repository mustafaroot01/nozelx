class UserModel {
  final String id;
  final String phoneNumber;
  final String name;
  final String pinCode;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? profileImage;
  final bool isActive;

  UserModel({
    required this.id,
    required this.phoneNumber,
    required this.name,
    this.pinCode = '', // لا يُحفظ محلياً - للتوافق فقط
    required this.createdAt,
    this.lastLoginAt,
    this.profileImage,
    this.isActive = true,
  });

  /// toMap لا يتضمن pinCode لمنع حفظ كلمة المرور محلياً
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      // pinCode مُستبعد عمداً - لا نحفظ كلمة المرور
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'profileImage': profileImage,
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      phoneNumber: map['phoneNumber'] ?? map['phone'] ?? '',
      name: map['name'] ?? '',
      pinCode: '', // لا نقرأ كلمة المرور من التخزين المحلي
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : (map['created_at'] != null
              ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
              : DateTime.now()),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.tryParse(map['lastLoginAt'])
          : (map['last_login_at'] != null
              ? DateTime.tryParse(map['last_login_at'].toString())
              : null),
      profileImage: map['profileImage'] ?? map['avatar'] ?? map['avatar_url'],
      isActive: map['isActive'] ?? true,
    );
  }

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? pinCode,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? profileImage,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      pinCode: pinCode ?? this.pinCode,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      profileImage: profileImage ?? this.profileImage,
      isActive: isActive ?? this.isActive,
    );
  }

}
