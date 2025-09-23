#!/usr/bin/env python3

import os
import sys
import django

# Add the backend directory to the Python path
sys.path.append('/home/sunaookami/Documents/kuliahh/magang/driver_manajement_project/backend')

# Set up Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'driver_management_backend.settings')
django.setup()

from drivers.models import Driver

def update_driver_city():
    print("Updating driver city data...")
    
    try:
        # Update driver Kuvikala with city Palembang
        driver = Driver.objects.filter(nama="Kuvikala").first()
        if driver:
            driver.kota = "Palembang"
            driver.save()
            print(f"Updated driver {driver.nama} with city: {driver.kota}")
        else:
            print("Driver Kuvikala not found")
        
        # Update other drivers with sample cities
        other_drivers = Driver.objects.exclude(nama="Kuvikala")
        cities = ["Jakarta", "Bandung", "Surabaya", "Medan", "Makassar"]
        
        for i, driver in enumerate(other_drivers):
            city = cities[i % len(cities)]
            driver.kota = city
            driver.save()
            print(f"Updated driver {driver.nama} with city: {city}")
        
        print("City data updated successfully!")
        
    except Exception as e:
        print(f"Error updating city data: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    update_driver_city()