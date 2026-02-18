FROM php:8.2-apache

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libxml2-dev \
    libonig-dev \
    pkg-config \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) gd pdo_mysql mysqli zip xml mbstring \
  && a2enmod rewrite \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

COPY . /var/www/html

RUN mkdir -p /var/www/html/files /var/www/html/logs \
  && chown -R www-data:www-data /var/www/html/files /var/www/html/logs

COPY docker/entrypoint.sh /usr/local/bin/omeka-entrypoint
RUN chmod +x /usr/local/bin/omeka-entrypoint

ENTRYPOINT ["/usr/local/bin/omeka-entrypoint"]
CMD ["apache2-foreground"]
