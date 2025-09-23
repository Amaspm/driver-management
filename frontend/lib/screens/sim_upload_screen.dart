import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'sim_camera_screen.dart';
import 'certificate_upload_screen.dart';

class SimUploadScreen extends StatefulWidget {
  @override
  _SimUploadScreenState createState() => _SimUploadScreenState();
}

class _SimUploadScreenState extends State<SimUploadScreen> {
  final _nomorSimController = TextEditingController();
  final _namaController = TextEditingController();
  final _akhirBerlakuController = TextEditingController();
  String _jenisSim = 'A';
  File? _simImage;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nomorSimController.addListener(() => setState(() {}));
    _namaController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nomorSimController.dispose();
    _namaController.dispose();
    _akhirBerlakuController.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    final File? capturedImage = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SimCameraScreen()),
    );
    
    if (capturedImage != null) {
      setState(() {
        _simImage = capturedImage;
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
      
      registrationData['foto_sim'] = base64String;
      registrationData['no_sim'] = _nomorSimController.text;
      registrationData['jenis_sim'] = _jenisSim;
      await prefs.setString('registration_data', json.encode(registrationData));
    }
  }

  bool _isFormValid() {
    return _nomorSimController.text.isNotEmpty &&
           _namaController.text.isNotEmpty &&
           _akhirBerlakuController.text.isNotEmpty &&
           _simImage != null;
  }

  void _showSimGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Foto SIM',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF495057),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fotomu akan diambil otomatis.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF495057),
                      ),
                    ),
                    Text(
                      'Cukup letakkan SIM sesuai langkah di bawah ini, nanti kami akan ambil otomatis',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 30),
                    
                    // Grid of example images
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.2,
                      children: [
                        _buildExampleCard(true, 'Benar'),
                        _buildExampleCard(false, 'Salah'),
                        _buildExampleCard(true, 'Benar'),
                        _buildExampleCard(false, 'Salah'),
                      ],
                    ),
                    
                    SizedBox(height: 30),
                    
                    Text(
                      'Ketentuan foto SIM :',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF495057),
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildRule('1. Nomor SIM harus terbaca dengan jelas.'),
                    _buildRule('2. Nama di SIM harus sama dengan yang didaftarkan di aplikasi.'),
                    _buildRule('3. Masa berlaku SIM masih aktif.'),
                    
                    SizedBox(height: 20),
                    
                    Text(
                      'Perhatikan hal-hal berikut :',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF495057),
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildRule('1. Pegang HP dengan stabil dan pastikan lensa kamera bersih agar hasil foto tidak buram.'),
                    _buildRule('2. Gunakan pencahayaan yang cukup, jangan terlalu gelap atau terlalu terang.'),
                    _buildRule('3. Sesuaikan posisi SIM dengan kotak yang tersedia di layar.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(bool isCorrect, String label) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.image_outlined,
                size: 40,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red,
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isCorrect ? Colors.green : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRule(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade700,
        ),
      ),
    );
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
                width: 120,
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
              
              // SIM Title
              Text(
                'SIM',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF495057),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Upload SIM section
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Upload Your SIM',
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
                      child: _simImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_simImage!, fit: BoxFit.cover),
                            )
                          : Icon(Icons.image_outlined, size: 30, color: Colors.grey.shade400),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 30),
              
              // Nomor SIM Field
              Text(
                'Nomor SIM',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF495057),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _nomorSimController,
                keyboardType: TextInputType.text,
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
              
              // Name Field
              Text(
                'Name',
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
              
              // Jenis SIM Field
              Text(
                'Jenis SIM',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF495057),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _jenisSim,
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
                items: ['A', 'B1', 'B2', 'C'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _jenisSim = newValue!;
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
                      onPressed: _isFormValid() ? () async {
                        // Save SIM data to SharedPreferences
                        final prefs = await SharedPreferences.getInstance();
                        final existingData = prefs.getString('registration_data');
                        Map<String, dynamic> registrationData = {};
                        
                        if (existingData != null) {
                          registrationData = json.decode(existingData);
                        }
                        
                        registrationData['no_sim'] = _nomorSimController.text.trim();
                        registrationData['jenis_sim'] = _jenisSim;
                        registrationData['tanggal_kedaluarsa_sim'] = _selectedDate?.toIso8601String().split('T')[0] ?? '2025-12-31';
                        
                        // Add foto_sim if available
                        if (_simImage != null) {
                          final bytes = await _simImage!.readAsBytes();
                          final base64String = base64Encode(bytes);
                          registrationData['foto_sim'] = base64String;
                        }
                        
                        await prefs.setString('registration_data', json.encode(registrationData));
                        print('DEBUG: Saved SIM data - No: ${_nomorSimController.text}, Jenis: $_jenisSim');
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CertificateUploadScreen()),
                        );
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFormValid() ? Color(0xFFDC3545) : Colors.grey.shade300,
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
              
              // Camera button and Guide button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showSimGuide,
                      icon: Icon(Icons.help_outline, color: Color(0xFFDC3545)),
                      label: Text(
                        'Panduan Foto',
                        style: TextStyle(color: Color(0xFFDC3545), fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Color(0xFFDC3545)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openCamera,
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      label: Text(
                        'Ambil Foto SIM',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDC3545),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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