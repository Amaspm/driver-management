# Login Vehicle Check Fix

## Masalah
Driver `kuvuki@kuvuki.com` yang sudah memiliki kendaraan masih diarahkan ke halaman vehicle matching saat login, padahal di admin panel kendaraan motor sudah aktif dengan driver Kuvikala.

## Penyebab
- Login tidak mengecek apakah driver sudah memiliki kendaraan
- Sistem selalu mengarahkan driver active ke vehicle matching screen
- Tidak ada auto-check vehicle assignment saat login

## Solusi

### 1. Backend Changes (`backend/drivers/views.py`)
Modifikasi `login_driver` endpoint untuk mengembalikan informasi kendaraan:

```python
@api_view(['POST'])
@permission_classes([AllowAny])
def login_driver(request):
    # ... existing login logic ...
    
    if user:
        try:
            driver = Driver.objects.get(email=email)
            token, created = Token.objects.get_or_create(user=user)
            
            # Check if driver has vehicle assignment
            has_vehicle = DriverArmada.objects.filter(id_driver=driver).exists()
            
            return Response({
                'token': token.key,
                'driver_id': driver.id_driver,
                'status': driver.status,
                'has_vehicle': has_vehicle,  # NEW FIELD
                'message': 'Login successful'
            })
```

### 2. Frontend Changes (`frontend/lib/services/api_service.dart`)
Tambah method untuk menyimpan dan mengambil data login:

```dart
class ApiService {
  static Map<String, dynamic>? _lastLoginData;
  
  Future<bool> loginDriver(String email, String password) async {
    // ... existing login logic ...
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Store login data for later use
      _lastLoginData = data;
      
      // ... save token logic ...
    }
  }
  
  Future<Map<String, dynamic>> getLoginData() async {
    if (_lastLoginData != null) {
      return _lastLoginData!;
    }
    return await checkDriverStatus();
  }
}
```

### 3. Login Screen Changes (`frontend/lib/screens/login_screen.dart`)
Update logika navigasi untuk menggunakan informasi `has_vehicle`:

```dart
case 'active':
  if (hasVehicle) {
    print('NAVIGATING TO: Dashboard Screen (has vehicle)');
    Navigator.pushReplacementNamed(context, '/dashboard');
  } else {
    print('NAVIGATING TO: Vehicle Matching Screen (no vehicle)');
    Navigator.pushReplacementNamed(context, '/vehicle_matching');
  }
  break;
```

### 4. Vehicle Matching Screen Changes
Tambah flag untuk menandai vehicle matching sudah selesai:

```dart
if (response.statusCode == 201 || response.statusCode == 200) {
  // Mark vehicle matching as completed
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('vehicle_matching_completed', true);
  
  Navigator.pushReplacementNamed(context, '/dashboard');
}
```

## Testing
Login endpoint sekarang mengembalikan:
```json
{
  "token": "86d929ca3d602830f097...",
  "driver_id": 12,
  "status": "active",
  "has_vehicle": true,
  "message": "Login successful"
}
```

## Hasil
✅ Driver dengan kendaraan langsung ke dashboard
✅ Driver tanpa kendaraan ke vehicle matching
✅ Auto-check vehicle assignment saat login
✅ Tidak ada redirect loop lagi

## Status
**FIXED** - Driver kuvuki@kuvuki.com sekarang langsung masuk dashboard saat login.