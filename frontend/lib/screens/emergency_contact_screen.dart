import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'bank_account_screen.dart';

class EmergencyContactScreen extends StatefulWidget {
  @override
  _EmergencyContactScreenState createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final _namaController = TextEditingController();
  final _nomorController = TextEditingController();
  String _hubungan = 'Orang Tua';

  @override
  void initState() {
    super.initState();
    _namaController.addListener(() => setState(() {}));
    _nomorController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nomorController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _namaController.text.isNotEmpty && _nomorController.text.isNotEmpty;
  }

  void _handleNext() async {
    if (_isFormValid()) {
      // Save emergency contact data
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString('registration_data');
      Map<String, dynamic> registrationData = {};
      
      if (existingData != null) {
        registrationData = json.decode(existingData);
      }
      
      registrationData['nama_kontak_darurat'] = _namaController.text;
      registrationData['nomor_kontak_darurat'] = _nomorController.text;
      registrationData['hubungan_kontak_darurat'] = _hubungan;
      
      await prefs.setString('registration_data', json.encode(registrationData));
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BankAccountScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mohon lengkapi semua field')),
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
              
              // Title
              Text(
                'Kontak Darurat',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF495057),
                ),
              ),
              
              SizedBox(height: 8),
              
              Text(
                'Masukkan kontak darurat Anda untuk mendaftar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              
              SizedBox(height: 30),
              
              // Nama Kontak Darurat Field
              Text(
                'Nama Kontak Darurat',
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
              
              // Nomor Handphone Field
              Text(
                'Nomor Handphone Kontak Darurat',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF495057),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _nomorController,
                keyboardType: TextInputType.phone,
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
              
              // Hubungan Field
              Text(
                'Hubungan Dengan Kontak Darurat',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF495057),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _hubungan,
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
                  'Orang Tua',
                  'Saudara Kandung',
                  'Pasangan',
                  'Teman',
                  'Rekan Kerja'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _hubungan = newValue!;
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
            ],
          ),
        ),
      ),
    );
  }
}