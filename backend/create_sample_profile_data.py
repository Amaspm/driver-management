#!/usr/bin/env python3

import os
import sys
import django
from datetime import datetime, timedelta
from decimal import Decimal

# Add the backend directory to the Python path
sys.path.append('/home/sunaookami/Documents/kuliahh/magang/driver_manajement_project/backend')

# Set up Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'driver_management_backend.settings')
django.setup()

from drivers.models import (
    Driver, Pelanggan, SalesOrder, DeliveryOrder, 
    Armada, RatingDriver, RiwayatPerjalanan
)

def create_sample_data():
    print("Creating sample data for driver profile...")
    
    # Get or create a sample driver
    try:
        driver = Driver.objects.filter(status='active').first()
        if not driver:
            print("No active driver found. Creating sample driver...")
            driver = Driver.objects.create(
                nama="John Doe",
                email="john.doe@example.com",
                no_hp="081234567890",
                alamat="Jl. Contoh No. 123, Jakarta",
                ttl=datetime(1990, 1, 1).date(),
                nik="1234567890123456",
                no_sim="SIM123456789",
                jenis_sim="A",
                no_bpjs="BPJS123456789",
                nama_kontak_darurat="Jane Doe",
                nomor_kontak_darurat="081234567891",
                hubungan_kontak_darurat="Istri",
                status="active"
            )
        
        print(f"Using driver: {driver.nama} (ID: {driver.id_driver})")
        
        # Create sample customers
        customers = []
        customer_names = ["PT. ABC Corp", "CV. XYZ", "Toko Maju Jaya", "PT. Sejahtera", "UD. Berkah"]
        
        for i, name in enumerate(customer_names):
            customer, created = Pelanggan.objects.get_or_create(
                nama=name,
                defaults={
                    'no_hp': f"0812345678{90+i}",
                    'email': f"customer{i+1}@example.com",
                    'alamat': f"Jl. Pelanggan {i+1} No. {10+i}, Jakarta"
                }
            )
            customers.append(customer)
            if created:
                print(f"Created customer: {customer.nama}")
        
        # Create sample vehicle
        armada, created = Armada.objects.get_or_create(
            nomor_polisi="B1234XYZ",
            defaults={
                'jenis_armada': "Truck",
                'kapasitas_muatan': 5000,
                'status': True,
                'warna_armada': "Putih",
                'id_stnk': "STNK123456",
                'tahun_pembuatan': datetime(2020, 1, 1),
                'id_bpkb': "BPKB123456"
            }
        )
        if created:
            print(f"Created vehicle: {armada.nomor_polisi}")
        
        # Create sample sales orders and delivery orders
        for i in range(10):
            # Create sales order
            sales_order = SalesOrder.objects.create(
                id_pelanggan=customers[i % len(customers)],
                tanggal_order=datetime.now() - timedelta(days=30-i*3),
                total_harga_order=Decimal(f"{500000 + i*100000}"),
                alamat_pengiriman=f"Jl. Pengiriman {i+1} No. {20+i}, Jakarta Selatan",
                status="completed"
            )
            
            # Create delivery order
            delivery_order = DeliveryOrder.objects.create(
                id_sales_order=sales_order,
                id_armada=armada,
                id_driver=driver,
                tanggal_kirim=datetime.now() - timedelta(days=25-i*3),
                gps_log={"start": "Jakarta", "end": "Bandung", "route": "Tol Cipularang"},
                status="completed"
            )
            
            # Create rating for some deliveries
            if i % 2 == 0:  # Create rating for every other delivery
                rating = RatingDriver.objects.create(
                    id_driver=driver,
                    id_pelanggan=sales_order.id_pelanggan,
                    rating=4 + (i % 2),  # Rating 4 or 5
                    ulasan=f"Pelayanan sangat baik, driver ramah dan tepat waktu. Pengiriman ke-{i+1}",
                    timestamp=datetime.now() - timedelta(days=20-i*3)
                )
                print(f"Created rating {rating.rating}/5 for delivery {delivery_order.id_delivery_order}")
            
            # Create travel history
            RiwayatPerjalanan.objects.create(
                id_delivery_order=delivery_order,
                rute="Jakarta - Bandung via Tol Cipularang",
                tanggal=delivery_order.tanggal_kirim,
                jarak_tempuh_km=Decimal("150.5"),
                durasi_perjalanan=180  # 3 hours in minutes
            )
            
            print(f"Created delivery order {delivery_order.id_delivery_order} for {sales_order.id_pelanggan.nama}")
        
        print(f"\nSample data created successfully!")
        print(f"Driver: {driver.nama}")
        print(f"Total trips: {driver.get_total_trips()}")
        print(f"Average rating: {driver.get_average_rating()}")
        print(f"Experience: {driver.get_experience_years()} years")
        
    except Exception as e:
        print(f"Error creating sample data: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    create_sample_data()