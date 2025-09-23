#!/bin/bash

echo "=== Fixing USB ADB Permissions ==="
echo ""

# Get device vendor ID
VENDOR_ID=$(lsusb | grep -i android | awk '{print $6}' | cut -d: -f1)
if [ -z "$VENDOR_ID" ]; then
    VENDOR_ID="18d1"  # Google default
fi

echo "Setting up udev rules for vendor ID: $VENDOR_ID"

# Create udev rule
sudo tee /etc/udev/rules.d/51-android.rules > /dev/null << EOF
SUBSYSTEM=="usb", ATTR{idVendor}=="$VENDOR_ID", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="22b8", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="0bb4", MODE="0666", GROUP="plugdev"
EOF

# Set permissions
sudo chmod a+r /etc/udev/rules.d/51-android.rules

# Add user to plugdev group
sudo usermod -a -G plugdev $USER

# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "✓ Udev rules created"
echo "✓ User added to plugdev group"
echo ""
echo "Now restart ADB and reconnect device:"
adb kill-server
adb start-server

echo ""
echo "Disconnect and reconnect USB cable, then check:"
echo "adb devices"