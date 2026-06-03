class ServiceBookingModel {
  final int? id;
  final int? userId;
  final int serviceId;
  final String customerName;
  final String customerPhone;
  final String status;
  final DateTime? bookingDate;
  final String? notes;
  final DateTime? createdAt;

  ServiceBookingModel({
    this.id,
    this.userId,
    required this.serviceId,
    required this.customerName,
    required this.customerPhone,
    this.status = 'pending',
    this.bookingDate,
    this.notes,
    this.createdAt,
  });

  factory ServiceBookingModel.fromMap(Map<String, dynamic> map) {
    return ServiceBookingModel(
      id: map['id'],
      userId: map['user_id'],
      serviceId: map['service_id'] ?? 0,
      customerName: map['customer_name'] ?? '',
      customerPhone: map['customer_phone'] ?? '',
      status: map['status'] ?? 'pending',
      bookingDate: map['booking_date'] != null ? DateTime.tryParse(map['booking_date']) : null,
      notes: map['notes'],
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'service_id': serviceId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'booking_date': bookingDate?.toIso8601String(),
      'notes': notes,
    };
  }
}
