import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

/// Service for syncing data between app and admin panel
class SyncService {
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _cachedDataKey = 'cached_data';

  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  DateTime? _lastSyncTime;
  bool _isSyncing = false;

  // Callbacks for real-time updates
  static Function(Map<String, dynamic>)? onProductsUpdated;
  static Function(Map<String, dynamic>)? onOrdersUpdated;
  static Function(Map<String, dynamic>)? onCategoriesUpdated;

  /// Initialize sync service
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString(_lastSyncKey);
    if (lastSync != null) {
      _instance._lastSyncTime = DateTime.tryParse(lastSync);
    }
  }

  /// Get last sync time
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;

  /// Sync all data from server
  static Future<SyncResult> syncAll() async {
    if (_instance._isSyncing) {
      return SyncResult(success: false, message: 'Sync already in progress');
    }

    _instance._isSyncing = true;

    try {
      final lastSync = _instance._lastSyncTime?.toIso8601String();
      final url =
          '${AppConstants.baseUrl}/sync.php?types=all${lastSync != null ? '&last_sync=$lastSync' : ''}';

      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Sync timeout');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          // Save sync time
          _instance._lastSyncTime = DateTime.now();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            _lastSyncKey,
            _instance._lastSyncTime!.toIso8601String(),
          );

          // Cache data for offline use
          await _cacheData(data['data']);

          // Trigger callbacks
          if (data['data'] != null) {
            _triggerCallbacks(data['data']);
          }

          _instance._isSyncing = false;

          return SyncResult(
            success: true,
            message: 'Sync completed successfully',
            data: data['data'],
          );
        } else {
          _instance._isSyncing = false;
          return SyncResult(
            success: false,
            message: data['message'] ?? 'Sync failed',
          );
        }
      } else {
        _instance._isSyncing = false;
        return SyncResult(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      _instance._isSyncing = false;
      return SyncResult(success: false, message: 'Sync error: $e');
    }
  }

  /// Sync only products
  static Future<SyncResult> syncProducts() async {
    return _syncType('products');
  }

  /// Sync only orders
  static Future<SyncResult> syncOrders() async {
    return _syncType('orders');
  }

  /// Sync only categories
  static Future<SyncResult> syncCategories() async {
    return _syncType('categories');
  }

  /// Sync specific type
  static Future<SyncResult> _syncType(String type) async {
    try {
      final lastSync = _instance._lastSyncTime?.toIso8601String();
      final url =
          '${AppConstants.baseUrl}/sync.php?types=$type${lastSync != null ? '&last_sync=$lastSync' : ''}';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          // Update last sync time
          _instance._lastSyncTime = DateTime.now();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            _lastSyncKey,
            _instance._lastSyncTime!.toIso8601String(),
          );

          return SyncResult(
            success: true,
            message: '$type synced successfully',
            data: data['data'],
          );
        }
      }

      return SyncResult(success: false, message: 'Failed to sync $type');
    } catch (e) {
      return SyncResult(success: false, message: 'Error syncing $type: $e');
    }
  }

  /// Get live stats from admin panel
  static Future<Map<String, dynamic>?> getLiveStats() async {
    try {
      final url = '${AppConstants.baseUrl}/stats.php?type=summary';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
    } catch (e) {
      print('Error getting live stats: $e');
    }
    return null;
  }

  /// Check for updates (lightweight check)
  static Future<UpdatesCheckResult> checkForUpdates() async {
    try {
      final lastSync = _instance._lastSyncTime?.toIso8601String();
      final url =
          '${AppConstants.baseUrl}/live_updates.php?types=orders,products${lastSync != null ? '&last_update=$lastSync' : ''}';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final hasUpdates = data['data']['has_updates'] == true;
          final updates = data['data'];

          // Trigger callbacks if there are updates
          if (hasUpdates) {
            _triggerCallbacks(updates);
          }

          return UpdatesCheckResult(hasUpdates: hasUpdates, updates: updates);
        }
      }
    } catch (e) {
      print('Error checking for updates: $e');
    }

    return UpdatesCheckResult(hasUpdates: false, updates: {});
  }

  /// Trigger callbacks based on update type
  static void _triggerCallbacks(Map<String, dynamic> data) {
    if (data['orders'] != null && onOrdersUpdated != null) {
      onOrdersUpdated!(data['orders']);
    }

    if (data['products'] != null && onProductsUpdated != null) {
      onProductsUpdated!(data['products']);
    }

    if (data['categories'] != null && onCategoriesUpdated != null) {
      onCategoriesUpdated!(data['categories']);
    }
  }

  /// Cache data for offline use
  static Future<void> _cacheData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cachedDataKey, json.encode(data));
    } catch (e) {
      print('Error caching data: $e');
    }
  }

  /// Get cached data
  static Future<Map<String, dynamic>?> getCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cachedDataKey);
      if (cached != null) {
        return json.decode(cached);
      }
    } catch (e) {
      print('Error getting cached data: $e');
    }
    return null;
  }

  /// Clear cache
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedDataKey);
  }

  /// Force full refresh (ignoring last sync time)
  static Future<SyncResult> forceRefresh() async {
    _instance._lastSyncTime = null;
    return syncAll();
  }
}

/// Result of sync operation
class SyncResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  SyncResult({required this.success, required this.message, this.data});
}

/// Result of update check
class UpdatesCheckResult {
  final bool hasUpdates;
  final Map<String, dynamic> updates;

  UpdatesCheckResult({required this.hasUpdates, required this.updates});
}
