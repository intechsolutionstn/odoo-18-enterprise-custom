#!/bin/bash

# Odoo 18 Enterprise Custom Image - One-Command Installation
# This script sets up Odoo 18 Enterprise with subscription warning removed
# Usage: curl -s https://raw.githubusercontent.com/YOUR_USERNAME/odoo-18-enterprise-custom/master/run.sh | bash -s PROJECT_NAME ODOO_PORT POSTGRES_PORT

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}==========================================${NC}"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_warning "Running as root. This is not recommended for security reasons."
    print_warning "Consider running as a regular user with sudo privileges."
fi

# Get parameters
PROJECT_NAME=${1:-"odoo18-enterprise"}
ODOO_PORT=${2:-"10036"}
POSTGRES_PORT=${3:-"5432"}

print_header "Odoo 18 Enterprise Custom Installation"
echo "Project: $PROJECT_NAME"
echo "Odoo Port: $ODOO_PORT"
echo "PostgreSQL Port: $POSTGRES_PORT"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker is running
if ! docker ps &> /dev/null; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

print_status "Docker is installed and running."

# Create project directory
print_status "Creating project directory: $PROJECT_NAME"
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create Docker Compose file
print_status "Creating Docker Compose configuration..."
cat > docker-compose.yml << EOF
version: '3.8'

services:
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: postgres
      POSTGRES_USER: odoo
      POSTGRES_PASSWORD: odoo
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - "$POSTGRES_PORT:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U odoo"]
      interval: 10s
      timeout: 5s
      retries: 5

  odoo:
    image: odoo18-enterprise-custom:latest
    depends_on:
      db:
        condition: service_healthy
    ports:
      - "$ODOO_PORT:8069"
    environment:
      HOST: db
      PORT: "5432"
      USER: odoo
      PASSWORD: odoo
      DB_HOST: db
      DB_PORT: "5432"
      DB_USER: odoo
      DB_PASSWORD: odoo
      DB_NAME: postgres
    volumes:
      - odoo-data:/var/lib/odoo
      - ./addons:/mnt/extra-addons

volumes:
  pgdata:
  odoo-data:
EOF

# Create addons directory
mkdir -p addons

# Create management script
print_status "Creating management script..."
cat > manage.sh << 'EOF'
#!/bin/bash

# Odoo 18 Enterprise Management Script
PROJECT_NAME=$(basename "$PWD")

case "$1" in
    start)
        echo "Starting Odoo 18 Enterprise..."
        docker compose up -d
        ;;
    stop)
        echo "Stopping Odoo 18 Enterprise..."
        docker compose down
        ;;
    restart)
        echo "Restarting Odoo 18 Enterprise..."
        docker compose restart
        ;;
    status)
        echo "Odoo 18 Enterprise Status:"
        docker compose ps
        ;;
    logs)
        echo "Showing Odoo logs (press Ctrl+C to exit)..."
        docker compose logs -f odoo
        ;;
    logs-db)
        echo "Showing database logs (press Ctrl+C to exit)..."
        docker compose logs -f db
        ;;
    shell)
        echo "Opening Odoo shell..."
        docker compose exec odoo /bin/bash
        ;;
    db-shell)
        echo "Opening database shell..."
        docker compose exec db psql -U odoo postgres
        ;;
    backup)
        BACKUP_FILE="odoo_backup_$(date +%Y%m%d_%H%M%S).sql"
        echo "Creating backup: $BACKUP_FILE"
        docker compose exec -T db pg_dump -U odoo postgres > "$BACKUP_FILE"
        echo "Backup created: $PWD/$BACKUP_FILE"
        ;;
    update)
        echo "Updating to latest image..."
        docker compose pull
        docker compose up -d
        ;;
    clean)
        echo "Cleaning up unused Docker resources..."
        docker system prune -f
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs|logs-db|shell|db-shell|backup|update|clean}"
        echo ""
        echo "Commands:"
        echo "  start      - Start Odoo services"
        echo "  stop       - Stop Odoo services"
        echo "  restart    - Restart Odoo services"
        echo "  status     - Show service status"
        echo "  logs       - Show Odoo logs (follow mode)"
        echo "  logs-db    - Show database logs (follow mode)"
        echo "  shell      - Open Odoo container shell"
        echo "  db-shell   - Open database shell"
        echo "  backup     - Create database backup"
        echo "  update     - Update to latest image"
        echo "  clean      - Clean up unused Docker resources"
        ;;
