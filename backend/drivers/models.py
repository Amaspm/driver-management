from django.db import models
from django.utils import timezone

class Driver(models.Model):
    STATUS_CHOICES = [
        ('training', 'Training'),
        ('pending', 'Pending Approval'),
        ('active', 'Active'),
        ('inactive', 'Inactive'),
        ('suspended', 'Suspended'),
        ('rejected', 'Rejected'),
    ]
    
    id_driver = models.AutoField(primary_key=True)
    no_hp = models.CharField(max_length=15)
    nama = models.CharField(max_length=100)
    email = models.EmailField()
    wkt_daftar = models.DateTimeField(auto_now_add=True)
    kota = models.CharField(max_length=50, blank=True, null=True)
    alamat = models.TextField()
    ttl = models.DateField()
    nik = models.CharField(max_length=16)
    no_sim = models.CharField(max_length=20)
    jenis_sim = models.CharField(max_length=10)
    tanggal_kedaluarsa_sim = models.DateField(blank=True, null=True)
    no_bpjs = models.CharField(max_length=20)
    tanggal_kedaluarsa_bpjs = models.DateField(blank=True, null=True)
    no_sertifikat = models.CharField(max_length=50, blank=True, null=True)
    tanggal_kedaluarsa_sertifikat = models.DateField(blank=True, null=True)
    nama_kontak_darurat = models.CharField(max_length=100)
    nomor_kontak_darurat = models.CharField(max_length=15)
    hubungan_kontak_darurat = models.CharField(max_length=20)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')
    
    # Photo fields
    foto_ktp = models.TextField(blank=True, null=True)
    foto_sim = models.TextField(blank=True, null=True)
    foto_profil = models.TextField(blank=True, null=True)
    foto_sertifikat = models.TextField(blank=True, null=True)
    foto_bpjs = models.TextField(blank=True, null=True)
    
    # Bank account fields
    nama_bank = models.CharField(max_length=50, blank=True, null=True)
    nomor_rekening = models.CharField(max_length=30, blank=True, null=True)
    
    # Rejection reason
    alasan_penolakan = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.nama} - {self.no_sim}"
    
    def get_average_rating(self):
        """Calculate average rating for this driver"""
        ratings = RatingDriver.objects.filter(id_driver=self)
        if ratings.exists():
            total_rating = sum(r.rating for r in ratings)
            return round(total_rating / ratings.count(), 1)
        return 0.0
    
    def get_total_trips(self):
        """Get total completed trips for this driver"""
        return DeliveryOrder.objects.filter(
            id_driver=self, 
            status__in=['completed', 'delivered', 'selesai']
        ).count()
    
    def get_experience_years(self):
        """Calculate experience in years since registration"""
        from datetime import datetime
        years = (datetime.now().date() - self.wkt_daftar.date()).days / 365.25
        return max(0, round(years, 1))

class DriverAttachment(models.Model):
    FILE_TYPE_CHOICES = [
        ('sim', 'SIM'),
        ('ktp', 'KTP'),
        ('bpjs', 'BPJS'),
        ('foto', 'Foto'),
    ]
    
    id_attachment = models.AutoField(primary_key=True)
    id_driver = models.ForeignKey(Driver, on_delete=models.CASCADE)
    file_type = models.CharField(max_length=10, choices=FILE_TYPE_CHOICES)
    file_dok = models.TextField()
    upload_time = models.DateTimeField(auto_now_add=True)

class Armada(models.Model):
    id_armada = models.AutoField(primary_key=True)
    nomor_polisi = models.CharField(max_length=15)
    jenis_armada = models.CharField(max_length=50)
    kapasitas_muatan = models.IntegerField()
    status = models.BooleanField(default=True)
    warna_armada = models.CharField(max_length=20)
    id_stnk = models.CharField(max_length=30)
    tahun_pembuatan = models.DateTimeField()
    id_bpkb = models.CharField(max_length=30)
    
    # Photo fields for vehicle documents
    foto_stnk = models.TextField(blank=True, null=True)  # Base64 image
    foto_bpkb = models.TextField(blank=True, null=True)  # Base64 image

    def __str__(self):
        return f"{self.nomor_polisi} - {self.jenis_armada}"

class Produk(models.Model):
    ID_Produk = models.AutoField(primary_key=True)
    Nama_Produk = models.CharField(max_length=100)
    Deskripsi = models.TextField()
    Kategori = models.CharField(max_length=50)
    Satuan = models.CharField(max_length=20)
    Barcode_Produk = models.CharField(max_length=50)
    Status = models.CharField(max_length=20)

    def __str__(self):
        return self.Nama_Produk

