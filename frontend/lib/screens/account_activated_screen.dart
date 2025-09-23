import 'package:flutter/material.dart';

class AccountActivatedScreen extends StatelessWidget {
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
          'Aktivasi Akun',
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
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFF28A745), width: 3),
                ),
                child: Icon(
                  Icons.check,
                  color: Color(0xFF28A745),
                  size: 60,
                ),
              ),
              
              SizedBox(height: 30),
              
              // Title
              Text(
                'Akun Anda Telah Aktif!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF28A745),
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 20),
              
              // Description
              Text(
                'Selamat! Akun Anda sudah aktif dan siap digunakan. Sekarang, kami akan mencocokkan Anda dengan kendaraan yang sesuai sebelum Anda mulai menerima tugas',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF495057),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 40),
              
              // Vehicle matching button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/vehicle_matching');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDC3545),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Lihat Status Pencocokan Kendaraan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
}