from django.contrib import admin
from django.contrib import messages
from django.utils.html import format_html
from .models import *

@admin.register(Driver)
class DriverAdmin(admin.ModelAdmin):
    list_display = ['nama', 'email', 'no_hp', 'status', 'wkt_daftar', 'has_photos']
    list_filter = ['status', 'wkt_daftar']
    search_fields = ['nama', 'no_sim', 'jenis_sim', 'no_bpjs', 'no_sertifikat', 'email']
    actions = ['activate_drivers', 'suspend_drivers', 'accept_drivers']
    readonly_fields = ['wkt_daftar', 'foto_ktp_preview', 'foto_sim_preview', 'foto_profil_preview', 'foto_sertifikat_preview', 'foto_bpjs_preview']
    
    def has_photos(self, obj):
        photos = [obj.foto_ktp, obj.foto_sim, obj.foto_profil, obj.foto_sertifikat, obj.foto_bpjs]
        count = sum(1 for photo in photos if photo and photo.strip())
        return f"{count}/5 photos"
    has_photos.short_description = 'Photos'
    
    def foto_ktp_preview(self, obj):
        if obj.foto_ktp and obj.foto_ktp.startswith('data:image'):
            return format_html('<img src="{}" style="max-width: 200px; max-height: 200px;" />', obj.foto_ktp)
        elif obj.foto_ktp:
            return format_html('<img src="data:image/jpeg;base64,{}" style="max-width: 200px; max-height: 200px;" />', obj.foto_ktp)
        return "No photo"
    foto_ktp_preview.short_description = 'KTP Preview'
    
    def foto_sim_preview(self, obj):
        if obj.foto_sim and obj.foto_sim.startswith('data:image'):
            return format_html('<img src="{}" style="max-width: 200px; max-height: 200px;" />', obj.foto_sim)
        elif obj.foto_sim:
            return format_html('<img src="data:image/jpeg;base64,{}" style="max-width: 200px; max-height: 200px;" />', obj.foto_sim)
        return "No photo"
    foto_sim_preview.short_description = 'SIM Preview'
    
    def foto_profil_preview(self, obj):
        if obj.foto_profil and obj.foto_profil.startswith('data:image'):
            return format_html('<img src="{}" style="max-width: 200px; max-height: 200px;" />', obj.foto_profil)
        elif obj.foto_profil:
            return format_html('<img src="data:image/jpeg;base64,{}" style="max-width: 200px; max-height: 200px;" />', obj.foto_profil)
        return "No photo"
    foto_profil_preview.short_description = 'Profile Photo Preview'
    
    def foto_sertifikat_preview(self, obj):
        if obj.foto_sertifikat and obj.foto_sertifikat.startswith('data:image'):
            return format_html('<img src="{}" style="max-width: 200px; max-height: 200px;" />', obj.foto_sertifikat)
        elif obj.foto_sertifikat:
            return format_html('<img src="data:image/jpeg;base64,{}" style="max-width: 200px; max-height: 200px;" />', obj.foto_sertifikat)
        return "No photo"
    foto_sertifikat_preview.short_description = 'Certificate Preview'
    
    def foto_bpjs_preview(self, obj):
        if obj.foto_bpjs and obj.foto_bpjs.startswith('data:image'):
            return format_html('<img src="{}" style="max-width: 200px; max-height: 200px;" />', obj.foto_bpjs)
        elif obj.foto_bpjs:
            return format_html('<img src="data:image/jpeg;base64,{}" style="max-width: 200px; max-height: 200px;" />', obj.foto_bpjs)
        return "No photo"
    foto_bpjs_preview.short_description = 'BPJS Preview'
    
    fieldsets = (
        ('Informasi Dasar', {
            'fields': ('nama', 'email', 'no_hp', 'alamat', 'status')
        }),
        ('Dokumen Identitas', {
            'fields': ('nik', 'ttl', 'no_sim', 'jenis_sim', 'tanggal_kedaluarsa_sim')
        }),
        ('BPJS & Sertifikat', {
            'fields': ('no_bpjs', 'tanggal_kedaluarsa_bpjs', 'no_sertifikat', 'tanggal_kedaluarsa_sertifikat')
        }),
        ('Kontak Darurat', {
            'fields': ('nama_kontak_darurat', 'nomor_kontak_darurat', 'hubungan_kontak_darurat')
        }),
        ('Bank', {
            'fields': ('nama_bank', 'nomor_rekening')
        }),
        ('Foto Dokumen', {
            'fields': ('foto_ktp_preview', 'foto_sim_preview', 'foto_profil_preview', 'foto_sertifikat_preview', 'foto_bpjs_preview')
        }),
        ('Sistem', {
            'fields': ('wkt_daftar', 'alasan_penolakan'),
            'classes': ('collapse',)
        })
    )
    
    def activate_drivers(self, request, queryset):
        updated = queryset.update(status='active')
        self.message_user(request, f'{updated} driver(s) berhasil diaktifkan.')
    activate_drivers.short_description = "Aktifkan driver yang dipilih"
    
    def suspend_drivers(self, request, queryset):
        updated = queryset.update(status='suspended')
        self.message_user(request, f'{updated} driver(s) berhasil disuspend.')
    suspend_drivers.short_description = "Suspend driver yang dipilih"
    
    def accept_drivers(self, request, queryset):
        updated = queryset.filter(status='pending').update(status='active')
        self.message_user(request, f'{updated} driver(s) berhasil diterima dan diaktifkan.')
    accept_drivers.short_description = "Terima dan aktifkan driver pending"

