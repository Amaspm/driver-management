import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/theme_service.dart';
import '../services/driver_shift_service.dart';
import '../widgets/order_notification_dialog.dart';
import '../widgets/notification_popup.dart';
import 'login_screen.dart';

class NewDashboardScreen extends StatefulWidget {
  @override
  _NewDashboardScreenState createState() => _NewDashboardScreenState();
}

class _NewDashboardScreenState extends State<NewDashboardScreen> {
  bool _isLoading = true;
  bool _sideMenuOpen = false;
  Map<String, dynamic> _driverStats = {};
  List<dynamic> _recentTrips = [];
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shiftService = Provider.of<DriverShiftService>(context, listen: false);
      shiftService.onOrderReceived = _handleOrderReceived;
      shiftService.loadShiftStatus();
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
  
  @override
  void dispose() {
    super.dispose();
  }
  
  void _handleOrderReceived(Map<String, dynamic> orderData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OrderNotificationDialog(
        orderData: orderData,
      ),
    );
  }
  
  void _showNotificationPopup(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 320,
        kToolbarHeight + MediaQuery.of(context).padding.top + 8,
        MediaQuery.of(context).size.width - 16,
        kToolbarHeight + MediaQuery.of(context).padding.top + 8,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          child: NotificationPopup(),
        ),
      ],
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
  
  Future<void> _toggleShift() async {
    try {
      final shiftService = Provider.of<DriverShiftService>(context, listen: false);
      final driverId = _driverStats['id_driver']?.toString() ?? 'driver_001';
      final kota = _driverStats['kota'];
      
      print('Driver stats kota: ${_driverStats['kota']}');
      print('Using kota: $kota');
      
      if (kota == null || kota.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kota tidak ditemukan di profil. Silakan update profil Anda.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      print('Toggle shift - Current status: ${shiftService.isOnShift}');
      print('Driver ID: $driverId, Kota: $kota');
      
      bool success;
      if (shiftService.isOnShift) {
        print('Ending shift...');
        success = await shiftService.endShift();
      } else {
        print('Starting shift...');
        success = await shiftService.startShift(driverId, kota);
      }
      
      print('Shift toggle result: $success');
      print('New status: ${shiftService.isOnShift}');
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(shiftService.isOnShift ? 'Anda sekarang ONLINE' : 'Anda sekarang OFFLINE'),
            backgroundColor: shiftService.isOnShift ? Colors.green : Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah status. Periksa koneksi internet.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error in _toggleShift: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _loadDashboardData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final apiService = ApiService(authService);
      
      final stats = await apiService.getDriverStatistics();
      final trips = await apiService.getDriverTrips();
      
      setState(() {
        _driverStats = stats;
        _recentTrips = trips.take(3).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final driverName = _driverStats['nama'] ?? 'Driver';
    final avgRating = _driverStats['average_rating'] ?? 0.0;
    final totalTrips = _driverStats['total_trips'] ?? 0;
    final fotoProfil = _driverStats['foto_profil'];

    return Scaffold(
      body: Stack(
        children: [
          // Main Content with Collapsible Header
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160,
                floating: false,
                pinned: true,
                centerTitle: false,
                leading: IconButton(
                  onPressed: () => setState(() => _sideMenuOpen = true),
                  icon: Icon(Icons.menu, color: Colors.white),
                ),
                actions: [
                  Consumer<DriverShiftService>(
                    builder: (context, shiftService, child) => Stack(
                      children: [
                        IconButton(
                          onPressed: () => _showNotificationPopup(context),
                          icon: Icon(Icons.notifications, color: Colors.white),
                        ),
                        if (shiftService.unreadCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${shiftService.unreadCount}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Consumer<DriverShiftService>(
                    builder: (context, shiftService, child) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: shiftService.isOnShift ? Color(0xFF10B981) : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                shiftService.isOnShift ? 'ONLINE' : 'OFFLINE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                      ],
                    ),
                  ),
                ],
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCollapsed = constraints.biggest.height <= kToolbarHeight + MediaQuery.of(context).padding.top;
                    return FlexibleSpaceBar(
                      title: isCollapsed ? Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: fotoProfil != null && fotoProfil.isNotEmpty
                                ? MemoryImage(base64Decode(fotoProfil.split(',').last))
                                : null,
                            child: fotoProfil == null || fotoProfil.isEmpty
                                ? Icon(Icons.local_shipping, color: Colors.white, size: 12)
                                : null,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$driverName • B 1234 XYZ • ⭐ $avgRating',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Consumer<DriverShiftService>(
                            builder: (context, shiftService, child) => Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: shiftService.isOnShift ? Color(0xFF10B981) : Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                shiftService.isOnShift ? 'ON' : 'OFF',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ) : null,
                      titlePadding: EdgeInsets.only(left: 72, bottom: 16),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: Theme.of(context).brightness == Brightness.dark
                                ? [Color(0xFF161A30), Color(0xFF31304D), Color(0xFFB6BBC4)]
                                : [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                            stops: Theme.of(context).brightness == Brightness.dark
                                ? [0.0, 0.6, 1.0]
                                : null,
                            begin: Alignment(-0.7, -0.7),
                            end: Alignment(0.7, 0.7),
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 60, 16, 16),
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/profile_edit'),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundImage: fotoProfil != null && fotoProfil.isNotEmpty
                                          ? MemoryImage(base64Decode(fotoProfil.split(',').last))
                                          : null,
                                      child: fotoProfil == null || fotoProfil.isEmpty
                                          ? Icon(Icons.local_shipping, color: Colors.white)
                                          : null,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          driverName,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'B 1234 XYZ',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(' • ', style: TextStyle(color: Colors.white70)),
                                            Icon(Icons.star, color: Colors.amber, size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              avgRating.toString(),
                                              style: TextStyle(color: Colors.white70, fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Today Stats
                      Text(
                        'Statistik Hari Ini',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard('Trip Hari Ini', '5', Icons.route, Color(0xFFF0ECE5))),
                          SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Pendapatan', 'Rp 450K', Icons.attach_money, Color(0xFFF0ECE5))),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard('Jarak Tempuh', '287 km', Icons.navigation, Color(0xFFF0ECE5))),
                          SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Waktu Online', '8h 32m', Icons.access_time, Color(0xFFF0ECE5))),
                        ],
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Quick Actions
                      Text(
                        'Aksi Cepat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Consumer<DriverShiftService>(
                            builder: (context, shiftService, child) => GestureDetector(
                              onTap: _toggleShift,
                              child: _buildQuickAction(
                                shiftService.isOnShift ? Icons.stop : Icons.play_arrow,
                                shiftService.isOnShift ? 'Akhiri' : 'Mulai',
                                shiftService.isOnShift ? Colors.red[600]! : Colors.green[600]!,
                              ),
                            ),
                          ),
                          _buildQuickAction(Icons.local_shipping, 'Inspeksi', 
                              Theme.of(context).brightness == Brightness.dark ? Color(0xFFB6BBC4) : Color(0xFF161A30),
                              iconColor: Theme.of(context).brightness == Brightness.dark ? Color(0xFF161A30) : Colors.white),
                          _buildQuickAction(Icons.settings, 'Pengaturan', 
                              Theme.of(context).brightness == Brightness.dark ? Color(0xFFF0ECE5) : Color(0xFF31304D),
                              iconColor: Theme.of(context).brightness == Brightness.dark ? Color(0xFF161A30) : Colors.white),
                          _buildQuickAction(Icons.notifications, 'Notifikasi', 
                              Theme.of(context).brightness == Brightness.dark ? Color(0xFFB6BBC4) : Color(0xFF161A30),
                              iconColor: Theme.of(context).brightness == Brightness.dark ? Color(0xFF161A30) : Colors.white),
                        ],
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Recent Trips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Trip Terbaru',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/trips'),
                            child: Text('Lihat Semua'),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      ..._recentTrips.map((trip) => _buildTripCard(trip)).toList(),
                      
                      SizedBox(height: 24),
                      
                      // Vehicle Status
                      Text(
                        'Status Kendaraan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFF10B981)),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kondisi Kendaraan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                Text(
                                  'Baik - Siap Beroperasi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Side Menu
          if (_sideMenuOpen)
            GestureDetector(
              onTap: () => setState(() => _sideMenuOpen = false),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Row(
                  children: [
                    Container(
                      width: 280,
                      height: double.infinity,
                      color: Theme.of(context).colorScheme.surface,
                      child: _buildSideMenu(),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFF161A30), size: 20),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
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

  Widget _buildQuickAction(IconData icon, String label, Color color, {Color? iconColor}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary, size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTime(trip['tanggal_kirim']),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Rp 85,000',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  trip['alamat_pengiriman'] ?? 'Alamat tidak tersedia',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '→ ${trip['pelanggan'] ?? 'Pelanggan'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideMenu() {
    final authService = Provider.of<AuthService>(context);
    final themeService = Provider.of<ThemeService>(context);
    
    return Column(
      children: [
        // Menu Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.light
                  ? [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary]
                  : [Color(0xFF161A30), Color(0xFF31304D), Color(0xFFB6BBC4)],
              stops: Theme.of(context).brightness == Brightness.dark
                  ? [0.0, 0.6, 1.0]
                  : null,
              begin: Alignment(-0.7, -0.7),
              end: Alignment(0.7, 0.7),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() => _sideMenuOpen = false);
                    Navigator.pushNamed(context, '/profile_edit');
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: _driverStats['foto_profil'] != null && _driverStats['foto_profil'].isNotEmpty
                          ? MemoryImage(base64Decode(_driverStats['foto_profil'].split(',').last))
                          : null,
                      child: _driverStats['foto_profil'] == null || _driverStats['foto_profil'].isEmpty
                          ? Icon(Icons.person, color: Colors.white, size: 16)
                          : null,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _sideMenuOpen = false);
                      Navigator.pushNamed(context, '/profile_edit');
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _driverStats['nama'] ?? 'Driver',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'B 1234 XYZ',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _sideMenuOpen = false),
                  icon: Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        
        // Menu Items
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildMenuSection('Akun', [
                _buildMenuItem(Icons.person, 'Profil Saya', () => Navigator.pushNamed(context, '/profile_edit')),
                _buildMenuItem(Icons.settings, 'Pengaturan', () {}),
                _buildMenuItem(Icons.verified_user, 'Verifikasi Dokumen', () {}),
              ]),
              
              _buildMenuSection('Aktivitas', [
                _buildMenuItem(Icons.history, 'Riwayat Perjalanan', () => Navigator.pushNamed(context, '/trips')),
                _buildMenuItem(Icons.attach_money, 'Laporan Pendapatan', () {}),
                _buildMenuItem(Icons.star, 'Rating & Ulasan', () {}),
              ]),
              
              _buildMenuSection('Kendaraan', [
                _buildMenuItem(Icons.local_shipping, 'Detail Kendaraan', () {}),
                _buildMenuItem(Icons.description, 'Dokumen Kendaraan', () {}),
              ]),
              
              _buildMenuSection('Tampilan', [
                ListTile(
                  leading: Icon(
                    themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  title: Text(
                    'Mode Gelap',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Switch(
                    value: themeService.isDarkMode,
                    onChanged: (value) {
                      themeService.toggleTheme();
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
                ),
              ]),
              
              _buildMenuSection('Bantuan', [
                _buildMenuItem(Icons.help_center, 'Pusat Bantuan', () {}),
                _buildMenuItem(Icons.book, 'Panduan Driver', () {}),
                _buildMenuItem(Icons.phone, 'Hubungi Support', () {}),
              ]),
              
              _buildMenuSection('Lainnya', [
                _buildMenuItem(Icons.credit_card, 'Metode Pembayaran', () {}),
                _buildMenuItem(Icons.notifications, 'Notifikasi', () {}),
                _buildMenuItem(Icons.logout, 'Keluar', () async {
                  await authService.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                }, isRed: true),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8),
        ...items,
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap, {bool isRed = false}) {
    return ListTile(
      leading: Icon(
        icon, 
        color: isRed ? Colors.red : Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isRed ? Colors.red : Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        setState(() => _sideMenuOpen = false);
        onTap();
      },
      contentPadding: EdgeInsets.symmetric(horizontal: 0),
    );
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return '00:00';
    try {
      final date = DateTime.parse(dateString);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00';
    }
  }
}