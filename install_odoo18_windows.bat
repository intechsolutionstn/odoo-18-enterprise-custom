@echo off
REM Odoo 18 Enterprise Installation Script for Windows
REM This script installs Odoo 18 Enterprise using Docker Desktop on Windows

setlocal enabledelayedexpansion

echo ==========================================
echo Odoo 18 Enterprise Installation Script
echo ==========================================
echo.

REM Configuration
set REGISTRY=registry.polyline.xyz
set REGUSER=ahmed
set REGPASSWORD=Bestat@98552376
set PROJECT_DIR=odoo18_enterprise
set ODOO_VERSION=18.0
set ODOO_PORT=10036

echo [INFO] Starting Odoo 18 Enterprise installation...
echo.

REM Check if Docker Desktop is running
echo [INFO] Checking Docker Desktop status...
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker Desktop is not running or not installed.
    echo Please install Docker Desktop and ensure it's running.
    echo Download from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo [INFO] Docker Desktop is running.
echo.

REM Create project directory
echo [INFO] Creating project directory...
if not exist "%PROJECT_DIR%" mkdir "%PROJECT_DIR%"
cd /d "%PROJECT_DIR%"

REM Create extra-addons directory
if not exist "extra-addons" mkdir "extra-addons"

echo [INFO] Project directory created: %CD%
echo.

REM Configure Docker daemon for insecure registry
echo [INFO] Configuring Docker for private registry access...
echo Creating Docker daemon configuration...

REM Create Docker daemon configuration file
echo { > daemon.json
echo   "insecure-registries": ["registry.polyline.xyz"] >> daemon.json
echo } >> daemon.json

echo [INFO] Docker daemon configuration created.
echo [WARNING] You may need to restart Docker Desktop for registry configuration to take effect.
echo.

REM Login to private registry
echo [INFO] Logging into private registry...
echo %REGPASSWORD% | docker login %REGISTRY% -u %REGUSER% --password-stdin
if %errorlevel% neq 0 (
    echo [ERROR] Failed to login to private registry.
    echo Please check your credentials and registry access.
    pause
    exit /b 1
)

echo [INFO] Successfully logged into private registry.
echo.

REM Pull the Enterprise Image
echo [INFO] Pulling Odoo 18 Enterprise image...
docker pull %REGISTRY%/odooenterprise:%ODOO_VERSION%
if %errorlevel% neq 0 (
    echo [ERROR] Failed to pull Odoo image.
    echo Please check your registry access and image availability.
    pause
    exit /b 1
)

echo [INFO] Successfully pulled Odoo 18 Enterprise image.
echo.

REM Create Docker Compose File
echo [INFO] Creating Docker Compose configuration...

(
echo services:
echo   db:
echo     image: postgres:16
echo     environment:
echo       POSTGRES_DB: postgres
echo       POSTGRES_USER: odoo
echo       POSTGRES_PASSWORD: odoo
echo     volumes:
echo       - pgdata:/var/lib/postgresql/data
echo     healthcheck:
echo       test: ["CMD-SHELL", "pg_isready -U odoo"]
echo       interval: 10s
echo       timeout: 5s
echo       retries: 5
echo.
echo   odoo:
echo     image: registry.polyline.xyz/odooenterprise:18.0
echo     depends_on:
echo       db:
echo         condition: service_healthy
echo     ports:
echo       - "%ODOO_PORT%:8069"
echo     environment:
echo       HOST: db
echo       PORT: "5432"
echo       USER: odoo
echo       PASSWORD: odoo
echo       DB_HOST: db
echo       DB_PORT: "5432"
echo       DB_USER: odoo
echo       DB_PASSWORD: odoo
echo     volumes:
echo       - odoo-data:/var/lib/odoo
echo       - ./extra-addons:/mnt/extra-addons
echo.
echo volumes:
echo   pgdata:
echo   odoo-data:
) > compose.yml

echo [INFO] Docker Compose file created.
echo.

REM Start Odoo
echo [INFO] Starting Odoo services...
docker compose up -d
if %errorlevel% neq 0 (
    echo [ERROR] Failed to start Odoo services.
    echo Please check Docker Compose configuration.
    pause
    exit /b 1
)

echo [INFO] Waiting for services to start...
timeout /t 15 /nobreak >nul

REM Show logs
echo [INFO] Showing Odoo logs (press Ctrl+C to exit):
echo.
docker compose logs -f odoo

echo.
echo ==========================================
echo Installation completed successfully!
echo ==========================================
echo Odoo 18 Enterprise is now running on:
echo http://localhost:%ODOO_PORT%
echo.
echo To manage the services, use the management script:
echo manage_odoo.bat
echo ==========================================
pause

