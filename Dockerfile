FROM php:8.2-apache

RUN a2enmod rewrite

WORKDIR /var/www/html
COPY ./ /var/www/html/Fail2Ban-Report/

RUN chown -R www-data:www-data /var/www/html/Fail2Ban-Report/archive || true
