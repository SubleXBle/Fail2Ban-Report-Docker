FROM php:8.2-apache

RUN a2enmod rewrite

WORKDIR /var/www/html
COPY ./Fail2Ban-Report/* /var/www/html/Fail2Ban-Report/

EXPOSE 80
EXPOSE 443

RUN chown -R www-data:www-data /var/www/html/Fail2Ban-Report/archive || true
