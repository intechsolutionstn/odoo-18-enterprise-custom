# Odoo 18 Enterprise Installation Guide (Docker, Private Registry)

This guide provides step-by-step instructions for installing Odoo 18 Enterprise using Docker with access to a private registry.

## Prerequisites

- Ubuntu/Debian-based Linux system
- Root or sudo access
- Internet connection
- Access to private registry: `registry.polyline.xyz`

## Quick Installation

For a quick installation, run the provided script:

```bash
# Make the script executable
chmod +x install_odoo18_enterprise.sh

# Run the installation script
sudo ./install_odoo18_enterprise.sh
```

## Manual Installation Steps

### 1. System Preparation

Update the system and install required packages:

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release
```

### 2. Add Docker Repository

Configure Docker's official repository:

```bash
# Create directory for Docker keyrings
sudo install -m 0755 -d /etc/apt/keyrings

# Download and add Docker's GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository to sources list
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/debian $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list
```

### 3. Install Docker & Tools

Install Docker and required tools:

```bash
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin unzip jq

# Enable and start Docker service
sudo systemctl enable --now docker
sudo systemctl status docker --no-pager
```

### 4. Configure Access to Private Registry

Configure Docker to access the private registry:

```bash
# Create Docker daemon configuration
sudo tee /etc/docker/daemon.json > /dev/null << 'JSON'
{
  "insecure-registries": ["registry.polyline.xyz"]
}
JSON

# Restart Docker to apply configuration
sudo systemctl restart docker

# Login to private registry
export REGISTRY=registry.polyline.xyz
export REGUSER=ahmed
printf "%s" "Bestat@98552376" | docker login "$REGISTRY" -u "$REGUSER" --password-stdin
```

### 5. Create Project Directory

Set up the project directory structure:

```bash
sudo mkdir -p /opt/odoo18/extra-addons
cd /opt/odoo18
```

### 6. Pull the Enterprise Image

Download the Odoo 18 Enterprise image:

```bash
docker pull registry.polyline.xyz/odooenterprise:18.0
```

### 7. Create Docker Compose File

Create the `compose.yml` file in `/opt/odoo18/`:

```yaml
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
```

### 8. Start Odoo

Launch the Odoo services:

```bash
cd /opt/odoo18
docker compose up -d

# View logs
docker compose logs -f odoo
```

## Accessing Odoo

Once the installation is complete, access Odoo through your web browser:

- **Local access**: http://localhost:8069
- **Remote access**: http://YOUR_SERVER_IP:8069

## Managing the Installation

### Service Management

```bash
# Navigate to project directory
cd /opt/odoo18

# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f odoo

# Check service status
docker compose ps

# Restart services
docker compose restart
```

### Adding Custom Addons

1. Place your custom addons in `/opt/odoo18/extra-addons/`
2. Restart the Odoo service:
   ```bash
   cd /opt/odoo18
   docker compose restart odoo
   ```

### Database Management

The PostgreSQL database is stored in a Docker volume named `pgdata`. To backup or restore:

```bash
# Backup database
docker exec -t odoo18-db-1 pg_dump -U odoo postgres > backup.sql

# Restore database
docker exec -i odoo18-db-1 psql -U odoo postgres < backup.sql
```

## Troubleshooting

### Common Issues

1. **Registry authentication failed**
   - Verify registry credentials
   - Check if registry is accessible
   - Ensure Docker daemon configuration is correct

2. **Port 8069 already in use**
   - Change the port mapping in `compose.yml`
   - Kill any process using port 8069

3. **Database connection issues**
   - Wait for database to be ready (health check)
   - Check database container logs

4. **Permission issues with volumes**
   - Ensure proper ownership of the extra-addons directory
   - Check Docker volume permissions

### Logs and Debugging

```bash
# View all service logs
docker compose logs

# View specific service logs
docker compose logs odoo
docker compose logs db

# Follow logs in real-time
docker compose logs -f odoo
```

## Security Considerations

1. **Change default passwords** in production
2. **Use environment files** for sensitive data
3. **Configure firewall** to restrict access
4. **Enable SSL/TLS** for production deployments
5. **Regular backups** of database and files

## Production Recommendations

1. Use a reverse proxy (nginx) for SSL termination
2. Implement proper backup strategies
3. Monitor system resources
4. Use Docker secrets for sensitive data
5. Configure log rotation
6. Set up monitoring and alerting

## Support

For issues related to:
- **Odoo functionality**: Contact Odoo support
- **Docker issues**: Check Docker documentation
- **Registry access**: Contact registry administrator
