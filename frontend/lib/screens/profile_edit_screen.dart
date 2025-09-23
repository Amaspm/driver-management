import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../widgets/camera_screen.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic> _driverData = {};
  
  // Controllers for form fields
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _nikController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noSimController = TextEditingController();
  final _noBpjsController = TextEditingController();
  final _namaKontakDaruratController = TextEditingController();
  final _nomorKontakDaruratController = TextEditingController();
  final _hubunganKontakDaruratController = TextEditingController();
  final _namaBankController = TextEditingController();
  final _nomorRekeningController = TextEditingController();
  
  // Photo variables
  String? _fotoProfil;
  String? _fotoKtp;
  String? _fotoSim;
  String? _fotoBpjs;
  
  // Date variables
  DateTime? _ttl;
  DateTime? _tanggalKedaluarsaSim;
  DateTime? _tanggalKedaluarsaBpjs;
  
  // Dropdown values
  String? _jenisSimSelected;
  String? _hubunganKontakSelected;
  String? _kotaSelected;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDriverData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _nikController.dispose();
    _alamatController.dispose();
    _noSimController.dispose();
    _noBpjsController.dispose();
    _namaKontakDaruratController.dispose();
    _nomorKontakDaruratController.dispose();
    _hubunganKontakDaruratController.dispose();
    _namaBankController.dispose();
    _nomorRekeningController.dispose();
    super.dispose();
  }

  Future<void> _loadDriverData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final apiService = ApiService(authService);
      
      final profile = await apiService.getDriverProfile();
      
      setState(() {
        _driverData = profile;
        _namaController.text = profile['nama'] ?? '';
        _emailController.text = profile['email'] ?? '';
        _noHpController.text = profile['no_hp'] ?? '';
        _nikController.text = profile['nik'] ?? '';
        _alamatController.text = profile['alamat'] ?? '';
        _noSimController.text = profile['no_sim'] ?? '';
        _noBpjsController.text = profile['no_bpjs'] ?? '';
        _namaKontakDaruratController.text = profile['nama_kontak_darurat'] ?? '';
        _nomorKontakDaruratController.text = profile['nomor_kontak_darurat'] ?? '';
        _hubunganKontakDaruratController.text = profile['hubungan_kontak_darurat'] ?? '';
        _namaBankController.text = profile['nama_bank'] ?? '';
        _nomorRekeningController.text = profile['nomor_rekening'] ?? '';
        
        _fotoProfil = profile['foto_profil'];
        _fotoKtp = profile['foto_ktp'];
        _fotoSim = profile['foto_sim'];
        _fotoBpjs = profile['foto_bpjs'];
        
        if (profile['ttl'] != null) {
          _ttl = DateTime.parse(profile['ttl']);
        }
        if (profile['tanggal_kedaluarsa_sim'] != null) {
          _tanggalKedaluarsaSim = DateTime.parse(profile['tanggal_kedaluarsa_sim']);
        }
        if (profile['tanggal_kedaluarsa_bpjs'] != null) {
          _tanggalKedaluarsaBpjs = DateTime.parse(profile['tanggal_kedaluarsa_bpjs']);
        }
        
        // Handle dropdown values with fallback
        final jenisSimValue = profile['jenis_sim'];
        final hubunganValue = profile['hubungan_kontak_darurat'];
        
        // Validate jenis SIM
        final validJenisSim = ['A', 'B1', 'B2', 'C'];
        _jenisSimSelected = validJenisSim.contains(jenisSimValue) ? jenisSimValue : null;
        
        // Validate hubungan kontak
        final validHubungan = ['Keluarga', 'Teman', 'Saudara', 'Saudara Kandung', 'Orang Tua', 'Anak', 'Suami/Istri', 'Lainnya'];
        _hubunganKontakSelected = validHubungan.contains(hubunganValue) ? hubunganValue : null;
        
        // Validate kota
        final kotaValue = profile['kota'];
        final validKota = ['Jakarta', 'Bandung', 'Surabaya', 'Medan', 'Makassar', 'Palembang', 'Semarang', 'Yogyakarta', 'Denpasar', 'Balikpapan'];
        _kotaSelected = validKota.contains(kotaValue) ? kotaValue : null;
        
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading driver data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _takePhoto(String type) async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(
            camera: cameras.first,
            title: _getPhotoTitle(type),
          ),
        ),
      );

      if (result != null) {
        setState(() {
          switch (type) {
            case 'profil':
              _fotoProfil = result;
              break;
            case 'ktp':
              _fotoKtp = result;
              break;
            case 'sim':
              _fotoSim = result;
              break;
            case 'bpjs':
              _fotoBpjs = result;
              break;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e')),
      );
    }
  }

  String _getPhotoTitle(String type) {
    switch (type) {
      case 'profil': return 'Foto Profil';
      case 'ktp': return 'Foto KTP';
      case 'sim': return 'Foto SIM';
      case 'bpjs': return 'Foto BPJS';
      default: return 'Foto';
    }
  }

  Future<void> _selectDate(String type) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    
    if (date != null) {
      setState(() {
        switch (type) {
          case 'ttl':
            _ttl = date;
            break;
          case 'sim':
            _tanggalKedaluarsaSim = date;
            break;
          case 'bpjs':
            _tanggalKedaluarsaBpjs = date;
            break;
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      setState(() => _isLoading = true);
      
      final authService = Provider.of<AuthService>(context, listen: false);
      final apiService = ApiService(authService);
      
      final data = {
        'nama': _namaController.text,
        'no_hp': _noHpController.text,
        'kota': _kotaSelected,
        'alamat': _alamatController.text,
        'nik': _nikController.text,
        'no_sim': _noSimController.text,
        'jenis_sim': _jenisSimSelected,
        'tanggal_kedaluarsa_sim': _tanggalKedaluarsaSim?.toIso8601String()?.split('T')[0],
        'no_bpjs': _noBpjsController.text,
        'tanggal_kedaluarsa_bpjs': _tanggalKedaluarsaBpjs?.toIso8601String()?.split('T')[0],
        'nama_kontak_darurat': _namaKontakDaruratController.text,
        'nomor_kontak_darurat': _nomorKontakDaruratController.text,
        'hubungan_kontak_darurat': _hubunganKontakSelected,
        'nama_bank': _namaBankController.text,
        'nomor_rekening': _nomorRekeningController.text,
        'ttl': _ttl?.toIso8601String()?.split('T')[0],
        'foto_profil': _fotoProfil,
        'foto_ktp': _fotoKtp,
        'foto_sim': _fotoSim,
        'foto_bpjs': _fotoBpjs,
      };
      
      print('Saving city: ${data['kota']}');
      
      await apiService.updateDriverProfile(data);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui profil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Edit Profil'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profil'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white 
            : Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).brightness == Brightness.dark 
            ? Color(0xFF161A30) 
            : Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).brightness == Brightness.dark 
              ? Color(0xFF161A30) 
              : Colors.white,
          unselectedLabelColor: Theme.of(context).brightness == Brightness.dark 
              ? Color(0xFF161A30).withOpacity(0.7) 
              : Colors.white70,
          indicatorColor: Theme.of(context).brightness == Brightness.dark 
              ? Color(0xFF161A30) 
              : Colors.white,
          tabs: [
            Tab(text: 'Umum'),
            Tab(text: 'Identitas'),
            Tab(text: 'Dokumen'),
            Tab(text: 'Keuangan'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text('Simpan', style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Color(0xFF161A30) 
                  : Colors.white
            )),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralTab(),
          _buildIdentityTab(),
          _buildDocumentTab(),
          _buildFinancialTab(),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Photo
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _fotoProfil != null 
                    ? MemoryImage(base64Decode(_fotoProfil!))
                    : null,
                  child: _fotoProfil == null 
                    ? Icon(Icons.person, size: 50)
                    : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      onPressed: () => _takePhoto('profil'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          
          TextField(
            controller: _namaController,
            decoration: InputDecoration(
              labelText: 'Nama Lengkap',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          
          TextField(
            controller: _emailController,
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.verified, color: Colors.green),
            ),
          ),
          SizedBox(height: 16),
          
          TextField(
            controller: _noHpController,
            decoration: InputDecoration(
              labelText: 'Nomor Telepon',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _nikController,
            decoration: InputDecoration(
              labelText: 'NIK',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _kotaSelected,
            decoration: InputDecoration(
              labelText: 'Kota Tempat Berkendara',
              border: OutlineInputBorder(),
            ),
            items: ['Jakarta', 'Bandung', 'Surabaya', 'Medan', 'Makassar', 'Palembang', 'Semarang', 'Yogyakarta', 'Denpasar', 'Balikpapan'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) => setState(() => _kotaSelected = value),
          ),
          SizedBox(height: 16),
          
          TextField(
            controller: _alamatController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Alamat Lengkap',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          
          InkWell(
            onTap: () => _selectDate('ttl'),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Tanggal Lahir',
                border: OutlineInputBorder(),
              ),
              child: Text(
                _ttl != null 
                  ? '${_ttl!.day}/${_ttl!.month}/${_ttl!.year}'
                  : 'Pilih tanggal lahir',
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // Photo KTP
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _takePhoto('ktp'),
              icon: Icon(_fotoKtp != null ? Icons.check_circle : Icons.camera_alt),
              label: Text(_fotoKtp != null ? 'Foto KTP ✓' : 'Ambil Foto KTP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _fotoKtp != null ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _noSimController,
            decoration: InputDecoration(
              labelText: 'Nomor SIM',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _jenisSimSelected,
            decoration: InputDecoration(
              labelText: 'Jenis SIM',
              border: OutlineInputBorder(),
            ),
            items: ['A', 'B1', 'B2', 'C'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text('SIM $value'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _jenisSimSelected = value),
          ),
          SizedBox(height: 16),
          
          InkWell(
            onTap: () => _selectDate('sim'),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Tanggal Kedaluarsa SIM',
                border: OutlineInputBorder(),
              ),
              child: Text(
                _tanggalKedaluarsaSim != null 
                  ? '${_tanggalKedaluarsaSim!.day}/${_tanggalKedaluarsaSim!.month}/${_tanggalKedaluarsaSim!.year}'
                  : 'Pilih tanggal kedaluarsa',
              ),
            ),
          ),
          SizedBox(height: 16),
          
          ElevatedButton.icon(
            onPressed: () => _takePhoto('sim'),
            icon: Icon(_fotoSim != null ? Icons.check_circle : Icons.camera_alt),
            label: Text(_fotoSim != null ? 'Foto SIM ✓' : 'Ambil Foto SIM'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _fotoSim != null ? Colors.green : Colors.grey,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
            ),
          ),
          SizedBox(height: 24),
          
          TextField(
            controller: _noBpjsController,
            decoration: InputDecoration(
              labelText: 'Nomor BPJS',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          
          InkWell(
            onTap: () => _selectDate('bpjs'),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Tanggal Kedaluarsa BPJS',
                border: OutlineInputBorder(),
              ),
              child: Text(
                _tanggalKedaluarsaBpjs != null 
                  ? '${_tanggalKedaluarsaBpjs!.day}/${_tanggalKedaluarsaBpjs!.month}/${_tanggalKedaluarsaBpjs!.year}'
                  : 'Pilih tanggal kedaluarsa',
              ),
            ),
          ),
          SizedBox(height: 16),
          
          ElevatedButton.icon(
            onPressed: () => _takePhoto('bpjs'),
            icon: Icon(_fotoBpjs != null ? Icons.check_circle : Icons.camera_alt),
            label: Text(_fotoBpjs != null ? 'Foto BPJS ✓' : 'Ambil Foto BPJS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _fotoBpjs != null ? Colors.green : Colors.grey,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _namaBankController,
            decoration: InputDecoration(
              labelText: 'Nama Bank',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          
          TextField(
            controller: _nomorRekeningController,
            decoration: InputDecoration(
              labelText: 'Nomor Rekening',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 24),
          
          TextField(
            controller: _namaKontakDaruratController,
            decoration: InputDecoration(
              labelText: 'Nama Kontak Darurat',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          
          TextField(
            controller: _nomorKontakDaruratController,
            decoration: InputDecoration(
              labelText: 'Nomor Kontak Darurat',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _hubunganKontakSelected,
            decoration: InputDecoration(
              labelText: 'Hubungan Kontak Darurat',
              border: OutlineInputBorder(),
            ),
            items: ['Keluarga', 'Teman', 'Saudara', 'Saudara Kandung', 'Orang Tua', 'Anak', 'Suami/Istri', 'Lainnya'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) => setState(() => _hubunganKontakSelected = value),
          ),
        ],
      ),
    );
  }
}