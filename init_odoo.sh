#!/bin/bash

# Odoo 18 Enterprise Initialization Script
# This script starts Odoo and applies the subscription fix

set -e

echo "=========================================="
echo "Odoo 18 Enterprise Custom Image Starting"
echo "=========================================="

# Wait for database to be ready
echo "[INFO] Waiting for database to be ready..."
until pg_isready -h "$HOST" -p "$PORT" -U "$USER" > /dev/null 2>&1; do
    echo "[INFO] Waiting for database..."
    sleep 2
done

echo "[INFO] Database is ready!"

# Start Odoo in the background
echo "[INFO] Starting Odoo..."
exec /entrypoint.sh odoo &

# Wait a moment for Odoo to start
sleep 10

# Apply subscription fix
echo "[INFO] Applying subscription fix..."
if psql -h "$HOST" -p "$PORT" -U "$USER" -d "$DB_NAME" -f /opt/odoo/custom-scripts/fix_subscription.sql > /dev/null 2>&1; then
    echo "[SUCCESS] Subscription warning has been removed!"
else
    echo "[WARNING] Could not apply subscription fix. Odoo will continue running."
fi

echo "[INFO] Odoo 18 Enterprise is ready!"
echo "[INFO] Access at: http://localhost:8069"
echo "=========================================="

# Keep the container running
wait
