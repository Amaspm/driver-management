import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class VehicleScreen extends StatefulWidget {
  @override
  _VehicleScreenState createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _vehicleData;
  bool get hasVehicle => _vehicleData != null;

  @override
  void initState() {
    super.initState();
    _loadVehicleData();
  }

  Future<void> _loadVehicleData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final apiService = ApiService(authService);
      
      // Get driver's vehicle assignment
      final response = await apiService.get('/driver-armada/');
      
      if (response is List && response.isNotEmpty) {
        // Driver has vehicle assigned, get vehicle details
        final vehicleId = response[0]['id_armada'];
        final vehicleResponse = await apiService.get('/armada/$vehicleId/');
        setState(() {
          _vehicleData = vehicleResponse;
          _isLoading = false;
        });
      } else {
        setState(() {
          _vehicleData = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading vehicle data: $e');
      setState(() {
        _vehicleData = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Kendaraan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.light
                    ? [Color(0xFF161A30), Color(0xFF4A4E69)]
                    : [Color(0xFF161A30), Color(0xFF31304D), Color(0xFFB6BBC4)],
                stops: Theme.of(context).brightness == Brightness.dark
                    ? [0.0, 0.6, 1.0]
                    : null,
                begin: Alignment(-0.7, -0.7),
                end: Alignment(0.7, 0.7),
              ),
            ),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kendaraan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.light
                  ? [Color(0xFF161A30), Color(0xFF4A4E69)]
                  : [Color(0xFF161A30), Color(0xFF31304D), Color(0xFFB6BBC4)],
              stops: Theme.of(context).brightness == Brightness.dark
                  ? [0.0, 0.6, 1.0]
                  : null,
              begin: Alignment(-0.7, -0.7),
              end: Alignment(0.7, 0.7),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasVehicle) ...[
              // Vehicle Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
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
                    Container(
                      height: 120,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.directions_car,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      _vehicleData?['jenis_armada'] ?? 'Kendaraan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      _vehicleData?['nomor_polisi'] ?? 'Tidak ada',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // No Vehicle Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
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
                    Container(
                      height: 120,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.no_transfer,
                        size: 60,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tidak Ada Kendaraan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Belum terdaftar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            SizedBox(height: 20),
            
            if (hasVehicle) ...[
              Text(
                'Informasi Kendaraan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              
              SizedBox(height: 15),
              
              // Vehicle Info Cards
              _buildInfoCard('Tahun', _vehicleData?['tahun_pembuatan']?.toString().substring(0, 4) ?? 'N/A'),
              _buildInfoCard('Warna', _vehicleData?['warna_armada'] ?? 'N/A'),
              _buildInfoCard('Jenis', _vehicleData?['jenis_armada'] ?? 'N/A'),
              _buildInfoCard('Kapasitas', '${_vehicleData?['kapasitas_muatan'] ?? 0} kg'),
            ] else ...[
              Text(
                'Informasi Driver',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              
              SizedBox(height: 15),
              
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[600]),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Anda belum memiliki kendaraan terdaftar. Hubungi admin untuk mendapatkan kendaraan atau daftarkan kendaraan pribadi.',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            SizedBox(height: 20),
            
            if (hasVehicle) ...[
              Text(
                'Status Kendaraan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              
              SizedBox(height: 15),
              
              // Status Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatusCard(
                      title: 'Kondisi',
                      value: 'Baik',
                      icon: Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: _buildStatusCard(
                      title: 'Status',
                      value: 'Aktif',
                      icon: Icons.verified,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 15),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatusCard(
                      title: 'Service',
                      value: '2 bulan',
                      icon: Icons.build,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: _buildStatusCard(
                      title: 'STNK',
                      value: 'Valid',
                      icon: Icons.assignment,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
            
            SizedBox(height: 25),
            
            // Action Buttons
            if (hasVehicle) ...[
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fitur dalam pengembangan')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Laporkan Masalah',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Color(0xFF161A30) 
                        : Colors.white,
                  ),
                ),
              ),
              
              SizedBox(height: 12),
              
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fitur dalam pengembangan')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Riwayat Service',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/vehicle_matching');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Daftarkan Kendaraan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              
              SizedBox(height: 12),
              
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hubungi admin untuk mendapatkan kendaraan')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Hubungi Admin',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoCard(String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
          Icon(
            icon,
            color: color,
            size: 30,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}