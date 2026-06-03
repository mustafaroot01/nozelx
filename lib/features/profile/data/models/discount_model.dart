class DiscountModel {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final double discountPercentage;
  final String couponCode;
  final int requiredOrders;
  final int requiredPoints;
  final double minOrder;
  final double maxDiscount;
  final int? usageLimit;
  final int usedCount;
  final String? expiryDate;
  final bool status;
  final int sortOrder;
  final bool unlocked;
  final bool claimed;
  final double progress;
  final int userOrders;
  final int userPoints;
  final String? claimedAt;

  DiscountModel({
    required this.id,
    required this.title,
    this.description = '',
    this.imageUrl = '',
    required this.discountPercentage,
    required this.couponCode,
    this.requiredOrders = 0,
    this.requiredPoints = 0,
    this.minOrder = 0,
    this.maxDiscount = 0,
    this.usageLimit,
    this.usedCount = 0,
    this.expiryDate,
    this.status = true,
    this.sortOrder = 0,
    this.unlocked = false,
    this.claimed = false,
    this.progress = 0,
    this.userOrders = 0,
    this.userPoints = 0,
    this.claimedAt,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      discountPercentage:
          double.tryParse(json['discount_percentage']?.toString() ?? '0') ?? 0,
      couponCode: json['coupon_code'] ?? json['couponCode'] ?? '',
      requiredOrders:
          int.tryParse(json['required_orders']?.toString() ?? '0') ?? 0,
      requiredPoints:
          int.tryParse(json['required_points']?.toString() ?? '0') ?? 0,
      minOrder: double.tryParse(json['min_order']?.toString() ?? '0') ?? 0,
      maxDiscount:
          double.tryParse(json['max_discount']?.toString() ?? '0') ?? 0,
      usageLimit: json['usage_limit'] != null
          ? int.tryParse(json['usage_limit'].toString())
          : null,
      usedCount: int.tryParse(json['used_count']?.toString() ?? '0') ?? 0,
      expiryDate: json['expiry_date'],
      status: json['status'] == 1 || json['status'] == true,
      sortOrder: int.tryParse(json['sort_order']?.toString() ?? '0') ?? 0,
      unlocked: json['unlocked'] == true || json['unlocked'] == 1,
      claimed: json['claimed'] == true || json['claimed'] == 1,
      progress: double.tryParse(json['progress']?.toString() ?? '0') ?? 0,
      userOrders:
          int.tryParse(
            json['user_orders']?.toString() ??
                json['user_stats']?['order_count']?.toString() ??
                '0',
          ) ??
          0,
      userPoints:
          int.tryParse(
            json['user_points']?.toString() ??
                json['user_stats']?['user_points']?.toString() ??
                '0',
          ) ??
          0,
      claimedAt: json['claimed_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'discount_percentage': discountPercentage,
      'coupon_code': couponCode,
      'required_orders': requiredOrders,
      'required_points': requiredPoints,
      'min_order': minOrder,
      'max_discount': maxDiscount,
      'usage_limit': usageLimit,
      'used_count': usedCount,
      'expiry_date': expiryDate,
      'status': status,
      'sort_order': sortOrder,
      'unlocked': unlocked,
      'claimed': claimed,
      'progress': progress,
      'user_orders': userOrders,
      'user_points': userPoints,
      'claimed_at': claimedAt,
    };
  }
}
