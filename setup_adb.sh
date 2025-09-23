#!/bin/bash

echo "Setting up ADB port forwarding for physical device..."

# Setup port forwarding untuk backend
adb reverse tcp:8001 tcp:8001

# Verify port forwarding
adb reverse --list

echo "ADB port forwarding setup completed!"
echo "Backend should now be accessible at http://localhost:8001 from your device"