class Pelanggan(models.Model):
    id_pelanggan = models.AutoField(primary_key=True)
    nama = models.CharField(max_length=100)
    no_hp = models.CharField(max_length=15)
    email = models.EmailField()
    alamat = models.CharField(max_length=255)

    def __str__(self):
        return self.nama

class SalesOrder(models.Model):
    id_sales_order = models.AutoField(primary_key=True)
    id_pelanggan = models.ForeignKey(Pelanggan, on_delete=models.CASCADE)
    tanggal_order = models.DateTimeField()
    total_harga_order = models.DecimalField(max_digits=12, decimal_places=2)
    alamat_pengiriman = models.TextField()
    status = models.CharField(max_length=20)

    def __str__(self):
        return f"SO-{self.id_sales_order}"

class DeliveryOrder(models.Model):
    id_delivery_order = models.AutoField(primary_key=True)
    id_sales_order = models.ForeignKey(SalesOrder, on_delete=models.CASCADE)
    id_armada = models.ForeignKey(Armada, on_delete=models.CASCADE)
    id_driver = models.ForeignKey(Driver, on_delete=models.CASCADE)
    tanggal_kirim = models.DateTimeField()
    gps_log = models.JSONField()
    status = models.CharField(max_length=20)

    def __str__(self):
        return f"DO-{self.id_delivery_order}"

class Notifikasi(models.Model):
    id_notifikasi = models.AutoField(primary_key=True)
    id_driver = models.ForeignKey(Driver, on_delete=models.CASCADE)
    jenis_notifikasi = models.CharField(max_length=50)
    isi_pesan = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

class LaporanDarurat(models.Model):
    id_laporan = models.AutoField(primary_key=True)
    id_driver = models.ForeignKey(Driver, on_delete=models.CASCADE)
    jenis_insiden = models.CharField(max_length=50)
    isi_laporan = models.TextField()
    lokasi = models.CharField(max_length=255)
    timestamp = models.DateTimeField(auto_now_add=True)

class LogChat(models.Model):
    id_chat = models.AutoField(primary_key=True)
    id_pengirim = models.ForeignKey(Driver, on_delete=models.CASCADE, related_name='chat_sent')
    id_penerima = models.ForeignKey(Pelanggan, on_delete=models.CASCADE)
    timestamp = models.DateTimeField(auto_now_add=True)
    isi_pesan = models.TextField()

class LogAttachmentChat(models.Model):
    id_attach_chat = models.AutoField(primary_key=True)
    id_chat = models.ForeignKey(LogChat, on_delete=models.CASCADE)
    tipe_file = models.CharField(max_length=20)
    ukuran_file = models.IntegerField()
    file = models.TextField()

class LogPanggilan(models.Model):
    id_panggilan = models.AutoField(primary_key=True)
    id_pengirim = models.ForeignKey(Driver, on_delete=models.CASCADE, related_name='call_made')
    id_penerima = models.ForeignKey(Pelanggan, on_delete=models.CASCADE)
    timestamp = models.DateTimeField(auto_now_add=True)
    rekaman_panggilan = models.CharField(max_length=255)
    durasi_panggilan = models.IntegerField()

class Bank(models.Model):
    id_bank = models.AutoField(primary_key=True)
    nama_bank = models.CharField(max_length=50)

    def __str__(self):
        return self.nama_bank

class RekeningDriver(models.Model):
    id_rekening = models.AutoField(primary_key=True)
    id_driver = models.ForeignKey(Driver, on_delete=models.CASCADE)
    id_bank = models.ForeignKey(Bank, on_delete=models.CASCADE)
    nomor_rekening = models.CharField(max_length=20)
    status = models.BooleanField(default=True)

class PembayaranFee(models.Model):
    METODE_CHOICES = [
        ('cash', 'Cash'),
        ('transfer', 'Transfer'),
        ('ewallet', 'E-Wallet'),
    ]
    
    id_pembayaran = models.AutoField(primary_key=True)
    id_delivery_order = models.ForeignKey(DeliveryOrder, on_delete=models.CASCADE)
    id_rekening = models.ForeignKey(RekeningDriver, on_delete=models.CASCADE)
    metode_pembayaran = models.CharField(max_length=20, choices=METODE_CHOICES)
    jumlah = models.DecimalField(max_digits=10, decimal_places=2)
    tanggal = models.DateTimeField()

