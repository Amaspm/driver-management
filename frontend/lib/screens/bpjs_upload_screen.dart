import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'bpjs_camera_screen.dart';
import 'emergency_contact_screen.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class BpjsUploadScreen extends StatefulWidget {
  final bool isRejectionFlow;
  
  BpjsUploadScreen({this.isRejectionFlow = false});
  
  @override
  _BpjsUploadScreenState createState() => _BpjsUploadScreenState();
}

class _BpjsUploadScreenState extends State<BpjsUploadScreen> {
  final ApiService _apiService = ApiService(AuthService());
  final _nomorBpjsController = TextEditingController();
  final _namaController = TextEditingController();
  final _akhirBerlakuController = TextEditingController();
  String _status = 'aktif';
  File? _bpjsImage;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomorBpjsController.addListener(() => setState(() {}));
    _namaController.addListener(() => setState(() {}));
    if (widget.isRejectionFlow) {
      _loadExistingData();
    }
  }

  Future<void> _loadExistingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final registrationDataString = prefs.getString('registration_data');
      
      if (registrationDataString != null) {
        final registrationData = json.decode(registrationDataString);
        setState(() {
          _nomorBpjsController.text = registrationData['no_bpjs'] ?? '';
          if (registrationData['tanggal_kedaluarsa_bpjs'] != null) {
            _selectedDate = DateTime.parse(registrationData['tanggal_kedaluarsa_bpjs']);
            _akhirBerlakuController.text = '${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}';
          }
        });
      }
    } catch (e) {
      print('Error loading existing data: $e');
    }
  }

  @override
  void dispose() {
    _nomorBpjsController.dispose();
    _namaController.dispose();
    _akhirBerlakuController.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    final File? capturedImage = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BpjsCameraScreen()),
    );
    
    if (capturedImage != null) {
      setState(() {
        _bpjsImage = capturedImage;
      });
      
      // Save photo as base64 to SharedPreferences
      final bytes = await capturedImage.readAsBytes();
      final base64String = base64Encode(bytes);
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString('registration_data');
      Map<String, dynamic> registrationData = {};
      
      if (existingData != null) {
        registrationData = json.decode(existingData);
      }
      
      registrationData['foto_bpjs'] = base64String;
      registrationData['no_bpjs'] = _nomorBpjsController.text;
      await prefs.setString('registration_data', json.encode(registrationData));
    }
  }

  bool _isFormValid() {
    return _nomorBpjsController.text.isNotEmpty &&
           _namaController.text.isNotEmpty &&
           _akhirBerlakuController.text.isNotEmpty &&
           _bpjsImage != null;
  }

  void _handleNext() async {
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mohon lengkapi semua field')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.isRejectionFlow) {
        // Update rejected documents via API
        final bytes = await _bpjsImage!.readAsBytes();
        final base64String = base64Encode(bytes);
        
        final updateData = {
          'foto_bpjs': base64String,
          'no_bpjs': _nomorBpjsController.text.trim(),
          'tanggal_kedaluarsa_bpjs': _selectedDate?.toIso8601String().split('T')[0] ?? '2025-12-31',
        };

        await _apiService.updateRejectedDocuments(updateData);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data BPJS berhasil diperbaiki'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return to rejection details screen with success indicator
        Navigator.pop(context, true);
      } else {
        // Normal flow - save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final existingData = prefs.getString('registration_data');
        Map<String, dynamic> registrationData = {};
        
        if (existingData != null) {
          registrationData = json.decode(existingData);
        }
        
        registrationData['no_bpjs'] = _nomorBpjsController.text.trim();
        registrationData['tanggal_kedaluarsa_bpjs'] = _selectedDate?.toIso8601String().split('T')[0] ?? '2025-12-31';
        
        if (_bpjsImage != null) {
          final bytes = await _bpjsImage!.readAsBytes();
          final base64String = base64Encode(bytes);
          registrationData['foto_bpjs'] = base64String;
        }
        
        await prefs.setString('registration_data', json.encode(registrationData));
        print('DEBUG: Saved BPJS data - No: ${_nomorBpjsController.text}');
        
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EmergencyContactScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbaiki data BPJS: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          'Register',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Help Center', style: TextStyle(color: Colors.grey.shade600)),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              Container(
                width: 200,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFFDC3545),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 30),
              
              // Phone image
              Center(
                child: Container(
                  width: double.infinity,
                  height: 180,
                  child: Image.asset(
                    'assets/images/Rectangle 299.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.phone_android, size: 80, color: Colors.orange),
                      );
                    },
                  ),
                ),
              ),
              
              SizedBox(height: 30),
              
              // BPJS Title
              Text(
                'BPJS Kesehatan',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF495057),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Upload BPJS section
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Upload BPJS Anda',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF495057),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _openCamera,
                    child: Container(
                      width: 80,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _bpjsImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_bpjsImage!, fit: BoxFit.cover),
                            )
                          : Icon(Icons.image_outlined, size: 30, color: Colors.grey.shade400),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 30),
              
              // Nomor BPJS Field
              Text(
                'Nomor BPJS',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF495057),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _nomorBpjsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFDC3545)),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Nama Field
              Text(
                'Nama pada BPJS',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF495057),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _namaController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFDC3545)),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Akhir Berlaku Field
              Text(
                'Akhir Berlaku',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF495057),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now().add(Duration(days: 365)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2050),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                      _akhirBerlakuController.text = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: _akhirBerlakuController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFFDC3545)),
                      ),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Status Field
              Text(
                'Status',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF495057),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFDC3545)),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                  DropdownMenuItem(value: 'tidak_aktif', child: Text('Tidak Aktif')),
                ].map((item) => item).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
              ),
              
              SizedBox(height: 40),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDC3545),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              widget.isRejectionFlow ? 'Perbaiki BPJS' : 'Selanjutnya',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              // Camera button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _openCamera,
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  label: Text(
                    'Ambil Foto BPJS',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDC3545),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}