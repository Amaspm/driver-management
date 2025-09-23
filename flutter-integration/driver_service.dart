import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class DriverService {
  static const String baseUrl = 'http://localhost:8001/api';
  static const String wsUrl = 'ws://localhost:8080/ws';
  
  WebSocketChannel? _channel;
  String? _driverId;
  
  // Connect to WebSocket for real-time notifications
  void connectWebSocket(String driverId) {
    _driverId = driverId;
    _channel = WebSocketChannel.connect(
      Uri.parse('$wsUrl?driver_id=$driverId'),
    );
    
    // Listen for incoming orders
    _channel!.stream.listen(
      (data) {
        final orderData = jsonDecode(data);
        _showOrderNotification(orderData);
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
    );
  }
  
  // Disconnect WebSocket
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
  
  // Set driver online
  Future<bool> setDriverOnline(String driverId, String kota) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/driver/online'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'driver_id': driverId,
          'kota': kota,
        }),
      );
      
      if (response.statusCode == 200) {
        connectWebSocket(driverId);
        return true;
      }
      return false;
    } catch (e) {
      print('Error setting driver online: $e');
      return false;
    }
  }
  
  // Set driver offline
  Future<bool> setDriverOffline(String driverId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/driver/offline'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'driver_id': driverId,
        }),
      );
      
      if (response.statusCode == 200) {
        disconnect();
        return true;
      }
      return false;
    } catch (e) {
      print('Error setting driver offline: $e');
      return false;
    }
  }
  
  // Show order notification (implement with your notification system)
  void _showOrderNotification(Map<String, dynamic> orderData) {
    // This should trigger a notification or popup in your Flutter app
    print('New order received: ${orderData['order_id']}');
    print('Pickup: ${orderData['pickup']}');
    print('Destination: ${orderData['tujuan']}');
    print('Payment: Rp${orderData['ongkos']}');
    
    // TODO: Show notification dialog or push notification
    // You can use flutter_local_notifications or similar package
  }
  
  // Accept order
  Future<bool> acceptOrder(String orderId) async {
    try {
      // Send response via WebSocket or HTTP
      final response = await http.post(
        Uri.parse('$baseUrl/order/response'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'driver_id': _driverId,
          'order_id': orderId,
          'action': 'terima',
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error accepting order: $e');
      return false;
    }
  }
  
  // Reject order
  Future<bool> rejectOrder(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/order/response'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'driver_id': _driverId,
          'order_id': orderId,
          'action': 'abaikan',
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error rejecting order: $e');
      return false;
    }
  }
}