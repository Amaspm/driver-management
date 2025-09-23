import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'ktp_camera_screen.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class EditKtpUploadScreen extends StatefulWidget {
  final bool isRejectionFlow;
  final List<String> nextDocuments;

  EditKtpUploadScreen({
    this.isRejectionFlow = false,
    this.nextDocuments = const [],
  });

  @override
  _EditKtpUploadScreenState createState() => _EditKtpUploadScreenState();
}

class _EditKtpUploadScreenState extends State<EditKtpUploadScreen> {
  final ApiService _apiService = ApiService(AuthService());
  final _nikController = TextEditingController();
  final _namaController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  String _jenisKelamin = 'Laki-laki';
  File? _ktpImage;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    _tanggalLahirController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final registrationDataString = prefs.getString('registration_data');
      
      if (registrationDataString != null) {
        final registrationData = json.decode(registrationDataString);
        setState(() {
          _nikController.text = registrationData['nik'] ?? '';
          _namaController.text = registrationData['nama'] ?? '';
          if (registrationData['ttl'] != null) {
            _selectedDate = DateTime.parse(registrationData['ttl']);
            _tanggalLahirController.text = '${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}';
          }
          _jenisKelamin = registrationData['jenis_kelamin'] ?? 'Laki-laki';
        });
      }
    } catch (e) {
      print('Error loading existing data: $e');
    }
  }

  Future<void> _openCamera() async {
    final File? capturedImage = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => KtpCameraScreen()),
    );
    
    if (capturedImage != null) {
      setState(() {
        _ktpImage = capturedImage;
      });
    }
  }

  bool _isFormValid() {
    return _nikController.text.isNotEmpty &&
           _namaController.text.isNotEmpty &&
           _tanggalLahirController.text.isNotEmpty &&
           _ktpImage != null;
  }

  Future<void> _updateKtpData() async {
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mohon lengkapi semua data dan foto KTP'),
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
      final bytes = await _ktpImage!.readAsBytes();
      final base64String = base64Encode(bytes);

      // Prepare update data
      final updateData = {
        'foto_ktp': base64String,
        'nik': _nikController.text.trim(),
        'nama': _namaController.text.trim(),
        'ttl': _selectedDate?.toIso8601String().split('T')[0] ?? '1990-01-01',
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
          content: Text('Data KTP berhasil diperbaiki'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate based on flow
      if (widget.isRejectionFlow) {
        // Return to rejection details screen with success indicator
        Navigator.pop(context, true);
      } else {
        // Normal flow
        Navigator.pushReplacementNamed(context, '/account_pending');
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbaiki data KTP: $e'),
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
          'Perbaiki KTP',
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
                          'Perbaiki Data KTP',
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
                      'Silakan perbaiki data KTP Anda sesuai dengan dokumen asli. Pastikan foto KTP jelas dan dapat dibaca.',
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
              
              // KTP Title
              Text(
                'KTP',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF495057),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Upload KTP section
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Unggah KTP Kamu',
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
                      child: _ktpImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_ktpImage!, fit: BoxFit.cover),
                            )
                          : Icon(Icons.image_outlined, size: 30, color: Colors.grey.shade400),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 30),
              
              // NIK Field
              Text(
                'NIK',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF495057),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _nikController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '3582736487246665',
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
              
              // Nama Field
              Text(
                'Nama lengkap pada KTP',
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
                  hintText: 'Kevin De Burney',
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
              
              // Tanggal Lahir Field
              Text(
                'Tanggal Lahir',
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
                    initialDate: _selectedDate ?? DateTime(2000),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                      _tanggalLahirController.text = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: _tanggalLahirController,
                    decoration: InputDecoration(
                      hintText: '11-11-2006',
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
              
              SizedBox(height: 20),
              
              // Jenis Kelamin Field
              Text(
                'Jenis Kelamin',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF495057),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _jenisKelamin,
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
                items: ['Laki-laki', 'Perempuan'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _jenisKelamin = newValue!;
                  });
                },
              ),
              
              SizedBox(height: 40),
              
              // Update button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateKtpData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid() ? Color(0xFFDC3545) : Colors.grey.shade300,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Perbaiki Data KTP',
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
                    'Ambil Foto KTP',
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