# Vehicle Assignment Fix

## Masalah
Driver dengan email `kuvuki@kuvuki.com` mengalami error saat mencoba memilih kendaraan di aplikasi Flutter:

```
I/flutter (11104): Assignment response: 400
I/flutter (11104): Assignment response body: {"non_field_errors":["The fields id_driver, id_armada must make a unique set."]}
```

## Penyebab
Error terjadi karena:
1. Driver sudah memiliki assignment kendaraan sebelumnya (Driver ID 12 -> Vehicle ID 1)
2. Sistem mencoba membuat assignment baru dengan kombinasi yang sama
3. Model `DriverArmada` memiliki constraint `unique_together = ('id_driver', 'id_armada')`
4. Database menolak duplikat assignment

## Solusi
Dimodifikasi method `create` di `DriverArmadaViewSet` untuk:
1. Cek apakah assignment sudah ada sebelum membuat yang baru
2. Jika sudah ada, return assignment yang existing dengan status 200
3. Jika belum ada, buat assignment baru dengan status 201

### Perubahan di Backend (`backend/drivers/views.py`)
```python
def create(self, request, *args, **kwargs):
    try:
        driver = Driver.objects.get(email=request.user.email)
        armada_id = request.data.get('id_armada')
        
        # Check existing assignment
        existing = DriverArmada.objects.filter(
            id_driver=driver,
            id_armada=armada_id
        ).first()
        
        if existing:
            # Return existing assignment
            serializer = self.get_serializer(existing)
            return Response(serializer.data, status=status.HTTP_200_OK)
        else:
            # Create new assignment
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            instance = serializer.save(id_driver=driver)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
```

### Perubahan di Frontend (`frontend/lib/screens/vehicle_matching_screen.dart`)
```dart
if (response.statusCode == 201 || response.statusCode == 200) {
  String message = response.statusCode == 200 
      ? 'Kendaraan sudah terdaftar' 
      : 'Kendaraan berhasil didaftarkan';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
  Navigator.pushReplacementNamed(context, '/dashboard');
}
```

## Testing
Dibuat script test (`test_vehicle_assignment_fix.py`) yang memverifikasi:
1. Login berhasil
2. Cek assignment yang ada
3. Test duplicate assignment (tidak error)

## Hasil
✅ Driver sekarang bisa memilih kendaraan tanpa error
✅ Sistem menangani assignment yang sudah ada dengan benar
✅ Tidak ada duplikat data di database
✅ User experience lebih baik dengan pesan yang informatif

## Status
**FIXED** - Masalah telah diselesaikan dan ditest berhasil.