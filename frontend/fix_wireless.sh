#!/bin/bash

echo "=== Flutter Wireless Debugging Fix ==="
echo ""

DEVICE_IP="10.170.192.168"

echo "Step 1: Testing connection to device..."
ping -c 2 $DEVICE_IP > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Device is reachable at $DEVICE_IP"
else
    echo "✗ Cannot reach device at $DEVICE_IP"
    echo "Please check WiFi connection"
    exit 1
fi

echo ""
echo "Step 2: Checking ADB status..."
adb devices

echo ""
echo "Step 3: Killing ADB server and restarting..."
adb kill-server
sleep 2
adb start-server

echo ""
echo "Step 4: Attempting wireless connection..."
echo "Trying different ports..."

# Try common wireless debugging ports
for port in 5555 5556 37000 37001; do
    echo "Trying port $port..."
    adb connect $DEVICE_IP:$port
    sleep 1
    
    # Check if connection successful
    adb devices | grep -q "$DEVICE_IP:$port"
    if [ $? -eq 0 ]; then
        echo "✓ Connected successfully on port $port"
        echo ""
        echo "Current devices:"
        adb devices
        echo ""
        echo "You can now run: flutter run"
        exit 0
    fi
done

echo ""
echo "✗ All connection attempts failed"
echo ""
echo "MANUAL STEPS TO FIX:"
echo "1. On your Android device:"
echo "   - Go to Settings > Developer Options"
echo "   - Enable 'Wireless debugging' or 'ADB over network'"
echo "   - Note the IP and port shown (might be different from 5555)"
echo ""
echo "2. If using Android 11+:"
echo "   - Go to Settings > Developer Options > Wireless debugging"
echo "   - Tap 'Pair device with pairing code'"
echo "   - Use the IP and port shown there"
echo ""
echo "3. Alternative method:"
echo "   - Connect device via USB cable"
echo "   - Run: adb tcpip 5555"
echo "   - Disconnect USB"
echo "   - Run: adb connect $DEVICE_IP:5555"
echo ""
echo "4. Check if device allows wireless debugging:"
echo "   - Some devices require enabling 'USB debugging' first"
echo "   - Some require 'Developer options' to be enabled"