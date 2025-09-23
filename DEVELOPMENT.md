# Development Guide

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone git@github.com:Amaspm/driver-management.git
   cd driver-management
   ```

2. **Run the setup script:**
   ```bash
   ./setup_project.sh
   ```

3. **Start development:**
   ```bash
   docker-compose up -d
   ```

## Development Workflow

### Backend Development (Django)

```bash
# Access backend container
docker-compose exec backend bash

# Run migrations
docker-compose exec backend python manage.py migrate

# Create superuser
docker-compose exec backend python manage.py createsuperuser

# Collect static files
docker-compose exec backend python manage.py collectstatic

# Run tests
docker-compose exec backend python manage.py test
```

### Frontend Development (Flutter)

```bash
# Navigate to frontend directory
cd frontend

# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Build APK
flutter build apk

# Run tests
flutter test
```

### Admin Panel Development (React)

```bash
# Navigate to admin panel directory
cd admin-panel

# Install dependencies
npm install

# Start development server
npm start

# Build for production
npm run build

# Run tests
npm test
```

## Environment Configuration

### Backend Environment Variables

Create `.env` file in the backend directory:

```env
DEBUG=True
SECRET_KEY=your-secret-key
DATABASE_URL=postgresql://postgres:postgres123@db:5432/driver_management
KAFKA_BROKER=kafka:9092
```

### Flutter Configuration

Update `frontend/lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://YOUR_IP:8001/api/';
  static const String wsUrl = 'ws://YOUR_IP:8001/ws/';
}
```

## Database Management

### Backup Database

```bash
docker-compose exec db pg_dump -U postgres driver_management > backup.sql
```

### Restore Database

```bash
docker-compose exec -T db psql -U postgres driver_management < backup.sql
```

### Reset Database

```bash
docker-compose down
docker volume rm driver_manajement_project_postgres_data
docker-compose up -d db
docker-compose exec backend python manage.py migrate
```

## Kafka Management

### View Kafka Topics

```bash
docker-compose exec kafka kafka-topics --bootstrap-server localhost:9092 --list
```

### Create Topic

```bash
docker-compose exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic order_events --partitions 1 --replication-factor 1
```

### Consume Messages

```bash
docker-compose exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic order_events --from-beginning
```

## Testing

### Backend Tests

```bash
# Run all tests
docker-compose exec backend python manage.py test

# Run specific app tests
docker-compose exec backend python manage.py test apps.drivers

# Run with coverage
docker-compose exec backend coverage run --source='.' manage.py test
docker-compose exec backend coverage report
```

### Frontend Tests

```bash
cd frontend
flutter test
flutter test --coverage
```

### Integration Tests

```bash
# Run end-to-end tests
cd frontend
flutter drive --target=test_driver/app.dart
```

## Debugging

### Backend Debugging

1. Add breakpoints in your Python code
2. Run with debugger:
   ```bash
   docker-compose exec backend python -m pdb manage.py runserver 0.0.0.0:8000
   ```

### Flutter Debugging

1. Use Flutter Inspector in VS Code/Android Studio
2. Add debug prints:
   ```dart
   print('Debug: $variable');
   ```
3. Use Flutter DevTools

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f kafka
```

## Performance Monitoring

### Database Performance

```bash
# Monitor database connections
docker-compose exec db psql -U postgres -c "SELECT * FROM pg_stat_activity;"

# Check slow queries
docker-compose exec db psql -U postgres -c "SELECT query, mean_time, calls FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"
```

### API Performance

Use tools like:
- Postman for API testing
- Apache Bench for load testing
- Django Debug Toolbar for profiling

## Deployment

### Production Build

```bash
# Build all services
docker-compose -f docker-compose.prod.yml build

# Deploy
docker-compose -f docker-compose.prod.yml up -d
```

### Environment-specific Configurations

- **Development**: `docker-compose.yml`
- **Staging**: `docker-compose.staging.yml`
- **Production**: `docker-compose.prod.yml`

## Troubleshooting

### Common Issues

1. **Port conflicts**: Change ports in docker-compose.yml
2. **Permission issues**: Check file permissions and Docker user
3. **Database connection**: Ensure database is running and accessible
4. **Flutter build issues**: Clean and rebuild
   ```bash
   flutter clean
   flutter pub get
   flutter build apk
   ```

### Reset Everything

```bash
# Stop all services
docker-compose down

# Remove all containers and volumes
docker-compose down -v --remove-orphans

# Remove all images
docker-compose down --rmi all

# Start fresh
./setup_project.sh
```

## Contributing

1. Create feature branch: `git checkout -b feature/new-feature`
2. Make changes and test
3. Commit: `git commit -m "Add new feature"`
4. Push: `git push origin feature/new-feature`
5. Create Pull Request

## Code Style

### Python (Backend)
- Follow PEP 8
- Use Black for formatting
- Use flake8 for linting

### Dart (Flutter)
- Follow Dart style guide
- Use `dart format` for formatting
- Use `dart analyze` for linting

### JavaScript (React)
- Follow Airbnb style guide
- Use Prettier for formatting
- Use ESLint for linting