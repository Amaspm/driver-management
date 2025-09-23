#!/bin/bash

echo "=== Wireless ADB Setup ==="

# Check if device is connected via USB first
adb devices | grep -q "device$"
if [ $? -ne 0 ]; then
    echo "✗ No USB device found."
    echo "Choose an option:"
    echo "1. Connect device via USB and try again"
    echo "2. Enter device IP manually"
    read -p "Enter choice (1 or 2): " choice
    
    if [ "$choice" = "2" ]; then
        read -p "Enter device IP address: " DEVICE_IP
        if [ -z "$DEVICE_IP" ]; then
            echo "✗ No IP address provided"
            exit 1
        fi
        echo "Using manual IP: $DEVICE_IP"
    else
        echo "Please connect device via USB and run script again."
        exit 1
    fi
else
    echo "✓ USB device found"
    
    # Enable wireless debugging
    echo "Enabling wireless debugging..."
    adb tcpip 5555
    
    sleep 2
    
    # Get device IP
    DEVICE_IP=$(adb shell ip route | grep wlan0 | grep -oE '192\.168\.[0-9]+\.[0-9]+|10\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    
    if [ -z "$DEVICE_IP" ]; then
        echo "✗ Could not detect device IP. Please check WiFi connection."
        exit 1
    fi
    
    echo "Device IP detected: $DEVICE_IP"
fi

# Connect wireless
echo "Connecting to $DEVICE_IP:5555..."
adb connect $DEVICE_IP:5555

if [ $? -eq 0 ]; then
    echo "✓ Wireless connection established"
    echo "✓ You can now disconnect USB cable (if connected)"
    echo "Device IP: $DEVICE_IP"
    
    # Save IP for future use
    echo "$DEVICE_IP" > .device_ip
    
    # Run Flutter app
    echo "Starting Flutter app..."
    flutter run
else
    echo "✗ Wireless connection failed"
    echo "Make sure:"
    echo "- Device and computer are on same WiFi network"
    echo "- Wireless debugging is enabled on device"
    echo "- IP address is correct"
    exit 1
fi