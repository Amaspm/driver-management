#!/bin/bash

echo "=== Run Flutter Android ==="

# Check connection type and setup accordingly
adb devices | grep ":5555" | grep -q "device$"
if [ $? -eq 0 ]; then
    echo "✓ Wireless device detected"
    ./run_wireless.sh
else
    adb devices | grep -q "device$"
    if [ $? -eq 0 ]; then
        echo "✓ USB device detected"
        ./quick_connect.sh
        flutter run
    else
        echo "✗ No Android device found"
        echo "Please connect device via USB or setup wireless connection"
        exit 1
    fi
fi