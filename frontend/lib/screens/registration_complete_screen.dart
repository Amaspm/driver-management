import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class RegistrationCompleteScreen extends StatefulWidget {
  @override
  _RegistrationCompleteScreenState createState() => _RegistrationCompleteScreenState();
}

class _RegistrationCompleteScreenState extends State<RegistrationCompleteScreen> {
  final ApiService _apiService = ApiService(AuthService());
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _submitRegistration();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService().logout();
              Navigator.of(context).pop();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRegistration() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get registration data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final registrationDataString = prefs.getString('registration_data');
      
      Map<String, dynamic> baseData = {};
      if (registrationDataString != null) {
        baseData = json.decode(registrationDataString);
      }
      
      // Complete registration data with required fields
      final Map<String, dynamic> registrationData = {
        'nama': baseData['nama'] ?? 'Sample Driver ${DateTime.now().millisecondsSinceEpoch}',
        'email': baseData['email'] ?? 'driver${DateTime.now().millisecondsSinceEpoch}@example.com',
        'password': baseData['password'] ?? 'driver123',
        'no_hp': baseData['no_hp'] ?? '081234567890',
        'alamat': baseData['alamat'] ?? 'Jakarta',
        'ttl': baseData['ttl'] ?? '1990-01-01',
        'nik': baseData['nik'] ?? '1234567890123456',
        'no_sim': baseData['no_sim'] ?? 'SIM123456789',
        'jenis_sim': baseData['jenis_sim'] ?? 'A',
        'no_bpjs': baseData['no_bpjs'] ?? 'BPJS123456789',
        'nama_kontak_darurat': baseData['nama_kontak_darurat'] ?? 'Jane Doe',
        'nomor_kontak_darurat': baseData['nomor_kontak_darurat'] ?? '081234567891',
        'hubungan_kontak_darurat': baseData['hubungan_kontak_darurat'] ?? 'Istri',
        'foto_ktp': baseData['foto_ktp'],
        'foto_sim': baseData['foto_sim'],
        'foto_profil': baseData['foto_profil'],
        'foto_sertifikat': baseData['foto_sertifikat'],
        'foto_bpjs': baseData['foto_bpjs'],
        'nama_bank': baseData['nama_bank'],
        'nomor_rekening': baseData['nomor_rekening'],
      };
      
      print('Sending registration data: $registrationData');

      final result = await _apiService.submitDriverRegistration(registrationData);
      print('Registration submitted successfully: $result');
    } catch (e) {
      print('Error submitting registration: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim data registrasi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
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
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
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
                'Registrasi Selesai!',
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
                'Anda telah menyelesaikan registrasi dan pelatihan dengan sukses! Tim kami sekarang akan meninjau data Anda sebelum akun diaktifkan',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF495057),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 40),
              
              // Check status button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () {
                    Navigator.pushNamed(context, '/account_pending');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDC3545),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Periksa Status Akun',
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