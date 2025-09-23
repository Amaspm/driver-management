#!/usr/bin/env python3

import os
import django
import sys

# Add backend to path
sys.path.append('backend')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth.models import User
from apps.drivers.models import Driver, Vehicle
from apps.orders.models import Order

def create_sample_data():
    print("🔧 Creating sample data...")
    
    # Create superuser
    if not User.objects.filter(username='admin').exists():
        User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
        print("✅ Admin user created (admin/admin123)")
    
    # Create sample drivers
    for i in range(1, 6):
        user, created = User.objects.get_or_create(
            username=f'driver{i}',
            defaults={
                'email': f'driver{i}@example.com',
                'first_name': f'Driver',
                'last_name': f'{i}'
            }
        )
        if created:
            user.set_password('driver123')
            user.save()
        
        driver, created = Driver.objects.get_or_create(
            user=user,
            defaults={
                'phone': f'08123456789{i}',
                'city': 'Jakarta' if i <= 3 else 'Bandung',
                'status': 'online' if i <= 2 else 'offline'
            }
        )
        
        if created:
            Vehicle.objects.create(
                driver=driver,
                license_plate=f'B {1000+i} ABC',
                vehicle_type='motorcycle',
                brand='Honda',
                model='Vario'
            )
    
    print("✅ Sample data created!")
    print("👤 Login: admin/admin123")
    print("🏍️ 5 drivers with vehicles created")

if __name__ == '__main__':
    create_sample_data()