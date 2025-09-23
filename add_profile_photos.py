#!/usr/bin/env python3

import os
import sys
import django
import base64

# Add the backend directory to the Python path
sys.path.append('/home/sunaookami/Documents/kuliahh/magang/driver_manajement_project/backend')

# Set up Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'driver_management_backend.settings')
django.setup()

from drivers.models import Driver

def add_sample_profile_photo():
    print("Adding sample profile photo to drivers...")
    
    # Create a simple base64 encoded sample image (1x1 pixel PNG)
    # This is just for testing - in real app, this would be actual photo data
    sample_image_base64 = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
    
    try:
        # Get all drivers without profile photos
        drivers_without_photos = Driver.objects.filter(foto_profil__isnull=True)
        
        for driver in drivers_without_photos:
            driver.foto_profil = sample_image_base64
            driver.save()
            print(f"Added profile photo to driver: {driver.nama} (ID: {driver.id_driver})")
        
        # Also update drivers with empty photo strings
        drivers_with_empty_photos = Driver.objects.filter(foto_profil="")
        
        for driver in drivers_with_empty_photos:
            driver.foto_profil = sample_image_base64
            driver.save()
            print(f"Updated profile photo for driver: {driver.nama} (ID: {driver.id_driver})")
        
        total_updated = drivers_without_photos.count() + drivers_with_empty_photos.count()
        print(f"\nTotal drivers updated with profile photos: {total_updated}")
        
    except Exception as e:
        print(f"Error adding profile photos: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    add_sample_profile_photo()