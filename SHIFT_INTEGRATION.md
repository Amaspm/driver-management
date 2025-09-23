# Driver Shift Integration Guide

## ✅ Fitur yang Telah Dibuat

### 1. **Flutter Integration**
- `DriverShiftService` - Service untuk manage online/offline status
- `OrderNotificationDialog` - Dialog untuk notifikasi order baru
- Updated `NewDashboardScreen` - Tombol "Mulai" / "Akhiri" dengan status indicator
- WebSocket connection untuk real-time notifications
- Status badge di header (ONLINE/OFFLINE)

### 2. **Backend Integration**
- Django API endpoints untuk driver online/offline
- Kafka producer untuk publish events
- Order confirmation dan response handling

### 3. **Go Service**
- WebSocket server untuk Flutter connections
- Kafka consumer/producer
- Real-time order distribution ke driver online

### 4. **Web Testing Interface**
- Updated seller page dengan backend integration
- Real-time order confirmation ke Kafka

## 🚀 Cara Menggunakan

### 1. Start System
```bash
# Start all services
docker-compose up -d

# Test system
./test_shift.sh
```

### 2. Flutter App Flow
```dart
// Di Flutter app
final shiftService = DriverShiftService();

// Mulai shift
await shiftService.startShift("driver_001", "jakarta");

// Driver akan menerima notifikasi order via WebSocket
// Dialog akan muncul otomatis untuk terima/abaikan order
```

### 3. Testing Flow
1. **Buka Flutter app** → Klik "Mulai" (driver online, status badge hijau)
2. **Buka seller page** → Konfirmasi order
3. **Flutter app** → Akan muncul dialog notifikasi order
4. **Driver** → Pilih "Terima" atau "Abaikan"
5. **Klik "Akhiri"** → Driver offline (status badge merah)

## 📱 UI Changes

### Dashboard Screen
- Tombol berubah dinamis: "Mulai" ↔ "Akhiri"
- Status badge di header: "ONLINE" (hijau) / "OFFLINE" (merah)
- Real-time order notifications

### Header Status Indicator
- **ONLINE**: Badge hijau dengan dot putih
- **OFFLINE**: Badge merah dengan dot putih
- **Collapsed**: "ON"/"OFF" badge kecil

### Order Dialog
- Popup otomatis saat ada order baru
- Info lengkap: pickup, tujuan, bayaran
- Tombol "Terima" / "Abaikan"

## 🔄 Data Flow

```
Seller confirms → Django API → Kafka → Go Service → WebSocket → Flutter
Driver response → Flutter → Django API → Go Service → Kafka
```

## 🧪 Testing

```bash
# Test manual
./test_shift.sh

# Test dengan Flutter
1. Run Flutter app
2. Klik "Mulai" (lihat status berubah ke ONLINE)
3. Buka seller page, konfirmasi order
4. Check notifikasi di Flutter
5. Klik "Akhiri" (status kembali OFFLINE)
```

## 📋 Dependencies Added

```yaml
# pubspec.yaml
web_socket_channel: ^2.4.0  # WebSocket connection
```

## 🐛 Troubleshooting

### Tombol "Mulai" Tidak Berfungsi:
1. Check console logs untuk error messages
2. Pastikan backend accessible: `curl http://localhost:8001/api/drivers/`
3. Pastikan driver service running: `curl http://localhost:8080/driver/status`
4. Check network connectivity di Flutter app

Sistem shift driver sudah terintegrasi penuh dengan Kafka dan real-time notifications!