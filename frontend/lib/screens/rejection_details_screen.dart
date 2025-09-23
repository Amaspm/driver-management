import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class RejectionDetailsScreen extends StatefulWidget {
  final String rejectionReason;
  final List<String> rejectedDocuments;

  RejectionDetailsScreen({
    required this.rejectionReason,
    required this.rejectedDocuments,
  });

  @override
  _RejectionDetailsScreenState createState() => _RejectionDetailsScreenState();
}

class _RejectionDetailsScreenState extends State<RejectionDetailsScreen> {
  List<String> _completedDocuments = [];
  bool _isDocumentRejection = false;

  @override
  void initState() {
    super.initState();
    _isDocumentRejection = widget.rejectionReason.contains('Dokumen tidak jelas/tidak sesuai');
    _loadCompletedDocuments();
  }

  Future<void> _loadCompletedDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList('completed_rejection_docs') ?? [];
    setState(() {
      _completedDocuments = completed;
    });
  }

  Future<void> _markDocumentCompleted(String docType) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_completedDocuments.contains(docType)) {
      _completedDocuments.add(docType);
      await prefs.setStringList('completed_rejection_docs', _completedDocuments);
      setState(() {});
    }
  }

  bool get _allDocumentsCompleted {
    return widget.rejectedDocuments.every((doc) => _completedDocuments.contains(doc));
  }

  void _navigateToDocumentFix(String docType) {
    switch (docType) {
      case 'ktp':
        Navigator.pushNamed(context, '/edit_ktp_upload', arguments: {'isRejectionFlow': true}).then((result) {
          if (result == true) _markDocumentCompleted(docType);
        });
        break;
      case 'sim':
        Navigator.pushNamed(context, '/edit_sim_upload', arguments: {'isRejectionFlow': true}).then((result) {
          if (result == true) _markDocumentCompleted(docType);
        });
        break;
      case 'bpjs':
        Navigator.pushNamed(context, '/bpjs_upload', arguments: {'isRejectionFlow': true}).then((result) {
          if (result == true) _markDocumentCompleted(docType);
        });
        break;
      case 'sertifikat':
        Navigator.pushNamed(context, '/edit_certificate_upload').then((result) {
          if (result == true) _markDocumentCompleted(docType);
        });
        break;
      case 'profil':
        Navigator.pushNamed(context, '/photo_upload', arguments: {'isRejectionFlow': true}).then((result) {
          if (result == true) _markDocumentCompleted(docType);
        });
        break;
    }
  }

  Future<void> _completeRejectionProcess() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('completed_rejection_docs');
      
      final authService = AuthService();
      final apiService = ApiService(authService);
      await apiService.completeRejectedDocuments();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Semua dokumen berhasil diperbaiki. Status berubah menjadi pending.'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
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
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
        title: Text(
          'Akun Ditolak',
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
            children: [
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
                      widget.rejectionReason,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF721C24),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 30),
              
              if (_isDocumentRejection && widget.rejectedDocuments.isNotEmpty) ...[
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
                            'Dokumen yang Perlu Diperbaiki',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Pilih dokumen yang ingin diperbaiki:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      SizedBox(height: 12),
                      ...widget.rejectedDocuments.map((doc) => _buildDocumentButton(doc)).toList(),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                if (_allDocumentsCompleted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _completeRejectionProcess,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Selesai - Kirim untuk Review',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ] else ...[
                Text(
                  'Silakan hubungi admin untuk informasi lebih lanjut atau daftar ulang.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF495057),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 30),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/ktp_upload'),
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
              
              SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentButton(String documentType) {
    String documentName;
    IconData icon;
    bool isCompleted = _completedDocuments.contains(documentType);
    
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
      child: ElevatedButton(
        onPressed: isCompleted ? null : () => _navigateToDocumentFix(documentType),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted ? Colors.green : Color(0xFFDC3545),
          padding: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : icon, 
              color: Colors.white, 
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                isCompleted ? '$documentName (Selesai)' : 'Perbaiki $documentName',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            if (isCompleted)
              Icon(Icons.check, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}