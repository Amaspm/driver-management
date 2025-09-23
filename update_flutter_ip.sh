#!/bin/bash

# Manual IP update script
if [ -z "$1" ]; then
    echo "Usage: $0 <IP_ADDRESS>"
    echo "Example: $0 192.168.1.100"
    exit 1
fi

NEW_IP=$1
echo "Updating Flutter config to use IP: $NEW_IP"

# Update Flutter config
sed -i "s/http:\/\/[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+:8001\/api/http:\/\/$NEW_IP:8001\/api/g" frontend/lib/config/api_config.dart

echo "✓ Updated Flutter config with IP: $NEW_IP"
echo "Please rebuild your Flutter app"