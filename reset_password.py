#!/usr/bin/env python3
import os
import django
import sys

sys.path.append('/app')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'driver_management_backend.settings')
django.setup()

from django.contrib.auth.models import User

try:
    user = User.objects.get(email='kuvuki@kuvuki.com')
    user.set_password('driver123')  # Reset to default password
    user.save()
    print(f"Password reset for {user.email} - New password: driver123")
except User.DoesNotExist:
    print("User not found")