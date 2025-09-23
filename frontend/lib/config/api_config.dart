import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';

class ApiConfig {
  static String? _cachedBaseUrl;
  
  static Future<String> get baseUrl async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;
    
    final candidates = [
      '192.168.137.135:8001',
      '192.168.1.100:8001', 
      '192.168.0.100:8001',
      '10.0.2.2:8001',
      'localhost:8001'
    ];
    
    for (String candidate in candidates) {
      try {
        final response = await http.get(
          Uri.parse('http://$candidate/api/drivers/status/')
        ).timeout(Duration(seconds: 2));
        
        if (response.statusCode == 200 || response.statusCode == 405) {
          _cachedBaseUrl = 'http://$candidate';
          print('Found working API at: $_cachedBaseUrl');
          return _cachedBaseUrl!;
        }
      } catch (e) {
        continue;
      }
    }
    
    _cachedBaseUrl = 'http://192.168.137.135:8001';
    return _cachedBaseUrl!;
  }
}
