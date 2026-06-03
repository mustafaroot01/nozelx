import 'package:flutter/material.dart';
import '../../data/models/service_model.dart';
import '../../data/services/service_service.dart';

class ServiceProvider with ChangeNotifier {
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _error;

  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ServiceProvider() {
    loadServices();
  }

  Future<void> fetchServices() async {
    await loadServices();
  }

  Future<void> loadServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ServiceService.getServices();
      _services = data.map((map) => ServiceModel.fromMap(map)).toList();
      if (_services.isEmpty) {
        _error = 'لا توجد خدمات متاحة حالياً';
      }
    } catch (e) {
      debugPrint('Error loading services: $e');
      _error = 'حدث خطأ أثناء تحميل الخدمات. يرجى المحاولة مرة أخرى.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> bookService(Map<String, dynamic> bookingData) async {
    return await ServiceService.bookService(bookingData);
  }
}

