/// Payment Method Model - نموذج طرق الدفع
class PaymentMethodModel {
  final int? id;
  final int userId;
  final String type; // 'card', 'wallet', 'cash'
  final String cardNumber; // Last 4 digits only
  final String cardHolderName;
  final String expiryMonth;
  final String expiryYear;
  final String? cardType; // 'visa', 'mastercard', 'mada'
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentMethodModel({
    this.id,
    required this.userId,
    required this.type,
    this.cardNumber = '',
    this.cardHolderName = '',
    this.expiryMonth = '',
    this.expiryYear = '',
    this.cardType,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert to Map for JSON/API
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'card_number': cardNumber,
      'card_holder_name': cardHolderName,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'card_type': cardType,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create from Map
  factory PaymentMethodModel.fromMap(Map<String, dynamic> map) {
    return PaymentMethodModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      type: map['type'] ?? 'card',
      cardNumber: map['card_number'] ?? '',
      cardHolderName: map['card_holder_name'] ?? '',
      expiryMonth: map['expiry_month'] ?? '',
      expiryYear: map['expiry_year'] ?? '',
      cardType: map['card_type'],
      isDefault: map['is_default'] == 1 || map['is_default'] == true,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'])
          : null,
    );
  }

  /// Copy with new values
  PaymentMethodModel copyWith({
    int? id,
    int? userId,
    String? type,
    String? cardNumber,
    String? cardHolderName,
    String? expiryMonth,
    String? expiryYear,
    String? cardType,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cardType: cardType ?? this.cardType,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get masked card number (show last 4 digits)
  String get maskedCardNumber {
    if (cardNumber.isEmpty) return '';
    if (cardNumber.length <= 4) return '****$cardNumber';
    return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }

  /// Get display name
  String get displayName {
    switch (type) {
      case 'card':
        return 'بطاقة ${cardType?.toUpperCase() ?? 'بنكية'}';
      case 'wallet':
        return 'محفظة إلكترونية';
      case 'cash':
        return 'دفع نقدي';
      default:
        return 'طريقة دفع';
    }
  }

  /// Get type in Arabic
  String get typeArabic {
    switch (type) {
      case 'card':
        return 'بطاقة بنكية';
      case 'wallet':
        return 'محفظة إلكترونية';
      case 'cash':
        return 'دفع عند الاستلام';
      default:
        return type;
    }
  }

  /// Get card icon based on card type
  String get cardIcon {
    switch (cardType?.toLowerCase()) {
      case 'visa':
        return 'visa';
      case 'mastercard':
        return 'mastercard';
      case 'mada':
        return 'mada';
      default:
        return 'card';
    }
  }

  /// Check if card is expired
  bool get isExpired {
    if (expiryMonth.isEmpty || expiryYear.isEmpty) return false;

    final now = DateTime.now();
    final expiry = DateTime(
      int.tryParse(expiryYear) ?? 0,
      int.tryParse(expiryMonth) ?? 0,
    );

    return expiry.isBefore(now);
  }

  /// Get expiry display
  String get expiryDisplay {
    if (expiryMonth.isEmpty || expiryYear.isEmpty) return '';
    return '$expiryMonth/$expiryYear';
  }

  @override
  String toString() {
    return 'PaymentMethodModel(id: $id, type: $type, cardNumber: $maskedCardNumber)';
  }
}
