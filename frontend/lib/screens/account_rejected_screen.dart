import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AccountRejectedScreen extends StatefulWidget {
  @override
  _AccountRejectedScreenState createState() => _AccountRejectedScreenState();
}

class _AccountRejectedScreenState extends State<AccountRejectedScreen> {
  final ApiService _apiService = ApiService(AuthService());
  String? _rejectionReason;
  List<String> _rejectedDocuments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRejectionReason();
  }

  void _startReregistration() {
    Navigator.pushReplacementNamed(context, '/ktp_upload');
  }

  void _navigateToDocumentFix(String documentType) {
    switch (documentType) {
      case 'ktp':
        Navigator.pushReplacementNamed(context, '/edit_ktp_upload');
        break;
      case 'sim':
        Navigator.pushReplacementNamed(context, '/edit_sim_upload');
        break;
      case 'bpjs':
        Navigator.pushReplacementNamed(context, '/bpjs_upload');
        break;
      case 'sertifikat':
        Navigator.pushReplacementNamed(context, '/edit_certificate_upload');
        break;
      case 'profil':
        Navigator.pushReplacementNamed(context, '/photo_upload');
        break;
      default:
        _startReregistration();
    }
  }

  Future<void> _loadRejectionReason() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final registrationDataString = prefs.getString('registration_data');
      
      if (registrationDataString != null) {
        final registrationData = json.decode(registrationDataString);
        final email = registrationData['email'];
        final password = registrationData['password'];
        
        final loginSuccess = await _apiService.loginDriver(email, password);
        if (loginSuccess) {
          final statusData = await _apiService.checkDriverStatus();
          setState(() {
            _rejectionReason = statusData['alasan_penolakan']?.toString();
            final rejectedDocs = statusData['rejected_documents'];
            if (rejectedDocs is List) {
              _rejectedDocuments = List<String>.from(rejectedDocs);
            } else {
              _rejectedDocuments = [];
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading rejection reason: $e');
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
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
        title: Text(
          'Status Akun',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFFDC3545), width: 3),
                ),
                child: Icon(
                  Icons.close,
                  color: Color(0xFFDC3545),
                  size: 60,
                ),
              ),
              
              SizedBox(height: 30),
              
              // Title
              Text(
                'Akun Ditolak',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC3545),
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 20),
              
              // Description
              Text(
                'Maaf, pendaftaran Anda tidak dapat diproses saat ini.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF495057),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 30),
              
              // Rejection reason
              if (_isLoading)
                CircularProgressIndicator(color: Color(0xFFDC3545))
              else if (_rejectionReason != null && _rejectionReason!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8D7DA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFDC3545).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alasan Penolakan:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF721C24),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _rejectionReason!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF721C24),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Show specific document fix options if documents are rejected
              if (_rejectedDocuments.isNotEmpty)
                Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Perbaiki Dokumen:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF495057),
                      ),
                    ),
                    SizedBox(height: 12),
                    ...(_rejectedDocuments.map((doc) => _buildDocumentFixButton(doc)).toList()),
                  ],
                ),
              
              SizedBox(height: 40),
              
              // Buttons
              if (_rejectedDocuments.isEmpty)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Kembali ke Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _startReregistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFDC3545),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Daftar Ulang',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Kembali ke Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              
              SizedBox(height: 20),
              
              // Help text
              Text(
                'Untuk informasi lebih lanjut, silakan hubungi Help Center',
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

  Widget _buildDocumentFixButton(String documentType) {
    String documentName;
    IconData icon;
    
    switch (documentType) {
      case 'ktp':
        documentName = 'KTP';
        icon = Icons.credit_card;
        break;
      case 'sim':
        documentName = 'SIM';
        icon = Icons.drive_eta;
        break;
      case 'bpjs':
        documentName = 'BPJS';
        icon = Icons.local_hospital;
        break;
      case 'sertifikat':
        documentName = 'Sertifikat';
        icon = Icons.school;
        break;
      case 'profil':
        documentName = 'Foto Profil';
        icon = Icons.person;
        break;
      default:
        documentName = documentType.toUpperCase();
        icon = Icons.description;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: () => _navigateToDocumentFix(documentType),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          'Perbaiki $documentName',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFDC3545),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}