/// Address Model - نموذج العناوين
class AddressModel {
  final int? id;
  final int userId;
  final String label;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String city;
  final String district;
  final String? notes;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressModel({
    this.id,
    required this.userId,
    required this.label,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.city,
    this.district = '',
    this.notes,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert to Map for JSON/API
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'full_name': fullName,
      'phone': phoneNumber, // backend uses 'phone'
      'street_address': address, // backend uses 'street_address'
      'city': city,
      'district': district,
      'notes': notes,
      'is_default': isDefault ? 1 : 0,
    };
  }

  /// Create from Map
  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] as int?,
      userId: map['user_id'] is String ? int.tryParse(map['user_id']) ?? 0 : (map['user_id'] as int? ?? 0),
      label: map['label'] ?? 'المنزل',
      fullName: map['full_name'] ?? '',
      phoneNumber: map['phone'] ?? '', // backend uses 'phone'
      address: map['street_address'] ?? '', // backend uses 'street_address'
      city: map['city'] ?? '',
      district: map['district'] ?? '',
      notes: map['notes'],
      isDefault: map['is_default'] == 1 || map['is_default'] == true,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
    );
  }

  /// Copy with new values
  AddressModel copyWith({
    int? id,
    int? userId,
    String? label,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? city,
    String? district,
    String? notes,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      district: district ?? this.district,
      notes: notes ?? this.notes,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get display address
  String get displayAddress {
    final parts = <String>[];
    if (address.isNotEmpty) parts.add(address);
    if (district.isNotEmpty) parts.add(district);
    if (city.isNotEmpty) parts.add(city);
    return parts.join(' - ');
  }

  /// Get label in Arabic
  String get labelArabic {
    switch (label.toLowerCase()) {
      case 'home':
      case 'المنزل':
        return 'المنزل';
      case 'work':
      case 'العمل':
        return 'العمل';
      case 'other':
      case 'أخرى':
        return 'أخرى';
      default:
        return label;
    }
  }

  @override
  String toString() {
    return 'AddressModel(id: $id, label: $label, address: $address, city: $city)';
  }
}
