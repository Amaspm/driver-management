#!/bin/bash

echo "=== Hotspot Mode Setup ==="
echo ""
echo "HP sebagai hotspot tidak mendukung wireless debugging."
echo "Pilihan solusi:"
echo ""
echo "1. USB Connection (Recommended)"
echo "2. Setup WiFi untuk wireless debugging"
echo ""
read -p "Pilih opsi (1 atau 2): " choice

if [ "$choice" = "1" ]; then
    echo ""
    echo "=== USB Connection Setup ==="
    echo "1. Sambungkan HP ke laptop dengan kabel USB"
    echo "2. Aktifkan USB Debugging di HP"
    echo "3. Tekan Enter ketika sudah siap..."
    read
    
    echo "Checking USB connection..."
    adb devices
    
    if adb devices | grep -q "device$"; then
        echo "✓ USB device found!"
        echo "Starting Flutter app..."
        flutter run
    else
        echo "✗ No USB device found"
        echo "Pastikan:"
        echo "- Kabel USB terhubung"
        echo "- USB Debugging aktif"
        echo "- Allow USB debugging di popup HP"
    fi
    
elif [ "$choice" = "2" ]; then
    echo ""
    echo "=== WiFi Setup untuk Wireless Debugging ==="
    echo ""
    echo "Langkah-langkah:"
    echo "1. Matikan hotspot di HP"
    echo "2. Hubungkan HP dan laptop ke WiFi yang sama"
    echo "3. Di HP: Settings > Developer Options > Wireless debugging"
    echo "4. Aktifkan Wireless debugging"
    echo "5. Catat IP address yang muncul"
    echo ""
    echo "Setelah setup WiFi, jalankan:"
    echo "  ./setup_wireless.sh"
    echo ""
    echo "Atau manual:"
    echo "  adb connect IP_HP:5555"
    echo "  flutter run"
    
else
    echo "Pilihan tidak valid"
fi