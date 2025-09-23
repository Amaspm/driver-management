#!/bin/bash

echo "=== Run Flutter Wireless ==="

# Update Flutter config for wireless
../update_flutter_ip_auto.sh

# Update Flutter config mode
sed -i "s/static const String mode = .*/static const String mode = 'device_wireless';/" lib/config/api_config.dart
echo "✓ Flutter config updated for wireless connection"

# Check wireless connection
adb devices | grep ":5555" | grep -q "device$"
if [ $? -eq 0 ]; then
    echo "✓ Wireless device connected"
    echo "Running Flutter app..."
    flutter run
else
    echo "✗ No wireless device found"
    echo "Please run setup_wireless.sh first or check connection"
fi