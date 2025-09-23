#!/bin/bash

echo "=== Reconnect Wireless ADB ==="

# Check if we have saved device IP
if [ -f .device_ip ]; then
    DEVICE_IP=$(cat .device_ip | tr -d '\n')
    echo "Using saved device IP: $DEVICE_IP"
    
    # Validate IP format
    if [[ ! $DEVICE_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || [[ $DEVICE_IP == "192.168.0.0" ]]; then
        echo "✗ Invalid saved IP: $DEVICE_IP"
        echo "Running fix script..."
        ./fix_wireless_connection.sh
        exit $?
    fi
else
    echo "No saved device IP found. Running setup..."
    ./fix_wireless_connection.sh
    exit $?
fi

# Disconnect any existing connections to avoid conflicts
adb disconnect $DEVICE_IP:5555 2>/dev/null

# Try to reconnect
echo "Connecting to $DEVICE_IP:5555..."
adb connect $DEVICE_IP:5555

# Wait a moment for connection to establish
sleep 2

# Check if device is now connected
if adb devices | grep -q "$DEVICE_IP:5555"; then
    echo "✓ Reconnected to $DEVICE_IP"
    adb devices
    
    # Test connection with a simple command
    if adb -s $DEVICE_IP:5555 shell echo "test" >/dev/null 2>&1; then
        echo "✓ Connection verified and working"
    else
        echo "⚠ Connected but device not responding"
    fi
else
    echo "✗ Failed to reconnect. Device might be offline or IP changed."
    echo "Running fix script..."
    ./fix_wireless_connection.sh
fi