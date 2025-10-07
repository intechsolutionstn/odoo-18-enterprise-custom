@echo off
REM Script to remove Odoo subscription expiration warning for test environment
REM This updates the database expiration date to end of 2030

setlocal enabledelayedexpansion

REM Configuration
set DB_HOST=odoo18_enterprise-db-1
set DB_USER=odoo
set DB_NAME=postgres
set EXPIRATION_DATE=2030-12-31 23:59:59
set LOG_FILE=odoo_expiration_update.log

REM Colors for output (using echo with color codes)

echo ==========================================
echo Odoo Subscription Warning Removal Script
echo ==========================================
echo.

REM Function to log with timestamp
:log_message
echo %date% %time% - %~1 >> "%LOG_FILE%"
echo %date% %time% - %~1
goto :eof

REM Check if Docker is running
echo [INFO] Checking Docker status...
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)

REM Check if Odoo containers are running
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

REM Update the expiration date
echo [INFO] Updating database expiration date...
call :log_message "Starting expiration date update..."

REM Execute the update command
docker exec %DB_HOST% psql -U %DB_USER% -d %DB_NAME% -c "UPDATE ir_config_parameter SET value = '%EXPIRATION_DATE%', write_date = NOW() WHERE key = 'database.expiration_date';" >nul 2>&1

if %errorlevel% equ 0 (
    call :log_message "Successfully updated expiration date to %EXPIRATION_DATE%"
) else (
    call :log_message "ERROR: Failed to update expiration date"
    echo [ERROR] Failed to update expiration date. Please check database connection.
    pause
    exit /b 1
)

REM Verify the update
echo [INFO] Verifying the update...
for /f "tokens=*" %%i in ('docker exec %DB_HOST% psql -U %DB_USER% -d %DB_NAME% -t -c "SELECT value FROM ir_config_parameter WHERE key = 'database.expiration_date';" 2^>nul') do set CURRENT_VALUE=%%i

REM Clean up the value (remove spaces and newlines)
set CURRENT_VALUE=%CURRENT_VALUE: =%
set CURRENT_VALUE=%CURRENT_VALUE: =%

if "%CURRENT_VALUE%"=="%EXPIRATION_DATE%" (
    call :log_message "Verification successful: expiration date is correctly set to %CURRENT_VALUE%"
    echo [SUCCESS] Subscription warning has been removed!
) else (
    call :log_message "WARNING: Verification failed. Current value: %CURRENT_VALUE%, Expected: %EXPIRATION_DATE%"
    echo [WARNING] Verification failed. Current value: %CURRENT_VALUE%
)

call :log_message "Expiration date update completed"

echo.
echo ==========================================
echo Process completed!
echo ==========================================
echo.
echo [INFO] You may need to refresh your browser to see the changes.
echo [INFO] If the warning still appears, try clearing your browser cache.
echo.
echo [INFO] Log file created: %LOG_FILE%
echo.
pause
