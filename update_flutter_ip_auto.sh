#!/bin/bash

# Get current IP address
CURRENT_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')

if [ -z "$CURRENT_IP" ]; then
    echo "❌ Could not detect IP address"
    exit 1
fi

echo "Current server IP: $CURRENT_IP"

# Update Flutter config - replace all hardcoded IPs
sed -i "s/http:\/\/[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+:8001\/api/http:\/\/$CURRENT_IP:8001\/api/g" frontend/lib/config/api_config.dart

# Test backend connectivity
echo "Testing backend connectivity..."
if curl -s --connect-timeout 3 http://$CURRENT_IP:8001/api/drivers/ > /dev/null; then
    echo "✅ Backend accessible at $CURRENT_IP:8001"
else
    echo "⚠️  Backend not accessible, but config updated"
fi

echo "Updated Flutter config with IP: $CURRENT_IP"
echo "Run: cd frontend && flutter run"