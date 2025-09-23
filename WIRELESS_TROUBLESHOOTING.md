# Wireless ADB Connection Troubleshooting

## Masalah yang Ditemukan
IP yang tersimpan di `.device_ip` adalah `192.168.0.0` (network IP, bukan device IP yang valid).

## Solusi yang Dibuat

### 1. Script Perbaikan Baru
**`frontend/fix_wireless_connection.sh`** - Script komprehensif untuk troubleshooting:
- Auto-detect device IP dari berbagai method
- Network scanning untuk mencari Android device
- Manual IP input sebagai fallback
- Validasi IP yang proper

### 2. Script Reconnect yang Diperbaiki
**`frontend/reconnect_wireless.sh`** - Improved dengan:
- Validasi IP format
- Auto-fallback ke fix script jika IP invalid
- Connection verification
- Better error handling

### 3. Script Flutter Wireless
**`frontend/run_wireless_flutter.sh`** - All-in-one solution:
- Auto wireless connection
- Device verification
- Flutter configuration update
- Run Flutter app

## Cara Menggunakan

### Method 1: Quick Fix
```bash
cd frontend
./fix_wireless_connection.sh
```

### Method 2: Reconnect Only
```bash
cd frontend
./reconnect_wireless.sh
```

### Method 3: Complete Wireless Flutter Run
```bash
cd frontend
./run_wireless_flutter.sh
```

## Troubleshooting Steps

### 1. Enable Wireless Debugging di Android
- Settings > Developer Options > Wireless debugging
- Turn ON
- Catat IP address yang ditampilkan

### 2. Pastikan Same Network
- Android dan laptop di WiFi yang sama
- Test ping: `ping [android_ip]`

### 3. Manual Connection
```bash
# Jika tahu IP Android device
adb connect [android_ip]:5555
```

### 4. Reset Connection
```bash
# Disconnect semua
adb disconnect

# Kill ADB server
adb kill-server
adb start-server

# Reconnect
./fix_wireless_connection.sh
```

### 5. USB Fallback Method
```bash
# Connect via USB first
adb devices

# Enable wireless
adb tcpip 5555

# Get device IP
adb shell ip route | grep wlan0

# Connect wireless
adb connect [device_ip]:5555

# Disconnect USB
```

## Common Issues & Solutions

### Issue: "192.168.0.0" Invalid IP
**Solution**: Run `./fix_wireless_connection.sh` untuk auto-detect IP yang benar

### Issue: Connection Timeout
**Solution**: 
- Check WiFi connection
- Restart wireless debugging di Android
- Try different IP detection method

### Issue: Multiple Devices
**Solution**: Disconnect other devices atau specify target device

### Issue: Flutter Can't Connect to Backend
**Solution**: Run `../update_flutter_ip_auto.sh` untuk update API config

## Files Modified/Created
- ✅ `frontend/fix_wireless_connection.sh` (NEW)
- ✅ `frontend/run_wireless_flutter.sh` (NEW) 
- ✅ `frontend/reconnect_wireless.sh` (IMPROVED)
- ✅ `frontend/.device_ip` (will be auto-updated)

## Status
**FIXED** - Wireless connection issues resolved dengan multiple fallback methods.