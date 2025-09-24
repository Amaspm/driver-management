#!/bin/bash

# Driver Management System - Podman Migration Script
# Automated migration from Docker to Podman

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Check if Podman is installed
check_podman() {
    if ! command -v podman &> /dev/null; then
        print_error "Podman is not installed. Please install Podman first."
        echo "Ubuntu/Debian: sudo apt install podman podman-compose"
        echo "CentOS/RHEL: sudo dnf install podman podman-compose"
        exit 1
    fi
    
    if ! command -v podman-compose &> /dev/null; then
        print_error "Podman Compose is not installed."
        exit 1
    fi
    
    print_success "Podman and Podman Compose are installed"
}

# Backup current setup
backup_docker_setup() {
    print_status "Backing up Docker setup..."
    
    cp docker-compose.yml docker-compose.yml.backup
    
    # Export database if Docker is running
    if docker-compose ps | grep -q "Up"; then
        print_status "Exporting database..."
        docker-compose exec -T db pg_dump -U postgres -d driver_management > database_export_pre_migration.sql 2>/dev/null || true
    fi
    
    print_success "Backup completed"
}

# Stop Docker services
stop_docker() {
    print_status "Stopping Docker services..."
    docker-compose down 2>/dev/null || true
    print_success "Docker services stopped"
}

# Create Podman compose file
create_podman_compose() {
    print_status "Creating Podman compose file..."
    
    cp docker-compose.yml podman-compose.yml
    
    # Add Podman-specific network configuration
    cat >> podman-compose.yml << 'EOF'

networks:
  default:
    driver: bridge
EOF
    
    print_success "Podman compose file created"
}

# Update scripts for Podman
update_scripts() {
    print_status "Updating scripts for Podman..."
    
    # Create Podman versions of scripts
    for script in setup_project.sh export_database.sh import_database.sh project_status.sh; do
        if [ -f "$script" ]; then
            cp "$script" "podman_$script"
            sed -i 's/docker-compose/podman-compose/g' "podman_$script"
            sed -i 's/docker /podman /g' "podman_$script"
            chmod +x "podman_$script"
        fi
    done
    
    print_success "Scripts updated for Podman"
}

# Start Podman services
start_podman() {
    print_status "Starting Podman services..."
    
    # Create network if needed
    podman network create driver-management-net 2>/dev/null || true
    
    # Start services
    podman-compose -f podman-compose.yml up -d
    
    print_success "Podman services started"
}

# Import database
import_database() {
    if [ -f "database_export_pre_migration.sql" ]; then
        print_status "Importing database..."
        
        # Wait for database to be ready
        sleep 15
        
        podman-compose -f podman-compose.yml exec -T db psql -U postgres -d driver_management < database_export_pre_migration.sql
        
        print_success "Database imported"
    else
        print_warning "No database backup found, skipping import"
    fi
}

# Test migration
test_migration() {
    print_status "Testing migration..."
    
    # Check services
    if podman-compose -f podman-compose.yml ps | grep -q "Up"; then
        print_success "Services are running"
    else
        print_error "Some services failed to start"
        return 1
    fi
    
    # Test API endpoint
    sleep 10
    if curl -s http://localhost:8001/api/ > /dev/null; then
        print_success "Backend API is accessible"
    else
        print_warning "Backend API not yet accessible (may need more time)"
    fi
    
    print_success "Migration test completed"
}

# Main migration function
main() {
    echo -e "${BLUE}🚀 Driver Management System - Podman Migration${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo
    
    # Confirmation
    read -p "This will migrate from Docker to Podman. Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Migration cancelled."
        exit 0
    fi
    
    # Migration steps
    check_podman
    backup_docker_setup
    stop_docker
    create_podman_compose
    update_scripts
    start_podman
    import_database
    test_migration
    
    echo
    print_success "🎉 Migration to Podman completed successfully!"
    echo
    echo "Next steps:"
    echo "- Use 'podman-compose' instead of 'docker-compose'"
    echo "- Use Podman scripts: podman_setup_project.sh, etc."
    echo "- Test all functionality thoroughly"
    echo "- Update team documentation"
    echo
    echo "Rollback: Use docker-compose.yml.backup if needed"
}

# Run migration
main "$@"