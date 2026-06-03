import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/result.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/address_model.dart';
import '../models/payment_method_model.dart';
import 'package:auto_lube/core/network/dio_client.dart';


/// Account Service - خدمة إدارة الحساب الشاملة
/// تتعامل مع جميع عمليات الحساب من جلب البيانات وتحديثها وحذفها
class AccountService {
  static const String baseUrl = ApiService.baseUrl;

  // Local storage keys
  static const String _userKey = 'user_data';
  static const String _addressesKey = 'user_addresses';
  static const String _paymentMethodsKey = 'user_payment_methods';
  static const String _notificationsKey = 'user_notifications';

  /// Get current user from local storage
  static Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        return UserModel.fromMap(json.decode(userJson));
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
    return null;
  }

  /// Save user to local storage
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(user.toMap());
    await prefs.setString('user_data', jsonStr);
    await prefs.setString('current_user', jsonStr);
  }

  /// Clear user from local storage (logout)
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('current_user');
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
  }

  // ==================== PROFILE ====================

  /// Get profile from server
  static Future<Result<UserModel>> getProfile() async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        return Result.failure('المستخدم غير مسجل الدخول');
      }

      final response = await apiClient.get('/auth/me');
      final data = response.data;

      if (data['success'] == true) {
        final userData = data['data'];
        final updatedUser = UserModel(
          id: userData['id'].toString(),
          phoneNumber: userData['phone'] ?? user.phoneNumber,
          name: userData['name'] ?? user.name,
          pinCode: user.pinCode,
          createdAt: user.createdAt,
          lastLoginAt: DateTime.now(),
          profileImage: userData['avatar_url'],
          isActive: true,
        );

        // Save to local
        await saveUser(updatedUser);

        return Result.success(updatedUser);
      } else {
        return Result.failure(data['message'] ?? 'فشل جلب البيانات');
      }
    } catch (e) {
      // Return local user if server fails
      final localUser = await getCurrentUser();
      if (localUser != null) {
        return Result.success(localUser);
      }
      return Result.failure('خطأ في الاتصال: $e');
    }
  }

  /// Update profile
  static Future<Result<UserModel>> updateProfile({
    required String name,
    String? email,
    String? avatar,
  }) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        return Result.failure('المستخدم غير مسجل الدخول');
      }

      final response = await apiClient.put(
        '/auth/profile',
        data: {
          'name': name,
          'avatar_url': avatar ?? '',
        },
      );

      final data = response.data;

      if (data['success'] == true) {
        final userData = data['data'];
        final updatedUser = user.copyWith(
          name: userData['name'] ?? name,
          profileImage: userData['avatar_url'] ?? avatar,
        );

        await saveUser(updatedUser);
        return Result.success(updatedUser);
      } else {
        return Result.failure(data['message'] ?? 'فشل تحديث البيانات');
      }
    } catch (e) {
      return Result.failure('خطأ في الاتصال: $e');
    }
  }

  /// Change password
  static Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        return Result.failure('المستخدم غير مسجل الدخول');
      }

      // Verify current password
      if (user.pinCode != currentPassword) {
        return Result.failure('كلمة المرور الحالية غير صحيحة');
      }

      // Validate new password
      if (newPassword.length < 6) {
        return Result.failure('كلمة المرور يجب أن تكون 6 أرقام على الأقل');
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/account.php?action=reset_pin'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'phone': user.phoneNumber,
              'new_pin': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final updatedUser = user.copyWith(pinCode: newPassword);
        await saveUser(updatedUser);
        return Result.success(null);
      } else {
        return Result.failure(data['message'] ?? 'فشل تغيير كلمة المرور');
      }
    } catch (e) {
      return Result.failure('خطأ في الاتصال: $e');
    }
  }

  // ==================== ADDRESSES ====================

  /// Get addresses from server (database)
  static Future<List<AddressModel>> getAddresses() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return [];

      final userId = int.tryParse(user.id);
      if (userId == null || userId <= 0) return [];

      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/account.php?action=get_addresses&user_id=$userId',
            ),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final addressesList = data['data']['addresses'] as List? ?? [];
        return addressesList.map((e) => AddressModel.fromMap(e)).toList();
      }
    } catch (e) {
      print('Error getting addresses from server: $e');
    }
    return [];
  }

  /// Add new address to server
  static Future<Result<AddressModel>> addAddress(AddressModel address) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        return Result.failure('المستخدم غير مسجل الدخول');
      }

      final userId = int.tryParse(user.id) ?? 0;

      final response = await http
          .post(
            Uri.parse('$baseUrl/account.php?action=add_address'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'user_id': userId,
              'label': address.label,
              'full_name': address.fullName,
              'phone': address.phoneNumber,
              'address': address.address,
              'city': address.city,
              'district': address.district,
              'notes': address.notes ?? '',
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final newAddress = AddressModel.fromMap(data['data']['address']);
        return Result.success(newAddress);
      } else {
        return Result.failure(data['message'] ?? 'فشل إضافة العنوان');
      }
    } catch (e) {
      return Result.failure('خطأ في إضافة العنوان: $e');
    }
  }

  /// Update address on server
  static Future<Result<AddressModel>> updateAddress(
    AddressModel address,
  ) async {
    try {
      if (address.id == null) {
        return Result.failure('معرف العنوان مطلوب');
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/account.php?action=update_address'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'address_id': address.id,
              'label': address.label,
              'full_name': address.fullName,
              'phone': address.phoneNumber,
              'address': address.address,
              'city': address.city,
              'district': address.district,
              'notes': address.notes ?? '',
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final updatedAddress = AddressModel.fromMap(data['data']['address']);
        return Result.success(updatedAddress);
      } else {
        return Result.failure(data['message'] ?? 'فشل تحديث العنوان');
      }
    } catch (e) {
      return Result.failure('خطأ في تحديث العنوان: $e');
    }
  }

  /// Delete address from server
  static Future<Result<void>> deleteAddress(int addressId) async {
    try {
      final response = await http
          .delete(
            Uri.parse(
              '$baseUrl/account.php?action=delete_address&address_id=$addressId',
            ),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        return Result.success(null);
      } else {
        return Result.failure(data['message'] ?? 'فشل حذف العنوان');
      }
    } catch (e) {
      return Result.failure('خطأ في حذف العنوان: $e');
    }
  }

  /// Set default address on server
  static Future<Result<void>> setDefaultAddress(int addressId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/account.php?action=set_default_address'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'address_id': addressId}),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        return Result.success(null);
      } else {
        return Result.failure(data['message'] ?? 'فشل تعيين العنوان الافتراضي');
      }
    } catch (e) {
      return Result.failure('خطأ في تعيين العنوان الافتراضي: $e');
    }
  }

  /// Get default address from server
  static Future<AddressModel?> getDefaultAddress() async {
    final addresses = await getAddresses();
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (e) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  // ==================== PAYMENT METHODS ====================

  /// Get payment methods from local storage
  static Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final methodsJson = prefs.getString(_paymentMethodsKey);
      if (methodsJson != null) {
        final List<dynamic> list = json.decode(methodsJson);
        return list.map((e) => PaymentMethodModel.fromMap(e)).toList();
      }
    } catch (e) {
      print('Error getting payment methods: $e');
    }
    return [];
  }

  /// Save payment methods to local storage
  static Future<void> savePaymentMethods(
    List<PaymentMethodModel> methods,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = methods.map((e) => e.toMap()).toList();
    await prefs.setString(_paymentMethodsKey, json.encode(jsonList));
  }

  /// Add payment method
  static Future<Result<PaymentMethodModel>> addPaymentMethod(
    PaymentMethodModel method,
  ) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        return Result.failure('المستخدم غير مسجل الدخول');
      }

      final userId = int.tryParse(user.id) ?? 0;
      final methods = await getPaymentMethods();

      final newMethod = method.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: userId,
        isDefault: methods.isEmpty,
        createdAt: DateTime.now(),
      );

      methods.add(newMethod);
      await savePaymentMethods(methods);

      return Result.success(newMethod);
    } catch (e) {
      return Result.failure('خطأ في إضافة طريقة الدفع: $e');
    }
  }

  /// Delete payment method
  static Future<Result<void>> deletePaymentMethod(int methodId) async {
    try {
      final methods = await getPaymentMethods();
      methods.removeWhere((m) => m.id == methodId);
      await savePaymentMethods(methods);
      return Result.success(null);
    } catch (e) {
      return Result.failure('خطأ في حذف طريقة الدفع: $e');
    }
  }

  /// Set default payment method
  static Future<Result<void>> setDefaultPaymentMethod(int methodId) async {
    try {
      final methods = await getPaymentMethods();

      for (var i = 0; i < methods.length; i++) {
        methods[i] = methods[i].copyWith(isDefault: methods[i].id == methodId);
      }

      await savePaymentMethods(methods);
      return Result.success(null);
    } catch (e) {
      return Result.failure('خطأ في تعيين طريقة الدفع الافتراضية: $e');
    }
  }

  /// Get default payment method
  static Future<PaymentMethodModel?> getDefaultPaymentMethod() async {
    final methods = await getPaymentMethods();
    try {
      return methods.firstWhere((m) => m.isDefault);
    } catch (e) {
      return methods.isNotEmpty ? methods.first : null;
    }
  }



  // ==================== NOTIFICATIONS ====================

  /// Get notification settings
  static Future<Map<String, bool>> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_notificationsKey);
      if (settingsJson != null) {
        return Map<String, bool>.from(json.decode(settingsJson));
      }
    } catch (e) {
      print('Error getting notification settings: $e');
    }

    // Default settings
    return {
      'orderNotifications': true,
      'offerNotifications': true,
      'loyaltyNotifications': true,
      'pushNotifications': true,
      'emailNotifications': false,
    };
  }

  /// Save notification settings
  static Future<void> saveNotificationSettings(
    Map<String, bool> settings,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationsKey, json.encode(settings));
  }

  // ==================== DELETE ACCOUNT ====================

  /// Delete account from server and local storage
  static Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final response = await apiClient.get('/orders');
      final data = response.data;
      if (data['success'] == true || data['status'] == 'success') {
        final List ordersList = data['data'] as List;
        return ordersList.map((o) {
          final itemsCount = o['items_count'] ?? 0;
          return {
            'id': o['id'],
            'status': o['status'],
            'created_at': o['created_at'],
            'total_amount': o['total_amount'],
            'order_items': List.generate(itemsCount, (_) => {}), // Compatibility wrapper
          };
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting orders: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getOrderById(int orderId) async {
    try {
      final response = await apiClient.get('/orders/$orderId');
      final data = response.data;
      if (data['success'] == true || data['status'] == 'success') {
        final orderDetails = Map<String, dynamic>.from(data['data']);
        
        // Map order_items to orderItems/order_items for display compatibility if needed
        if (orderDetails['items'] != null) {
          orderDetails['order_items'] = orderDetails['items'];
        }
        
        return orderDetails;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting order by ID $orderId: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      if (userJson == null) return [];

      final userData = jsonDecode(userJson);
      final userId = userData['id'];

      final response = await Dio().get(
        '${ApiService.baseUrl}get_notifications.php',
        queryParameters: {'user_id': userId},
      );

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['notifications']);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      return [];
    }
  }

  /// Delete account from server and local storage
  static Future<Result<void>> deleteAccount(String reason) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        return Result.failure('المستخدم غير مسجل الدخول');
      }

      final userId = int.tryParse(user.id);
      if (userId == null || userId <= 0) {
        return Result.failure('معرف المستخدم غير صالح');
      }

      // Send delete request to server
      final response = await http
          .post(
            Uri.parse('$baseUrl/account.php?action=delete_account'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'user_id': userId,
              'reason': reason,
              'confirm': true,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        // Clear all local data after successful server deletion
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        return Result.success(null);
      } else {
        return Result.failure(data['message'] ?? 'فشل حذف الحساب');
      }
    } catch (e) {
      return Result.failure('خطأ في حذف الحساب: $e');
    }
  }

  // ==================== SYNC ====================

  /// Sync all user data from server
  static Future<Result<Map<String, dynamic>>> syncAllData() async {
    try {
      final profileResult = await getProfile();

      if (!profileResult.isSuccess) {
        return Result.failure(profileResult.error);
      }



      return Result.success({
        'profile': profileResult.getOrNull(),
        'addresses': await getAddresses(),
        'paymentMethods': await getPaymentMethods(),
        'notificationSettings': await getNotificationSettings(),
      });
    } catch (e) {
      return Result.failure('خطأ في المزامنة: $e');
    }
  }

  // ==================== PHONE NUMBER BASED METHODS ====================
  // These methods use phone number as the primary identifier

  /// Get current user's phone number
  static Future<String?> getCurrentPhoneNumber() async {
    final user = await getCurrentUser();
    return user?.phoneNumber;
  }

  /// Get addresses by phone number
  static Future<List<AddressModel>> getAddressesByPhone(
    String phoneNumber,
  ) async {
    try {
      // Fetch from server using phone number
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/account.php?action=get_addresses&phone=${Uri.encodeComponent(phoneNumber)}',
            ),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final addressesList = data['data']['addresses'] as List? ?? [];
        return addressesList.map((e) => AddressModel.fromMap(e)).toList();
      }
    } catch (e) {
      print('Error getting addresses by phone: $e');
    }
    return [];
  }

  /// Get orders by phone number
  static Future<List<Map<String, dynamic>>> getOrdersByPhone(
    String phoneNumber,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/orders.php?action=get_orders&phone=${Uri.encodeComponent(phoneNumber)}',
            ),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']['orders'] ?? []);
      }
    } catch (e) {
      print('Error getting orders by phone: $e');
    }
    return [];
  }

  /// Get favorites by phone number
  static Future<List<Map<String, dynamic>>> getFavoritesByPhone(
    String phoneNumber,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/favorites.php?action=get_by_phone&phone=${Uri.encodeComponent(phoneNumber)}',
            ),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']['favorites'] ?? []);
      }
    } catch (e) {
      print('Error getting favorites by phone: $e');
    }
    return [];
  }

  /// Add to favorites by phone number
  static Future<bool> addToFavoritesByPhone(
    String phoneNumber,
    int productId,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/favorites.php'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'phone': phoneNumber, 'product_id': productId}),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('Error adding to favorites by phone: $e');
      return false;
    }
  }

  /// Remove from favorites by phone number
  static Future<bool> removeFromFavoritesByPhone(
    String phoneNumber,
    int productId,
  ) async {
    try {
      final response = await http
          .delete(
            Uri.parse(
              '$baseUrl/favorites.php?action=remove_by_phone&phone=${Uri.encodeComponent(phoneNumber)}&product_id=$productId',
            ),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('Error removing from favorites by phone: $e');
      return false;
    }
  }



  /// Add address by phone number
  static Future<Result<AddressModel>> addAddressByPhone(
    String phoneNumber,
    AddressModel address,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/account.php?action=add_address'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'phone': phoneNumber,
              'label': address.label,
              'full_name': address.fullName,
              'address': address.address,
              'city': address.city,
              'district': address.district,
              'notes': address.notes,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final newAddress = AddressModel.fromMap(data['data']['address']);
        return Result.success(newAddress);
      } else {
        return Result.failure(data['message'] ?? 'فشل إضافة العنوان');
      }
    } catch (e) {
      return Result.failure('خطأ في الاتصال: $e');
    }
  }

  /// Delete address by phone number
  static Future<Result<void>> deleteAddressByPhone(
    String phoneNumber,
    int addressId,
  ) async {
    try {
      final response = await http
          .delete(
            Uri.parse(
              '$baseUrl/account.php?action=delete_address&phone=${Uri.encodeComponent(phoneNumber)}&address_id=$addressId',
            ),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        return Result.success(null);
      } else {
        return Result.failure(data['message'] ?? 'فشل حذف العنوان');
      }
    } catch (e) {
      return Result.failure('خطأ في الاتصال: $e');
    }
  }
}
