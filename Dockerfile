FROM php:8.2-apache

# Apache-Konfiguration: .htaccess erlauben
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# Kopiere nur relevante Dateien ins Webverzeichnis
COPY index.php /var/www/html/
COPY assets/ /var/www/html/assets/
COPY .htaccess /var/www/html/

# Erstelle Verzeichnis für externe Konfigurationen
RUN mkdir -p /opt/Fail2Ban-Report

# Setze Berechtigungen
RUN chown -R www-data:www-data /var/www/html /opt/Fail2Ban-Report

# Port 80 freigeben
EXPOSE 80

# Starte Apache im Vordergrund
CMD ["apache2-foreground"]
