FROM php:8.2-apache

# Install optional PHP extensions you might need
RUN docker-php-ext-install pdo pdo_mysql

# Enable Apache Rewrite module
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/Fail2Ban-Report

# Optional: copy default code into image (will be overridden by volume mount)
COPY ./ /var/www/Fail2Ban-Report/

# Adjust permissions for archive folder (inside container)
RUN chown -R www-data:www-data /var/www/Fail2Ban-Report/archive || true
