import 'package:flutter/material.dart';
import 'driver_service.dart';

class DriverHomePage extends StatefulWidget {
  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final DriverService _driverService = DriverService();
  bool _isOnline = false;
  bool _isLoading = false;
  
  final String _driverId = "driver_001"; // This should come from login
  final String _kota = "jakarta"; // This should come from driver profile
  
  @override
  void dispose() {
    _driverService.disconnect();
    super.dispose();
  }
  
  Future<void> _toggleOnlineStatus() async {
    setState(() {
      _isLoading = true;
    });
    
    bool success;
    if (_isOnline) {
      success = await _driverService.setDriverOffline(_driverId);
    } else {
      success = await _driverService.setDriverOnline(_driverId, _kota);
    }
    
    if (success) {
      setState(() {
        _isOnline = !_isOnline;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isOnline ? 'Anda sekarang ONLINE' : 'Anda sekarang OFFLINE'),
          backgroundColor: _isOnline ? Colors.green : Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Dashboard'),
        backgroundColor: _isOnline ? Colors.green : Colors.grey,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isOnline ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 100,
              color: _isOnline ? Colors.green : Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              _isOnline ? 'ONLINE' : 'OFFLINE',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isOnline ? Colors.green : Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Kota: $_kota',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _toggleOnlineStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isOnline ? Colors.red : Colors.green,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isOnline ? 'GO OFFLINE' : 'GO ONLINE',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
            SizedBox(height: 20),
            if (_isOnline)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Anda akan menerima notifikasi order baru',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}