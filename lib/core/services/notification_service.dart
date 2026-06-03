import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Notification Service - handles local notifications & Firebase Push Notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _firebaseEnabled = false;
  String? _deviceToken;

  // API Configuration - Using your Firebase project
  // Project ID: nozzle-3254e
  static const String _baseUrl = ApiService.baseUrl;

  /// Get device token
  String? get deviceToken => _deviceToken;

  /// Initialize the notification service
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Initialize Firebase Messaging (optional)
    await _initFirebaseMessaging();

    _isInitialized = true;
  }

  /// Initialize Firebase Messaging (optional - will fail gracefully if no Firebase)
  Future<void> _initFirebaseMessaging() async {
    try {
      // Check if Firebase is initialized before trying to use it
      if (Firebase.apps.isEmpty) {
        print('Firebase not initialized - skipping Firebase Messaging setup');
        _firebaseEnabled = false;
        return;
      }

      // Try to initialize Firebase Messaging
      final FirebaseMessaging fcm = FirebaseMessaging.instance;

      // Request permission
      await requestPermissions();

      // Get device token
      _deviceToken = await fcm.getToken();
      print('FCM Token: $_deviceToken');
      _firebaseEnabled = true;

      // Save token to server
      if (_deviceToken != null) {
        await _saveTokenToServer(_deviceToken!);
      }

      // Handle foreground messages (only if Firebase is enabled)
      if (_firebaseEnabled) {
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle when app is opened from notification
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpened);

        // Check if app was opened from notification (cold start)
        final initialMessage = await fcm.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationOpened(initialMessage);
        }
      }
    } catch (e) {
      print('Firebase Messaging not available: $e');
      _firebaseEnabled = false;
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.notification?.title}');

    final title = message.notification?.title ?? message.data['title'] ?? '';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final type = message.data['type'] ?? 'general';
    final payload = jsonEncode(message.data);

    showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: payload,
    );
  }

  /// Handle when user taps on notification
  void _handleNotificationOpened(RemoteMessage message) {
    print('Notification opened: ${message.data}');

    // Handle navigation based on notification type
    final type = message.data['type'] ?? 'general';
    // You can emit a stream or use a callback to navigate
  }

  /// Save token to server
  Future<void> _saveTokenToServer(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      await http.post(
        Uri.parse('$_baseUrl/notifications.php?action=save_token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'user_id': userId,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
          'device_name': Platform.isAndroid ? 'Android' : 'iOS',
          'app_version': '1.0.0',
        }),
      );
      print('Token saved to server');
    } catch (e) {
      print('Error saving token to server: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        // Handle navigation based on data
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  /// Request permissions
  Future<bool> requestPermissions() async {
    try {
      final FirebaseMessaging fcm = FirebaseMessaging.instance;

      if (Platform.isIOS) {
        final result = await fcm.requestPermission(
          alert: true,
          announcement: true,
          badge: true,
          sound: true,
        );
        return result.authorizationStatus == AuthorizationStatus.authorized;
      } else if (Platform.isAndroid) {
        final result = await fcm.requestPermission();
        return result == AuthorizationStatus.authorized;
      }
    } catch (e) {
      print('Error requesting permissions: $e');
    }
    return false;
  }

  /// Get notifications from server
  Future<List<Map<String, dynamic>>> getNotifications({
    int userId = 0,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/notifications.php?action=get_notifications&user_id=$userId&limit=$limit&offset=$offset',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(
            data['data']['notifications'] ?? [],
          );
        }
      }
    } catch (e) {
      print('Error getting notifications: $e');
    }
    return [];
  }

  /// Mark notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications.php?action=mark_read'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': notificationId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
    return false;
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications.php?action=mark_all_read'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
    return false;
  }

  /// Delete notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications.php?action=delete_notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': notificationId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
    return false;
  }

  /// Show simple notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'auto_lube_channel',
      'تنبيهات نوزل',
      channelDescription: 'تنبيهات تطبيق نوزل',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'auto_lube_channel',
      'تنبيهات نوزل',
      channelDescription: 'تنبيهات تطبيق نوزل',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Show order notification
  Future<void> showOrderNotification({
    required String orderId,
    required String status,
  }) async {
    String title;
    String body;

    switch (status) {
      case 'confirmed':
        title = 'تم تأكيد الطلب';
        body = 'تم تأكيد طلبك رقم $orderId';
        break;
      case 'shipped':
        title = 'تم الشحن';
        body = 'تم شحن طلبك رقم $orderId';
        break;
      case 'delivered':
        title = 'تم التوصيل';
        body = 'تم توصيل طلبك رقم $orderId';
        break;
      default:
        title = 'تحديث الطلب';
        body = 'حالة طلبك رقم $orderId: $status';
    }

    await showNotification(
      id: orderId.hashCode,
      title: title,
      body: body,
      payload: orderId,
    );
  }

  /// Show oil change reminder
  Future<void> showOilChangeReminder({
    required String vehicleName,
    required int daysUntilChange,
  }) async {
    String body;
    if (daysUntilChange <= 0) {
      body = 'حان وقت تغيير الزيت لـ $vehicleName';
    } else {
      body = 'متبقي $daysUntilChange يوم على تغيير الزيت لـ $vehicleName';
    }

    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'تذكير تغيير الزيت',
      body: body,
      payload: 'oil_reminder',
    );
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Schedule oil change reminder for a vehicle
  Future<void> scheduleOilChangeReminder({
    required String vehicleId,
    required String vehicleName,
    required int daysUntilChange,
  }) async {
    // Calculate reminder date (3 days before the change date)
    final reminderDate = DateTime.now().add(
      Duration(days: daysUntilChange - 3),
    );

    if (reminderDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: vehicleId.hashCode,
        title: 'تذكير تغيير الزيت',
        body:
            'متبقي ${daysUntilChange - 3} يوم على تغيير الزيت لـ $vehicleName',
        scheduledTime: reminderDate,
        payload: 'oil_reminder:$vehicleId',
      );
    }
  }
}
