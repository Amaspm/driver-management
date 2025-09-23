#!/bin/bash

# Driver Management System - Project Status Script
# Shows current status of all services and components

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}  Driver Management System${NC}"
    echo -e "${PURPLE}      Project Status${NC}"
    echo -e "${PURPLE}================================${NC}"
    echo
}

print_section() {
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}$(printf '%.0s-' {1..30})${NC}"
}

check_service_status() {
    local service=$1
    local port=$2
    
    if docker-compose ps | grep -q "$service.*Up"; then
        echo -e "  ${GREEN}✓${NC} $service (Port: $port) - ${GREEN}Running${NC}"
        return 0
    else
        echo -e "  ${RED}✗${NC} $service (Port: $port) - ${RED}Stopped${NC}"
        return 1
    fi
}

check_url_status() {
    local name=$1
    local url=$2
    
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200\|302"; then
        echo -e "  ${GREEN}✓${NC} $name - ${GREEN}Accessible${NC}"
    else
        echo -e "  ${RED}✗${NC} $name - ${RED}Not accessible${NC}"
    fi
}

check_git_status() {
    echo -e "  Repository: ${BLUE}$(git remote get-url origin)${NC}"
    echo -e "  Current branch: ${BLUE}$(git branch --show-current)${NC}"
    echo -e "  Last commit: ${BLUE}$(git log -1 --pretty=format:'%h - %s (%cr)')${NC}"
    
    if git status --porcelain | grep -q .; then
        echo -e "  Working directory: ${YELLOW}Has uncommitted changes${NC}"
    else
        echo -e "  Working directory: ${GREEN}Clean${NC}"
    fi
}

main() {
    print_header
    
    # Git Status
    print_section "📁 Repository Status"
    check_git_status
    echo
    
    # Docker Services Status
    print_section "🐳 Docker Services"
    if command -v docker-compose &> /dev/null; then
        check_service_status "backend" "8001"
        check_service_status "db" "5432"
        check_service_status "kafka" "9092"
        check_service_status "driver-service" "8080"
        check_service_status "pgadmin" "5050"
    else
        echo -e "  ${RED}✗${NC} Docker Compose not installed"
    fi
    echo
    
    # Web Services Status
    print_section "🌐 Web Services"
    check_url_status "Backend API" "http://localhost:8001/api/"
    check_url_status "Django Admin" "http://localhost:8001/admin/"
    check_url_status "PgAdmin" "http://localhost:5050"
    echo
    
    # Development Tools
    print_section "🛠️ Development Tools"
    
    # Flutter
    if command -v flutter &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Flutter - ${GREEN}$(flutter --version | head -1)${NC}"
    else
        echo -e "  ${RED}✗${NC} Flutter - ${RED}Not installed${NC}"
    fi
    
    # Node.js
    if command -v node &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Node.js - ${GREEN}$(node --version)${NC}"
    else
        echo -e "  ${RED}✗${NC} Node.js - ${RED}Not installed${NC}"
    fi
    
    # Python
    if command -v python3 &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Python - ${GREEN}$(python3 --version)${NC}"
    else
        echo -e "  ${RED}✗${NC} Python - ${RED}Not installed${NC}"
    fi
    
    # Docker
    if command -v docker &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Docker - ${GREEN}$(docker --version | cut -d' ' -f3 | cut -d',' -f1)${NC}"
    else
        echo -e "  ${RED}✗${NC} Docker - ${RED}Not installed${NC}"
    fi
    echo
    
    # Project Structure
    print_section "📂 Project Structure"
    echo -e "  ${GREEN}✓${NC} Backend (Django) - $(find backend -name "*.py" | wc -l) Python files"
    echo -e "  ${GREEN}✓${NC} Frontend (Flutter) - $(find frontend -name "*.dart" | wc -l) Dart files"
    
    if [ -d "admin-panel" ]; then
        echo -e "  ${GREEN}✓${NC} Admin Panel (React) - $(find admin-panel/src -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" 2>/dev/null | wc -l) JS/TS files"
    fi
    
    if [ -d "web-frontend" ]; then
        echo -e "  ${GREEN}✓${NC} Web Frontend (React) - $(find web-frontend/src -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" 2>/dev/null | wc -l) JS/TS files"
    fi
    
    if [ -d "driver-service" ]; then
        echo -e "  ${GREEN}✓${NC} Driver Service (Go) - $(find driver-service -name "*.go" 2>/dev/null | wc -l) Go files"
    fi
    echo
    
    # Quick Actions
    print_section "⚡ Quick Actions"
    echo -e "  Start all services:     ${BLUE}docker-compose up -d${NC}"
    echo -e "  Stop all services:      ${BLUE}docker-compose down${NC}"
    echo -e "  View logs:              ${BLUE}docker-compose logs -f${NC}"
    echo -e "  Setup project:          ${BLUE}./setup_project.sh${NC}"
    echo -e "  Update Flutter IP:      ${BLUE}./update_flutter_ip_auto.sh${NC}"
    echo -e "  Run Flutter app:        ${BLUE}cd frontend && flutter run${NC}"
    echo
    
    # Access URLs
    print_section "🔗 Access URLs"
    echo -e "  Backend API:            ${BLUE}http://localhost:8001/api/${NC}"
    echo -e "  Django Admin:           ${BLUE}http://localhost:8001/admin/${NC}"
    echo -e "  PgAdmin:                ${BLUE}http://localhost:5050${NC}"
    echo -e "  Admin Panel:            ${BLUE}http://localhost:3000${NC}"
    echo
    
    # Documentation
    print_section "📚 Documentation"
    echo -e "  Development Guide:      ${BLUE}DEVELOPMENT.md${NC}"
    echo -e "  Project Guide:          ${BLUE}PROJECT_GUIDE.md${NC}"
    echo -e "  API Documentation:      ${BLUE}http://localhost:8001/api/docs/${NC}"
    echo
    
    echo -e "${GREEN}Project setup complete! 🎉${NC}"
    echo -e "For detailed development instructions, see ${BLUE}DEVELOPMENT.md${NC}"
}

# Run main function
main "$@"