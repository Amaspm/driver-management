# Mobile Connection Fix Guide

## Problem
Flutter app tidak bisa connect ke backend dengan error "Connection reset by peer"

## Root Cause
IP address di Flutter config tidak match dengan IP server yang sebenarnya.

## Solution

### 1. Auto Update IP (Recommended)
```bash
./update_flutter_ip_auto.sh
```

### 2. Manual Update IP
1. Cek IP server:
```bash
ip route get 8.8.8.8 | grep -oP 'src \K\S+'
```

2. Update file `frontend/lib/config/api_config.dart`:
```dart
return _cachedBaseUrl ?? 'http://YOUR_SERVER_IP:8001/api';
```

### 3. Rebuild Flutter App
```bash
cd frontend
flutter clean
flutter pub get
flutter run
```

## Verification

### Test API dari server:
```bash
curl -X POST http://YOUR_IP:8001/api/drivers/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"password"}'
```

### Expected Response:
```json
{"error":"Invalid credentials"}
```

## Network Requirements

1. **Same Network**: HP dan server harus dalam network WiFi yang sama
2. **Firewall**: Port 8001 harus terbuka
3. **Docker**: Container backend harus running

## Troubleshooting

### Jika masih error:
1. Pastikan HP dan server di network yang sama
2. Cek firewall: `sudo ufw status`
3. Restart Docker: `docker-compose restart backend`
4. Test ping dari HP ke server IP

### Alternative Solutions:
1. Gunakan USB debugging dengan ADB port forwarding
2. Setup ngrok untuk external access
3. Configure router port forwarding