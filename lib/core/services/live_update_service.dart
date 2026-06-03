import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../../providers/cart_provider.dart';

/// Real-time live update service utilizing FastAPI WebSockets
class LiveUpdateService {
  static final LiveUpdateService _instance = LiveUpdateService._internal();
  factory LiveUpdateService() => _instance;
  LiveUpdateService._internal();

  WebSocket? _webSocket;
  bool _isListening = false;
  bool _isConnected = false;
  Timer? _reconnectTimer;

  // Stream for stock updates so widgets can listen directly
  static final StreamController<Map<String, dynamic>> _stockUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
      
  /// Broadcast stream for real-time stock updates
  static Stream<Map<String, dynamic>> get stockUpdates => _stockUpdateController.stream;

  // Stream for order updates
  static final StreamController<Map<String, dynamic>> _orderUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
      
  /// Broadcast stream for real-time order updates
  static Stream<Map<String, dynamic>> get orderUpdates => _orderUpdateController.stream;

  /// Start listening for real-time updates over WebSocket
  void startListening() {
    if (_isListening) return;
    _isListening = true;
    _connectWebSocket();
  }

  /// Stop listening and close WebSocket connection
  void stopListening() {
    _isListening = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _closeWebSocket();
  }

  /// Establish WebSocket connection
  Future<void> _connectWebSocket() async {
    if (!_isListening || _isConnected) return;

    final String wsUrl = 'ws://${ApiService.domain}/api/ws/stock';
    debugPrint('🔄 LiveUpdateService: Connecting to WebSocket at $wsUrl');

    try {
      _webSocket = await WebSocket.connect(wsUrl).timeout(const Duration(seconds: 8));
      _isConnected = true;
      debugPrint('⚡ LiveUpdateService: Connected to WebSocket successfully!');

      _webSocket!.listen(
        (message) {
          _handleWebSocketMessage(message);
        },
        onError: (error) {
          debugPrint('❌ LiveUpdateService: WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          debugPrint('ℹ️ LiveUpdateService: WebSocket connection closed by server');
          _handleDisconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('⚠️ LiveUpdateService: Failed to connect to WebSocket: $e');
      _handleDisconnect();
    }
  }

  /// Handle WebSocket disconnection and schedule reconnect
  void _handleDisconnect() {
    _isConnected = false;
    _closeWebSocket();
    
    if (_isListening) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        debugPrint('🔄 LiveUpdateService: Attempting WebSocket reconnection...');
        _connectWebSocket();
      });
    }
  }

  /// Safely close WebSocket
  void _closeWebSocket() {
    try {
      _webSocket?.close();
    } catch (e) {
      debugPrint('Error closing WebSocket: $e');
    }
    _webSocket = null;
    _isConnected = false;
  }

  /// Handle incoming messages from WebSocket
  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = json.decode(message.toString()) as Map<String, dynamic>;
      debugPrint('📩 LiveUpdateService: Received WebSocket payload: $data');

      // Check for stock update events
      if (data['event'] == 'stock_updated') {
        final productId = data['product_id']?.toString();
        final int newQty = data['new_qty'] ?? data['stock_quantity'] ?? 0;
        
        // 1. Broadcast update to UI listeners
        _stockUpdateController.add(data);
        
        // 2. Synchronize with local Cart state provider
        CartProvider().updateStockFromWebSocket(productId, newQty);
        
        debugPrint('🔔 LiveUpdateService: Processed stock update for $productId: $newQty');
      } else if (data['event'] == 'order_status_updated') {
        // Broadcast update to UI listeners
        _orderUpdateController.add(data);
        debugPrint('🔔 LiveUpdateService: Processed order status update for ${data['order_id']}: ${data['status']}');
      }
    } catch (e) {
      debugPrint('❌ LiveUpdateService: Error processing WebSocket payload: $e');
    }
  }

  /// Check if WebSocket is currently connected
  bool get isConnected => _isConnected;

  /// Check if the service is running
  bool get isListening => _isListening;
}
