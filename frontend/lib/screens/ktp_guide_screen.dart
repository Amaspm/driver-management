import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class KtpGuideScreen extends StatelessWidget {
  Future<void> _pickImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      );
      
      if (pickedFile != null) {
        Navigator.pop(context, pickedFile.path);
      }
    } catch (e) {
      try {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
        );
        
        if (pickedFile != null) {
          Navigator.pop(context, pickedFile.path);
        }
      } catch (e2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat mengakses kamera/galeri')),
        );
      }
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
              Text(
                'Foto e-KTP',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF495057),
                ),
              ),
              
              SizedBox(height: 10),
              
              Text(
                'Fotomu akan diambil otomatis.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF495057),
                ),
              ),
              
              Text(
                'Cukup letakkan e-ktp sesuai langkah di bawah ini, nanti kami akan ambil otomatis',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              
              SizedBox(height: 30),
              
              // Guide images
              Container(
                child: Image.asset(
                  'assets/images/panduanKTP.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      children: [
                        // Correct examples
                        Row(
                          children: [
                            Expanded(
                              child: _buildGuideCard(true, 'Benar'),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: _buildGuideCard(true, 'Benar'),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        // Wrong examples
                        Row(
                          children: [
                            Expanded(
                              child: _buildGuideCard(false, 'Salah'),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: _buildGuideCard(false, 'Salah'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              
              SizedBox(height: 30),
              
              Text(
                'Ketentuan foto KTP :',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF495057),
                ),
              ),
              
              SizedBox(height: 15),
              
              _buildRule('1. Nomor KTP dapat terbaca jelas'),
              _buildRule('2. Nama harus sama dengan nama yang didaftarkan di aplikasi'),
              
              SizedBox(height: 20),
              
              Text(
                'Perhatikan hal-hal berikut :',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF495057),
                ),
              ),
              
              SizedBox(height: 15),
              
              _buildRule('1. Pegang HP yang stabil dan bersihkan lensa kamera supaya fotonya gak buram.'),
              _buildRule('2. Cari tempat yang punya pencahayaan cukup (gak terlalu gelap/terang).'),
              _buildRule('3. Pastiin e-KTP-nya gak terpotong atau ketutup.'),
              
              SizedBox(height: 40),
              
              // Camera button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(context),
                  icon: Icon(kIsWeb ? Icons.upload_file : Icons.camera_alt, color: Colors.white),
                  label: Text(
                    kIsWeb ? 'Pilih Gambar' : 'Ambil Gambar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDC3545),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
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

  Widget _buildGuideCard(bool isCorrect, String label) {
    return Column(
      children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade100,
          ),
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: 40,
              color: Colors.grey.shade400,
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
              size: 20,
            ),
            SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isCorrect ? Colors.green : Colors.red,
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
          color: Color(0xFF495057),
        ),
      ),
    );
  }
}