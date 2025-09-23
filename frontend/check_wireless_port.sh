#!/bin/bash

DEVICE_IP="10.170.192.168"

echo "=== Checking Wireless Debugging Port ==="
echo ""
echo "Scanning common ADB ports on $DEVICE_IP..."

# Common ADB wireless ports
ports=(5555 5556 37000 37001 40000 40001 44444 5037)

for port in "${ports[@]}"; do
    echo -n "Testing port $port... "
    
    # Test if port is open using netcat with timeout
    timeout 2 nc -z $DEVICE_IP $port 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "OPEN - trying ADB connection..."
        adb connect $DEVICE_IP:$port
        
        # Check if ADB connection successful
        if adb devices | grep -q "$DEVICE_IP:$port"; then
            echo "✓ SUCCESS! Connected on port $port"
            adb devices
            exit 0
        fi
    else
        echo "closed"
    fi
done

echo ""
echo "No open ADB ports found."
echo ""
echo "NEXT STEPS:"
echo "1. Check wireless debugging settings on your device"
echo "2. Look for the actual port number in Developer Options > Wireless debugging"
echo "3. Or use USB method: ./setup_usb_to_wireless.sh"