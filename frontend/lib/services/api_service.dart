import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/driver.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService _authService;
  static bool _autoDetectionDone = false;
  static Map<String, dynamic>? _lastLoginData;

  ApiService(this._authService);
  
  Future<String> get _baseUrl async {
    return await ApiConfig.baseUrl;
  }
  
  static Future<String> get baseUrl async {
    return await ApiConfig.baseUrl;
  }

  Future<Map<String, String>> get _headers async {
    String? token = _authService.getToken();
    
    // Fallback to SharedPreferences if AuthService doesn't have token
    if (token == null) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token');
      print('API: Using token from SharedPreferences: $token');
    }
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };
  }

  Future<List<Driver>> getDrivers() async {
    final url = await _baseUrl;
    final headers = await _headers;
    final response = await http.get(
      Uri.parse('$url/drivers/'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Driver.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load drivers');
    }
  }

  Future<Driver> createDriver(Driver driver) async {
    final url = await _baseUrl;
    final headers = await _headers;
    final response = await http.post(
      Uri.parse('$url/drivers/'),
      headers: headers,
      body: json.encode(driver.toJson()),
    );

    if (response.statusCode == 201) {
      return Driver.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create driver');
    }
  }

  Future<void> updateDriverStatus(int driverId, String action) async {
    final url = await _baseUrl;
    final headers = await _headers;
    final response = await http.post(
      Uri.parse('$url/drivers/$driverId/$action/'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update driver status');
    }
  }

  Future<Map<String, dynamic>> submitDriverRegistration(Map<String, dynamic> data) async {
    final url = await _baseUrl;
    final response = await http.post(
      Uri.parse('$url/drivers/register/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to submit registration');
    }
  }
  
  Future<Map<String, dynamic>> completeTraining(String email) async {
    final url = await _baseUrl;
    final response = await http.post(
      Uri.parse('$url/training/complete/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'email': email}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to complete training');
    }
  }

  Future<Map<String, dynamic>> checkDriverStatus() async {
    try {
      final url = await _baseUrl;
      print('API: Checking status at $url/drivers/status/');
      final headers = await _headers;
      print('API: Headers: $headers');
      final response = await http.get(
        Uri.parse('$url/drivers/status/'),
        headers: headers,
      );

      print('API: Status check response: ${response.statusCode}');
      print('API: Status check body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API: Driver status: ${data['status']}');
        return data;
      } else {
        print('API: Status check failed, returning pending');
        return {'status': 'pending', 'rejected_documents': []};
      }
    } catch (e) {
      print('API: Error checking driver status: $e');
      return {'status': 'pending', 'rejected_documents': []};
    }
  }

  Future<bool> loginDriver(String email, String password) async {
    final url = await _baseUrl;
    print('API: Attempting login to $url/drivers/login/');
    final response = await http.post(
      Uri.parse('$url/drivers/login/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    print('API: Login response status: ${response.statusCode}');
    print('API: Login response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('API: Saving token: ${data['token']}');
      print('API: Driver status from login: ${data['status']}');
      print('API: Has vehicle: ${data['has_vehicle']}');
      
      // Store login data for later use
      _lastLoginData = data;
      
      // Save token to AuthService
      await _authService.saveToken(data['token']);
      
      // Also save to SharedPreferences directly for immediate use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
      
      return true;
    } else {
      print('API: Login failed with status ${response.statusCode}');
      return false;
    }
  }

  Future<Map<String, dynamic>> getLoginData() async {
    if (_lastLoginData != null) {
      return _lastLoginData!;
    }
    // Fallback to status check if no login data available
    return await checkDriverStatus();
  }

  Future<Map<String, dynamic>> getDriverStatistics() async {
    try {
      final url = await _baseUrl;
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('$url/drivers/statistics/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get driver statistics');
      }
    } catch (e) {
      print('API: Error getting driver statistics: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> getDriverProfile() async {
    try {
      final url = await _baseUrl;
      final headers = await _headers;
      
      // First get user info to get driver ID
      final userResponse = await http.get(
        Uri.parse('$url/auth/user/'),
        headers: headers,
      );
      
      if (userResponse.statusCode == 200) {
        final userData = json.decode(userResponse.body);
        final driverId = userData['id'];
        
        // Then get complete driver data
        final driverResponse = await http.get(
          Uri.parse('$url/drivers/$driverId/'),
          headers: headers,
        );
        
        if (driverResponse.statusCode == 200) {
          return json.decode(driverResponse.body);
        } else {
          // Fallback to user data if driver endpoint fails
          return userData;
        }
      } else {
        throw Exception('Failed to get driver profile');
      }
    } catch (e) {
      print('API: Error getting driver profile: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> updateDriverProfile(Map<String, dynamic> data) async {
    try {
      final url = await _baseUrl;
      final headers = await _headers;
      
      // Get driver ID from profile first
      final profile = await getDriverProfile();
      final driverId = profile['id_driver'] ?? profile['id'];
      
      print('Updating profile for driver $driverId');
      
      final response = await http.put(
        Uri.parse('$url/drivers/$driverId/'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        print('Profile updated successfully');
        return json.decode(response.body);
      } else {
        print('Update failed: ${response.statusCode}');
        throw Exception('Failed to update driver profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Update error: $e');
      throw e;
    }
  }

  // Training API methods
  Future<List<dynamic>> getTrainingModules() async {
    try {
      final url = await _baseUrl;
      final response = await http.get(
        Uri.parse('$url/training-modules/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load training modules');
      }
    } catch (e) {
      print('API: Error getting training modules: $e');
      throw e;
    }
  }

  Future<List<dynamic>> getTrainingContents(int moduleId) async {
    try {
      final url = await _baseUrl;
      final response = await http.get(
        Uri.parse('$url/training-contents/?module_id=$moduleId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load training contents');
      }
    } catch (e) {
      print('API: Error getting training contents: $e');
      throw e;
    }
  }

  Future<List<dynamic>> getTrainingQuizzes(int moduleId) async {
    try {
      final url = await _baseUrl;
      final response = await http.get(
        Uri.parse('$url/training-quizzes/?module_id=$moduleId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load training quizzes');
      }
    } catch (e) {
      print('API: Error getting training quizzes: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> startTrainingModule(int moduleId, {bool isGuest = false}) async {
    try {
      final endpoint = isGuest ? 'start_module_guest' : 'start_module';
      final headers = isGuest ? {'Content-Type': 'application/json'} : await _headers;
      
      final url = await _baseUrl;
      final response = await http.post(
        Uri.parse('$url/training-progress/$endpoint/'),
        headers: headers,
        body: json.encode({'module_id': moduleId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to start training module');
      }
    } catch (e) {
      print('API: Error starting training module: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> completeTrainingContent(int moduleId, int contentId, {bool isGuest = false, List<int>? completedContents}) async {
    try {
      final endpoint = isGuest ? 'complete_content_guest' : 'complete_content';
      final headers = isGuest ? {'Content-Type': 'application/json'} : await _headers;
      
      final Map<String, dynamic> body = {
        'module_id': moduleId,
        'content_id': contentId,
      };
      
      if (isGuest && completedContents != null) {
        body['completed_contents'] = completedContents;
      }
      
      final url = await _baseUrl;
      final response = await http.post(
        Uri.parse('$url/training-progress/$endpoint/'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to complete training content');
      }
    } catch (e) {
      print('API: Error completing training content: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> submitTrainingQuiz(int moduleId, Map<String, String> answers, {bool isGuest = false, List<int>? completedContents}) async {
    try {
      final endpoint = isGuest ? 'submit_quiz_guest' : 'submit_quiz';
      final headers = isGuest ? {'Content-Type': 'application/json'} : await _headers;
      
      final Map<String, dynamic> body = {
        'module_id': moduleId,
        'answers': answers,
      };
      
      if (isGuest && completedContents != null) {
        body['completed_contents'] = completedContents;
      }
      
      final url = await _baseUrl;
      final response = await http.post(
        Uri.parse('$url/training-progress/$endpoint/'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to submit quiz');
      }
    } catch (e) {
      print('API: Error submitting quiz: $e');
      throw e;
    }
  }

  Future<List<dynamic>> getTrainingProgress() async {
    try {
      final url = await _baseUrl;
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('$url/training-progress/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load training progress');
      }
    } catch (e) {
      print('API: Error getting training progress: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> updateRejectedDocuments(Map<String, dynamic> data) async {
    try {
      final url = await _baseUrl;
      final headers = await _headers;
      final response = await http.post(
        Uri.parse('$url/drivers/update-documents/'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update documents');
      }
    } catch (e) {
      print('API: Error updating rejected documents: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> completeRejectedDocuments() async {
    try {
      final url = await _baseUrl;
      final headers = await _headers;
      final response = await http.post(
        Uri.parse('$url/drivers/complete-documents/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to complete documents');
      }
    } catch (e) {
      print('API: Error completing rejected documents: $e');
      throw e;
    }
  }

  Future<List<dynamic>> getDriverTrips() async {
    try {
      final url = await _baseUrl;
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('$url/drivers/trips/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get driver trips');
      }
    } catch (e) {
      print('API: Error getting driver trips: $e');
      throw e;
    }
  }

  // Generic GET method
  Future<dynamic> get(String endpoint) async {
    try {
      final url = await _baseUrl;
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('$url$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to GET $endpoint: ${response.statusCode}');
      }
    } catch (e) {
      print('API: Error GET $endpoint: $e');
      throw e;
    }
  }
}