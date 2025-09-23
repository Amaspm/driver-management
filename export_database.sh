#!/bin/bash

# Export database for sharing across devices

set -e

echo "🗄️ Exporting Driver Management Database..."

# Start database if not running
docker-compose up -d db

# Wait for database
sleep 5

# Export database
docker-compose exec -T db pg_dump -U postgres -d driver_management > database_export.sql

echo "✅ Database exported to database_export.sql"
echo "📤 To use on another device:"
echo "   1. Copy database_export.sql to new device"
echo "   2. Run: ./import_database.sh"