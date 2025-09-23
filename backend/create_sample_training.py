#!/usr/bin/env python3

import os
import sys
import django

# Add the backend directory to Python path
sys.path.append('/home/sunaookami/Documents/kuliahh/magang/driver_manajement_project/backend')

# Set Django settings
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'driver_management_backend.settings')

# Setup Django
django.setup()

from drivers.models import TrainingModule, TrainingContent, TrainingQuiz

def create_sample_training():
    print("Creating sample training data...")
    
    # Create Training Module 1: Berkendara Defensif
    module1, created = TrainingModule.objects.get_or_create(
        title="Berkendara Defensif",
        defaults={
            'description': 'Pelajari teknik berkendara yang aman dan bertanggung jawab untuk menghindari kecelakaan.',
            'level': 'pemula',
            'instructor': 'Instructor A',
            'order': 1,
            'is_active': True
        }
    )
    
    if created:
        print(f"Created module: {module1.title}")
        
        # Add contents to module 1
        TrainingContent.objects.create(
            module=module1,
            title="Pengenalan Berkendara Defensif",
            content_type="narration",
            text_content="Berkendara defensif adalah teknik mengemudi yang mengutamakan keselamatan dengan selalu waspada terhadap kondisi jalan dan pengguna jalan lainnya. Prinsip utamanya adalah mengantisipasi bahaya sebelum terjadi."
        )
        
        TrainingContent.objects.create(
            module=module1,
            title="Posisi Berkendara yang Benar",
            content_type="image",
            text_content="Posisi duduk yang benar sangat penting untuk kontrol kendaraan yang optimal. Pastikan jarak dengan pedal dan kemudi sesuai dengan postur tubuh Anda.",
            media_content="data:image/placeholder"
        )
        
        TrainingContent.objects.create(
            module=module1,
            title="Video: Teknik Melihat Spion",
            content_type="video",
            text_content="Pelajari cara menggunakan spion dengan benar untuk memantau kondisi sekitar kendaraan.",
            media_content="https://example.com/video1"
        )
        
        TrainingContent.objects.create(
            module=module1,
            title="Infografis: Jarak Aman Berkendara",
            content_type="infographic",
            text_content="Jaga jarak aman dengan kendaraan di depan minimal 3 detik pada kondisi normal, dan lebih jauh pada kondisi hujan atau berkabut.",
            media_content="data:image/infographic1"
        )
        
        # Add quiz questions to module 1
        TrainingQuiz.objects.create(
            module=module1,
            question="Apa yang dimaksud dengan berkendara defensif?",
            option_a="Mengemudi dengan kecepatan tinggi",
            option_b="Teknik mengemudi yang mengutamakan keselamatan",
            option_c="Mengemudi sambil menggunakan handphone",
            option_d="Mengemudi tanpa menggunakan sabuk pengaman",
            correct_answer="B",
            explanation="Berkendara defensif adalah teknik mengemudi yang mengutamakan keselamatan dengan selalu waspada."
        )
        
        TrainingQuiz.objects.create(
            module=module1,
            question="Berapa jarak aman minimal dengan kendaraan di depan pada kondisi normal?",
            option_a="1 detik",
            option_b="2 detik", 
            option_c="3 detik",
            option_d="5 detik",
            correct_answer="C",
            explanation="Jarak aman minimal adalah 3 detik untuk memberikan waktu reaksi yang cukup."
        )
    
    # Create Training Module 2: Manajemen Rute & Efisiensi Waktu
    module2, created = TrainingModule.objects.get_or_create(
        title="Manajemen Rute & Efisiensi Waktu",
        defaults={
            'description': 'Teknik navigasi, optimalisasi rute, dan strategi menghindari keterlambatan dalam pengiriman.',
            'level': 'lanjutan',
            'instructor': 'Instructor B',
            'order': 2,
            'is_active': True
        }
    )
    
    if created:
        print(f"Created module: {module2.title}")
        
        # Add contents to module 2
        TrainingContent.objects.create(
            module=module2,
            title="Perencanaan Rute Efektif",
            content_type="narration",
            text_content="Perencanaan rute yang baik dapat menghemat waktu, bahan bakar, dan meningkatkan kepuasan pelanggan. Gunakan aplikasi navigasi dan pertimbangkan kondisi lalu lintas."
        )
        
        TrainingContent.objects.create(
            module=module2,
            title="Penggunaan GPS dan Aplikasi Navigasi",
            content_type="video",
            text_content="Pelajari cara menggunakan GPS dan aplikasi navigasi untuk menemukan rute tercepat dan menghindari kemacetan.",
            media_content="https://example.com/video2"
        )
        
        TrainingContent.objects.create(
            module=module2,
            title="Tips Menghindari Kemacetan",
            content_type="infographic",
            text_content="Kenali jam sibuk di area pengiriman Anda dan rencanakan rute alternatif untuk menghindari kemacetan.",
            media_content="data:image/infographic2"
        )
        
        # Add quiz questions to module 2
        TrainingQuiz.objects.create(
            module=module2,
            question="Apa manfaat utama dari perencanaan rute yang baik?",
            option_a="Menghemat waktu dan bahan bakar",
            option_b="Membuat perjalanan lebih menyenangkan",
            option_c="Mengurangi keausan kendaraan",
            option_d="Semua jawaban benar",
            correct_answer="D",
            explanation="Perencanaan rute yang baik memberikan semua manfaat tersebut."
        )
    
    # Create Training Module 3: Keselamatan dan Tanggap Darurat
    module3, created = TrainingModule.objects.get_or_create(
        title="Keselamatan dan Tanggap Darurat",
        defaults={
            'description': 'Prosedur keselamatan dan langkah-langkah yang harus diambil dalam situasi darurat.',
            'level': 'expert',
            'instructor': 'Instructor C',
            'order': 3,
            'is_active': True
        }
    )
    
    if created:
        print(f"Created module: {module3.title}")
        
        # Add contents to module 3
        TrainingContent.objects.create(
            module=module3,
            title="Prosedur Keselamatan Dasar",
            content_type="narration",
            text_content="Keselamatan adalah prioritas utama. Selalu gunakan APD, periksa kendaraan sebelum berangkat, dan ikuti prosedur keselamatan perusahaan."
        )
        
        TrainingContent.objects.create(
            module=module3,
            title="Penanganan Kecelakaan",
            content_type="video",
            text_content="Langkah-langkah yang harus diambil jika terjadi kecelakaan: amankan lokasi, hubungi bantuan, dan laporkan ke perusahaan.",
            media_content="https://example.com/video3"
        )
        
        # Add quiz questions to module 3
        TrainingQuiz.objects.create(
            module=module3,
            question="Apa yang harus dilakukan pertama kali jika terjadi kecelakaan?",
            option_a="Menghubungi keluarga",
            option_b="Mengamankan lokasi kejadian",
            option_c="Mengambil foto",
            option_d="Meninggalkan lokasi",
            correct_answer="B",
            explanation="Prioritas utama adalah mengamankan lokasi untuk mencegah kecelakaan lebih lanjut."
        )
    
    print("Sample training data created successfully!")
    print(f"Total modules: {TrainingModule.objects.count()}")
    print(f"Total contents: {TrainingContent.objects.count()}")
    print(f"Total quiz questions: {TrainingQuiz.objects.count()}")

if __name__ == "__main__":
    create_sample_training()