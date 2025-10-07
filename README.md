# Odoo 18 Enterprise Custom - One-Command Installation

Set up Odoo 18 Enterprise with subscription warning removed quickly for development/production using Docker Compose.

## 🚀 Quick Installation

Install Docker and Docker Compose, then run the following to set up Odoo 18 Enterprise:

```bash
curl -s https://raw.githubusercontent.com/intechsolutionstn/odoo-18-enterprise-custom/main/run.sh | bash -s odoo18-project 10036 5432
```

### Parameters:
- **First argument** (`odoo18-project`): Project folder name
- **Second argument** (`10036`): Odoo port
- **Third argument** (`5432`): PostgreSQL port

### Examples:

```bash
# Default installation (port 10036)
curl -s https://raw.githubusercontent.com/intechsolutionstn/odoo-18-enterprise-custom/main/run.sh | bash

# Custom ports
curl -s https://raw.githubusercontent.com/intechsolutionstn/odoo-18-enterprise-custom/main/run.sh | bash -s my-odoo 8080 5433

# Multiple instances
curl -s https://raw.githubusercontent.com/intechsolutionstn/odoo-18-enterprise-custom/main/run.sh | bash -s odoo-dev 10036 5432
curl -s https://raw.githubusercontent.com/intechsolutionstn/odoo-18-enterprise-custom/main/run.sh | bash -s odoo-test 11036 5433
```

## ✨ Features

- **🚫 No Subscription Warning**: Automatically removes the trial expiration warning
- **🔧 Ready to Use**: Pre-configured for development and testing
- **📦 Custom Addons Support**: Easy integration of custom modules
- **🔄 Easy Management**: Simple commands for all operations
- **🐳 Docker Based**: Consistent environment across all systems
- **⚡ Fast Setup**: One command installation

## 📋 Prerequisites

- Docker and Docker Compose installed
- Internet connection for image download
- Access to private registry: `registry.polyline.xyz`

## 🛠️ Usage

### Start Odoo:
```bash
./manage.sh start
```

### Stop Odoo:
```bash
./manage.sh stop
```

### View Logs:
```bash
./manage.sh logs
```

### Check Status:
```bash
./manage.sh status
```

### Create Backup:
```bash
./manage.sh backup
```

### Access Shell:
```bash
./manage.sh shell
```

## 📁 Project Structure

```
your-project/
├── docker-compose.yml    # Docker configuration
├── manage.sh            # Management script
├── addons/              # Custom addons directory
└── odoo_backup_*.sql    # Database backups
```

## 🔧 Configuration

### Custom Addons
Place your custom addons in the `addons/` directory. They will be automatically loaded by Odoo.

### Port Configuration
To change ports, edit the `docker-compose.yml` file:

```yaml
ports:
  - "YOUR_PORT:8069"  # Odoo port
  - "YOUR_DB_PORT:5432"  # PostgreSQL port
```

### Environment Variables
The following environment variables are available:

- `HOST`: Database host
- `PORT`: Database port
- `USER`: Database user
- `PASSWORD`: Database password
- `DB_NAME`: Database name

## 🐳 Docker Images

- **Odoo**: Custom image based on `registry.polyline.xyz/odooenterprise:18.0`
- **PostgreSQL**: `postgres:16`

## 🔒 Security

- Default database password is `odoo` (change in production)
- Subscription warning removed for test environments
- All data persisted in Docker volumes

## 📊 Management Commands

| Command | Description |
|---------|-------------|
| `start` | Start Odoo services |
| `stop` | Stop Odoo services |
| `restart` | Restart Odoo services |
| `status` | Show service status |
| `logs` | Show Odoo logs (follow mode) |
| `logs-db` | Show database logs (follow mode) |
| `shell` | Open Odoo container shell |
| `db-shell` | Open database shell |
| `backup` | Create database backup |
| `update` | Update to latest image |
| `clean` | Clean up unused Docker resources |

## 🚨 Troubleshooting

### Port Already in Use
If you get a "port already allocated" error, use a different port:

```bash
curl -s https://raw.githubusercontent.com/intechsolutionstn/odoo-18-enterprise-custom/main/run.sh | bash -s my-odoo 8080 5433
```

### Permission Issues
If you encounter permission issues:

```bash
sudo chmod -R 777 addons
sudo chmod +x manage.sh
```

### Docker Not Running
Make sure Docker is installed and running:

```bash
# Check Docker status
docker ps

# Start Docker (if needed)
sudo systemctl start docker
```

### Registry Access Issues
Ensure you have access to the private registry `registry.polyline.xyz`:

```bash
# Login to registry
docker login registry.polyline.xyz
```

## 📈 Performance

For better performance in production:

1. **Increase Docker resources** in Docker Desktop settings
2. **Use SSD storage** for better I/O performance
3. **Allocate more memory** to PostgreSQL container
4. **Use reverse proxy** (nginx) for SSL termination

## 🔄 Updates

To update to the latest image:

```bash
./manage.sh update
```

## 📝 Logs

- **Odoo logs**: `./manage.sh logs`
- **Database logs**: `./manage.sh logs-db`
- **All logs**: `docker compose logs`

## 🎯 Production Deployment

For production deployment:

1. **Change default passwords**
2. **Configure SSL/TLS**
3. **Set up proper backup strategy**
4. **Use environment files for secrets**
5. **Configure monitoring and alerting**

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.


## 📞 Support

If you encounter any issues:

1. Check the troubleshooting section
2. Review the logs: `./manage.sh logs`
3. Open an issue on GitHub
4. Check Docker and Docker Compose documentation

---

**Happy Odoo-ing! 🎉**
