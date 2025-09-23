#!/usr/bin/env python
import os
import sys
import django

# Setup Django
sys.path.append('/app')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'driver_management_backend.settings')
django.setup()

from django.contrib.auth.models import User
from drivers.models import Driver

def cleanup_orphaned_users():
    """Remove User accounts that don't have corresponding Driver records"""
    
    # Get all users except admin
    all_users = User.objects.exclude(is_staff=True)
    
    # Get all driver emails
    driver_emails = set(Driver.objects.values_list('email', flat=True))
    
    orphaned_users = []
    for user in all_users:
        if user.email not in driver_emails:
            orphaned_users.append(user)
    
    print(f"Found {len(orphaned_users)} orphaned user accounts:")
    for user in orphaned_users:
        print(f"  - {user.username} ({user.email})")
    
    if orphaned_users:
        confirm = input("Delete these orphaned users? (y/N): ")
        if confirm.lower() == 'y':
            for user in orphaned_users:
                print(f"Deleting user: {user.username}")
                user.delete()
            print(f"Deleted {len(orphaned_users)} orphaned users")
        else:
            print("Cleanup cancelled")
    else:
        print("No orphaned users found")

if __name__ == '__main__':
    cleanup_orphaned_users()