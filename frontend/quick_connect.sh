#!/bin/bash

echo "=== Quick Connect Script ==="
echo "Connecting to Android device..."

# Check if device is connected via USB
adb devices | grep -q "device$"
if [ $? -eq 0 ]; then
    echo "✓ Device found via USB"
    
    # Setup port forwarding
    adb reverse tcp:8001 tcp:8001
    echo "✓ Port forwarding setup (8001)"
    
    # Update Flutter config for ADB
    sed -i "s/static const String mode = .*/static const String mode = 'device_adb';/" lib/config/api_config.dart
    echo "✓ Flutter config updated for ADB connection"
    
    echo "Ready to run: flutter run"
else
    echo "✗ No USB device found"
    echo "Please connect device via USB or use wireless connection"
fi