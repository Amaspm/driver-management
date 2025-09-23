#!/usr/bin/env python
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'driver_management_backend.settings')
django.setup()

from django.contrib.auth.models import User

# Create admin user if not exists
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@admin.com', 'admin123')
    print('Admin user created: admin/admin123')
else:
    print('Admin user already exists')