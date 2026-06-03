import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_lube/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_lube/core/network/dio_client.dart';

class CenterService {
  final int id;
  final String name;
  final String nameEn;
  final String? description;
  final String icon;
  final String? image;
  final int price;
  final int durationMinutes;
  final bool isActive;

  CenterService({
    required this.id,
    required this.name,
    required this.nameEn,
    this.description,
    required this.icon,
    this.image,
    required this.price,
    required this.durationMinutes,
    required this.isActive,
  });

  factory CenterService.fromJson(Map<String, dynamic> json) {
    return CenterService(
      id: json['id'] ?? 0,
      name: json['title_ar'] ?? json['name'] ?? '',
      nameEn: json['title'] ?? json['name_en'] ?? '',
      description: json['description_ar'] ?? json['description'],
      icon: json['icon'] ?? 'build',
      image: ApiService.fixImageUrl(json['image']),
      price: json['price'] is int ? json['price'] : (double.tryParse(json['price']?.toString() ?? '0')?.toInt() ?? 0),
      durationMinutes: json['duration_minutes'] ?? 30,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'description': description,
      'icon': icon,
      'image': image,
      'price': price,
      'duration_minutes': durationMinutes,
      'is_active': isActive ? 1 : 0,
    };
  }
}

class ServiceAppointment {
  final int id;
  final int userId;
  final int serviceId;
  final String? carModel;
  final String? carNumber;
  final DateTime preferredDate;
  final String preferredTime;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final String status;
  final String? serviceName;
  final String? serviceNameEn;
  final String? serviceIcon;
  final int? servicePrice;
  final int? serviceDuration;
  final DateTime createdAt;

  ServiceAppointment({
    required this.id,
    required this.userId,
    required this.serviceId,
    this.carModel,
    this.carNumber,
    required this.preferredDate,
    required this.preferredTime,
    this.customerName,
    this.customerPhone,
    this.notes,
    required this.status,
    this.serviceName,
    this.serviceNameEn,
    this.serviceIcon,
    this.servicePrice,
    this.serviceDuration,
    required this.createdAt,
  });

  factory ServiceAppointment.fromJson(Map<String, dynamic> json) {
    final serviceMap = json['service'] as Map<String, dynamic>?;
    final optionMap = json['option'] as Map<String, dynamic>?;

    final sName = serviceMap != null ? serviceMap['name'] as String? : null;
    final oName = optionMap != null ? optionMap['name'] as String? : null;
    final displayServiceName = oName != null ? '$sName - $oName' : (sName ?? json['service_name'] ?? 'خدمة حجز مواعيد');

    return ServiceAppointment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      serviceId: (json['service_id'] as num?)?.toInt() ?? 0,
      carModel: json['car_model'],
      carNumber: json['car_number'],
      preferredDate: DateTime.tryParse(json['scheduled_date'] ?? json['preferred_date'] ?? '') ?? DateTime.now(),
      preferredTime: json['scheduled_time'] ?? json['preferred_time'] ?? '',
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      notes: json['notes'],
      status: json['status'] ?? 'new',
      serviceName: displayServiceName,
      serviceNameEn: serviceMap != null ? serviceMap['name_en'] as String? : json['name_en'],
      serviceIcon: serviceMap != null ? serviceMap['icon_emoji'] as String? : json['icon'],
      servicePrice: (json['total_price'] ?? json['price'] ?? serviceMap?['base_price'] as num?)?.toInt(),
      serviceDuration: (serviceMap?['duration_minutes'] ?? json['duration_minutes'] as num?)?.toInt(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  String get statusText {
    switch (status) {
      case 'new':
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'تم التأكيد';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغى';
      default:
        return status;
    }
  }
}

class ServicesApi {
  static const String _baseUrl = ApiService.baseUrl;

  /// Get all services from the server
  static Future<List<CenterService>> getServices() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/services'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          return (data['data'] as List)
              .map((s) => CenterService.fromJson(s))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching services: $e');
      return [];
    }
  }

  /// Get a single service by ID
  static Future<CenterService?> getService(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/services/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          return CenterService.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching service: $e');
      return null;
    }
  }

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token') ?? '';
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Book an appointment
  static Future<Map<String, dynamic>> bookAppointment({
    required int userId,
    required int serviceId,
    String? carModel,
    String? carNumber,
    required String preferredDate,
    required String preferredTime,
    String? customerName,
    String? customerPhone,
    String? customerDistrict,
    String? notes,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/services/book'),
        headers: headers,
        body: json.encode({
          'service_id': serviceId,
          'car_model': carModel,
          'car_number': carNumber,
          'booking_date': preferredDate,
          'preferred_time': preferredTime,
          'customer_name': customerName,
          'customer_phone': customerPhone,
          'customer_district': customerDistrict,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': data['status'] == 'success',
          'message': data['message'] ?? 'تم الحجز بنجاح',
          'data': data['data']
        };
      }
      return {'success': false, 'message': 'فشل الاتصال بالخادم'};
    } catch (e) {
      print('Error booking appointment: $e');
      return {'success': false, 'message': 'حدث خطأ يرجى المحاولة مرة أخرى'};
    }
  }

  /// Get user's appointments
  static Future<List<ServiceAppointment>> getUserAppointments([int? userId]) async {
    try {
      final response = await apiClient.get('/services/appointments');
      final data = response.data;
      if (data != null && data['status'] == 'success') {
        final rawList = data['data'];
        if (rawList is List) {
          return rawList
              .map((a) => ServiceAppointment.fromJson(a as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching appointments: $e');
      throw Exception('تعذر تحميل الحجوزات، الرجاء التحقق من الاتصال بالشبكة.');
    }
  }
}