class RatingDriver(models.Model):
    id_rating = models.AutoField(primary_key=True)
    id_driver = models.ForeignKey(Driver, on_delete=models.CASCADE)
    id_pelanggan = models.ForeignKey(Pelanggan, on_delete=models.CASCADE)
    rating = models.IntegerField()
    ulasan = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

class RiwayatPerjalanan(models.Model):
    id_perjalanan = models.AutoField(primary_key=True)
    id_delivery_order = models.ForeignKey(DeliveryOrder, on_delete=models.CASCADE)
    rute = models.TextField()
    tanggal = models.DateTimeField()
    jarak_tempuh_km = models.DecimalField(max_digits=6, decimal_places=2)
    durasi_perjalanan = models.IntegerField()

class LogIstirahatDriver(models.Model):
    id_rest_log = models.AutoField(primary_key=True)
    id_delivery_order = models.ForeignKey(DeliveryOrder, on_delete=models.CASCADE)
    start_rest_time = models.DateTimeField()
    end_rest_time = models.DateTimeField()
    durasi_istirahat = models.IntegerField()
    lokasi = models.JSONField()

class AuditTrail(models.Model):
    ACTION_CHOICES = [
        ('create', 'Create'),
        ('update', 'Update'),
        ('delete', 'Delete'),
    ]
    
    id_audit = models.AutoField(primary_key=True)
    nama_tabel = models.CharField(max_length=50)
    id_record = models.IntegerField()
    action = models.CharField(max_length=10, choices=ACTION_CHOICES)
    changed_by = models.CharField(max_length=50)
    changed_at = models.DateTimeField(auto_now_add=True)
    old_value = models.TextField()
    new_value = models.TextField()

# Junction Tables
class DriverArmada(models.Model):
    id = models.AutoField(primary_key=True)
    id_driver = models.ForeignKey(Driver, on_delete=models.CASCADE)
    id_armada = models.ForeignKey(Armada, on_delete=models.CASCADE)
    tanggal_mulai = models.DateTimeField()
    tanggal_selesai = models.DateTimeField()

    class Meta:
        unique_together = ('id_driver', 'id_armada')

class SalesorderProduk(models.Model):
    id_sales_order = models.ForeignKey(SalesOrder, on_delete=models.CASCADE)
    id_produk = models.ForeignKey(Produk, on_delete=models.CASCADE)
    jumlah = models.IntegerField()
    satuan = models.CharField(max_length=20)
    harga_satuan = models.DecimalField(max_digits=10, decimal_places=2)
    subtotal_harga = models.DecimalField(max_digits=12, decimal_places=2)

    class Meta:
        unique_together = ('id_sales_order', 'id_produk')

class DeliveryorderSalesorder(models.Model):
    id_delivery_order = models.ForeignKey(DeliveryOrder, on_delete=models.CASCADE)
    id_sales_order = models.ForeignKey(SalesOrder, on_delete=models.CASCADE)
    id_produk = models.ForeignKey(Produk, on_delete=models.CASCADE)
    jumlah_produk_terkirim = models.IntegerField()
    status_pengiriman = models.CharField(max_length=20)
    tanggal_pengiriman = models.DateTimeField()

    class Meta:
        unique_together = ('id_delivery_order', 'id_sales_order', 'id_produk')

class DriverDeliveryorder(models.Model):
    id_driver = models.ForeignKey(Driver, on_delete=models.CASCADE)
    id_delivery_order = models.ForeignKey(DeliveryOrder, on_delete=models.CASCADE)
    tanggal_assign = models.DateTimeField()
    status_tugas = models.CharField(max_length=20)

    class Meta:
        unique_together = ('id_driver', 'id_delivery_order')

class ArmadaDeliveryorder(models.Model):
    id_delivery_order = models.ForeignKey(DeliveryOrder, on_delete=models.CASCADE)
    id_armada = models.ForeignKey(Armada, on_delete=models.CASCADE)
    tanggal_pakai = models.DateTimeField()
    kapasitas_digunakan = models.DecimalField(max_digits=10, decimal_places=2)

    class Meta:
        unique_together = ('id_delivery_order', 'id_armada')

# Keep old models for compatibility
class Vehicle(models.Model):
    VEHICLE_TYPES = [
        ('car', 'Car'),
        ('truck', 'Truck'),
        ('motorcycle', 'Motorcycle'),
    ]
    
    driver = models.ForeignKey(Driver, on_delete=models.CASCADE, related_name='vehicles')
    plate_number = models.CharField(max_length=20, unique=True)
    vehicle_type = models.CharField(max_length=20, choices=VEHICLE_TYPES)
    model = models.CharField(max_length=50)
    year = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.plate_number} - {self.model}"

