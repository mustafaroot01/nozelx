class AppSettings {
  static final AppSettings _instance = AppSettings._internal();

  factory AppSettings() {
    return _instance;
  }

  AppSettings._internal();

  // --- Configuration fields with default fallbacks ---
  String storeName = 'نوزل برو';
  String storePhone = '+9647700000000';
  String storeEmail = 'support@nozzle.com';
  String storeAddress = 'العراق، بغداد';
  String invoiceLogo = '';
  double shippingFee = 3000.0;
  double freeShippingThreshold = 100000.0;

  /// Updates settings from a JSON map retrieved from the backend
  void updateFromJson(Map<String, dynamic> json) {
    // 1. Parse store name (handles both String and localized Map)
    final rawName = json['store_name'];
    if (rawName is Map) {
      storeName = rawName['ar']?.toString() ?? rawName['en']?.toString() ?? storeName;
    } else if (rawName is String && rawName.isNotEmpty) {
      storeName = rawName;
    }

    // 2. Contact details
    if (json['store_phone'] != null && json['store_phone'].toString().isNotEmpty) {
      storePhone = json['store_phone'].toString();
    }
    if (json['store_email'] != null && json['store_email'].toString().isNotEmpty) {
      storeEmail = json['store_email'].toString();
    }

    // 3. Parse store address (handles both String and localized Map)
    final rawAddress = json['store_address'];
    if (rawAddress is Map) {
      storeAddress = rawAddress['ar']?.toString() ?? rawAddress['en']?.toString() ?? storeAddress;
    } else if (rawAddress is String && rawAddress.isNotEmpty) {
      storeAddress = rawAddress;
    }

    // 4. Logo
    if (json['invoice_logo'] != null) {
      invoiceLogo = json['invoice_logo'].toString();
    }

    // 5. Fees
    if (json['shipping_fee'] != null) {
      shippingFee = double.tryParse(json['shipping_fee'].toString()) ?? shippingFee;
    }
    if (json['free_shipping_threshold'] != null) {
      freeShippingThreshold = double.tryParse(json['free_shipping_threshold'].toString()) ?? freeShippingThreshold;
    }
  }
}
