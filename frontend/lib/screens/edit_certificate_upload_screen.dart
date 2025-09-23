import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'certificate_camera_screen.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class EditCertificateUploadScreen extends StatefulWidget {
  @override
  _EditCertificateUploadScreenState createState() => _EditCertificateUploadScreenState();
}

class _EditCertificateUploadScreenState extends State<EditCertificateUploadScreen> {
  final ApiService _apiService = ApiService(AuthService());
  final _nomorSertifikatController = TextEditingController();
  final _akhirBerlakuController = TextEditingController();
  File? _certificateImage;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    _nomorSertifikatController.dispose();
    _akhirBerlakuController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final registrationDataString = prefs.getString('registration_data');
      
      if (registrationDataString != null) {
        final registrationData = json.decode(registrationDataString);
        setState(() {
          _nomorSertifikatController.text = registrationData['no_sertifikat'] ?? '';
          if (registrationData['tanggal_kedaluarsa_sertifikat'] != null) {
            _selectedDate = DateTime.parse(registrationData['tanggal_kedaluarsa_sertifikat']);
            _akhirBerlakuController.text = '${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}';
          }
        });
      }
    } catch (e) {
      print('Error loading existing data: $e');
    }
  }

  Future<void> _openCamera() async {
    final File? capturedImage = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CertificateCameraScreen()),
    );
    
    if (capturedImage != null) {
      setState(() {
        _certificateImage = capturedImage;
      });
    }
  }

  bool _isFormValid() {
    return _nomorSertifikatController.text.isNotEmpty &&
           _akhirBerlakuController.text.isNotEmpty &&
           _certificateImage != null;
  }

  Future<void> _updateCertificateData() async {
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mohon lengkapi semua data dan foto sertifikat'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert image to base64
      final bytes = await _certificateImage!.readAsBytes();
      final base64String = base64Encode(bytes);

      // Prepare update data
      final updateData = {
        'foto_sertifikat': base64String,
        'no_sertifikat': _nomorSertifikatController.text.trim(),
        'tanggal_kedaluarsa_sertifikat': _selectedDate?.toIso8601String().split('T')[0] ?? '2025-12-31',
      };

      // Update via API
      await _apiService.updateRejectedDocuments(updateData);

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString('registration_data');
      Map<String, dynamic> registrationData = {};
      
      if (existingData != null) {
        registrationData = json.decode(existingData);
      }
      
      registrationData.addAll(updateData);
      await prefs.setString('registration_data', json.encode(registrationData));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data sertifikat berhasil diperbaiki'),
          backgroundColor: Colors.green,
        ),
      );

      // Return to rejection details screen with success indicator
      Navigator.pop(context, true);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbaiki data sertifikat: $e'),
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
          'Perbaiki Sertifikat',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info message
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFF2196F3).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Color(0xFF1976D2), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Perbaiki Data Sertifikat',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Silakan perbaiki data sertifikat Anda sesuai dengan dokumen asli. Pastikan foto sertifikat jelas dan dapat dibaca.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1976D2),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 30),
              
              // Certificate Title
              Text(
                'Sertifikat',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF495057),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Upload Certificate section
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Upload Your Certificate',
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
                      child: _certificateImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_certificateImage!, fit: BoxFit.cover),
                            )
                          : Icon(Icons.image_outlined, size: 30, color: Colors.grey.shade400),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 30),
              
              // Nomor Sertifikat Field
              Text(
                'Nomor Sertifikat',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF495057),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _nomorSertifikatController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Masukkan nomor sertifikat',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
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
                      hintText: 'Pilih tanggal kedaluarsa',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
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
              
              SizedBox(height: 40),
              
              // Update button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateCertificateData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid() ? Color(0xFFDC3545) : Colors.grey.shade300,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Perbaiki Data Sertifikat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Camera button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _openCamera,
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  label: Text(
                    'Ambil Foto Sertifikat',
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