esac
EOF

chmod +x manage.sh

# Check if custom image exists
print_status "Checking for custom Odoo 18 Enterprise image..."
if ! docker images | grep -q "odoo18-enterprise-custom"; then
    print_warning "Custom image not found. Building it now..."
    
    # Create Dockerfile
    cat > Dockerfile << 'EOF'
FROM registry.polyline.xyz/odooenterprise:18.0

LABEL maintainer="Odoo 18 Enterprise Custom"
LABEL description="Odoo 18 Enterprise with subscription warning removed for test environments"
LABEL version="1.0"

USER root
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /opt/odoo/custom-scripts \
    && chown -R odoo:odoo /opt/odoo

USER odoo

COPY --chown=odoo:odoo fix_subscription.sql /opt/odoo/custom-scripts/
COPY --chown=odoo:odoo init_odoo.sh /opt/odoo/custom-scripts/

RUN chmod +x /opt/odoo/custom-scripts/*.sh

EXPOSE 8069

CMD ["/opt/odoo/custom-scripts/init_odoo.sh"]
EOF

    # Create subscription fix SQL
    cat > fix_subscription.sql << 'EOF'
INSERT INTO ir_config_parameter (key, value, create_date, write_date)
VALUES ('database.expiration_date', '2030-12-31 23:59:59', NOW(), NOW())
ON CONFLICT (key) 
DO UPDATE SET 
    value = EXCLUDED.value,
    write_date = NOW();
EOF

    # Create initialization script
    cat > init_odoo.sh << 'EOF'
#!/bin/bash
set -e

echo "=========================================="
echo "Odoo 18 Enterprise Custom Image Starting"
echo "=========================================="

# Wait for database to be ready
echo "[INFO] Waiting for database to be ready..."
until pg_isready -h "$HOST" -p "$PORT" -U "$USER" > /dev/null 2>&1; do
    echo "[INFO] Waiting for database..."
    sleep 2
done

echo "[INFO] Database is ready!"

# Start Odoo in the background
echo "[INFO] Starting Odoo..."
exec /entrypoint.sh odoo &

# Wait a moment for Odoo to start
sleep 10

# Apply subscription fix
echo "[INFO] Applying subscription fix..."
if psql -h "$HOST" -p "$PORT" -U "$USER" -d "$DB_NAME" -f /opt/odoo/custom-scripts/fix_subscription.sql > /dev/null 2>&1; then
    echo "[SUCCESS] Subscription warning has been removed!"
else
    echo "[WARNING] Could not apply subscription fix. Odoo will continue running."
fi

echo "[INFO] Odoo 18 Enterprise is ready!"
echo "[INFO] Access at: http://localhost:8069"
echo "=========================================="

wait
EOF

    chmod +x init_odoo.sh

    # Build the image
    print_status "Building custom Odoo 18 Enterprise image..."
    docker build -t odoo18-enterprise-custom:latest .
    
    # Clean up build files
    rm -f Dockerfile fix_subscription.sql init_odoo.sh
fi

# Start services
print_status "Starting Odoo 18 Enterprise services..."
docker compose up -d

# Wait for services to be ready
print_status "Waiting for services to be ready..."
sleep 15

# Check if services are running
if docker compose ps | grep -q "Up"; then
    print_header "Installation completed successfully!"
    echo ""
    echo "🎉 Odoo 18 Enterprise is now running!"
    echo ""
    echo "📋 Access Information:"
    echo "   • Odoo URL: http://localhost:$ODOO_PORT"
    echo "   • PostgreSQL: localhost:$POSTGRES_PORT"
    echo "   • Project Directory: $PWD"
    echo ""
    echo "🛠️  Management Commands:"
    echo "   • Start:   ./manage.sh start"
    echo "   • Stop:    ./manage.sh stop"
    echo "   • Logs:    ./manage.sh logs"
    echo "   • Status:  ./manage.sh status"
    echo "   • Backup:  ./manage.sh backup"
    echo ""
    echo "✨ Features:"
    echo "   • Subscription warning automatically removed"
    echo "   • Ready for development and testing"
    echo "   • Custom addons support in ./addons/ directory"
    echo ""
    echo "📁 Project Structure:"
    echo "   • docker-compose.yml - Docker configuration"
    echo "   • manage.sh - Management script"
    echo "   • addons/ - Custom addons directory"
    echo ""
else
    print_error "Failed to start services. Please check the logs:"
    echo "docker compose logs"
    exit 1
fi
