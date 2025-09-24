# 🚀 Podman Migration Guide

Panduan lengkap migrasi dari Docker ke Podman untuk Driver Management System.

## 📋 Prerequisites

### Install Podman
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install podman podman-compose

# CentOS/RHEL/Fedora
sudo dnf install podman podman-compose

# macOS
brew install podman podman-compose
```

### Verify Installation
```bash
podman --version
podman-compose --version
```

## ⏱️ Migration Timeline

- **Preparation**: 30 minutes
- **Core Migration**: 90 minutes  
- **CI/CD Update**: 60 minutes
- **Testing**: 30 minutes
- **Total**: 3.5 hours

## 🔄 Step-by-Step Migration

### Phase 1: Backup & Preparation

```bash
# 1. Backup current Docker setup
cp docker-compose.yml docker-compose.yml.backup
./export_database.sh

# 2. Stop Docker services
docker-compose down

# 3. Create migration branch
git checkout -b podman-migration
```

### Phase 2: Core Files Migration

#### 2.1 Create Podman Compose File
```bash
cp docker-compose.yml podman-compose.yml
```

#### 2.2 Update Scripts
Replace all Docker commands in scripts:

**setup_project.sh**:
```bash
# Replace
docker-compose → podman-compose
docker → podman
```

**export_database.sh**:
```bash
# Replace
docker-compose exec -T db → podman-compose exec -T db
```

**import_database.sh**:
```bash
# Replace  
docker-compose exec -T db → podman-compose exec -T db
```

**project_status.sh**:
```bash
# Replace
docker-compose ps → podman-compose ps
docker-compose logs → podman-compose logs
```

### Phase 3: Create Migration Scripts

#### 3.1 Podman Setup Script
```bash
#!/bin/bash
# setup_podman.sh

echo "🚀 Setting up Podman for Driver Management System..."

# Start Podman socket (if needed)
systemctl --user enable --now podman.socket

# Create Podman network
podman network create driver-management-net || true

# Start services
podman-compose up -d

echo "✅ Podman setup complete!"
```

#### 3.2 Migration Helper Script
```bash
#!/bin/bash
# migrate_to_podman.sh

echo "🔄 Migrating from Docker to Podman..."

# Stop Docker services
echo "Stopping Docker services..."
docker-compose down

# Export data if needed
if [ ! -f "database_export.sql" ]; then
    echo "Exporting database..."
    docker-compose up -d db
    sleep 5
    docker-compose exec -T db pg_dump -U postgres -d driver_management > database_export.sql
    docker-compose down
fi

# Start Podman services
echo "Starting Podman services..."
podman-compose up -d

# Import data
echo "Importing database..."
sleep 10
podman-compose exec -T db psql -U postgres -d driver_management < database_export.sql

echo "✅ Migration complete!"
```

### Phase 4: Update CI/CD Pipeline

#### 4.1 GitHub Actions Update
```yaml
# .github/workflows/podman-ci.yml
name: Podman CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  podman-build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install Podman
      run: |
        sudo apt update
        sudo apt install -y podman podman-compose
    
    - name: Build with Podman
      run: |
        podman build -t driver-management-backend ./backend
    
    - name: Test Podman Compose
      run: |
        podman-compose -f podman-compose.yml config
```

## 🔧 Configuration Changes

### Network Configuration
```yaml
# podman-compose.yml
networks:
  driver-management-net:
    driver: bridge

services:
  db:
    networks:
      - driver-management-net
  # ... other services
```

### Volume Permissions
```bash
# Fix volume permissions for rootless Podman
podman unshare chown -R 999:999 postgres_data
```

## 🧪 Testing Migration

### 1. Service Health Check
```bash
# Check all services
podman-compose ps

# Check logs
podman-compose logs -f

# Test connectivity
curl http://localhost:8001/api/
curl http://localhost:5050
```

### 2. Database Test
```bash
# Connect to database
podman-compose exec db psql -U postgres -d driver_management

# Check tables
\dt
```

### 3. Application Test
```bash
# Test backend API
curl http://localhost:8001/api/drivers/

# Test admin panel
curl http://localhost:3000
```

## 🚨 Common Issues & Solutions

### Issue 1: Permission Denied
```bash
# Solution: Use rootless mode
podman-compose up -d --userns=keep-id
```

### Issue 2: Network Connectivity
```bash
# Solution: Create custom network
podman network create driver-management-net
```

### Issue 3: Volume Mounting
```bash
# Solution: Fix SELinux context
podman-compose up -d --security-opt label=disable
```

### Issue 4: Port Binding
```bash
# Solution: Use different port range
# Change ports in podman-compose.yml if needed
```

## 📊 Performance Comparison

| Metric | Docker | Podman |
|--------|--------|--------|
| Memory Usage | Higher | Lower |
| Startup Time | ~30s | ~25s |
| Security | Daemon | Rootless |
| Resource Usage | More | Less |

## 🔄 Rollback Plan

If migration fails:

```bash
# 1. Stop Podman services
podman-compose down

# 2. Restore Docker setup
cp docker-compose.yml.backup docker-compose.yml

# 3. Start Docker services
docker-compose up -d

# 4. Import database backup
./import_database.sh
```

## ✅ Post-Migration Checklist

- [ ] All services start successfully
- [ ] Database data intact
- [ ] API endpoints accessible
- [ ] Frontend applications working
- [ ] CI/CD pipeline updated
- [ ] Documentation updated
- [ ] Team trained on Podman commands

## 📚 Podman Command Reference

| Docker Command | Podman Equivalent |
|----------------|-------------------|
| `docker-compose up` | `podman-compose up` |
| `docker-compose down` | `podman-compose down` |
| `docker ps` | `podman ps` |
| `docker logs` | `podman logs` |
| `docker exec` | `podman exec` |
| `docker build` | `podman build` |

## 🎯 Benefits After Migration

- ✅ **Security**: Rootless containers
- ✅ **Performance**: Lower resource usage
- ✅ **Compatibility**: OCI compliant
- ✅ **No Daemon**: Direct container management
- ✅ **Kubernetes**: Better K8s integration

## 📞 Support

If you encounter issues:
1. Check [Podman Documentation](https://docs.podman.io/)
2. Review common issues section above
3. Create issue in project repository
4. Consult team lead

---

**Migration Status**: Ready for implementation
**Risk Level**: Low
**Recommended**: Yes