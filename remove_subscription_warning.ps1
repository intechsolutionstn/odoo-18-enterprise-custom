# Script to remove Odoo subscription expiration warning for test environment
# This updates the database expiration date to end of 2030

# Configuration
$DB_HOST = "odoo18_enterprise-db-1"
$DB_USER = "odoo"
$DB_NAME = "postgres"
$EXPIRATION_DATE = "2030-12-31 23:59:59"
$LOG_FILE = "odoo_expiration_update.log"

# Colors for output
$GREEN = "Green"
$RED = "Red"
$YELLOW = "Yellow"

Write-Host "==========================================" -ForegroundColor $GREEN
Write-Host "Odoo Subscription Warning Removal Script" -ForegroundColor $GREEN
Write-Host "==========================================" -ForegroundColor $GREEN
Write-Host ""

# Function to log with timestamp
function Log-Message {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $Message"
    Add-Content -Path $LOG_FILE -Value $logEntry
    Write-Host $logEntry
}

# Check if Docker is running
Write-Host "[INFO] Checking Docker status..." -ForegroundColor Cyan
try {
    docker ps | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker not running"
    }
} catch {
    Write-Host "[ERROR] Docker is not running. Please start Docker Desktop first." -ForegroundColor $RED
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if Odoo containers are running
Write-Host "[INFO] Checking Odoo containers..." -ForegroundColor Cyan
$containers = docker ps --filter "name=odoo18_enterprise" --format "{{.Names}}"
if (-not $containers) {
    Write-Host "[ERROR] Odoo containers are not running. Please start Odoo first." -ForegroundColor $RED
    Write-Host "Run: .\manage_odoo.bat start" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "[INFO] Odoo containers are running." -ForegroundColor Green
Write-Host ""

# Update the expiration date
Write-Host "[INFO] Updating database expiration date..." -ForegroundColor Cyan
Log-Message "Starting expiration date update..."

# Execute the update command
$updateCommand = "UPDATE ir_config_parameter SET value = '$EXPIRATION_DATE', write_date = NOW() WHERE key = 'database.expiration_date';"
$result = docker exec $DB_HOST psql -U $DB_USER -d $DB_NAME -c $updateCommand 2>&1

if ($LASTEXITCODE -eq 0) {
    Log-Message "Successfully updated expiration date to $EXPIRATION_DATE"
} else {
    Log-Message "ERROR: Failed to update expiration date"
    Write-Host "[ERROR] Failed to update expiration date. Please check database connection." -ForegroundColor $RED
    Write-Host "Error details: $result" -ForegroundColor $RED
    Read-Host "Press Enter to exit"
    exit 1
}

# Verify the update
Write-Host "[INFO] Verifying the update..." -ForegroundColor Cyan
$verifyCommand = "SELECT value FROM ir_config_parameter WHERE key = 'database.expiration_date';"
$currentValue = docker exec $DB_HOST psql -U $DB_USER -d $DB_NAME -t -c $verifyCommand 2>$null

# Clean up the value (remove spaces and newlines)
$currentValue = $currentValue.Trim()

if ($currentValue -eq $EXPIRATION_DATE) {
    Log-Message "Verification successful: expiration date is correctly set to $currentValue"
    Write-Host "[SUCCESS] Subscription warning has been removed!" -ForegroundColor $GREEN
} else {
    Log-Message "WARNING: Verification failed. Current value: $currentValue, Expected: $EXPIRATION_DATE"
    Write-Host "[WARNING] Verification failed. Current value: $currentValue" -ForegroundColor $YELLOW
}

Log-Message "Expiration date update completed"

Write-Host ""
Write-Host "==========================================" -ForegroundColor $GREEN
Write-Host "Process completed!" -ForegroundColor $GREEN
Write-Host "==========================================" -ForegroundColor $GREEN
Write-Host ""
Write-Host "[INFO] You may need to refresh your browser to see the changes." -ForegroundColor Cyan
Write-Host "[INFO] If the warning still appears, try clearing your browser cache." -ForegroundColor Cyan
Write-Host ""
Write-Host "[INFO] Log file created: $LOG_FILE" -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter to exit"
