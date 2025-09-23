#!/bin/bash

echo "=== USB to Wireless Setup ==="
echo ""
echo "1. Connect your device via USB cable"
echo "2. Make sure USB debugging is enabled"
echo "3. Press Enter when ready..."
read

echo "Checking USB connection..."
adb devices

# Check if device connected
adb devices | grep -q "device$"
if [ $? -ne 0 ]; then
    echo "✗ No USB device found. Please connect device and enable USB debugging."
    exit 1
fi

echo "✓ USB device found"
echo ""
echo "Enabling wireless debugging..."
adb tcpip 5555

echo "Waiting 3 seconds..."
sleep 3

echo "Now disconnect USB cable and press Enter..."
read

DEVICE_IP="10.170.192.168"
echo "Connecting wirelessly to $DEVICE_IP:5555..."
adb connect $DEVICE_IP:5555

if adb devices | grep -q "$DEVICE_IP:5555"; then
    echo "✓ Wireless connection successful!"
    echo ""
    echo "Current devices:"
    adb devices
    echo ""
    echo "Starting Flutter app..."
    flutter run
else
    echo "✗ Wireless connection failed"
    echo "Try running: adb connect $DEVICE_IP:5555"
fi