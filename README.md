# Driver Management System

[![CI/CD Pipeline](https://github.com/Amaspm/driver-management/actions/workflows/ci.yml/badge.svg)](https://github.com/Amaspm/driver-management/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Sistem manajemen driver dengan Django backend, Flutter mobile app, dan React admin panel untuk mengelola order dan driver secara real-time.

## 🚀 Quick Start

### Automated Setup (Recommended)

```bash
# Clone repository
git clone git@github.com:Amaspm/driver-management.git
cd driver-management

# Run automated setup
./setup_project.sh
```

### Manual Setup

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

## 🌐 Access Points

- **📱 Mobile App**: Flutter app on device
- **🖥️ Admin Panel**: http://localhost:3000
- **🔧 Backend API**: http://localhost:8001/api/
- **⚙️ Django Admin**: http://localhost:8001/admin/
- **🗄️ PgAdmin**: http://localhost:5050

## 📋 Features

### 🚚 Driver Management
- Real-time driver tracking
- Driver status management (online/offline)
- Vehicle assignment
- Performance analytics

### 📦 Order Management
- Order creation and tracking
- Real-time order assignment to drivers
- Status updates (pending, in progress, completed)
- Order history and analytics

### 🔄 Real-time Communication
- Kafka-based messaging system
- WebSocket connections for live updates
- Push notifications
- Real-time order-driver matching

### 📊 Analytics & Reporting
- Driver performance metrics
- Order completion rates
- Revenue tracking
- Custom reports

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │  React Admin    │    │  React Web      │
│   (Mobile)      │    │    Panel        │    │   Frontend      │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────┴───────────┐
                    │    Django REST API      │
                    │      (Backend)          │
                    └─────────┬───────────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
    ┌─────────┴───────┐ ┌─────┴─────┐ ┌───────┴───────┐
    │   PostgreSQL    │ │   Kafka   │ │ Golang Service│
    │   Database      │ │ Message   │ │ (Real-time)   │
    └─────────────────┘ │  Broker   │ └───────────────┘
                        └───────────┘
```

## 🛠️ Technology Stack

### Backend
- **Django REST Framework** - API development
- **PostgreSQL** - Primary database
- **Kafka** - Message broker for real-time events
- **Docker** - Containerization

### Frontend
- **Flutter** - Cross-platform mobile app
- **React** - Web admin panel and frontend
- **WebSocket** - Real-time communication

### DevOps
- **Docker Compose** - Local development
- **GitHub Actions** - CI/CD pipeline
- **Nginx** - Reverse proxy (production)

## 📁 Project Structure

```
driver_manajement_project/
├── 📱 frontend/                 # Flutter mobile app
│   ├── lib/
│   │   ├── models/             # Data models
│   │   ├── services/           # API services
│   │   ├── screens/            # UI screens
│   │   └── widgets/            # Reusable widgets
│   └── pubspec.yaml
├── 🖥️ admin-panel/             # React admin panel
│   ├── src/
│   │   ├── components/         # React components
│   │   ├── pages/              # Page components
│   │   └── services/           # API services
│   └── package.json
├── 🌐 web-frontend/            # React web frontend
├── 🔧 backend/                 # Django REST API
│   ├── apps/
│   │   ├── drivers/            # Driver management
│   │   ├── orders/             # Order management
│   │   └── notifications/      # Real-time notifications
│   ├── config/                 # Django settings
│   └── requirements.txt
├── 🚀 driver-service/          # Golang microservice
├── 🐳 docker-compose.yml       # Docker orchestration
├── 📋 setup_project.sh         # Automated setup script
└── 📖 DEVELOPMENT.md           # Development guide
```

## 🔄 Real-time Flow

1. **User Checkout** → Order created with status "MENUNGGU KONFIRMASI PENJUAL"
2. **Seller Confirmation** → Status updated to "MENUNGGU DRIVER", event published to Kafka
3. **Driver Matching** → Golang service finds online drivers and sends notifications
4. **Driver Response** → Driver accepts/rejects order, status updated in real-time
5. **Status Updates** → All parties receive live updates via WebSocket

## 📚 Documentation

- [📖 Development Guide](DEVELOPMENT.md) - Comprehensive development workflow
- [📋 Project Guide](PROJECT_GUIDE.md) - Detailed project documentation
- [🔧 API Documentation](http://localhost:8001/api/docs/) - Interactive API docs

## 🧪 Testing

```bash
# Backend tests
docker-compose exec backend python manage.py test

# Frontend tests
cd frontend && flutter test

# Admin panel tests
cd admin-panel && npm test

# Integration tests
cd frontend && flutter drive --target=test_driver/app.dart
```

## 🚀 Deployment

### Development
```bash
docker-compose up -d
```

### Production
```bash
docker-compose -f docker-compose.prod.yml up -d
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Backend Development** - Django REST API, Database Design
- **Mobile Development** - Flutter App, Real-time Features
- **Frontend Development** - React Admin Panel, Web Interface
- **DevOps** - Docker, CI/CD, Deployment

## 📞 Support

For support and questions:
- Create an [Issue](https://github.com/Amaspm/driver-management/issues)
- Check [Documentation](DEVELOPMENT.md)
- Review [Project Guide](PROJECT_GUIDE.md)