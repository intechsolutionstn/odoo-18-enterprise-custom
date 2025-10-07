#!/bin/bash

# Odoo 18 Community Custom Image - One-Command Installation
# This script sets up Odoo 18 Community with subscription warning removed for educational purposes
# Usage: curl -s https://raw.githubusercontent.com/intechsolutionstn/odoo-18-enterprise-custom/main/run.sh | bash -s PROJECT_NAME ODOO_PORT POSTGRES_PORT

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

print_header "Odoo 18 Community Educational Installation"
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
    image: odoo:18.0
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
      - ./fix_subscription.sql:/opt/odoo/fix_subscription.sql
    command: >
      bash -c "
        echo 'Waiting for database to be ready...' &&
        until pg_isready -h db -p 5432 -U odoo; do
          echo 'PostgreSQL is unavailable - sleeping'
          sleep 1
        done &&
        echo 'PostgreSQL is up - starting Odoo' &&
        /entrypoint.sh odoo --init=base --stop-after-init --no-http &&
        echo 'Applying subscription fix...' &&
        psql -h db -p 5432 -U odoo -d postgres -f /opt/odoo/fix_subscription.sql &&
        echo 'Starting Odoo server...' &&
        /entrypoint.sh odoo
      "

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

# Create subscription fix SQL
print_status "Creating subscription fix script..."
cat > fix_subscription.sql << 'EOF'
INSERT INTO ir_config_parameter (key, value, create_date, write_date)
VALUES ('database.expiration_date', '2030-12-31 23:59:59', NOW(), NOW())
ON CONFLICT (key) 
DO UPDATE SET 
    value = EXCLUDED.value,
    write_date = NOW();
EOF

# Start services
print_status "Starting Odoo 18 Community services..."
docker compose up -d

# Wait for services to be ready
print_status "Waiting for services to be ready..."
sleep 15

# Check if services are running
if docker compose ps | grep -q "Up"; then
    print_header "Installation completed successfully!"
    echo ""
    echo "🎉 Odoo 18 Community is now running!"
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
    echo "   • Ready for educational and learning purposes"
    echo "   • Custom addons support in ./addons/ directory"
    echo "   • No external registry dependencies"
    echo ""
    echo "📁 Project Structure:"
    echo "   • docker-compose.yml - Docker configuration"
    echo "   • manage.sh - Management script"
    echo "   • addons/ - Custom addons directory"
    echo "   • fix_subscription.sql - Subscription fix script"
    echo ""
else
    print_error "Failed to start services. Please check the logs:"
    echo "docker compose logs"
    exit 1
fi
