#!/bin/bash

echo "=== Driver Management Quick Connect ==="

# Check if backend is running
echo "Checking backend status..."
docker-compose ps backend | grep -q "Up"
if [ $? -ne 0 ]; then
    echo "Starting backend..."
    docker-compose up -d backend
    sleep 5
fi

# Update Flutter IP
echo "Updating Flutter IP configuration..."
./update_flutter_ip_auto.sh

# Setup mobile connection
echo "Setting up mobile connection..."
cd frontend
./quick_connect.sh
cd ..

echo "✓ Quick connect setup complete"
echo "Now run: cd frontend && flutter run"