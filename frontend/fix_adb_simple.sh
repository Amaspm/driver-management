#!/bin/bash

echo "=== Simple ADB Fix ==="
echo ""
echo "Device detected: 099201934R001386"
echo "Issue: No permissions"
echo ""

echo "Quick fixes to try:"
echo ""

echo "1. Restart ADB as root (temporary fix):"
echo "   sudo adb kill-server"
echo "   sudo adb start-server"
echo "   adb devices"
echo ""

echo "2. Check USB debugging popup on phone:"
echo "   - Look for 'Allow USB debugging?' popup"
echo "   - Tap 'Always allow from this computer'"
echo "   - Tap 'OK'"
echo ""

echo "3. Try different USB modes on phone:"
echo "   - Pull down notification"
echo "   - Tap USB notification"
echo "   - Select 'File Transfer' or 'PTP'"
echo ""

echo "4. Manual permission fix (need password):"
echo "   sudo chmod 666 /dev/bus/usb/*/*"
echo ""

echo "Trying restart ADB first..."
adb kill-server
sleep 2
adb start-server
echo ""
echo "Current status:"
adb devices

echo ""
echo "If still 'no permissions', check phone for USB debugging popup!"