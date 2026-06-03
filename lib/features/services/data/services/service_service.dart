import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_lube/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceService {
  static const String baseUrl = ApiService.baseUrl;

  static Future<List<dynamic>> getServices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/services'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'] as List;
        }
      }
    } catch (e) {
      print('Error fetching services: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>> bookService(Map<String, dynamic> bookingData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');
      
      final response = await http.post(
        Uri.parse('$baseUrl/services/book'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(bookingData),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
