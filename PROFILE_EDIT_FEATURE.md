# Profile Edit Feature

## Fitur yang Diimplementasi

### 🔹 **Tab Profil Umum**
- Foto profil (upload dengan kamera)
- Nama lengkap
- Email (read-only, verified)
- Nomor telepon

### 🔹 **Tab Identitas**
- NIK
- Alamat domisili
- Tanggal lahir (date picker)
- Upload foto KTP

### 🔹 **Tab Dokumen**
- **SIM**: Nomor, jenis (A/B1/B2/C), tanggal kedaluarsa, foto
- **BPJS**: Nomor, tanggal kedaluarsa, foto

### 🔹 **Tab Keuangan**
- Nama bank
- Nomor rekening
- Kontak darurat (nama, nomor, hubungan)

## File yang Dibuat/Dimodifikasi

### Frontend
1. **`frontend/lib/screens/profile_edit_screen.dart`** - Screen utama edit profil dengan 4 tab
2. **`frontend/lib/main.dart`** - Tambah route `/profile_edit`
3. **`frontend/lib/screens/dashboard_screen.dart`** - Tambah navigasi ke edit profil
4. **`frontend/lib/services/api_service.dart`** - Tambah method:
   - `getDriverProfile()` - Get data driver lengkap
   - `updateDriverProfile()` - Update data driver

### Backend
5. **`backend/drivers/views.py`** - Tambah method `update()` di `DriverViewSet`

## Cara Menggunakan

1. **Akses dari Dashboard**: Klik menu "Profil" di dashboard
2. **Edit Data**: Gunakan 4 tab untuk edit berbagai kategori data
3. **Upload Foto**: Klik tombol kamera untuk ambil foto dokumen
4. **Simpan**: Klik "Simpan" di app bar untuk menyimpan perubahan

## API Endpoints

- **GET** `/api/drivers/{id}/` - Get driver profile
- **PUT** `/api/drivers/{id}/` - Update driver profile

## Validasi & Security

- ✅ User hanya bisa edit profil sendiri
- ✅ Email tidak bisa diubah (read-only)
- ✅ Foto disimpan dalam format base64
- ✅ Date picker untuk tanggal
- ✅ Dropdown untuk pilihan terbatas

## UI/UX Features

- ✅ Tab navigation untuk organisasi data
- ✅ Camera integration untuk foto
- ✅ Date picker untuk tanggal
- ✅ Dropdown untuk jenis SIM dan hubungan kontak
- ✅ Visual indicator untuk foto yang sudah diambil
- ✅ Loading states dan error handling

## Status
**COMPLETED** - Fitur edit profil driver sudah siap digunakan dengan semua requirement dasar terpenuhi.