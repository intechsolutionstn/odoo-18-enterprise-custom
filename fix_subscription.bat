@echo off
echo ==========================================
echo Odoo Subscription Warning Removal Script
echo ==========================================
echo.

REM Configuration
set DB_HOST=odoo18_enterprise-db-1
set DB_USER=odoo
set DB_NAME=test
set EXPIRATION_DATE=2030-12-31 23:59:59

echo [INFO] Checking Docker status...
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)

echo [INFO] Checking Odoo containers...
docker ps --filter "name=odoo18_enterprise" --format "table {{.Names}}" | findstr "odoo18_enterprise" >nul
if %errorlevel% neq 0 (
    echo [ERROR] Odoo containers are not running. Please start Odoo first.
    echo Run: .\manage_odoo.bat start
    pause
    exit /b 1
)

echo [INFO] Odoo containers are running.
echo.

echo [INFO] Updating database expiration date...
echo [INFO] Setting expiration date to: %EXPIRATION_DATE%

REM Execute the update command
docker exec %DB_HOST% psql -U %DB_USER% -d %DB_NAME% -c "UPDATE ir_config_parameter SET value = '%EXPIRATION_DATE%', write_date = NOW() WHERE key = 'database.expiration_date';"

if %errorlevel% equ 0 (
    echo [SUCCESS] Successfully updated expiration date!
) else (
    echo [ERROR] Failed to update expiration date. Please check database connection.
    pause
    exit /b 1
)

echo.
echo [INFO] Verifying the update...
for /f "tokens=*" %%i in ('docker exec %DB_HOST% psql -U %DB_USER% -d %DB_NAME% -t -c "SELECT value FROM ir_config_parameter WHERE key = 'database.expiration_date';" 2^>nul') do set CURRENT_VALUE=%%i

REM Clean up the value
set CURRENT_VALUE=%CURRENT_VALUE: =%

echo [INFO] Current expiration date: %CURRENT_VALUE%

if "%CURRENT_VALUE%"=="%EXPIRATION_DATE%" (
    echo [SUCCESS] Verification successful! Subscription warning has been removed!
) else (
    echo [WARNING] Verification failed. Current value: %CURRENT_VALUE%
)

echo.
echo ==========================================
echo Process completed!
echo ==========================================
echo.
echo [INFO] You may need to refresh your browser to see the changes.
echo [INFO] If the warning still appears, try clearing your browser cache.
echo.
pause
