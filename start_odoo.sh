#!/bin/bash

# Odoo 18 Enterprise Startup Script
# This script provides easy management of Odoo services

PROJECT_DIR="/opt/odoo18"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root (use sudo)"
    exit 1
fi

# Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Project directory $PROJECT_DIR does not exist. Please run the installation script first."
    exit 1
fi

cd "$PROJECT_DIR"

case "$1" in
    start)
        print_header "Starting Odoo 18 Enterprise Services"
        print_status "Starting services..."
        docker compose up -d
        print_status "Services started successfully!"
        print_status "Odoo is available at: http://$(hostname -I | awk '{print $1}'):10036"
        ;;
    stop)
        print_header "Stopping Odoo 18 Enterprise Services"
        print_status "Stopping services..."
        docker compose down
        print_status "Services stopped successfully!"
        ;;
    restart)
        print_header "Restarting Odoo 18 Enterprise Services"
        print_status "Restarting services..."
        docker compose restart
        print_status "Services restarted successfully!"
        ;;
    status)
        print_header "Odoo 18 Enterprise Services Status"
        docker compose ps
        ;;
    logs)
        print_header "Odoo 18 Enterprise Logs"
        print_status "Showing logs (press Ctrl+C to exit)..."
        docker compose logs -f odoo
        ;;
    logs-db)
        print_header "Database Logs"
        print_status "Showing database logs (press Ctrl+C to exit)..."
        docker compose logs -f db
        ;;
    shell)
        print_header "Odoo Shell Access"
        print_status "Opening Odoo shell..."
        docker compose exec odoo /bin/bash
        ;;
    db-shell)
        print_header "Database Shell Access"
        print_status "Opening database shell..."
        docker compose exec db psql -U odoo postgres
        ;;
    backup)
        print_header "Database Backup"
        BACKUP_FILE="odoo_backup_$(date +%Y%m%d_%H%M%S).sql"
        print_status "Creating backup: $BACKUP_FILE"
        docker compose exec -T db pg_dump -U odoo postgres > "$BACKUP_FILE"
        print_status "Backup created: $PROJECT_DIR/$BACKUP_FILE"
        ;;
    restore)
        if [ -z "$2" ]; then
            print_error "Please provide backup file path"
            echo "Usage: $0 restore /path/to/backup.sql"
            exit 1
        fi
        print_header "Database Restore"
        print_warning "This will replace the current database!"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Restoring database from: $2"
            docker compose exec -T db psql -U odoo postgres < "$2"
            print_status "Database restored successfully!"
        else
            print_status "Restore cancelled."
        fi
        ;;
    update)
        print_header "Updating Odoo 18 Enterprise"
        print_status "Pulling latest image..."
        docker compose pull
        print_status "Restarting services with new image..."
        docker compose up -d
        print_status "Update completed!"
        ;;
    clean)
        print_header "Cleaning Up Docker Resources"
        print_warning "This will remove unused Docker resources (images, containers, volumes)"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Cleaning up..."
            docker system prune -f
            print_status "Cleanup completed!"
        else
            print_status "Cleanup cancelled."
        fi
        ;;
    *)
        print_header "Odoo 18 Enterprise Management Script"
        echo "Usage: $0 {start|stop|restart|status|logs|logs-db|shell|db-shell|backup|restore|update|clean}"
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
        echo "  restore    - Restore database from backup"
        echo "  update     - Update to latest image"
        echo "  clean      - Clean up unused Docker resources"
        echo ""
        echo "Examples:"
        echo "  sudo $0 start"
        echo "  sudo $0 logs"
        echo "  sudo $0 backup"
        echo "  sudo $0 restore /opt/odoo18/odoo_backup_20240101_120000.sql"
        ;;
esac
