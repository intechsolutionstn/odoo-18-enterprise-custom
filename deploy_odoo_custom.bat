@echo off
REM Deployment script for Odoo 18 Enterprise Custom Image
REM This script deploys the custom Odoo image with PostgreSQL

echo ==========================================
echo Odoo 18 Enterprise Custom Deployment
echo ==========================================
echo.

REM Configuration
set IMAGE_NAME=odoo18-enterprise-custom
set IMAGE_TAG=latest
set PROJECT_NAME=odoo18-custom
set ODOO_PORT=10036
set POSTGRES_PORT=5432

echo [INFO] Deploying Odoo 18 Enterprise Custom Image...
echo [INFO] Project: %PROJECT_NAME%
echo [INFO] Odoo Port: %ODOO_PORT%
echo [INFO] PostgreSQL Port: %POSTGRES_PORT%
echo.

REM Check if Docker is running
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)

REM Check if image exists
docker images %IMAGE_NAME%:%IMAGE_TAG% | findstr %IMAGE_NAME% >nul
if %errorlevel% neq 0 (
    echo [ERROR] Custom image not found. Please build it first.
    echo Run: .\build_odoo_image.bat
    pause
    exit /b 1
)

echo [INFO] Custom image found.
echo.

REM Create project directory
if not exist "%PROJECT_NAME%" mkdir "%PROJECT_NAME%"
cd "%PROJECT_NAME%"

REM Create Docker Compose file
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
echo     ports:
echo       - "%POSTGRES_PORT%:5432"
echo     healthcheck:
echo       test: ["CMD-SHELL", "pg_isready -U odoo"]
echo       interval: 10s
echo       timeout: 5s
echo       retries: 5
echo.
echo   odoo:
echo     image: %IMAGE_NAME%:%IMAGE_TAG%
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
echo       DB_NAME: postgres
echo     volumes:
echo       - odoo-data:/var/lib/odoo
echo       - ./extra-addons:/mnt/extra-addons
echo.
echo volumes:
echo   pgdata:
echo   odoo-data:
) > compose.yml

REM Create extra-addons directory
if not exist "extra-addons" mkdir "extra-addons"

echo [INFO] Starting services...
docker compose up -d

if %errorlevel% equ 0 (
    echo [SUCCESS] Services started successfully!
    echo.
    echo ==========================================
    echo Deployment completed!
    echo ==========================================
    echo [INFO] Odoo 18 Enterprise is running at:
    echo   http://localhost:%ODOO_PORT%
    echo.
    echo [INFO] PostgreSQL is running at:
    echo   localhost:%POSTGRES_PORT%
    echo.
    echo [INFO] Management commands:
    echo   Start:   docker compose up -d
    echo   Stop:    docker compose down
    echo   Logs:    docker compose logs -f odoo
    echo   Status:  docker compose ps
    echo.
    echo [INFO] The subscription warning has been automatically removed!
) else (
    echo [ERROR] Failed to start services. Please check the error messages above.
)

echo.
pause
