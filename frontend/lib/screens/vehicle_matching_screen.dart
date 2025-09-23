import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/camera_screen.dart';
import '../config/api_config.dart';

class VehicleMatchingScreen extends StatefulWidget {
  @override
  _VehicleMatchingScreenState createState() => _VehicleMatchingScreenState();
}

class _VehicleMatchingScreenState extends State<VehicleMatchingScreen> {
  final ApiService _apiService = ApiService(AuthService());
  bool? _hasOwnVehicle;
  bool _isLoading = true;
  List<dynamic> _availableVehicles = [];
  Map<String, dynamic>? _selectedVehicle;
  
  // Form controllers for own vehicle
  final _platController = TextEditingController();
  String? _selectedJenisKendaraan;
  final _warnaController = TextEditingController();
  final _kapasitasController = TextEditingController();
  final _stnkController = TextEditingController();
  final _bpkbController = TextEditingController();
  
  // Photo variables
  String? _fotoStnk;
  String? _fotoBpkb;

  @override
  void initState() {
    super.initState();
    _loadAvailableVehicles();
  }

  Future<void> _takePhoto(String type) async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kamera tidak tersedia')),
        );
        return;
      }

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(
            camera: cameras.first,
            title: type == 'stnk' ? 'Foto STNK' : 'Foto BPKB',
          ),
        ),
      );

      if (result != null) {
        setState(() {
          if (type == 'stnk') {
            _fotoStnk = result;
          } else {
            _fotoBpkb = result;
          }
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e')),
      );
    }
  }

  Future<void> _loadAvailableVehicles() async {
    try {
      print('Loading vehicles from API...');
      final token = await _getToken();
      print('Token: $token');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/armada/'),
        headers: {
          'Authorization': 'Token $token',
        },
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        setState(() {
          _availableVehicles = json.decode(response.body);
          _isLoading = false;
        });
        print('Vehicles loaded: ${_availableVehicles.length}');
      } else {
        print('Failed to load vehicles: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading vehicles: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _submitOwnVehicle() async {
    if (_fotoStnk == null || _fotoBpkb == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap ambil foto STNK dan BPKB terlebih dahulu')),
      );
      return;
    }
    
    if (_selectedJenisKendaraan == null || _platController.text.isEmpty || 
        _warnaController.text.isEmpty || _kapasitasController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap lengkapi semua data kendaraan')),
      );
      return;
    }
    
    try {
      print('Submitting vehicle data...');
      final token = await _getToken();
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/armada/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({
          'nomor_polisi': _platController.text,
          'jenis_armada': _selectedJenisKendaraan,
          'warna_armada': _warnaController.text,
          'kapasitas_muatan': int.parse(_kapasitasController.text),
          'id_stnk': _stnkController.text,
          'id_bpkb': _bpkbController.text,
          'foto_stnk': _fotoStnk,
          'foto_bpkb': _fotoBpkb,
          'status': true,
          'tahun_pembuatan': DateTime.now().toIso8601String(),
        }),
      );
      
      print('Vehicle creation response: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final vehicleData = json.decode(response.body);
        await _assignVehicleToDriver(vehicleData['id_armada']);
        
        // Mark vehicle matching as completed
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('vehicle_matching_completed', true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendaftarkan kendaraan')),
        );
      }
    } catch (e) {
      print('Error submitting vehicle: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _assignVehicleToDriver(int vehicleId) async {
    try {
      print('Assigning vehicle $vehicleId to driver...');
      
      final token = await _getToken();
      
      // Get driver ID first
      final profileResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/user/'),
        headers: {
          'Authorization': 'Token $token',
        },
      );
      
      if (profileResponse.statusCode != 200) {
        throw Exception('Failed to get driver profile');
      }
      
      final profileData = json.decode(profileResponse.body);
      final driverId = profileData['id'];
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/driver-armada/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({
          'id_driver': driverId,
          'id_armada': vehicleId,
          'tanggal_mulai': DateTime.now().toIso8601String(),
          'tanggal_selesai': DateTime.now().add(Duration(days: 365)).toIso8601String(),
        }),
      );
      
      print('Assignment response: ${response.statusCode}');
      print('Assignment response body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        String message = response.statusCode == 200 
            ? 'Kendaraan sudah terdaftar' 
            : 'Kendaraan berhasil didaftarkan';
        
        // Mark vehicle matching as completed
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('vehicle_matching_completed', true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        String errorMessage = 'Gagal menghubungkan kendaraan ke driver';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          } else if (errorData is Map && errorData.containsKey('detail')) {
            errorMessage = errorData['detail'];
          } else if (errorData is Map && errorData.containsKey('non_field_errors')) {
            errorMessage = errorData['non_field_errors'][0];
          }
        } catch (e) {
          errorMessage = 'Error: ${response.statusCode}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      print('Error assigning vehicle: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _skipVehicleSelection() async {
    try {
      // Update driver status to indicate no vehicle assigned
      final token = await _getToken();
      
      // Just proceed to dashboard without vehicle assignment
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Melanjutkan tanpa kendaraan')),
      );
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      print('Error skipping vehicle: $e');
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kendaraan Driver',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Color(0xFFDC3545)))
            : SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kendaraan Saya',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF495057),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Question about own vehicle
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Apakah Anda sudah memiliki kendaraan pribadi?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF495057),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => setState(() => _hasOwnVehicle = true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _hasOwnVehicle == true ? Color(0xFFDC3545) : Colors.grey[300],
                                    foregroundColor: _hasOwnVehicle == true ? Colors.white : Colors.black,
                                  ),
                                  child: Text('Ya'),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => setState(() => _hasOwnVehicle = false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _hasOwnVehicle == false ? Color(0xFFDC3545) : Colors.grey[300],
                                    foregroundColor: _hasOwnVehicle == false ? Colors.white : Colors.black,
                                  ),
                                  child: Text('Tidak'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Show form based on selection
                    if (_hasOwnVehicle == true) ...[
                      _buildOwnVehicleForm(),
                    ] else if (_hasOwnVehicle == false) ...[
                      _buildAvailableVehicles(),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOwnVehicleForm() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Kendaraan Pribadi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF495057),
            ),
          ),
          SizedBox(height: 16),
          
          TextField(
            controller: _platController,
            decoration: InputDecoration(
              labelText: 'Nomor Polisi',
              hintText: 'B 1234 ABC',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _selectedJenisKendaraan,
            decoration: InputDecoration(
              labelText: 'Jenis Kendaraan',
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'Motor', child: Text('Motor')),
              DropdownMenuItem(value: 'Mobil', child: Text('Mobil')),
              DropdownMenuItem(value: 'Truk', child: Text('Truk')),
              DropdownMenuItem(value: 'Pick Up', child: Text('Pick Up')),
              DropdownMenuItem(value: 'Van', child: Text('Van')),
            ],
            onChanged: (value) => setState(() => _selectedJenisKendaraan = value),
          ),
          SizedBox(height: 16),
          
          TextField(
            controller: _warnaController,
            decoration: InputDecoration(
              labelText: 'Warna',
              hintText: 'Merah',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          
          TextField(
            controller: _kapasitasController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Kapasitas Muatan (kg)',
              hintText: '1000',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          
          TextField(
            controller: _stnkController,
            decoration: InputDecoration(
              labelText: 'ID STNK',
              hintText: 'STNK123456',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          
          TextField(
            controller: _bpkbController,
            decoration: InputDecoration(
              labelText: 'ID BPKB',
              hintText: 'BPKB123456',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          
          // Photo STNK
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _takePhoto('stnk'),
              icon: Icon(_fotoStnk != null ? Icons.check_circle : Icons.camera_alt),
              label: Text(_fotoStnk != null ? 'Foto STNK ✓' : 'Ambil Foto STNK'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _fotoStnk != null ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(height: 12),
          
          // Photo BPKB
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _takePhoto('bpkb'),
              icon: Icon(_fotoBpkb != null ? Icons.check_circle : Icons.camera_alt),
              label: Text(_fotoBpkb != null ? 'Foto BPKB ✓' : 'Ambil Foto BPKB'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _fotoBpkb != null ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitOwnVehicle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFDC3545),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Daftarkan Kendaraan',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableVehicles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Kendaraan Tersedia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF495057),
          ),
        ),
        SizedBox(height: 16),
        
        if (_availableVehicles.isEmpty)
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Tidak ada kendaraan tersedia saat ini',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _skipVehicleSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Lanjutkan Tanpa Kendaraan',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...(_availableVehicles.where((v) => v['status'] == true).map((vehicle) => 
            Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedVehicle?['id_armada'] == vehicle['id_armada'] 
                      ? Color(0xFFDC3545) 
                      : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: ListTile(
                title: Text(
                  '${vehicle['jenis_armada']} - ${vehicle['nomor_polisi']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Warna: ${vehicle['warna_armada']}'),
                    Text('Kapasitas: ${vehicle['kapasitas_muatan']} kg'),
                  ],
                ),
                onTap: () => setState(() => _selectedVehicle = vehicle),
                trailing: _selectedVehicle?['id_armada'] == vehicle['id_armada']
                    ? Icon(Icons.check_circle, color: Color(0xFFDC3545))
                    : null,
              ),
            ),
          ).toList()),
        
        if (_selectedVehicle != null) ...[
          SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await _assignVehicleToDriver(_selectedVehicle!['id_armada']);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFDC3545),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Pilih Kendaraan Ini',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
        
        // Add skip option even when vehicles are available
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Text(
                'Atau lanjutkan tanpa memilih kendaraan',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _skipVehicleSelection,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[600]!),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Lanjutkan Tanpa Kendaraan',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}