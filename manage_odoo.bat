@echo off
REM Odoo 18 Enterprise Management Script for Windows
REM This script provides easy management of Odoo services

setlocal enabledelayedexpansion

set PROJECT_DIR=odoo18_enterprise
set ODOO_PORT=10036

REM Check if project directory exists
if not exist "%PROJECT_DIR%" (
    echo [ERROR] Project directory %PROJECT_DIR% does not exist.
    echo Please run the installation script first.
    pause
    exit /b 1
)

cd /d "%PROJECT_DIR%"

if "%1"=="start" goto start
if "%1"=="stop" goto stop
if "%1"=="restart" goto restart
if "%1"=="status" goto status
if "%1"=="logs" goto logs
if "%1"=="logs-db" goto logs-db
if "%1"=="shell" goto shell
if "%1"=="db-shell" goto db-shell
if "%1"=="backup" goto backup
if "%1"=="restore" goto restore
if "%1"=="update" goto update
if "%1"=="clean" goto clean
goto help

:start
echo ==========================================
echo Starting Odoo 18 Enterprise Services
echo ==========================================
echo [INFO] Starting services...
docker compose up -d
if %errorlevel% equ 0 (
    echo [INFO] Services started successfully!
    echo [INFO] Odoo is available at: http://localhost:%ODOO_PORT%
) else (
    echo [ERROR] Failed to start services.
)
goto end

:stop
echo ==========================================
echo Stopping Odoo 18 Enterprise Services
echo ==========================================
echo [INFO] Stopping services...
docker compose down
if %errorlevel% equ 0 (
    echo [INFO] Services stopped successfully!
) else (
    echo [ERROR] Failed to stop services.
)
goto end

:restart
echo ==========================================
echo Restarting Odoo 18 Enterprise Services
echo ==========================================
echo [INFO] Restarting services...
docker compose restart
if %errorlevel% equ 0 (
    echo [INFO] Services restarted successfully!
) else (
    echo [ERROR] Failed to restart services.
)
goto end

:status
echo ==========================================
echo Odoo 18 Enterprise Services Status
echo ==========================================
docker compose ps
goto end

:logs
echo ==========================================
echo Odoo 18 Enterprise Logs
echo ==========================================
echo [INFO] Showing logs (press Ctrl+C to exit)...
docker compose logs -f odoo
goto end

:logs-db
echo ==========================================
echo Database Logs
echo ==========================================
echo [INFO] Showing database logs (press Ctrl+C to exit)...
docker compose logs -f db
goto end

:shell
echo ==========================================
echo Odoo Shell Access
echo ==========================================
echo [INFO] Opening Odoo shell...
docker compose exec odoo /bin/bash
goto end

:db-shell
echo ==========================================
echo Database Shell Access
echo ==========================================
echo [INFO] Opening database shell...
docker compose exec db psql -U odoo postgres
goto end

:backup
echo ==========================================
echo Database Backup
echo ==========================================
set BACKUP_FILE=odoo_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.sql
set BACKUP_FILE=!BACKUP_FILE: =0!
echo [INFO] Creating backup: !BACKUP_FILE!
docker compose exec -T db pg_dump -U odoo postgres > "!BACKUP_FILE!"
if %errorlevel% equ 0 (
    echo [INFO] Backup created: %CD%\!BACKUP_FILE!
) else (
    echo [ERROR] Failed to create backup.
)
goto end

:restore
if "%2"=="" (
    echo [ERROR] Please provide backup file path
    echo Usage: %0 restore "path\to\backup.sql"
    goto end
)
echo ==========================================
echo Database Restore
echo ==========================================
echo [WARNING] This will replace the current database!
set /p confirm="Are you sure? (y/N): "
if /i "!confirm!"=="y" (
    echo [INFO] Restoring database from: %2
    docker compose exec -T db psql -U odoo postgres < "%2"
    if %errorlevel% equ 0 (
        echo [INFO] Database restored successfully!
    ) else (
        echo [ERROR] Failed to restore database.
    )
) else (
    echo [INFO] Restore cancelled.
)
goto end

:update
echo ==========================================
echo Updating Odoo 18 Enterprise
echo ==========================================
echo [INFO] Pulling latest image...
docker compose pull
if %errorlevel% equ 0 (
    echo [INFO] Restarting services with new image...
    docker compose up -d
    if %errorlevel% equ 0 (
        echo [INFO] Update completed!
    ) else (
        echo [ERROR] Failed to restart services after update.
    )
) else (
    echo [ERROR] Failed to pull latest image.
)
goto end

:clean
echo ==========================================
echo Cleaning Up Docker Resources
echo ==========================================
echo [WARNING] This will remove unused Docker resources (images, containers, volumes)
set /p confirm="Are you sure? (y/N): "
if /i "!confirm!"=="y" (
    echo [INFO] Cleaning up...
    docker system prune -f
    if %errorlevel% equ 0 (
        echo [INFO] Cleanup completed!
    ) else (
        echo [ERROR] Failed to clean up resources.
    )
) else (
    echo [INFO] Cleanup cancelled.
)
goto end

:help
echo ==========================================
echo Odoo 18 Enterprise Management Script
echo ==========================================
echo Usage: %0 {start^|stop^|restart^|status^|logs^|logs-db^|shell^|db-shell^|backup^|restore^|update^|clean}
echo.
echo Commands:
echo   start      - Start Odoo services
echo   stop       - Stop Odoo services
echo   restart    - Restart Odoo services
echo   status     - Show service status
echo   logs       - Show Odoo logs (follow mode)
echo   logs-db    - Show database logs (follow mode)
echo   shell      - Open Odoo container shell
echo   db-shell   - Open database shell
echo   backup     - Create database backup
echo   restore    - Restore database from backup
echo   update     - Update to latest image
echo   clean      - Clean up unused Docker resources
echo.
echo Examples:
echo   %0 start
echo   %0 logs
echo   %0 backup
echo   %0 restore "odoo_backup_20240101_120000.sql"
echo.

:end
if "%1" neq "logs" if "%1" neq "logs-db" if "%1" neq "shell" if "%1" neq "db-shell" pause

