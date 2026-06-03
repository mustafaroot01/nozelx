import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../core/network/dio_client.dart';

// Import local providers to handle logout cleanup
import 'cart_provider.dart';
import '../features/favorites/presentation/providers/favorites_provider.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoggedIn = false;
  bool _initialized = false;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get initialized => _initialized;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get userId => _user?.id;
  bool get isSessionLoaded => _initialized;

  // ── تهيئة: تحميل الجلسة المحفوظة ────────────
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userData = prefs.getString('user_data');

      if (token != null && userData != null) {
        final json = jsonDecode(userData) as Map<String, dynamic>;
        _user = UserModel.fromJson({...json, 'token': token});
        _isLoggedIn = true;

        // تحديث بيانات المستخدم من السيرفر
        // في الخلفية — لا ينتظر
        _syncFromServer();
      }
    } catch (e) {
      debugPrint('Init error: $e');
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  // مزامنة البيانات من السيرفر في الخلفية
  Future<void> _syncFromServer() async {
    try {
      final res = await apiClient.get('/auth/me');
      final data = res.data['data'] as Map<String, dynamic>;
      _user = UserModel.fromJson({...data, 'token': _user!.token});
      await _saveUserLocal(_user!);
      notifyListeners();
      debugPrint('✅ بيانات المستخدم محدّثة: ${_user!.name}');
    } catch (e) {
      debugPrint('⚠️ تعذّر مزامنة البيانات: $e');
    }
  }

  // ── إرسال OTP ─────────────────────────────────
  Future<void> sendOtp(String phone) async {
    _setLoading(true);
    try {
      await apiClient.post('/auth/send-otp', data: {'phone': phone});
    } on DioException catch (e) {
      throw _extractError(e);
    } finally {
      _setLoading(false);
    }
  }

  // ── التحقق من OTP ─────────────────────────────
  // يُرجع true = مستخدم جديد
  Future<bool> verifyOtp(String phone, String otp) async {
    _setLoading(true);
    try {
      final res = await apiClient.post(
        '/auth/verify-otp',
        data: {'phone': phone, 'otp': otp},
      );
      final data = res.data['data'] as Map<String, dynamic>;
      final isNew = data['is_new_user'] as bool? ?? false;
      final token = data['token'] as String;

      // احفظ التوكن مؤقتاً
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('temp_token', token);

      if (!isNew) {
        // مستخدم قديم → تسجيل دخول فوري
        final userData = data['user'] as Map<String, dynamic>;
        await _finalizeLogin({...userData, 'token': token});
        debugPrint('✅ دخول: ${_user!.name} | طلبات: ${_user!.totalOrders}');
      }

      return isNew;
    } on DioException catch (e) {
      throw _extractError(e);
    } finally {
      _setLoading(false);
    }
  }

  // ── إتمّام الملف الشخصي (مستخدم جديد) ─────────
  Future<void> completeProfile(String name) async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final tempToken = prefs.getString('temp_token') ?? '';

      final res = await apiClient.post(
        '/auth/complete-profile',
        data: {'name': name},
        options: Options(headers: {
          'Authorization': 'Bearer $tempToken',
        }),
      );
      final data = res.data['data'] as Map<String, dynamic>;
      await _finalizeLogin({...data, 'token': data['token']});
      await prefs.remove('temp_token');
      debugPrint('✅ حساب جديد: ${_user!.name}');
    } on DioException catch (e) {
      throw _extractError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Compatibility helper for old onboarding name registration
  Future<void> saveName(String phone, String name) async {
    await completeProfile(name);
  }

  // ── إتمام تسجيل الدخول ─────────────────────────
  Future<void> _finalizeLogin(Map<String, dynamic> userData) async {
    _user = UserModel.fromJson(userData);
    _isLoggedIn = true;
    await _saveUserLocal(_user!);
    // تعيين التوكن في كل الطلبات
    DioClient.setToken(_user!.token);
    notifyListeners();
  }

  Future<void> finalizeLogin(BuildContext context, String phone, String token) async {
    DioClient.setToken(token);
    try {
      await Provider.of<CartProvider>(context, listen: false).fetchCart();
    } catch (e) {
      debugPrint('Error fetching cart after login: $e');
    }
    try {
      await Provider.of<FavoritesProvider>(context, listen: false).fetchFavorites();
    } catch (e) {
      debugPrint('Error fetching favorites after login: $e');
    }
  }

  // ── حفظ المستخدم محلياً ────────────────────────
  Future<void> _saveUserLocal(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', user.token);
    await prefs.setString('user_token', user.token);
    final jsonStr = jsonEncode(user.toJson());
    await prefs.setString('user_data', jsonStr);
    await prefs.setString('current_user', jsonStr);
  }

  // ── تحديث الملف الشخصي ─────────────────────────
  Future<void> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    _setLoading(true);
    try {
      final res = await apiClient.put(
        '/auth/profile',
        data: {
          if (name != null) 'name': name,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        },
      );
      final data = res.data['data'] as Map<String, dynamic>;
      _user = _user!.copyWith(
        name: data['name'] as String?,
        avatarUrl: data['avatar_url'] as String?,
      );
      await _saveUserLocal(_user!);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // ── تحديث الإحصاءات ────────────────────────────
  Future<void> refreshStats() async {
    if (!_isLoggedIn) return;
    await _syncFromServer();
  }

  // ── تسجيل الخروج ───────────────────────────────
  Future<void> logout([BuildContext? context]) async {
    try {
      await apiClient.post('/auth/logout');
    } catch (_) {}
    _user = null;
    _isLoggedIn = false;
    DioClient.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_token');
    await prefs.remove('user_data');
    await prefs.remove('temp_token');
    if (context != null && context.mounted) {
      try {
        Provider.of<CartProvider>(context, listen: false).clearForLogout();
      } catch (_) {}
      try {
        Provider.of<FavoritesProvider>(context, listen: false).clearForLogout();
      } catch (_) {}
    }
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Exception _extractError(DioException e) {
    final msg = e.response?.data?['message'] as String?;
    switch (e.response?.statusCode) {
      case 400:
        return Exception(msg ?? 'طلب غير صحيح');
      case 401:
        return Exception(msg ?? 'غير مصرح');
      case 404:
        return Exception(msg ?? 'غير موجود');
      case 429:
        return Exception('حاولت كثيراً. انتظر قليلاً');
      case 500:
        return Exception('خطأ في السيرفر. حاول لاحقاً');
      default:
        if (e.type == DioExceptionType.connectionError) {
          return Exception('تعذّر الاتصال. تحقق من الإنترنت');
        }
        return Exception(msg ?? 'حدث خطأ غير متوقع');
    }
  }
}
