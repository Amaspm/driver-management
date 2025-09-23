#!/bin/bash

echo "🔧 Fixing Flutter Connection Issues"
echo "=================================="

# 1. Check Docker services
echo "1. Checking Docker services..."
docker-compose ps

# 2. Test backend connectivity
echo -e "\n2. Testing backend connectivity..."
curl -s http://localhost:8001/api/drivers/ && echo "✅ Backend accessible" || echo "❌ Backend not accessible"

# 3. Update Flutter config for emulator
echo -e "\n3. Updating Flutter config for Android emulator..."
cat > frontend/lib/config/api_config.dart << 'EOF'
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiConfig {
  static const String mode = 'emulator';
  static String? _cachedBaseUrl;
  
  static String get baseUrl {
    switch (mode) {
      case 'emulator':
        return 'http://10.0.2.2:8001/api';
      case 'device_adb':
        return 'http://10.0.2.2:8001/api';
      case 'device_wireless':
        return 'http://192.168.137.135:8001/api';
      default:
        return 'http://10.0.2.2:8001/api';
    }
  }
}
EOF

# 4. Update WebSocket URL
echo -e "\n4. Updating WebSocket URL..."
sed -i 's/ws:\/\/.*:8080\/ws/ws:\/\/10.0.2.2:8080\/ws/g' frontend/lib/services/driver_shift_service.dart

# 5. Restart backend to fix import error
echo -e "\n5. Restarting backend..."
docker-compose restart backend

echo -e "\n✅ Flutter connection fix completed!"
echo "Now run: cd frontend && flutter run"