# Real-time Driver Management Setup

Dokumentasi untuk setup fitur online/offline driver secara realtime menggunakan Kafka dan Go service.

## Arsitektur

```
Flutter App (Driver) <--WebSocket--> Go Service <--Kafka--> Django Backend
                                         |
                                    Kafka Topics:
                                    - driver_status
                                    - order_request  
                                    - order_response
```

## Setup dan Menjalankan

### 1. Start All Services

```bash
# Start semua service dengan Kafka
docker-compose up -d

# Setup Kafka topics
./setup_kafka.sh

# Setup database (jika belum)
docker-compose exec backend python manage.py migrate
```

### 2. Integrasi Django Backend

Tambahkan ke `backend/urls.py`:

```python
from . import driver_api

urlpatterns = [
    # ... existing urls
    path('api/driver/online', driver_api.driver_online, name='driver_online'),
    path('api/driver/offline', driver_api.driver_offline, name='driver_offline'),
    path('api/order/confirmed', driver_api.order_confirmed, name='order_confirmed'),
]
```

Tambahkan ke `backend/settings.py`:

```python
DRIVER_SERVICE_URL = 'http://driver-service:8080'
```

### 3. Integrasi Flutter

Tambahkan dependencies ke `pubspec.yaml`:

```yaml
dependencies:
  web_socket_channel: ^2.4.0
  http: ^1.1.0
```

Copy file dari `flutter-integration/` ke project Flutter Anda.

## Flow Penggunaan

### 1. Driver Online/Offline

```dart
// Di Flutter app
final driverService = DriverService();

// Set online
await driverService.setDriverOnline("driver_001", "jakarta");

// Set offline  
await driverService.setDriverOffline("driver_001");
```

### 2. Order Flow

1. **Penjual konfirmasi order** → Django API call:
```bash
curl -X POST http://localhost:8001/api/order/confirmed \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": "order_123",
    "tujuan": "Jl. Sudirman",
    "kota": "jakarta"
  }'
```

2. **Go service** mencari driver online di kota yang sama
3. **Flutter app** menerima notifikasi via WebSocket
4. **Driver** bisa terima/abaikan order

### 3. Testing Manual

1. Buka Flutter app → set driver online
2. Buka `user-page/seller-home.html` → konfirmasi order
3. Driver akan menerima notifikasi realtime

## Kafka Topics

- **driver_status**: Status online/offline driver
- **order_request**: Order baru dari penjual
- **order_response**: Respon driver (terima/abaikan)

## Monitoring

- **Kafka UI**: http://localhost:9092 (jika ada)
- **Go Service**: http://localhost:8080
- **Django Backend**: http://localhost:8001
- **WebSocket**: ws://localhost:8080/ws?driver_id=xxx

## Troubleshooting

1. **Kafka tidak connect**: Pastikan Kafka service sudah running
2. **WebSocket error**: Check Go service logs
3. **Driver tidak dapat order**: Pastikan kota sama dan driver online

## Next Steps

1. Tambah GPS tracking
2. Implementasi push notifications
3. Add order history
4. Real-time location updates