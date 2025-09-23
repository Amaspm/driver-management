#!/bin/bash

echo "=== Wireless ADB Connection Fix ==="

# Function to test ADB connection
test_adb_connection() {
    local ip=$1
    echo "Testing connection to $ip:5555..."
    timeout 5 adb connect $ip:5555 2>/dev/null
    if adb devices | grep -q "$ip:5555"; then
        echo "✓ Connection successful to $ip"
        return 0
    else
        echo "✗ Connection failed to $ip"
        return 1
    fi
}

# Function to scan for devices on network
scan_network() {
    echo "Scanning network for Android devices..."
    
    # Get laptop IP to determine network range
    LAPTOP_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')
    NETWORK=$(echo $LAPTOP_IP | cut -d. -f1-3)
    
    echo "Laptop IP: $LAPTOP_IP"
    echo "Scanning network: $NETWORK.0/24"
    
    # Scan common Android device ports
    for i in {100..254}; do
        IP="$NETWORK.$i"
        if ping -c 1 -W 1 $IP >/dev/null 2>&1; then
            echo "Found device at $IP, testing ADB..."
            if test_adb_connection $IP; then
                echo "$IP" > .device_ip
                return 0
            fi
        fi
    done
    
    return 1
}

# Check current saved IP
if [ -f .device_ip ]; then
    SAVED_IP=$(cat .device_ip | tr -d '\n')
    echo "Saved IP: $SAVED_IP"
    
    # Test if saved IP is valid
    if [[ $SAVED_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && [[ $SAVED_IP != "192.168.0.0" ]]; then
        echo "Testing saved IP..."
        if test_adb_connection $SAVED_IP; then
            echo "✓ Reconnected successfully!"
            adb devices
            exit 0
        fi
    else
        echo "Invalid saved IP: $SAVED_IP"
    fi
fi

echo "Saved IP failed or invalid. Trying alternative methods..."

# Method 1: Try to get IP from USB connected device
echo "Method 1: Getting IP from USB device..."
if adb devices | grep -q "device$"; then
    echo "USB device found, getting IP..."
    
    # Try multiple methods to get device IP
    DEVICE_IP=$(adb shell ip route | grep wlan0 | grep -oE '192\.168\.[0-9]+\.[0-9]+' | head -1)
    
    if [ -z "$DEVICE_IP" ]; then
        DEVICE_IP=$(adb shell ifconfig wlan0 | grep -oE '192\.168\.[0-9]+\.[0-9]+' | head -1)
    fi
    
    if [ -z "$DEVICE_IP" ]; then
        DEVICE_IP=$(adb shell ip addr show wlan0 | grep -oE '192\.168\.[0-9]+\.[0-9]+' | head -1)
    fi
    
    if [ ! -z "$DEVICE_IP" ] && [[ $DEVICE_IP != "192.168.0.0" ]]; then
        echo "Device IP found: $DEVICE_IP"
        
        # Enable wireless debugging
        adb tcpip 5555
        sleep 3
        
        if test_adb_connection $DEVICE_IP; then
            echo "✓ Wireless connection established via USB method!"
            echo "$DEVICE_IP" > .device_ip
            adb devices
            exit 0
        fi
    else
        echo "Could not get valid device IP from USB"
    fi
else
    echo "No USB device found"
fi

# Method 2: Manual IP input
echo "Method 2: Manual IP input..."
read -p "Enter your Android device IP address (or press Enter to scan): " MANUAL_IP

if [ ! -z "$MANUAL_IP" ]; then
    if test_adb_connection $MANUAL_IP; then
        echo "✓ Manual IP connection successful!"
        echo "$MANUAL_IP" > .device_ip
        adb devices
        exit 0
    fi
fi

# Method 3: Network scan
echo "Method 3: Network scanning..."
if scan_network; then
    echo "✓ Device found via network scan!"
    adb devices
    exit 0
fi

# All methods failed
echo "✗ All connection methods failed."
echo ""
echo "Troubleshooting steps:"
echo "1. Make sure your Android device has 'Wireless debugging' enabled"
echo "2. Both devices should be on the same WiFi network"
echo "3. Try connecting via USB first and run this script"
echo "4. Check if device IP changed (restart router/device)"
echo "5. Disable and re-enable WiFi on Android device"
echo ""
echo "To enable wireless debugging on Android:"
echo "- Go to Settings > Developer Options > Wireless debugging"
echo "- Turn it ON"
echo "- Note the IP address shown"

exit 1