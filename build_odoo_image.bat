@echo off
REM Build script for Odoo 18 Enterprise Custom Image
REM This script builds a custom Docker image with subscription warning removed

echo ==========================================
echo Odoo 18 Enterprise Custom Image Builder
echo ==========================================
echo.

REM Configuration
set IMAGE_NAME=odoo18-enterprise-custom
set IMAGE_TAG=latest
set DOCKERFILE=Dockerfile.odoo18-enterprise

echo [INFO] Building custom Odoo 18 Enterprise image...
echo [INFO] Image name: %IMAGE_NAME%:%IMAGE_TAG%
echo [INFO] Dockerfile: %DOCKERFILE%
echo.

REM Check if Docker is running
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)

REM Check if required files exist
if not exist "%DOCKERFILE%" (
    echo [ERROR] Dockerfile not found: %DOCKERFILE%
    pause
    exit /b 1
)

if not exist "fix_subscription.sql" (
    echo [ERROR] fix_subscription.sql not found
    pause
    exit /b 1
)

if not exist "init_odoo.sh" (
    echo [ERROR] init_odoo.sh not found
    pause
    exit /b 1
)

echo [INFO] All required files found.
echo.

REM Build the image
echo [INFO] Building Docker image...
docker build -f %DOCKERFILE% -t %IMAGE_NAME%:%IMAGE_TAG% .

if %errorlevel% equ 0 (
    echo [SUCCESS] Image built successfully!
    echo.
    echo [INFO] Image details:
    docker images %IMAGE_NAME%:%IMAGE_TAG%
    echo.
    echo [INFO] You can now use this image with:
    echo   docker run -d -p 8069:8069 --name odoo-custom %IMAGE_NAME%:%IMAGE_TAG%
    echo.
    echo [INFO] Or use the deployment script: .\deploy_odoo_custom.bat
) else (
    echo [ERROR] Failed to build image. Please check the error messages above.
)

echo.
pause
