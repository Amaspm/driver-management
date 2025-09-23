# Driver Management System

Sistem manajemen driver dengan Django backend, Flutter mobile app, dan React admin panel.

## Quick Start

```bash
# Start all services
docker-compose up -d

# Setup database
docker-compose exec backend python manage.py migrate
docker-compose exec backend python manage.py createsuperuser

# Setup training data
./setup_training.sh

# Setup mobile connection
./update_flutter_ip_auto.sh

# Run Flutter app
cd frontend && flutter run
```

## Access Points

- **Mobile App**: Flutter app on device
- **Admin Panel**: http://localhost:3000
- **Backend API**: http://localhost:8001/api/
- **Django Admin**: http://localhost:8001/admin/
- **PgAdmin**: http://localhost:5050

## Documentation

See [PROJECT_GUIDE.md](PROJECT_GUIDE.md) for complete documentation.

## Project Structure

```
driver_manajement_project/
├── backend/                 # Django REST API
├── frontend/               # Flutter mobile app
├── admin-panel/            # React admin panel
├── web-frontend/           # React web frontend
└── docker-compose.yml      # Docker orchestration
```