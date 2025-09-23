import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class DriverShiftService extends ChangeNotifier {
  static const String wsUrl = 'ws://192.168.137.135:8080/ws';
  
  WebSocketChannel? _channel;
  bool _isOnShift = false;
  String? _driverId;
  String? _kota;
  List<Map<String, dynamic>> _notifications = [];
  
  bool get isOnShift => _isOnShift;
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n['read']).length;
  
  Future<void> loadShiftStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isOnShift = prefs.getBool('isOnShift') ?? false;
    _driverId = prefs.getString('driverId');
    _kota = prefs.getString('kota');
    
    if (_isOnShift && _driverId != null) {
      connectWebSocket(_driverId!);
    }
    notifyListeners();
  }
  
  Future<void> _saveShiftStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnShift', _isOnShift);
    if (_driverId != null) await prefs.setString('driverId', _driverId!);
    if (_kota != null) await prefs.setString('kota', _kota!);
  }
  
  void connectWebSocket(String driverId) {
    _driverId = driverId;
    print('Connecting to WebSocket: $wsUrl?driver_id=$driverId');
    _channel = WebSocketChannel.connect(
      Uri.parse('$wsUrl?driver_id=$driverId'),
    );
    
    _channel!.stream.listen(
      (data) {
        print('=== WebSocket received data ===');
        print('Raw data: $data');
        print('Data type: ${data.runtimeType}');
        try {
          final orderData = jsonDecode(data);
          print('Parsed order data: $orderData');
          _showOrderNotification(orderData);
        } catch (e) {
          print('Error parsing WebSocket data: $e');
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed');
      },
    );
    print('WebSocket connection established');
  }
  
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
  
  Future<bool> startShift(String driverId, String kota) async {
    try {
      final url = 'http://192.168.137.135:8080/driver/status';
      print('Starting shift - URL: $url');
      print('Driver ID: $driverId, Kota: $kota');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'driver_id': driverId,
          'kota': kota,
          'status': 'online',
        }),
      );
      
      print('Start shift response: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        _isOnShift = true;
        _driverId = driverId;
        _kota = kota;
        await _saveShiftStatus();
        notifyListeners();
        connectWebSocket(driverId);
        return true;
      }
      return false;
    } catch (e) {
      print('Error starting shift: $e');
      return false;
    }
  }
  
  Future<bool> endShift() async {
    if (_driverId == null) return false;
    
    try {
      final url = 'http://192.168.137.135:8080/driver/status';
      print('Ending shift - URL: $url');
      print('Driver ID: $_driverId');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'driver_id': _driverId,
          'status': 'offline',
        }),
      );
      
      print('End shift response: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        _isOnShift = false;
        await _saveShiftStatus();
        notifyListeners();
        disconnect();
        return true;
      }
      return false;
    } catch (e) {
      print('Error ending shift: $e');
      return false;
    }
  }
  
  void _showOrderNotification(Map<String, dynamic> orderData) {
    print('New order received: ${orderData['order_id']}');
    print('Pickup: ${orderData['pickup']}');
    print('Destination: ${orderData['tujuan']}');
    print('Payment: Rp${orderData['ongkos']}');
    
    // Add to notifications list
    _notifications.insert(0, {
      ...orderData,
      'type': 'order',
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    });
    
    notifyListeners();
    
    // Trigger notification callback if set
    if (onOrderReceived != null) {
      onOrderReceived!(orderData);
    }
  }
  
  void markNotificationAsRead(int index) {
    if (index < _notifications.length) {
      _notifications[index]['read'] = true;
      notifyListeners();
    }
  }
  
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }
  
  void removeNotificationByOrderId(String orderId) {
    _notifications.removeWhere((notification) => notification['order_id'] == orderId);
    notifyListeners();
  }
  
  Function(Map<String, dynamic>)? onOrderReceived;
  
  Future<bool> acceptOrder(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/order/response'),
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
  
  Future<bool> rejectOrder(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/order/response'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'driver_id': _driverId,
          'order_id': orderId,
          'action': 'abaikan',
        }),
      );
      
      print('Reject order response: ${response.statusCode}');
      return true; // Always return true for reject to show success message
    } catch (e) {
      print('Error rejecting order: $e');
      return true; // Still return true as rejection is handled locally
    }
  }
}