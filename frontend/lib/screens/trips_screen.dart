import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class TripsScreen extends StatefulWidget {
  @override
  _TripsScreenState createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  bool _isLoading = true;
  List<dynamic> _trips = [];
  List<dynamic> _filteredTrips = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'all';
  
  @override
  void initState() {
    super.initState();
    _loadTrips();
    _searchController.addListener(_filterTrips);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTrips() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final apiService = ApiService(authService);
      
      // Get completed delivery orders for this driver
      final trips = await apiService.getDriverTrips();
      
      setState(() {
        _trips = trips is List ? trips : [];
        _filteredTrips = List.from(_trips);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading trips: $e');
      setState(() => _isLoading = false);
    }
  }
  
  void _filterTrips() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredTrips = _trips.where((trip) {
        final pickup = (trip['alamat_pengiriman'] ?? '').toLowerCase();
        final dropoff = (trip['pelanggan'] ?? '').toLowerCase();
        final matchesSearch = pickup.contains(query) || dropoff.contains(query);
        
        final status = trip['status'] ?? 'completed';
        final tripStatus = status == 'completed' ? 'Selesai' : 'Dibatalkan';
        final matchesStatus = _selectedStatus == 'all' || tripStatus == _selectedStatus;
        
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }
  
  void _onStatusChanged(String? status) {
    setState(() {
      _selectedStatus = status ?? 'all';
    });
    _filterTrips();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Trip',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
          : _filteredTrips.isEmpty && _trips.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 80,
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada riwayat trip',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTrips,
                  color: Theme.of(context).colorScheme.primary,
                  child: Column(
                    children: [
                      // Search and Filter Section
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Search Box
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Cari lokasi pickup/dropoff...',
                                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.secondary),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                                ),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.background.withOpacity(0.3),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                            SizedBox(height: 12),
                            // Status Filter
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Status: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Expanded(
                                    child: DropdownButton<String>(
                                      value: _selectedStatus,
                                      isExpanded: true,
                                      underline: Container(),
                                      dropdownColor: Theme.of(context).colorScheme.surface,
                                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                                      items: [
                                        DropdownMenuItem(
                                          value: 'all', 
                                          child: Text('Semua Status', style: TextStyle(fontWeight: FontWeight.w500))
                                        ),
                                        DropdownMenuItem(
                                          value: 'Selesai', 
                                          child: Text('Selesai', style: TextStyle(fontWeight: FontWeight.w500))
                                        ),
                                        DropdownMenuItem(
                                          value: 'Dibatalkan', 
                                          child: Text('Dibatalkan', style: TextStyle(fontWeight: FontWeight.w500))
                                        ),
                                      ],
                                      onChanged: _onStatusChanged,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Results Count
                      if (_filteredTrips.isNotEmpty || _searchController.text.isNotEmpty || _selectedStatus != 'all')
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: Theme.of(context).colorScheme.background.withOpacity(0.5),
                          child: Text(
                            '${_filteredTrips.length} trip ditemukan',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      // Trip List
                      Expanded(
                        child: _filteredTrips.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Tidak ada trip yang sesuai',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Coba ubah kata kunci atau filter',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.all(16),
                                itemCount: _filteredTrips.length,
                                itemBuilder: (context, index) {
                                  final trip = _filteredTrips[index];
                                  return _buildTripCard(trip);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildTripCard(Map<String, dynamic> trip) {
    final tripId = trip['id_delivery_order']?.toString() ?? 'N/A';
    final tanggalKirim = trip['tanggal_kirim'] ?? '';
    final status = trip['status'] ?? 'completed';
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.background.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Color(0xFFF0ECE5)
                            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        status == 'completed' ? Icons.check_circle : Icons.cancel,
                        color: status == 'completed' ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Trip #$tripId',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: status == 'completed' 
                        ? Theme.of(context).colorScheme.secondary.withOpacity(0.1) 
                        : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status == 'completed' ? 'Selesai' : 'Dibatalkan',
                    style: TextStyle(
                      fontSize: 12,
                      color: status == 'completed' ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.secondary),
                SizedBox(width: 8),
                Text(
                  _formatDate(tanggalKirim),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.secondary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trip['alamat_pengiriman'] ?? 'Alamat tidak tersedia',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.secondary),
                SizedBox(width: 8),
                Text(
                  trip['pelanggan'] ?? 'Pelanggan tidak diketahui',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            if (trip['armada'] != null)
              Column(
                children: [
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.local_shipping, size: 16, color: Theme.of(context).colorScheme.secondary),
                      SizedBox(width: 8),
                      Text(
                        '${trip['armada']['nomor_polisi']} - ${trip['armada']['jenis_armada']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
  
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}