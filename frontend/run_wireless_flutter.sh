#!/bin/bash

echo "=== Flutter Wireless Run ==="

# Step 1: Ensure wireless connection
echo "Step 1: Checking wireless connection..."
./reconnect_wireless.sh

if [ $? -ne 0 ]; then
    echo "✗ Wireless connection failed"
    exit 1
fi

# Step 2: Verify device is available
echo "Step 2: Verifying device..."
DEVICE_COUNT=$(adb devices | grep -c "device$")

if [ $DEVICE_COUNT -eq 0 ]; then
    echo "✗ No devices found"
    exit 1
elif [ $DEVICE_COUNT -gt 1 ]; then
    echo "⚠ Multiple devices found:"
    adb devices
    echo "Please disconnect other devices or specify target device"
    exit 1
else
    echo "✓ Single device found"
    adb devices
fi

# Step 3: Update Flutter IP configuration
echo "Step 3: Updating Flutter configuration..."
if [ -f .device_ip ]; then
    DEVICE_IP=$(cat .device_ip | tr -d '\n')
    echo "Using device IP: $DEVICE_IP"
    
    # Update API config if exists
    if [ -f "lib/config/api_config.dart" ]; then
        echo "Updating API config with device IP..."
        # This will be handled by the existing update script
        ../update_flutter_ip_auto.sh
    fi
fi

# Step 4: Run Flutter
echo "Step 4: Starting Flutter app..."
echo "Press Ctrl+C to stop"
flutter run