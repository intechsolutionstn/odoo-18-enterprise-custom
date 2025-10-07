# Odoo 18 Enterprise Installation Guide (Windows, Docker Desktop, Port 10036)

This guide provides step-by-step instructions for installing Odoo 18 Enterprise locally on Windows using Docker Desktop with access to a private registry.

## Prerequisites

- Windows 10/11 (64-bit)
- Docker Desktop for Windows installed and running
- Internet connection
- Access to private registry: `registry.polyline.xyz`

## Quick Installation

### Option 1: Automated Installation (Recommended)

1. **Download Docker Desktop** (if not already installed):
   - Visit: https://www.docker.com/products/docker-desktop
   - Download and install Docker Desktop
   - Start Docker Desktop and ensure it's running

2. **Run the installation script**:
   ```cmd
   install_odoo18_windows.bat
   ```

3. **Access Odoo**:
   - Open your browser and go to: http://localhost:10036

### Option 2: Manual Installation

1. **Create project directory**:
   ```cmd
   mkdir odoo18_enterprise
   cd odoo18_enterprise
   mkdir extra-addons
   ```

2. **Configure Docker for private registry**:
   - Open Docker Desktop
   - Go to Settings → Docker Engine
   - Add the following configuration:
   ```json
   {
     "insecure-registries": ["registry.polyline.xyz"]
   }
   ```
   - Click "Apply & Restart"

3. **Login to private registry**:
   ```cmd
   echo Bestat@98552376 | docker login registry.polyline.xyz -u ahmed --password-stdin
   ```

4. **Pull Odoo image**:
   ```cmd
   docker pull registry.polyline.xyz/odooenterprise:18.0
   ```

5. **Create Docker Compose file**:
   Copy the `docker-compose.yml` file to your project directory.

6. **Start services**:
   ```cmd
   docker compose up -d
   ```

## Managing Odoo

Use the management script for easy service control:

```cmd
# Start Odoo
manage_odoo.bat start

# Stop Odoo
manage_odoo.bat stop

# Restart Odoo
manage_odoo.bat restart

# Check status
manage_odoo.bat status

# View logs
manage_odoo.bat logs

# Create backup
manage_odoo.bat backup

# Restore from backup
manage_odoo.bat restore "backup_file.sql"
```

## Accessing Odoo

Once installation is complete, access Odoo through your web browser:

- **Local access**: http://localhost:10036
- **Network access**: http://YOUR_COMPUTER_IP:10036

## Project Structure

```
odoo18_enterprise/
├── compose.yml              # Docker Compose configuration
├── extra-addons/            # Custom addons directory
├── odoo-data/              # Odoo data volume (created automatically)
├── pgdata/                 # PostgreSQL data volume (created automatically)
└── odoo_backup_*.sql       # Database backups
```

## Adding Custom Addons

1. Place your custom addons in the `extra-addons/` directory
2. Restart Odoo: `manage_odoo.bat restart`
3. Update the apps list in Odoo to see your addons

## Database Management

### Backup Database
```cmd
manage_odoo.bat backup
```
This creates a timestamped SQL backup file in the project directory.

### Restore Database
```cmd
manage_odoo.bat restore "backup_file.sql"
```

### Direct Database Access
```cmd
manage_odoo.bat db-shell
```

## Troubleshooting

### Common Issues

1. **Docker Desktop not running**
   - Ensure Docker Desktop is installed and running
   - Check system tray for Docker icon

2. **Port 10036 already in use**
   - Change the port in `compose.yml` (first number in ports section)
   - Or stop the service using that port

3. **Registry authentication failed**
   - Verify registry credentials
   - Check Docker daemon configuration
   - Restart Docker Desktop after configuration changes

4. **Services won't start**
   - Check logs: `manage_odoo.bat logs`
   - Ensure all required images are pulled
   - Verify Docker Compose file syntax

### Viewing Logs

```cmd
# Odoo logs
manage_odoo.bat logs

# Database logs
manage_odoo.bat logs-db

# All services logs
docker compose logs
```

### Container Shell Access

```cmd
# Odoo container shell
manage_odoo.bat shell

# Database container shell
manage_odoo.bat db-shell
```

## Security Considerations

1. **Change default passwords** in production
2. **Use environment files** for sensitive data
3. **Configure Windows Firewall** if needed
4. **Regular backups** of database and files
5. **Keep Docker Desktop updated**

## Performance Optimization

1. **Allocate more resources** to Docker Desktop:
   - Settings → Resources → Advanced
   - Increase CPU and Memory limits

2. **Use SSD storage** for better performance
3. **Close unnecessary applications** to free up resources

## Updating Odoo

```cmd
# Update to latest image
manage_odoo.bat update
```

## Cleanup

```cmd
# Clean up unused Docker resources
manage_odoo.bat clean
```

## File Locations

- **Installation directory**: `odoo18_enterprise/`
- **Docker volumes**: Managed by Docker Desktop
- **Backups**: `odoo18_enterprise/odoo_backup_*.sql`
- **Custom addons**: `odoo18_enterprise/extra-addons/`

## Support

For issues related to:
- **Odoo functionality**: Contact Odoo support
- **Docker issues**: Check Docker Desktop documentation
- **Registry access**: Contact registry administrator
- **Windows-specific issues**: Check Windows documentation

## Next Steps

1. **Configure Odoo**: Set up your database and initial configuration
2. **Install modules**: Add required Odoo modules
3. **Customize**: Add your custom addons
4. **Backup strategy**: Set up regular backups
5. **Production deployment**: Consider production-ready setup