# Training Content Models
class TrainingModule(models.Model):
    LEVEL_CHOICES = [
        ('pemula', 'Pemula'),
        ('lanjutan', 'Lanjutan'),
        ('expert', 'Expert'),
    ]
    
    LEVEL_ORDER = {
        'pemula': 1,
        'lanjutan': 2,
        'expert': 3,
    }
    
    title = models.CharField(max_length=200)
    description = models.TextField()
    level = models.CharField(max_length=20, choices=LEVEL_CHOICES)
    instructor = models.CharField(max_length=100)
    thumbnail = models.TextField(blank=True, null=True)  # Base64 image
    is_active = models.BooleanField(default=True)
    order = models.IntegerField(default=1)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['created_at']
    
    def __str__(self):
        return self.title

class TrainingContent(models.Model):
    CONTENT_TYPES = [
        ('narration', 'Narasi'),
        ('image', 'Gambar'),
        ('video', 'Video'),
        ('infographic', 'Infografis'),
    ]
    
    module = models.ForeignKey(TrainingModule, on_delete=models.CASCADE, related_name='contents')
    title = models.CharField(max_length=200)
    content_type = models.CharField(max_length=20, choices=CONTENT_TYPES)
    text_content = models.TextField(blank=True, null=True)
    media_content = models.TextField(blank=True, null=True)  # Base64, URL, or YouTube URL
    media_file = models.FileField(upload_to='training_media/', blank=True, null=True)  # File upload
    youtube_url = models.URLField(blank=True, null=True)  # YouTube URL
    points = models.IntegerField(default=10)  # Points for completing this content
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['created_at']  # FIFO ordering
    
    def __str__(self):
        return f"{self.module.title} - {self.title}"

class TrainingQuiz(models.Model):
    module = models.ForeignKey(TrainingModule, on_delete=models.CASCADE, related_name='quizzes')
    question = models.TextField()
    option_a = models.CharField(max_length=500)
    option_b = models.CharField(max_length=500)
    option_c = models.CharField(max_length=500)
    option_d = models.CharField(max_length=500)
    correct_answer = models.CharField(max_length=1, choices=[('A', 'A'), ('B', 'B'), ('C', 'C'), ('D', 'D')])
    explanation = models.TextField(blank=True, null=True)
    points = models.IntegerField(default=20)  # Points for correct answer
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['created_at']  # FIFO ordering
    
    def __str__(self):
        return f"{self.module.title} - Quiz"

class DriverTrainingProgress(models.Model):
    driver = models.ForeignKey(Driver, on_delete=models.CASCADE)
    module = models.ForeignKey(TrainingModule, on_delete=models.CASCADE)
    completed_contents = models.JSONField(default=list)  # List of content IDs
    quiz_answers = models.JSONField(default=dict)  # Quiz answers with points
    current_points = models.IntegerField(default=0)
    total_points = models.IntegerField(default=0)
    is_completed = models.BooleanField(default=False)
    completed_at = models.DateTimeField(null=True, blank=True)
    started_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ('driver', 'module')
    
    def __str__(self):
        return f"{self.driver.nama} - {self.module.title}"
    
    def calculate_total_points(self):
        content_points = sum([content.points for content in self.module.contents.all()])
        quiz_points = sum([quiz.points for quiz in self.module.quizzes.all()])
        return content_points + quiz_points
    
    def get_progress_percentage(self):
        if self.total_points == 0:
            return 0
        return int((self.current_points / self.total_points) * 100)

# New Order Model for Real-time Notifications
class Order(models.Model):
    STATUS_CHOICES = [
        ('menunggu_konfirmasi', 'Menunggu Konfirmasi Penjual'),
        ('menunggu_driver', 'Menunggu Driver'),
        ('sedang_dikirim', 'Sedang Dikirim'),
        ('selesai', 'Selesai'),
        ('dibatalkan', 'Dibatalkan'),
    ]
    
    order_id = models.CharField(max_length=50, unique=True, primary_key=True)
    barang = models.CharField(max_length=100)
    pickup = models.CharField(max_length=255)
    tujuan = models.CharField(max_length=255)
    kota = models.CharField(max_length=50)
    ongkos = models.IntegerField(default=20000)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='menunggu_konfirmasi')
    driver = models.ForeignKey(Driver, on_delete=models.SET_NULL, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Order {self.order_id} - {self.barang}"