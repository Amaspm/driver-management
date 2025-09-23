#!/usr/bin/env python3

import os
import sys
import django

sys.path.append('/home/sunaookami/Documents/kuliahh/magang/driver_manajement_project/backend')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'driver_management_backend.settings')
django.setup()

from drivers.models import TrainingModule, TrainingContent, TrainingQuiz

def create_complete_training():
    print("Creating complete training data...")
    
    # Clear existing data
    TrainingContent.objects.all().delete()
    TrainingQuiz.objects.all().delete()
    TrainingModule.objects.all().delete()
    
    # Module 1
    module1 = TrainingModule.objects.create(
        title="Berkendara Defensif",
        description="Pelajari teknik berkendara yang aman dan bertanggung jawab",
        level="pemula",
        instructor="Instructor A",
        order=1
    )
    
    TrainingContent.objects.create(
        module=module1,
        title="Pengenalan Berkendara Defensif",
        content_type="narration",
        text_content="Berkendara defensif adalah teknik mengemudi yang mengutamakan keselamatan dengan selalu waspada terhadap kondisi jalan dan pengguna jalan lainnya."
    )
    
    TrainingQuiz.objects.create(
        module=module1,
        question="Apa yang dimaksud dengan berkendara defensif?",
        option_a="Mengemudi dengan kecepatan tinggi",
        option_b="Teknik mengemudi yang mengutamakan keselamatan",
        option_c="Mengemudi sambil menggunakan handphone",
        option_d="Mengemudi tanpa sabuk pengaman",
        correct_answer="B",
        explanation="Berkendara defensif mengutamakan keselamatan."
    )
    
    # Module 2
    module2 = TrainingModule.objects.create(
        title="Manajemen Rute",
        description="Teknik navigasi dan optimalisasi rute pengiriman",
        level="lanjutan", 
        instructor="Instructor B",
        order=2
    )
    
    TrainingContent.objects.create(
        module=module2,
        title="Perencanaan Rute Efektif",
        content_type="narration",
        text_content="Perencanaan rute yang baik dapat menghemat waktu, bahan bakar, dan meningkatkan kepuasan pelanggan."
    )
    
    TrainingQuiz.objects.create(
        module=module2,
        question="Apa manfaat utama perencanaan rute yang baik?",
        option_a="Menghemat waktu dan bahan bakar",
        option_b="Membuat perjalanan menyenangkan", 
        option_c="Mengurangi keausan kendaraan",
        option_d="Semua jawaban benar",
        correct_answer="D",
        explanation="Perencanaan rute memberikan semua manfaat tersebut."
    )
    
    print(f"Created {TrainingModule.objects.count()} modules")
    print(f"Created {TrainingContent.objects.count()} contents") 
    print(f"Created {TrainingQuiz.objects.count()} quizzes")

if __name__ == "__main__":
    create_complete_training()