@admin.register(DriverAttachment)
class DriverAttachmentAdmin(admin.ModelAdmin):
    list_display = ['id_driver', 'file_type', 'upload_time']
    list_filter = ['file_type', 'upload_time']

@admin.register(Armada)
class ArmadaAdmin(admin.ModelAdmin):
    list_display = ['nomor_polisi', 'jenis_armada', 'kapasitas_muatan', 'status']
    list_filter = ['status', 'jenis_armada']
    search_fields = ['nomor_polisi', 'id_stnk']

@admin.register(Produk)
class ProdukAdmin(admin.ModelAdmin):
    list_display = ['Nama_Produk', 'Kategori', 'Status']
    list_filter = ['Kategori', 'Status']
    search_fields = ['Nama_Produk', 'Barcode_Produk']

@admin.register(Pelanggan)
class PelangganAdmin(admin.ModelAdmin):
    list_display = ['nama', 'no_hp', 'email']
    search_fields = ['nama', 'email']

@admin.register(SalesOrder)
class SalesOrderAdmin(admin.ModelAdmin):
    list_display = ['id_sales_order', 'id_pelanggan', 'tanggal_order', 'total_harga_order', 'status']
    list_filter = ['status', 'tanggal_order']

@admin.register(DeliveryOrder)
class DeliveryOrderAdmin(admin.ModelAdmin):
    list_display = ['id_delivery_order', 'id_driver', 'id_armada', 'tanggal_kirim', 'status']
    list_filter = ['status', 'tanggal_kirim']

@admin.register(Notifikasi)
class NotifikasiAdmin(admin.ModelAdmin):
    list_display = ['id_driver', 'jenis_notifikasi', 'timestamp']
    list_filter = ['jenis_notifikasi', 'timestamp']

@admin.register(LaporanDarurat)
class LaporanDaruratAdmin(admin.ModelAdmin):
    list_display = ['id_driver', 'jenis_insiden', 'timestamp']
    list_filter = ['jenis_insiden', 'timestamp']

@admin.register(Bank)
class BankAdmin(admin.ModelAdmin):
    list_display = ['nama_bank']

@admin.register(RekeningDriver)
class RekeningDriverAdmin(admin.ModelAdmin):
    list_display = ['id_driver', 'id_bank', 'nomor_rekening', 'status']
    list_filter = ['status']

@admin.register(PembayaranFee)
class PembayaranFeeAdmin(admin.ModelAdmin):
    list_display = ['id_delivery_order', 'metode_pembayaran', 'jumlah', 'tanggal']
    list_filter = ['metode_pembayaran', 'tanggal']

@admin.register(RatingDriver)
class RatingDriverAdmin(admin.ModelAdmin):
    list_display = ['id_driver', 'id_pelanggan', 'rating', 'timestamp']
    list_filter = ['rating', 'timestamp']

@admin.register(RiwayatPerjalanan)
class RiwayatPerjalananAdmin(admin.ModelAdmin):
    list_display = ['id_delivery_order', 'tanggal', 'jarak_tempuh_km']
    list_filter = ['tanggal']

@admin.register(Vehicle)
class VehicleAdmin(admin.ModelAdmin):
    list_display = ['plate_number', 'driver', 'vehicle_type', 'model', 'year']
    list_filter = ['vehicle_type', 'year']
    search_fields = ['plate_number', 'model']

# Training Content Admin
class TrainingContentInline(admin.TabularInline):
    model = TrainingContent
    extra = 1
    fields = ['title', 'content_type', 'text_content', 'youtube_url', 'media_file', 'points']

class TrainingQuizInline(admin.TabularInline):
    model = TrainingQuiz
    extra = 1
    fields = ['question', 'option_a', 'option_b', 'option_c', 'option_d', 'correct_answer', 'points']

@admin.register(TrainingModule)
class TrainingModuleAdmin(admin.ModelAdmin):
    list_display = ['title', 'level', 'instructor', 'is_active', 'created_at']
    list_filter = ['level', 'is_active', 'created_at']
    search_fields = ['title', 'instructor']
    inlines = [TrainingContentInline, TrainingQuizInline]
    list_editable = ['is_active']

@admin.register(TrainingContent)
class TrainingContentAdmin(admin.ModelAdmin):
    list_display = ['module', 'title', 'content_type', 'points', 'created_at']
    list_filter = ['content_type', 'module', 'created_at']
    search_fields = ['title', 'module__title']
    list_editable = ['points']
    readonly_fields = ['created_at']
    fieldsets = [
        ('Basic Information', {
            'fields': ['module', 'title', 'content_type', 'text_content', 'points']
        }),
        ('Media Content', {
            'fields': ['youtube_url', 'media_file', 'media_content'],
            'description': 'Use YouTube URL for videos, upload files for images/videos, or paste Base64/URL in media_content field'
        }),
        ('Timestamps', {
            'fields': ['created_at'],
            'classes': ['collapse']
        })
    ]

@admin.register(TrainingQuiz)
class TrainingQuizAdmin(admin.ModelAdmin):
    list_display = ['module', 'question', 'correct_answer', 'points', 'created_at']
    list_filter = ['module', 'correct_answer', 'created_at']
    search_fields = ['question', 'module__title']
    list_editable = ['points']
    readonly_fields = ['created_at']

@admin.register(DriverTrainingProgress)
class DriverTrainingProgressAdmin(admin.ModelAdmin):
    list_display = ['driver', 'module', 'current_points', 'total_points', 'get_progress_percentage', 'is_completed', 'completed_at']
    list_filter = ['is_completed', 'module', 'completed_at']
    search_fields = ['driver__nama', 'module__title']
    readonly_fields = ['started_at', 'completed_at', 'get_progress_percentage']