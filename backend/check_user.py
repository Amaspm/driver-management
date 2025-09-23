#!/usr/bin/env python3
import os
import django
import sys

# Add the backend directory to Python path
sys.path.append('/app')

# Set Django settings
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'driver_management_backend.settings')
django.setup()

from django.contrib.auth.models import User
from drivers.models import Driver

print("=== CHECKING USER ACCOUNTS ===")
users = User.objects.all()
print(f"Total users: {users.count()}")
for user in users:
    print(f"User: {user.username} | Email: {user.email} | Staff: {user.is_staff}")

print("\n=== CHECKING DRIVERS ===")
drivers = Driver.objects.all()
print(f"Total drivers: {drivers.count()}")
for driver in drivers:
    print(f"Driver: {driver.id_driver} | Email: {driver.email} | Name: {driver.nama} | Status: {driver.status}")

print("\n=== CHECKING KUVUKI ACCOUNT ===")
try:
    user = User.objects.get(email='kuvuki@kuvuki.com')
    print(f"User found: {user.username}")
    print(f"Password usable: {user.has_usable_password()}")
    
    driver = Driver.objects.get(email='kuvuki@kuvuki.com')
    print(f"Driver found: {driver.nama} | Status: {driver.status}")
except User.DoesNotExist:
    print("User kuvuki@kuvuki.com NOT FOUND")
except Driver.DoesNotExist:
    print("Driver kuvuki@kuvuki.com NOT FOUND")