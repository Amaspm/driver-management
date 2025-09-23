# User Page - Driver Management Testing

Halaman HTML sederhana untuk testing notifikasi driver dengan Tailwind CSS.

## Struktur File

- `login.html` - Halaman login dengan pilihan role (User/Penjual)
- `user-home.html` - Halaman user untuk memesan barang
- `seller-home.html` - Halaman penjual untuk konfirmasi pesanan

## Cara Menggunakan

1. Buka `login.html` di browser
2. Pilih role (User atau Penjual)
3. Klik Login untuk masuk ke halaman sesuai role

### Flow Testing

1. **User (Pembeli)**:
   - Pilih barang (A, B, atau C)
   - Pilih kota tujuan (Jakarta, Bandung, Surabaya)
   - Klik Checkout
   - Status pesanan: "MENUNGGU KONFIRMASI PENJUAL"

2. **Penjual**:
   - Lihat daftar pesanan yang menunggu konfirmasi
   - Klik "Konfirmasi Barang Siap"
   - Status berubah menjadi "MENUNGGU DRIVER"

## Fitur

- Responsive design dengan Tailwind CSS
- Local storage untuk simulasi data
- Auto refresh pada halaman penjual
- Status tracking pesanan

## Catatan

- Data disimpan di localStorage browser (untuk testing)
- Belum terintegrasi dengan backend Django
- Belum ada fitur driver online (akan ditambahkan nanti)