#!/bin/bash

echo "=== Setup Wireless Connection ==="

# Ensure backend is running
docker-compose up -d backend

# Update IP configuration
./update_flutter_ip_auto.sh

# Setup wireless ADB
cd frontend
./setup_wireless.sh
cd ..

echo "✓ Wireless setup complete"
echo "You can now disconnect USB and run: cd frontend && ./run_wireless.sh"