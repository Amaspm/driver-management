# Driver Management System - Complete Guide

## Project Structure

```
driver_manajement_project/
├── backend/                 # Django REST API
├── frontend/               # Flutter mobile app  
├── admin-panel/            # React admin panel
├── web-frontend/           # React web frontend
└── docker-compose.yml      # Docker orchestration
```

## Quick Start

### 1. Start All Services
```bash
docker-compose up -d
```

### 2. Setup Database
```bash
docker-compose exec backend python manage.py makemigrations
docker-compose exec backend python manage.py migrate
docker-compose exec backend python manage.py createsuperuser
```

### 3. Setup Training Data
```bash
./setup_training.sh
```

### 4. Mobile App Setup

#### Option A: USB Connection
```bash
./quick_connect.sh
cd frontend && flutter run
```

#### Option B: Wireless Connection
```bash
# Initial setup (USB required)
./setup_wireless.sh

# Then disconnect USB and run wirelessly
cd frontend && ./run_wireless.sh
```

#### Option C: Auto IP Update
```bash
./update_flutter_ip_auto.sh
cd frontend && flutter run
```

## Access Points

- **Mobile App**: Flutter app on device
- **Admin Panel**: http://localhost:3000
- **Web Frontend**: http://localhost:3000  
- **Backend API**: http://localhost:8001/api/
- **Django Admin**: http://localhost:8001/admin/
- **Database**: localhost:5432
- **PgAdmin**: http://localhost:5050

## Key Features

### Mobile App (Flutter)
- ✅ Driver registration with document upload
- ✅ Training system with modules and quizzes
- ✅ Dashboard with bottom navigation
- ✅ Trip history and vehicle management
- ✅ Profile management with logout

### Backend (Django)
- ✅ REST API with authentication
- ✅ Driver management system
- ✅ Training module system
- ✅ Document upload handling
- ✅ Status management (pending, active, rejected)

### Admin Panel (React)
- ✅ Driver management interface
- ✅ Training content management
- ✅ Document review and approval
- ✅ Fleet management

## Development

### Backend Development
```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python manage.py runserver
```

### Mobile Development
```bash
cd frontend
flutter pub get
flutter run
```

### Admin Panel Development
```bash
cd admin-panel
npm install
npm start
```

## Connection Scripts

### Root Level Scripts
- `quick_connect.sh` - Quick USB setup with backend start
- `setup_wireless.sh` - Setup wireless ADB connection
- `update_flutter_ip_auto.sh` - Auto-detect and update server IP
- `update_flutter_ip.sh <IP>` - Manually set server IP

### Frontend Scripts
- `frontend/quick_connect.sh` - USB connection with port forwarding
- `frontend/setup_wireless.sh` - Enable wireless ADB
- `frontend/reconnect_wireless.sh` - Reconnect wireless device
- `frontend/run_wireless.sh` - Run app on wireless device
- `frontend/run_android.sh` - Auto-detect USB/wireless and run
- `frontend/run_web.sh` - Run Flutter web version

## Troubleshooting

### Mobile Connection Issues
1. **USB Connection**: `./quick_connect.sh`
2. **Wireless Connection**: `./setup_wireless.sh`
3. **IP Changed**: `./update_flutter_ip_auto.sh`
4. **Manual IP**: `./update_flutter_ip.sh <YOUR_IP>`
5. Ensure phone and server on same network
6. Check firewall settings

### Docker Issues
```bash
docker-compose down
docker-compose up --build
```

### Database Issues
```bash
docker-compose exec backend python manage.py migrate
```

## API Endpoints

- `POST /api/drivers/login/` - Driver login
- `GET /api/drivers/status/` - Check driver status
- `GET /api/training-modules/` - Get training modules
- `POST /api/drivers/` - Create new driver
- `PUT /api/drivers/{id}/` - Update driver

## Environment Variables

Create `.env` files in backend/ and admin-panel/ directories:

### Backend .env
```
DEBUG=True
SECRET_KEY=your-secret-key
DB_NAME=driver_management
DB_USER=postgres
DB_PASSWORD=postgres123
DB_HOST=db
DB_PORT=5432
```

### Admin Panel .env
```
REACT_APP_API_URL=http://localhost:8001/api
```