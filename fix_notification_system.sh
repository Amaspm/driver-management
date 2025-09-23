#!/bin/bash

echo "🔧 Fixing Driver Notification System..."

# Get current IP address
IP=$(hostname -I | awk '{print $1}')
echo "📡 Detected IP: $IP"

# Update Flutter service files
echo "📱 Updating Flutter WebSocket connections..."
sed -i "s/ws:\/\/localhost:8080/ws:\/\/$IP:8080/g" frontend/lib/services/driver_shift_service.dart
sed -i "s/http:\/\/localhost:8080/http:\/\/$IP:8080/g" frontend/lib/services/driver_shift_service.dart

# Update user and seller pages
echo "🌐 Updating web pages..."
sed -i "s/localhost:8001/$IP:8001/g" user-page/user-home.html
sed -i "s/localhost:8001/$IP:8001/g" user-page/seller-home.html

# Create database migration
echo "🗄️ Creating database migration..."
docker-compose exec backend python manage.py makemigrations

# Run migration
echo "📊 Running database migration..."
docker-compose exec backend python manage.py migrate

# Restart services
echo "🔄 Restarting services..."
docker-compose restart backend driver-service

echo "✅ Notification system fixed!"
echo "📋 Next steps:"
echo "   1. Open user page: http://$IP:3000/user-home.html"
echo "   2. Open seller page: http://$IP:3000/seller-home.html"
echo "   3. Test Flutter app with driver login"
echo "   4. Check logs: docker-compose logs -f driver-service"