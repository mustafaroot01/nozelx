import 'package:auto_lube/core/network/dio_client.dart';

class AddressService {
  /// Translate local app Address model map to Backend FastAPI format
  static Map<String, dynamic> _translateToBackend(Map<String, dynamic> localData) {
    return {
      'title': localData['label'] ?? 'المنزل',
      'recipient_name': localData['full_name'] ?? '',
      'recipient_phone': localData['phone'] ?? '',
      'latitude': localData['latitude'] != null ? double.tryParse(localData['latitude'].toString()) : null,
      'longitude': localData['longitude'] != null ? double.tryParse(localData['longitude'].toString()) : null,
      'address_details': localData['street_address'] ?? '',
      'is_default': localData['is_default'] == 1 || localData['is_default'] == true,
    };
  }

  /// Translate Backend FastAPI Address response map to local app format
  static Map<String, dynamic> _translateToLocal(Map<String, dynamic> backendData) {
    return {
      'id': backendData['id'],
      'user_id': backendData['user_id'] ?? 0,
      'label': backendData['title'] ?? 'المنزل',
      'full_name': backendData['recipient_name'] ?? '',
      'phone': backendData['recipient_phone'] ?? '',
      'street_address': backendData['address_details'] ?? '',
      'city': '',
      'district': '',
      'is_default': (backendData['is_default'] == true || backendData['is_default'] == 1) ? 1 : 0,
    };
  }

  /// Get all addresses for current user
  static Future<List<Map<String, dynamic>>> getAddresses() async {
    try {
      final response = await apiClient.get('/addresses');
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> list = data['data'];
        return list.map((item) => _translateToLocal(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      print('Error fetching addresses: $e');
    }
    return [];
  }

  /// Add new address
  static Future<bool> addAddress(Map<String, dynamic> addressData) async {
    try {
      final body = _translateToBackend(addressData);
      final response = await apiClient.post(
        '/addresses',
        data: body,
      );
      final data = response.data;
      return data['success'] == true;
    } catch (e) {
      print('Error adding address: $e');
      return false;
    }
  }

  /// Update existing address
  static Future<bool> updateAddress(int id, Map<String, dynamic> addressData) async {
    try {
      final body = _translateToBackend(addressData);
      final response = await apiClient.put(
        '/addresses/$id',
        data: body,
      );
      final data = response.data;
      return data['success'] == true;
    } catch (e) {
      print('Error updating address: $e');
      return false;
    }
  }

  /// Delete address
  static Future<bool> deleteAddress(int id) async {
    try {
      final response = await apiClient.delete(
        '/addresses/$id',
      );
      final data = response.data;
      return data['success'] == true;
    } catch (e) {
      print('Error deleting address: $e');
      return false;
    }
  }

  /// Set address as default
  static Future<bool> setDefault(int id) async {
    try {
      final response = await apiClient.put(
        '/addresses/$id',
        data: {'is_default': true},
      );
      final data = response.data;
      return data['success'] == true;
    } catch (e) {
      print('Error setting default address: $e');
      return false;
    }
  }
}
