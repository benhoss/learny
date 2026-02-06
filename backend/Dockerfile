FROM php:8.3-fpm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        unzip \
        libzip-dev \
        libicu-dev \
        libonig-dev \
        libpq-dev \
    && docker-php-ext-install -j$(nproc) \
        mbstring \
        zip \
        intl \
        bcmath \
        pdo \
    && pecl install mongodb redis \
    && docker-php-ext-enable mongodb redis \
    && rm -rf /var/lib/apt/lists/*

# PHP configuration for file uploads and timeouts
RUN echo "upload_max_filesize = 50M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 50M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/uploads.ini

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
