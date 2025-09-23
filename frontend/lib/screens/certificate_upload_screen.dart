import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'certificate_camera_screen.dart';
import 'bpjs_upload_screen.dart';

class CertificateUploadScreen extends StatefulWidget {
  @override
  _CertificateUploadScreenState createState() => _CertificateUploadScreenState();
}

class _CertificateUploadScreenState extends State<CertificateUploadScreen> {
  final _jenisSertifikatController = TextEditingController();
  final _dikeluarkanOlehController = TextEditingController();
  final _masaBerlakuController = TextEditingController();
  String _status = 'aktif';
  File? _certificateImage;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _jenisSertifikatController.addListener(() => setState(() {}));
    _dikeluarkanOlehController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _jenisSertifikatController.dispose();
    _dikeluarkanOlehController.dispose();
    _masaBerlakuController.dispose();
    super.dispose();
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
      
      // Save photo as base64 to SharedPreferences
      final bytes = await capturedImage.readAsBytes();
      final base64String = base64Encode(bytes);
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString('registration_data');
      Map<String, dynamic> registrationData = {};
      
      if (existingData != null) {
        registrationData = json.decode(existingData);
      }
      
      registrationData['foto_sertifikat'] = base64String;
      await prefs.setString('registration_data', json.encode(registrationData));
    }
  }

  bool _isFormValid() {
    return _jenisSertifikatController.text.isNotEmpty &&
           _dikeluarkanOlehController.text.isNotEmpty &&
           _masaBerlakuController.text.isNotEmpty &&
           _certificateImage != null;
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Peringatan'),
          content: Text('Anda belum mengupload gambar sertifikat. Silakan upload terlebih dahulu.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batalkan', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openCamera();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFDC3545)),
              child: Text('Upload', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _handleNext() async {
    if (!_isFormValid()) {
      if (_certificateImage == null) {
        _showWarningDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mohon lengkapi semua field')),
        );
      }
    } else {
      // Save certificate data to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString('registration_data');
      Map<String, dynamic> registrationData = {};
      
      if (existingData != null) {
        registrationData = json.decode(existingData);
      }
      
      registrationData['jenis_sertifikat'] = _jenisSertifikatController.text.trim();
      registrationData['dikeluarkan_oleh'] = _dikeluarkanOlehController.text.trim();
      registrationData['tanggal_kedaluarsa_sertifikat'] = _selectedDate?.toIso8601String().split('T')[0] ?? '2025-12-31';
      
      // Add foto_sertifikat if available
      if (_certificateImage != null) {
        final bytes = await _certificateImage!.readAsBytes();
        final base64String = base64Encode(bytes);
        registrationData['foto_sertifikat'] = base64String;
      }
      
      await prefs.setString('registration_data', json.encode(registrationData));
      print('DEBUG: Saved Certificate data - Jenis: ${_jenisSertifikatController.text}');
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BpjsUploadScreen()),
      );
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
                width: 160,
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
              
              // Certificate Title
              Text(
                'Sertifikat Pelatihan',
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
                      'Upload Sertifikatmu',
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
              
              // Jenis Sertifikat Field
              Text(
                'Jenis Sertifikat',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF495057),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _jenisSertifikatController,
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
              
              // Dikeluarkan Oleh Field
              Text(
                'Dikeluarkan Oleh',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF495057),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _dikeluarkanOlehController,
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
              
              // Masa Berlaku Field with Date Picker
              Text(
                'Masa Berlaku',
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
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2050),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                      _masaBerlakuController.text = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: _masaBerlakuController,
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
                  DropdownMenuItem(value: 'kedaluarsa', child: Text('Kedaluarsa')),
                  DropdownMenuItem(value: 'dalam_proses_perpanjangan', child: Text('Dalam Proses Perpanjangan')),
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
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDC3545),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Selanjutnya',
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