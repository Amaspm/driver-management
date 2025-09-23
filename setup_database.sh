#!/bin/bash

echo "Setting up Driver Management Database..."

# Start Docker services
echo "Starting Docker services..."
docker-compose up -d db

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 10

# Run Django migrations
echo "Running Django migrations..."
docker-compose exec backend python manage.py makemigrations
docker-compose exec backend python manage.py migrate

# Create superuser (optional)
echo "Creating superuser..."
docker-compose exec backend python manage.py shell -c "
from django.contrib.auth.models import User

# Create admin user
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@admin.com', 'admin123')
    print('Superuser created: admin/admin123')
else:
    print('Superuser already exists')

# Create test driver users
if not User.objects.filter(username='driver1').exists():
    User.objects.create_user('driver1', 'driver1@example.com', 'driver123')
    print('Driver1 created: driver1/driver123')

if not User.objects.filter(username='driver2').exists():
    User.objects.create_user('driver2', 'driver2@example.com', 'driver123')
    print('Driver2 created: driver2/driver123')
"

echo "Database setup complete!"
echo ""
echo "Access points:"
echo "- Backend API: http://localhost:8000/api/"
echo "- Django Admin: http://localhost:8000/admin/ (admin/admin123)"
echo "- Web Frontend: http://localhost:3000"
echo "- PostgreSQL: localhost:5432 (postgres/postgres123)"
echo "- PgAdmin: http://localhost:5050 (admin@admin.com/admin123)"