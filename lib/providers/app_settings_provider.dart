import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_lube/core/services/api_service.dart';
import 'package:auto_lube/core/config/app_settings.dart';

class AppSettingsProvider extends ChangeNotifier {
  static final AppSettingsProvider _instance = AppSettingsProvider._internal();

  factory AppSettingsProvider() {
    return _instance;
  }

  AppSettingsProvider._internal();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetches system settings from the backend public endpoint
  Future<void> fetchSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Try loading cached settings first for instant startup
    await _loadCachedSettings();

    try {
      final url = '${ApiService.baseUrl}/v1/settings';
      debugPrint('Fetching app settings from: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        AppSettings().updateFromJson(data);
        
        // Cache the settings locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_app_settings', response.body);
        
        debugPrint('App settings updated successfully: ${AppSettings().storeName}');
      } else {
        _error = 'Failed to load settings: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching app settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads locally cached settings
  Future<void> _loadCachedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('cached_app_settings');
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(cachedJson);
        AppSettings().updateFromJson(data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached settings: $e');
    }
  }
}
