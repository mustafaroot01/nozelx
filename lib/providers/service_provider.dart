import 'package:flutter/foundation.dart';
import '../models/service_model.dart';
import '../repositories/service_repository.dart';

class ServiceProvider extends ChangeNotifier {
  final ServiceRepository _repo;

  ServiceProvider({ServiceRepository? repo})
      : _repo = repo ?? ServiceRepository();

  // ── State ─────────────────────────────────
  List<ServiceModel> _all = [];
  bool  _loading = false;
  bool  _hasError = false;
  String _error  = '';
  String _selectedCat = 'الكل';
  bool  _fetched = false; // منعاً لجلب متكرر

  // ── Getters ───────────────────────────────
  bool   get isLoading => _loading;
  bool   get hasError  => _hasError;
  String get error     => _error;
  String get errorMessage => _error; // للتوافقية
  bool   get isEmpty   => _all.isEmpty;
  String get selectedCategory => _selectedCat;

  List<String> get categories {
    final cats = _all
        .map((s) => s.category ?? 'أخرى')
        .toSet()
        .toList()
      ..sort();
    return ['الكل', ...cats];
  }

  List<ServiceModel> get services {
    if (_selectedCat == 'الكل') return _all;
    return _all
        .where((s) => (s.category ?? 'أخرى') == _selectedCat)
        .toList();
  }

  List<ServiceModel> get featured =>
      _all.where((s) => s.isFeatured).toList();

  // ── جلب الخدمات من السيرفر ────────────────
  Future<void> fetchServices({
    bool forceRefresh = false,
  }) async {
    // إذا محملة ومش refresh لا تعيد
    if (_fetched && !forceRefresh) return;

    _loading  = true;
    _hasError = false;
    _error    = '';
    Future.microtask(() => notifyListeners());

    try {
      _all     = await _repo.getServices();
      _fetched = true;
      debugPrint('✅ تم جلب ${_all.length} خدمة من السيرفر');
    } catch (e) {
      _hasError = true;
      _error    = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ خطأ جلب الخدمات: $_error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void selectCategory(String cat) {
    if (_selectedCat == cat) return;
    _selectedCat = cat;
    notifyListeners();
  }

  void refresh() => fetchServices(forceRefresh: true);

  // ── توافقية مع استدعاءات التطبيق السابقة ──
  Future<void> loadServices() async {
    await fetchServices(forceRefresh: true);
  }

  // ── Multi-Service Selection State ─────────
  final Set<ServiceModel> _selectedServices = {};

  Set<ServiceModel> get selectedServices => _selectedServices;

  bool isServiceSelected(ServiceModel service) {
    return _selectedServices.any((s) => s.id == service.id);
  }

  void toggleServiceSelection(ServiceModel service) {
    final exists = _selectedServices.any((s) => s.id == service.id);
    if (exists) {
      _selectedServices.removeWhere((s) => s.id == service.id);
    } else {
      _selectedServices.add(service);
    }
    notifyListeners();
  }

  void clearServiceSelection() {
    _selectedServices.clear();
    notifyListeners();
  }

  double get selectedServicesTotalPrice {
    return _selectedServices.fold(0.0, (sum, s) => sum + s.basePrice);
  }

  // دالة الحجز المتوافقة مع شاشة الطلبات
  Future<Map<String, dynamic>> bookService(Map<String, dynamic> bookingData) async {
    try {
      final dateStr = bookingData['scheduled_date'] as String;
      final timeStr = bookingData['scheduled_time'] as String;
      final parsedDate = DateTime.parse('${dateStr}T${timeStr}:00');

      final res = await _repo.submitRequest(
        serviceId: bookingData['service_id'] as int?,
        serviceOptionId: bookingData['service_option_id'] as int?,
        services: (bookingData['services'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
        customerName: bookingData['customer_name'] as String,
        customerPhone: bookingData['customer_phone'] as String,
        address: bookingData['address'] as String? ?? 'داخل المركز',
        scheduledAt: parsedDate,
        notes: bookingData['notes'] as String?,
        totalPrice: (bookingData['total_price'] as num).toDouble(),
        paymentMethod: bookingData['payment_method'] as String?,
        scheduledDate: dateStr,
        scheduledTime: timeStr,
      );

      debugPrint('✅ تم إرسال حجز الخدمة بنجاح: $res');
      return {
        'status': 'success',
        'data': res
      };
    } catch (e) {
      debugPrint('❌ خطأ في حجز الخدمة: $e');
      return {
        'status': 'error',
        'message': e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  ServiceModel? getById(int id) {
    try {
      return _all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
