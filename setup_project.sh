#!/bin/bash

# Driver Management System - Project Setup Script
# This script sets up the entire development environment

set -e

echo "🚀 Setting up Driver Management System..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_success "Docker and Docker Compose are installed"
}

# Setup backend dependencies
setup_backend() {
    print_status "Setting up Django backend..."
    
    if [ ! -f "backend/requirements.txt" ]; then
        print_warning "Backend requirements.txt not found, skipping backend setup"
        return
    fi
    
    # Build backend container
    docker-compose build backend
    print_success "Backend container built successfully"
}

# Setup frontend dependencies
setup_frontend() {
    print_status "Setting up Flutter frontend..."
    
    if ! command -v flutter &> /dev/null; then
        print_warning "Flutter is not installed. Please install Flutter SDK first."
        print_warning "Visit: https://docs.flutter.dev/get-started/install"
        return
    fi
    
    cd frontend
    flutter pub get
    cd ..
    print_success "Flutter dependencies installed"
}

# Setup admin panel dependencies
setup_admin_panel() {
    print_status "Setting up React admin panel..."
    
    if ! command -v npm &> /dev/null; then
        print_warning "npm is not installed. Please install Node.js first."
        return
    fi
    
    if [ -d "admin-panel" ]; then
        cd admin-panel
        npm install
        cd ..
        print_success "Admin panel dependencies installed"
    fi
}

# Setup web frontend dependencies
setup_web_frontend() {
    print_status "Setting up React web frontend..."
    
    if [ -d "web-frontend" ]; then
        cd web-frontend
        npm install
        cd ..
        print_success "Web frontend dependencies installed"
    fi
}

# Setup database
setup_database() {
    print_status "Setting up database..."
    
    # Start database container
    docker-compose up -d db
    
    # Wait for database to be ready
    print_status "Waiting for database to be ready..."
    sleep 10
    
    # Run migrations
    docker-compose exec backend python manage.py migrate
    
    print_success "Database setup completed"
}

# Create superuser
create_superuser() {
    print_status "Creating Django superuser..."
    
    echo "Please create a superuser for Django admin:"
    docker-compose exec backend python manage.py createsuperuser
    
    print_success "Superuser created"
}

# Setup Kafka
setup_kafka() {
    print_status "Setting up Kafka..."
    
    docker-compose up -d kafka
    
    # Wait for Kafka to be ready
    print_status "Waiting for Kafka to be ready..."
    sleep 15
    
    print_success "Kafka setup completed"
}

# Update Flutter IP configuration
update_flutter_ip() {
    print_status "Updating Flutter IP configuration..."
    
    if [ -f "update_flutter_ip_auto.sh" ]; then
        chmod +x update_flutter_ip_auto.sh
        ./update_flutter_ip_auto.sh
        print_success "Flutter IP configuration updated"
    else
        print_warning "Flutter IP update script not found"
    fi
}

# Main setup function
main() {
    print_status "Starting Driver Management System setup..."
    
    # Check prerequisites
    check_docker
    
    # Setup components
    setup_backend
    setup_frontend
    setup_admin_panel
    setup_web_frontend
    
    # Start services
    print_status "Starting all services..."
    docker-compose up -d
    
    # Setup database
    setup_database
    
    # Setup Kafka
    setup_kafka
    
    # Update Flutter configuration
    update_flutter_ip
    
    # Create superuser (optional)
    read -p "Do you want to create a Django superuser? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        create_superuser
    fi
    
    print_success "Setup completed successfully!"
    
    echo
    echo "🎉 Driver Management System is ready!"
    echo
    echo "Access points:"
    echo "- Mobile App: Flutter app on device"
    echo "- Admin Panel: http://localhost:3000"
    echo "- Backend API: http://localhost:8001/api/"
    echo "- Django Admin: http://localhost:8001/admin/"
    echo "- PgAdmin: http://localhost:5050"
    echo
    echo "To start the system: docker-compose up -d"
    echo "To stop the system: docker-compose down"
    echo "To view logs: docker-compose logs -f"
}

# Run main function
main "$@"