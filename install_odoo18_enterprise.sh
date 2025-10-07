#!/bin/bash

# Odoo 18 Enterprise Installation Script (Docker, Private Registry)
# This script installs Odoo 18 Enterprise using Docker with private registry access

set -e  # Exit on any error

echo "=========================================="
echo "Odoo 18 Enterprise Installation Script"
echo "=========================================="

# Configuration
REGISTRY="registry.polyline.xyz"
REGUSER="ahmed"
REGPASSWORD="Bestat@98552376"
PROJECT_DIR="/opt/odoo18"
ODOO_VERSION="18.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root (use sudo)"
    exit 1
fi

print_status "Starting Odoo 18 Enterprise installation..."

# Step 1: System Preparation
print_status "Step 1: Updating system packages..."
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release

# Step 2: Add Docker Repository
print_status "Step 2: Adding Docker repository..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/debian $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
> /etc/apt/sources.list.d/docker.list

# Step 3: Install Docker & Tools
print_status "Step 3: Installing Docker and tools..."
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin unzip jq

# Enable and start Docker
print_status "Enabling and starting Docker service..."
systemctl enable --now docker
systemctl status docker --no-pager

# Step 4: Configure Access to Private Registry
print_status "Step 4: Configuring access to private registry..."

# Create Docker daemon configuration for insecure registry
cat > /etc/docker/daemon.json << 'JSON'
{
  "insecure-registries": ["registry.polyline.xyz"]
}
JSON

# Restart Docker to apply configuration
systemctl restart docker

# Login to private registry
print_status "Logging into private registry..."
printf "%s" "$REGPASSWORD" | docker login "$REGISTRY" -u "$REGUSER" --password-stdin

# Step 5: Create Project Directory
print_status "Step 5: Creating project directory..."
mkdir -p "$PROJECT_DIR/extra-addons"
cd "$PROJECT_DIR"

# Step 6: Pull the Enterprise Image
print_status "Step 6: Pulling Odoo 18 Enterprise image..."
docker pull "$REGISTRY/odooenterprise:$ODOO_VERSION"

# Step 7: Create Docker Compose File
print_status "Step 7: Creating Docker Compose configuration..."

cat > "$PROJECT_DIR/compose.yml" << 'EOF'
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: postgres
      POSTGRES_USER: odoo
      POSTGRES_PASSWORD: odoo
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U odoo"]
      interval: 10s
      timeout: 5s
      retries: 5

  odoo:
    image: registry.polyline.xyz/odooenterprise:18.0
    depends_on:
      db:
        condition: service_healthy
    ports:
      - "8069:8069"
    environment:
      HOST: db
      PORT: "5432"
      USER: odoo
      PASSWORD: odoo
      DB_HOST: db
      DB_PORT: "5432"
      DB_USER: odoo
      DB_PASSWORD: odoo
    volumes:
      - odoo-data:/var/lib/odoo
      - ./extra-addons:/mnt/extra-addons

volumes:
  pgdata:
  odoo-data:
EOF

# Step 8: Start Odoo
print_status "Step 8: Starting Odoo services..."
cd "$PROJECT_DIR"
docker compose up -d

# Wait a moment for services to start
sleep 10

# Show logs
print_status "Showing Odoo logs (press Ctrl+C to exit):"
docker compose logs -f odoo

print_status "=========================================="
print_status "Installation completed successfully!"
print_status "=========================================="
print_status "Odoo 18 Enterprise is now running on:"
print_status "http://$(hostname -I | awk '{print $1}'):10036"
print_status "or"
print_status "http://localhost:10036"
print_status "=========================================="
print_status "To manage the services:"
print_status "  Start:   cd $PROJECT_DIR && docker compose up -d"
print_status "  Stop:    cd $PROJECT_DIR && docker compose down"
print_status "  Logs:    cd $PROJECT_DIR && docker compose logs -f odoo"
print_status "  Status:  cd $PROJECT_DIR && docker compose ps"
print_status "=========================================="
