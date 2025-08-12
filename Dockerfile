FROM php:8.2-apache

# Enable Apache Rewrite
RUN a2enmod rewrite

# Copy code into container
COPY ./www /var/www/Fail2Ban-Report

# Adjust permissions for archive folder
RUN chown -R www-data:www-data /var/www/Fail2Ban-Report/archive
