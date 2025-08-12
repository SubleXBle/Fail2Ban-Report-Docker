FROM php:8.2-apache

RUN a2enmod rewrite

WORKDIR /var/www/Fail2Ban-Report

COPY ./ /var/www/Fail2Ban-Report/

RUN chown -R www-data:www-data /var/www/Fail2Ban-Report/archive || true
