#!/bin/bash

# Import database from export file

set -e

echo "📥 Importing Driver Management Database..."

if [ ! -f "database_export.sql" ]; then
    echo "❌ database_export.sql not found!"
    exit 1
fi

# Start database
docker-compose up -d db

# Wait for database
sleep 10

# Import database
docker-compose exec -T db psql -U postgres -d driver_management < database_export.sql

echo "✅ Database imported successfully!"
echo "🚀 Run: docker-compose up -d"