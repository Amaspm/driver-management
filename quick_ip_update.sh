#!/bin/bash

echo "=== Quick IP Update ==="
echo ""

# Auto-detect current IP
CURRENT_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')
echo "Auto-detected IP: $CURRENT_IP"

# Show current config
echo ""
echo "Current Flutter config:"
grep -n "http://" frontend/lib/config/api_config.dart | head -3

echo ""
echo "Options:"
echo "1. Use auto-detected IP ($CURRENT_IP)"
echo "2. Enter IP manually"
echo "3. Enable auto-detection mode"

read -p "Choose option (1-3): " choice

case $choice in
    1)
        ./update_flutter_ip_auto.sh
        ;;
    2)
        read -p "Enter laptop IP: " MANUAL_IP
        sed -i "s/http:\/\/[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+:8001\/api/http:\/\/$MANUAL_IP:8001\/api/g" frontend/lib/config/api_config.dart
        echo "✅ Updated to manual IP: $MANUAL_IP"
        ;;
    3)
        sed -i "s/static const String mode = '[^']*';/static const String mode = 'auto_detect';/" frontend/lib/config/api_config.dart
        echo "✅ Enabled auto-detection mode"
        echo "App will automatically find backend IP"
        ;;
    *)
        echo "Invalid option"
        ;;
esac

echo ""
echo "Next: cd frontend && flutter run"