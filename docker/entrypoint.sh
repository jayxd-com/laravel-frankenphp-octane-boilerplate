#!/bin/sh
set -e

# 1. Wait for database ($DB_HOST is passed from .env/Dokploy)
echo "Waiting for database ($DB_HOST)..."
while ! nc -z $DB_HOST $DB_PORT; do
  sleep 1
done
echo "Database is ready!"

# 2. Check if APP_KEY is set
if [ -z "$APP_KEY" ]; then
    echo "No APP_KEY found, generating one..."
    php artisan key:generate --force
fi

# 3. Production Optimizations
echo "Caching configuration and routes..."
php artisan optimize:clear
php artisan optimize

echo "Optimizing Filament 4..."
# This caches Blade icons and components for massive speed gains in Octane
php artisan filament:optimize

echo "Linking storage..."
php artisan storage:link --force

# 4. Run migrations
echo "Running migrations..."
php artisan migrate --force

# 5. Start the process (CMD from docker-compose)
echo "Starting application..."
exec "$@"
