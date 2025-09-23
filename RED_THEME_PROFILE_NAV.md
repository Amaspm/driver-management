# Update: Tema Merah dan Navigasi Profil

## ✅ Perubahan yang Diimplementasikan

### **1. Tema Warna Merah**
- **Header Gradient**: Biru → Merah (`Color(0xFFDC3545)` dan `Color(0xFFE85A6B)`)
- **Statistik Cards**: 
  - Trip Hari Ini: Merah (`Color(0xFFDC3545)`)
  - Pendapatan: Hijau (`Color(0xFF28A745)`)
  - Jarak Tempuh: Ungu (`Color(0xFF6F42C1)`)
  - Waktu Online: Orange (`Color(0xFFFD7E14)`)
- **Quick Actions**:
  - Mulai Shift: Hijau (`Color(0xFF28A745)`)
  - Akhiri Shift: Merah (`Color(0xFFDC3545)`)
  - Inspeksi: Ungu (`Color(0xFF6F42C1)`)
  - Pengaturan: Merah (`Color(0xFFDC3545)`)
- **Trip Cards**: Icon merah (`Color(0xFFDC3545)`)
- **Hamburger Menu Header**: Gradient merah

### **2. Navigasi ke Profil**

#### **Dashboard Header**
```dart
GestureDetector(
  onTap: () => Navigator.pushNamed(context, '/profile_edit'),
  child: Row(
    children: [
      // Foto profil dan nama driver
    ],
  ),
)
```

#### **Hamburger Menu**
```dart
// Foto profil clickable
GestureDetector(
  onTap: () {
    setState(() => _sideMenuOpen = false);
    Navigator.pushNamed(context, '/profile_edit');
  },
  child: CircleAvatar(
    // Foto profil dari database
  ),
)

// Nama driver clickable
GestureDetector(
  onTap: () {
    setState(() => _sideMenuOpen = false);
    Navigator.pushNamed(context, '/profile_edit');
  },
  child: Column(
    // Nama dan nomor kendaraan
  ),
)
```

### **3. Fitur yang Ditambahkan**
- ✅ Klik foto profil di header → Navigasi ke `/profile_edit`
- ✅ Klik nama driver di header → Navigasi ke `/profile_edit`
- ✅ Klik foto profil di hamburger menu → Navigasi ke `/profile_edit`
- ✅ Klik nama driver di hamburger menu → Navigasi ke `/profile_edit`
- ✅ Foto profil dari database ditampilkan di hamburger menu
- ✅ Tema warna konsisten merah di seluruh dashboard

### **4. Konsistensi UI**
- Semua elemen menggunakan tema merah (`Color(0xFFDC3545)`)
- Gradient header dan hamburger menu sama
- Foto profil sinkron antara header dan hamburger menu
- Navigation flow yang smooth (tutup menu → buka profil)

## 🎯 **Status: SELESAI ✅**

Dashboard sekarang memiliki:
- ✅ Tema warna merah yang konsisten
- ✅ Navigasi ke profil dari 4 titik klik (foto + nama di header dan hamburger menu)
- ✅ Foto profil dari database di semua tempat
- ✅ UI yang responsif dan user-friendly