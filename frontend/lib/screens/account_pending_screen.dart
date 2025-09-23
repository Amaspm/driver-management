import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPendingScreen extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
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
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_empty,
                  size: 60,
                  color: Colors.orange.shade600,
                ),
              ),
              
              SizedBox(height: 30),
              
              Text(
                'Akun Menunggu Persetujuan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF495057),
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 20),
              
              Text(
                'Selamat! Anda telah menyelesaikan training dengan baik.\n\nAkun Anda sedang dalam proses verifikasi oleh admin. Kami akan mengirimkan notifikasi setelah akun Anda disetujui.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6C757D),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 40),
              
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade600),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Proses verifikasi biasanya memakan waktu 1-2 hari kerja.',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDC3545),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              Text(
                'Anda akan mendapat notifikasi email setelah akun disetujui',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}