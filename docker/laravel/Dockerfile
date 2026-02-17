FROM php:8.4-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libicu-dev \
    libzip-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_sqlite intl zip bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Allow environment variables to pass through to PHP-FPM workers
RUN echo "clear_env = no" >> /usr/local/etc/php-fpm.d/www.conf

WORKDIR /var/www/html

# Copy composer files and install dependencies
COPY backend/composer.json backend/composer.lock* ./
RUN composer install --no-dev --optimize-autoloader 2>/dev/null || true

# Copy backend source code
COPY backend/ ./

# Create SQLite database file if it doesn't exist
RUN mkdir -p database && touch database/database.sqlite

EXPOSE 9000

CMD ["php-fpm"]
