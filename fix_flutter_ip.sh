#!/bin/bash

IP=$(hostname -I | awk '{print $1}')
echo "🔧 Updating Flutter IP to: $IP"

# Update API config
sed -i "s/localhost:8001/$IP:8001/g" frontend/lib/config/api_config.dart

# Update driver shift service
sed -i "s/192\.168\.[0-9]*\.[0-9]*:8080/$IP:8080/g" frontend/lib/services/driver_shift_service.dart

# Update auth service if exists
if [ -f "frontend/lib/services/auth_service.dart" ]; then
    sed -i "s/localhost:8001/$IP:8001/g" frontend/lib/services/auth_service.dart
fi

# Update API service if exists  
if [ -f "frontend/lib/services/api_service.dart" ]; then
    sed -i "s/localhost:8001/$IP:8001/g" frontend/lib/services/api_service.dart
fi

echo "✅ Flutter IP updated to $IP"
echo "📱 Rebuild Flutter app: cd frontend && flutter run"