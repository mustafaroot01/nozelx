import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/network/dio_client.dart';
import '../models/service_model.dart';

class ServiceRepository {
  final Dio _dio;

  ServiceRepository({Dio? dio})
      : _dio = dio ?? DioClient.instance;

  // جلب جميع الخدمات
  Future<List<ServiceModel>> getServices({
    String? category,
  }) async {
    try {
      final response = await _dio.get(
        '/services',
        queryParameters: {
          if (category != null && category != 'الكل')
            'category': category,
          'is_available': true,
        },
      );

      final data = response.data;

      // يدعم response بشكلين:
      // { "data": [...] } أو مصفوفة مباشرة [...]
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      } else {
        debugPrint('⚠️ تنسيق غير متوقع: ${data.runtimeType}');
        return [];
      }

      return list
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList();

    } on DioException catch (e) {
      debugPrint('❌ خطأ جلب الخدمات: ${e.message}');
      throw _handleError(e);
    }
  }

  // جلب خدمة واحدة
  Future<ServiceModel> getServiceById(int id) async {
    try {
      final response = await _dio.get('/services/$id');
      final data = response.data;
      final json = data is Map && data.containsKey('data')
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      return ServiceModel.fromJson(json);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // إرسال طلب خدمة
  Future<Map<String, dynamic>> submitRequest({
    int? serviceId,
    int? serviceOptionId,
    List<Map<String, dynamic>>? services,
    required String customerName,
    required String customerPhone,
    required String address,
    required DateTime scheduledAt,
    String? notes,
    required double totalPrice,
    String? paymentMethod,
    String? scheduledDate,
    String? scheduledTime,
  }) async {
    try {
      final response = await _dio.post(
        '/service-requests',
        data: {
          if (serviceId != null) 'service_id': serviceId,
          if (serviceOptionId != null) 'service_option_id': serviceOptionId,
          if (services != null) 'services': services,
          'customer_name':     customerName,
          'customer_phone':    customerPhone,
          'address':           address,
          'scheduled_at':      scheduledAt.toIso8601String(),
          if (scheduledDate != null) 'scheduled_date': scheduledDate,
          if (scheduledTime != null) 'scheduled_time': scheduledTime,
          'notes':             notes ?? '',
          'total_price':       totalPrice,
          if (paymentMethod != null) 'payment_method': paymentMethod,
        },
      );
      final data = response.data;
      return data is Map && data.containsKey('data')
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // طلبات عميل برقم هاتفه
  Future<List<Map<String, dynamic>>> getMyRequests(String phone) async {
    try {
      final response = await _dio.get(
        '/service-requests',
        queryParameters: {'phone': phone},
      );
      final data = response.data;
      final list = data is List
          ? data
          : (data['data'] as List? ?? []);
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // معالجة الأخطاء
  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('انتهت مهلة الاتصال. تحقق من الإنترنت');
      case DioExceptionType.connectionError:
        return Exception('تعذّر الاتصال بالسيرفر. تحقق من الإنترنت');
      default:
        final msg = e.response?.data?['message'] as String? ??
                    e.response?.data?['detail'] as String? ??
                    'حدث خطأ. حاول مجدداً';
        return Exception(msg);
    }
  }
}
