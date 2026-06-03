import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../../core/services/api_service.dart';
import '../../../../core/error/result.dart';
import '../models/user_model.dart';

/// AuthService - Server-only authentication
/// لا يوجد تخزين محلي لبيانات المستخدمين - كل شيء على السيرفر
class AuthService {
  static const String _baseUrl = ApiService.baseUrl;

  // مفاتيح الجلسة فقط (لا يوجد users_database محلي)
  static const String _sessionKey = 'current_user';
  static const String _loggedInKey = 'isLoggedIn';
  static const String _tokenKey = 'user_token';
  static const String _userIdKey = 'user_id';

  // ==================== LOGIN ====================

  static Future<Result<UserModel>> login({
    required String phoneNumber,
    required String password,
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/account.php?action=login'),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: json.encode({'phone': cleanPhone, 'pin_code': password}),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final userData = data['data']['user'];
        final user = _userFromApiData(userData);
        await _saveSession(userData);
        return Result.success(user);
      } else {
        return Result.failure(data['message'] ?? 'فشل تسجيل الدخول');
      }
    } catch (e) {
      return Result.failure('تعذر الاتصال بالسيرفر. تحقق من اتصالك بالإنترنت.');
    }
  }

  // ==================== REGISTER ====================

  static Future<Result<UserModel>> register({
    required String phoneNumber,
    required String name,
    required String password,
    String? email,
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/account.php?action=register'),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: json.encode({
              'name': name.trim(),
              'phone': cleanPhone,
              'pin_code': password,
              'email': email ?? '',
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final userData = data['data']['user'];
        final user = _userFromApiData(userData);
        await _saveSession(userData);
        return Result.success(user);
      } else {
        return Result.failure(data['message'] ?? 'فشل التسجيل');
      }
    } catch (e) {
      return Result.failure('تعذر الاتصال بالسيرفر. تحقق من اتصالك بالإنترنت.');
    }
  }

  // ==================== VERIFY TOKEN ====================

  /// التحقق من صحة الجلسة مع السيرفر
  static Future<Result<UserModel>> verifyToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey) ?? '';
    final userId = prefs.getInt(_userIdKey) ?? 0;

    if (token.isEmpty || userId <= 0) {
      return Result.failure('لا توجد جلسة نشطة');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/account.php?action=verify_token'),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: json.encode({'token': token, 'user_id': userId}),
          )
          .timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final userData = data['data']['user'];
        final user = _userFromApiData(userData);
        // تحديث بيانات الجلسة المحلية (بدون كلمة مرور)
        await _saveSession(userData);
        return Result.success(user);
      } else {
        // الجلسة منتهية - مسح البيانات المحلية
        await clearSession();
        return Result.failure(data['message'] ?? 'الجلسة منتهية');
      }
    } catch (e) {
      // في حالة عدم الاتصال، نتحقق من وجود جلسة محلية
      return _getLocalSession();
    }
  }

  // ==================== LOGOUT ====================

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey) ?? '';
    final userId = prefs.getInt(_userIdKey) ?? 0;

    // إبلاغ السيرفر بتسجيل الخروج
    if (token.isNotEmpty && userId > 0) {
      try {
        await http
            .post(
              Uri.parse('$_baseUrl/account.php?action=logout'),
              headers: {'Content-Type': 'application/json; charset=utf-8'},
              body: json.encode({'token': token, 'user_id': userId}),
            )
            .timeout(const Duration(seconds: 8));
      } catch (_) {
        // تجاهل الخطأ - نمسح الجلسة المحلية على أي حال
      }
    }

    await clearSession();
  }

  /// تسجيل الخروج من جميع الأجهزة
  static Future<void> logoutAllDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey) ?? 0;

    if (userId > 0) {
      try {
        await http
            .post(
              Uri.parse('$_baseUrl/account.php?action=logout_all'),
              headers: {'Content-Type': 'application/json; charset=utf-8'},
              body: json.encode({'user_id': userId}),
            )
            .timeout(const Duration(seconds: 8));
      } catch (_) {}
    }

    await clearSession();
  }

  // ==================== CHECK PHONE ====================

  static Future<bool> isPhoneRegistered(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    try {
      final response = await http
          .get(
            Uri.parse(
              '$_baseUrl/account.php?action=check_phone&phone=$cleanPhone',
            ),
          )
          .timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);
      return data['success'] == true && data['data']['exists'] == true;
    } catch (_) {
      return false;
    }
  }

  // ==================== RESET PASSWORD ====================

  static Future<Result<void>> resetPassword({
    required String phoneNumber,
    required String newPassword,
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/account.php?action=reset_pin'),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: json.encode({
              'phone': cleanPhone,
              'new_password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);
      if (data['success'] == true) {
        return Result.success(null);
      } else {
        return Result.failure(data['message'] ?? 'فشل إعادة تعيين كلمة المرور');
      }
    } catch (_) {
      return Result.failure('تعذر الاتصال بالسيرفر');
    }
  }

  // ==================== UPDATE PROFILE ====================

  static Future<Result<UserModel>> updateProfile({
    required int userId,
    String? name,
    String? email,
    String? avatar,
  }) async {
    try {
      final body = <String, dynamic>{'user_id': userId};
      if (name != null && name.isNotEmpty) body['name'] = name;
      if (email != null && email.isNotEmpty) body['email'] = email;
      if (avatar != null && avatar.isNotEmpty) body['avatar'] = avatar;

      final response = await http
          .post(
            Uri.parse('$_baseUrl/account.php?action=update_profile'),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);
      if (data['success'] == true) {
        final userData = data['data']['user'];
        final user = _userFromApiData(userData);

        // تحديث الجلسة المحلية
        final prefs = await SharedPreferences.getInstance();
        final sessionJson = prefs.getString(_sessionKey);
        if (sessionJson != null) {
          final session = json.decode(sessionJson) as Map<String, dynamic>;
          if (name != null) session['name'] = name;
          if (email != null) session['email'] = email;
          if (avatar != null) session['avatar'] = avatar;
          await prefs.setString(_sessionKey, json.encode(session));
        }

        return Result.success(user);
      } else {
        return Result.failure(data['message'] ?? 'فشل تحديث البيانات');
      }
    } catch (_) {
      return Result.failure('تعذر الاتصال بالسيرفر');
    }
  }

  // ==================== GET CURRENT USER ====================

  static Future<UserModel?> getCurrentUser() async {
    return (await _getLocalSession()).getOrNull();
  }

  static UserModel? getCurrentUserSync() {
    // للاستخدام المتزامن - يعيد null إذا لم تكن البيانات محملة
    return null;
  }

  // ==================== SESSION HELPERS ====================

  /// حفظ بيانات الجلسة (بدون كلمة مرور أبداً)
  static Future<void> _saveSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    final sessionData = {
      'id': userData['id'].toString(),
      'name': userData['name'] ?? '',
      'phone': userData['phone'] ?? '',
      'email': userData['email'] ?? '',
      'avatar': userData['avatar'] ?? '',
      'is_admin': userData['is_admin'] ?? 0,
    };

    await prefs.setString(_sessionKey, json.encode(sessionData));
    await prefs.setBool(_loggedInKey, true);
    await prefs.setString(_tokenKey, userData['token'] ?? '');
    await prefs.setInt(
      _userIdKey,
      int.tryParse(userData['id'].toString()) ?? 0,
    );
  }

  /// قراءة الجلسة المحلية (للاستخدام عند انقطاع الإنترنت)
  static Future<Result<UserModel>> _getLocalSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_loggedInKey) ?? false;
      if (!isLoggedIn) return Result.failure('غير مسجل الدخول');

      final sessionJson = prefs.getString(_sessionKey);
      if (sessionJson == null) return Result.failure('لا توجد جلسة');

      final sessionData = json.decode(sessionJson) as Map<String, dynamic>;
      final user = UserModel(
        id: sessionData['id']?.toString() ?? '',
        phoneNumber: sessionData['phone'] ?? '',
        name: sessionData['name'] ?? '',
        pinCode: '', // لا نحفظ كلمة المرور أبداً
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isActive: true,
      );
      return Result.success(user);
    } catch (_) {
      return Result.failure('خطأ في قراءة الجلسة');
    }
  }

  /// مسح جميع بيانات الجلسة
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_loggedInKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove('cached_user_id');
  }

  /// تحويل بيانات API إلى UserModel
  static UserModel _userFromApiData(Map<String, dynamic> userData) {
    return UserModel(
      id: userData['id'].toString(),
      phoneNumber: userData['phone'] ?? '',
      name: userData['name'] ?? '',
      pinCode: '', // لا نحفظ كلمة المرور
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isActive: true,
    );
  }
}
