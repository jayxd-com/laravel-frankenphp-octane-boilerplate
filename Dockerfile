# --- Stage 1: The Builder (Prep Station) ---
FROM php:8.4-fpm-alpine AS builder

# Install system dependencies for PHP extensions & Node
RUN apk add --no-cache \
    nodejs npm \
    icu-dev \
    libzip-dev \
    libpng-dev \
    postgresql-dev \
    zlib-dev

# Install PHP extensions required by Composer (Filament requirements)
RUN docker-php-ext-install intl zip pcntl pdo_pgsql bcmath gd

WORKDIR /app
COPY . .

# Install Composer dependencies
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Build assets (Vite)
RUN npm install && npm run build

# --- Stage 2: Final Production Image (The Plate) ---
# We use the official FrankenPHP image which replaces Nginx + PHP-FPM
FROM dunglas/frankenphp:1.4-php8.4-alpine

# 1. Install Runtime Extensions
# We use 'install-php-extensions' helper for reliability
RUN install-php-extensions \
    pdo_pgsql \
    intl \
    bcmath \
    gd \
    zip \
    pcntl \
    posix \
    exif \
    opcache \
    redis \
    soap

WORKDIR /app

# 2. Copy code from builder (Baked-in, no more volume flicker)
COPY --from=builder /app /app

# 3. Apply your custom PHP config
COPY ./docker/php/local.ini /usr/local/etc/php/conf.d/app.ini

# 4. Setup your Entrypoint
COPY ./docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 5. Fix Permissions for storage/cache
RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache

# 6. Expose Port 80 (FrankenPHP handles HTTP directly)
EXPOSE 80

# Use your entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command starts FrankenPHP in high-performance Worker Mode
CMD ["php", "artisan", "octane:start", "--server=frankenphp", "--host=0.0.0.0", "--port=80", "--admin-port=2019"]
