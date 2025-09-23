#!/bin/bash

echo "=== Database Sync Script ==="

# Check for orphaned users
echo "Checking for orphaned users..."
docker-compose exec -T backend python manage.py shell -c "
from django.contrib.auth.models import User
from drivers.models import Driver

all_users = User.objects.exclude(is_staff=True)
driver_emails = set(Driver.objects.values_list('email', flat=True))

orphaned_users = []
for user in all_users:
    if user.email not in driver_emails:
        orphaned_users.append(user)

if orphaned_users:
    print(f'Found {len(orphaned_users)} orphaned users:')
    for user in orphaned_users:
        print(f'  - {user.username} ({user.email})')
    print('Run cleanup to remove these users.')
else:
    print('No orphaned users found. Database is clean.')
"

# Show current database state
echo ""
echo "Current database state:"
docker-compose exec -T backend python manage.py shell -c "
from django.contrib.auth.models import User
from drivers.models import Driver

print('=== USERS ===')
users = User.objects.all()
for u in users:
    print(f'  {u.username} ({u.email}) - Staff: {u.is_staff}')

print('=== DRIVERS ===')
drivers = Driver.objects.all()
for d in drivers:
    print(f'  ID: {d.id_driver}, Email: {d.email}, Name: {d.nama}, Status: {d.status}')

print(f'Total Users: {users.count()}')
print(f'Total Drivers: {drivers.count()}')
"