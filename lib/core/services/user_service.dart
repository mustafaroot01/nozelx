import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/api_service.dart';
import '../../core/error/result.dart';
import '../../features/auth/data/models/user_model.dart';

/// Service for managing users from database
class UserService {
  static const String baseUrl = ApiService.baseUrl;

  // ==================== GET USERS ====================

  /// Get all users from database
  static Future<Result<List<UserModel>>> getUsers({
    String? search,
    String? status,
    String? level,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      String url = '$baseUrl/users.php?page=$page&limit=$limit';

      if (search != null && search.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(search)}';
      }
      if (status != null && status.isNotEmpty) {
        url += '&status=$status';
      }
      if (level != null && level.isNotEmpty) {
        url += '&level=$level';
      }

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final usersList = data['data']['users'] as List;
        final users = usersList.map((user) => _mapToUserModel(user)).toList();

        return Result.success(users);
      } else {
        return Result.failure(data['message'] ?? 'Failed to get users');
      }
    } catch (e) {
      return Result.failure('Error: $e');
    }
  }

  /// Get single user by ID
  static Future<Result<UserModel>> getUserById(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users.php?id=$userId'))
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final user = _mapToUserModel(data['data']['user']);
        return Result.success(user);
      } else {
        return Result.failure(data['message'] ?? 'User not found');
      }
    } catch (e) {
      return Result.failure('Error: $e');
    }
  }

  /// Get user by phone number (linked with progress)
  static Future<Result<UserModel>> getUserByPhone(String phone) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/users.php?phone=${Uri.encodeComponent(phone)}'),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final user = _mapToUserModel(data['data']['user']);
        return Result.success(user);
      } else {
        return Result.failure(
          data['message'] ?? 'User not found with this phone number',
        );
      }
    } catch (e) {
      return Result.failure('Error: $e');
    }
  }

  // ==================== UPDATE USER ====================

  /// Update user profile
  static Future<Result<UserModel>> updateUser({
    required int userId,
    String? name,
    String? email,
    String? phone,
    String? level,
    String? status,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/users.php?id=$userId'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              if (name != null) 'name': name,
              if (email != null) 'email': email,
              if (phone != null) 'phone': phone,
              if (level != null) 'level': level,
              if (status != null) 'status': status,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final user = _mapToUserModel(data['data']['user']);
        return Result.success(user);
      } else {
        return Result.failure(data['message'] ?? 'Failed to update user');
      }
    } catch (e) {
      return Result.failure('Error: $e');
    }
  }



  /// Reset user password
  static Future<Result<void>> resetPassword({
    required int userId,
    required String newPin,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users.php'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'action': 'reset_password',
              'user_id': userId,
              'new_pin': newPin,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        return Result.success(null);
      } else {
        return Result.failure(data['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      return Result.failure('Error: $e');
    }
  }

  /// Toggle user status (activate/deactivate)
  static Future<Result<bool>> toggleUserStatus(int userId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users.php'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'action': 'toggle_status', 'user_id': userId}),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final newStatus = data['data']['new_status'] == 1;
        return Result.success(newStatus);
      } else {
        return Result.failure(data['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      return Result.failure('Error: $e');
    }
  }

  // ==================== STATS ====================

  /// Get user statistics
  static Future<Result<Map<String, dynamic>>> getUserStats() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users.php'))
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        return Result.success(data['data']['stats']);
      } else {
        return Result.failure(data['message'] ?? 'Failed to get stats');
      }
    } catch (e) {
      return Result.failure('Error: $e');
    }
  }

  // ==================== SYNC ====================

  /// Sync user from database to local storage
  static Future<UserModel?> syncUserFromDb(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users.php?id=$userId'))
          .timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        return _mapToUserModel(data['data']['user']);
      }
    } catch (e) {
      print('Error syncing user: $e');
    }
    return null;
  }

  // ==================== HELPERS ====================

  static UserModel _mapToUserModel(Map<String, dynamic> user) {
    return UserModel(
      id: user['id'].toString(),
      phoneNumber: user['phone'] ?? '',
      name: user['name'] ?? '',
      pinCode: '', // Don't expose PIN
      createdAt: user['created_at'] != null
          ? DateTime.tryParse(user['created_at']) ?? DateTime.now()
          : DateTime.now(),
      lastLoginAt: user['last_login'] != null
          ? DateTime.tryParse(user['last_login'])
          : null,
      profileImage: user['avatar'],
      isActive: user['status'] == 1,
    );
  }


}
