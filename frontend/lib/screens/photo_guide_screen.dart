import 'package:flutter/material.dart';
import 'dart:io';
import 'photo_camera_screen.dart';

class PhotoGuideScreen extends StatelessWidget {
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
              SizedBox(height: 20),
              
              // Title
              Text(
                'Foto Diri',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF495057),
                ),
              ),
              
              SizedBox(height: 10),
              
              Text(
                'Fotomu akan diambil otomatis.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF495057),
                ),
              ),
              
              SizedBox(height: 8),
              
              Text(
                'Pastikan wajah Anda terlihat jelas, dengan pencahayaan yang cukup, dan tanpa aksesoris yang menutupi wajah.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6C757D),
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 30),
              
              // Sample Document label
              Text(
                'Sample Document',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF495057),
                ),
              ),
              
              SizedBox(height: 15),
              
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
                'Ketentuan Foto Diri :',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF495057),
                ),
              ),
              
              SizedBox(height: 15),
              
              _buildRule('1. Foto diambil secara langsung dari HP dan tidak kabur (blur).'),
              _buildRule('2. Lepaskan semua aksesoris (kacamata, kalung, topi, masker, helm).'),
              _buildRule('3. Gunakan pakaian yang rapi dan polos tanpa logo maupun lambang dari instansi atau komunitas tertentu.'),
              _buildRule('4. Gunakan latar belakang polos tanpa ada objek lain.'),
              _buildRule('5. Pastikan Anda mengambil foto dengan postur tegap dari kepala hingga dada dengan pencahayaan yang baik.'),
              
              SizedBox(height: 40),
              
              // Photo button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final File? capturedImage = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PhotoCameraScreen()),
                    );
                    
                    if (capturedImage != null) {
                      Navigator.pop(context, capturedImage);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDC3545),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  label: Text(
                    'Foto',
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
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade700,
          height: 1.4,
        ),
      ),
    );
  }
}