import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'dart:async';

class AuthService extends ChangeNotifier {
  static String? _cachedBaseUrl;
  
  static Future<String> get baseUrl async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;
    
    // Try to find working IP
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
          _cachedBaseUrl = 'http://$candidate/api';
          print('Found working API at: $_cachedBaseUrl');
          return _cachedBaseUrl!;
        }
      } catch (e) {
        continue;
      }
    }
    
    // Fallback
    _cachedBaseUrl = 'http://192.168.137.135:8001/api';
    return _cachedBaseUrl!;
  }
  
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<User?> login(String username, String password) async {
    try {
      final apiUrl = await baseUrl;
      print('Attempting login to: $apiUrl/drivers/login/');
      print('Username: $username');
      
      final response = await http.post(
        Uri.parse('$apiUrl/drivers/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': username,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Login success data: $data');
        
        // Get full driver profile after login
        final driverId = data['driver_id'];
        final profileData = await _getDriverProfile(apiUrl, data['token'], driverId);
        
        // Merge login data with profile data
        final fullData = {
          ...data,
          'profile': profileData,
        };
        
        _currentUser = User.fromJson(fullData);
        
        // Save token and full data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _currentUser!.token);
        await prefs.setString('user_data', json.encode(fullData));
        
        notifyListeners();
        return _currentUser;
      } else {
        print('Login failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_data');
    notifyListeners();
  }

  Future<User?> loadSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      
      if (userData != null) {
        final data = json.decode(userData);
        _currentUser = User.fromJson(data);
        print('Loaded saved user: ${_currentUser?.username}');
        notifyListeners();
        return _currentUser;
      }
    } catch (e) {
      print('Error loading saved user: $e');
    }
    return null;
  }

  String? getToken() {
    final token = _currentUser?.token;
    print('AuthService: getToken() returning: $token');
    return token;
  }

  Future<void> saveToken(String token) async {
    print('AuthService: saveToken() called with: $token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    print('AuthService: Token saved to SharedPreferences');
  }
  
  Future<Map<String, dynamic>?> _getDriverProfile(String apiUrl, String token, int driverId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/drivers/$driverId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );
      
      if (response.statusCode == 200) {
        final profileData = json.decode(response.body);
        print('Driver profile data: $profileData');
        return profileData;
      } else {
        print('Failed to get driver profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting driver profile: $e');
    }
    return null;
  }
}