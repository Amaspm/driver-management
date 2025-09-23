import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _driverStats = {};
  
  @override
  void initState() {
    super.initState();
    _loadDriverStatistics();
  }
  
  Future<void> _loadDriverStatistics() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final apiService = ApiService(authService);
      
      final stats = await apiService.getDriverStatistics();
      
      setState(() {
        _driverStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading driver statistics: $e');
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(
            'Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFFDC3545),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final driverName = _driverStats['nama'] ?? 'Driver';
    final driverId = _driverStats['driver_id']?.toString() ?? 'DR001';
    final avgRating = _driverStats['average_rating'] ?? 0.0;
    final totalTrips = _driverStats['total_trips'] ?? 0;
    final experienceYears = _driverStats['experience_years'] ?? 0.0;
    final fotoProfil = _driverStats['foto_profil'];
    
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFFDC3545),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/profile_edit');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFFDC3545).withOpacity(0.1),
                    backgroundImage: fotoProfil != null && fotoProfil.isNotEmpty
                        ? MemoryImage(base64Decode(fotoProfil.split(',').last))
                        : null,
                    child: fotoProfil == null || fotoProfil.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFFDC3545),
                          )
                        : null,
                  ),
                  SizedBox(height: 16),
                  Text(
                    driverName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF495057),
                    ),
                  ),
                  Text(
                    'Driver ID: $driverId',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Color(0xFFFFC107), size: 20),
                      SizedBox(width: 4),
                      Text(
                        avgRating.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF495057),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '($totalTrips trip)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Statistics
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Trip',
                    value: totalTrips.toString(),
                    color: Color(0xFF007BFF),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    title: 'Pengalaman',
                    value: '${experienceYears.toString()} Tahun',
                    color: Color(0xFF28A745),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Menu Items
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {
                Navigator.pushNamed(context, '/profile_edit');
              },
            ),
            _buildMenuItem(
              icon: Icons.history,
              title: 'Riwayat Trip',
              onTap: () {
                Navigator.pushNamed(context, '/trips');
              },
            ),
            _buildMenuItem(
              icon: Icons.star,
              title: 'Rating & Ulasan',
              onTap: () {
                _showRatingsDialog();
              },
            ),
            _buildMenuItem(
              icon: Icons.security,
              title: 'Keamanan',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fitur dalam pengembangan')),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Bantuan',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fitur dalam pengembangan')),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Driver Management App v1.0')),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Keluar',
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Konfirmasi'),
                      content: Text('Apakah Anda yakin ingin keluar?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            final authService = Provider.of<AuthService>(context, listen: false);
                            await authService.logout();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                              (route) => false,
                            );
                          },
                          child: Text('Keluar', style: TextStyle(color: Color(0xFFDC3545))),
                        ),
                      ],
                    );
                  },
                );
              },
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6C757D),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  void _showRatingsDialog() {
    final recentRatings = _driverStats['recent_ratings'] ?? [];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rating & Ulasan Terbaru'),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: recentRatings.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada rating',
                      style: TextStyle(color: Color(0xFF6C757D)),
                    ),
                  )
                : ListView.builder(
                    itemCount: recentRatings.length,
                    itemBuilder: (context, index) {
                      final rating = recentRatings[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Row(
                                    children: List.generate(5, (i) => Icon(
                                      Icons.star,
                                      size: 16,
                                      color: i < rating['rating']
                                          ? Color(0xFFFFC107)
                                          : Color(0xFFE9ECEF),
                                    )),
                                  ),
                                  Spacer(),
                                  Text(
                                    rating['pelanggan'] ?? 'Pelanggan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6C757D),
                                    ),
                                  ),
                                ],
                              ),
                              if (rating['ulasan'] != null && rating['ulasan'].isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    rating['ulasan'],
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFFDC3545)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF495057),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Color(0xFF6C757D)),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}