FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

# Apache, SSL, SSH und Nano installieren
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apache2 \
        openssh-server \
        openssl \
        ca-certificates \
        nano && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Apache konfigurieren
# ------------------------------------------------------------

# SSL aktivieren
RUN a2enmod ssl && \
    a2enmod rewrite && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

# HTTP VirtualHost
RUN printf '%s\n' \
    '<VirtualHost *:80>' \
    '    ServerName localhost' \
    '    DocumentRoot /var/www/html' \
    '' \
    '    ErrorLog ${APACHE_LOG_DIR}/error.log' \
    '    CustomLog ${APACHE_LOG_DIR}/access.log combined' \
    '</VirtualHost>' \
    > /etc/apache2/sites-available/000-default.conf

# HTTPS VirtualHost
RUN printf '%s\n' \
    '<IfModule mod_ssl.c>' \
    '    <VirtualHost *:443>' \
    '        ServerName localhost' \
    '        DocumentRoot /var/www/html' \
    '' \
    '        SSLEngine on' \
    '        SSLCertificateFile /etc/apache2/ssl/server.crt' \
    '        SSLCertificateKeyFile /etc/apache2/ssl/server.key' \
    '' \
    '        ErrorLog ${APACHE_LOG_DIR}/error.log' \
    '        CustomLog ${APACHE_LOG_DIR}/access.log combined' \
    '    </VirtualHost>' \
    '</IfModule>' \
    > /etc/apache2/sites-available/default-ssl.conf

RUN a2ensite default-ssl

# ------------------------------------------------------------
# SSH konfigurieren
# ------------------------------------------------------------

RUN mkdir -p /run/sshd && \
    printf '%s\n' \
        'PermitRootLogin yes' \
        'PasswordAuthentication yes' \
        'UsePAM yes' \
        >> /etc/ssh/sshd_config

# ------------------------------------------------------------
# Test-Webseite
# ------------------------------------------------------------

RUN printf '%s\n' \
    '<!DOCTYPE html>' \
    '<html>' \
    '<head><meta charset="UTF-8"><title>Ubuntu Apache</title></head>' \
    '<body>' \
    '<h1>Ubuntu 26.04 Apache Server</h1>' \
    '<p>HTTPS funktioniert.</p>' \
    '</body>' \
    '</html>' \
    > /var/www/html/index.html

# ------------------------------------------------------------
# Startscript
# ------------------------------------------------------------

RUN printf '%s\n' \
    '#!/bin/bash' \
    'set -e' \
    '' \
    'if [ -z "$ROOT_PASSWORD" ]; then' \
    '    echo "FEHLER: ROOT_PASSWORD wurde nicht gesetzt!"' \
    '    echo "Beispiel: docker run -e ROOT_PASSWORD=meinpasswort ..."' \
    '    exit 1' \
    'fi' \
    '' \
    'echo "root:${ROOT_PASSWORD}" | chpasswd' \
    '' \
    '# SSH Host Keys erzeugen' \
    'ssh-keygen -A' \
    '' \
    '# Selbstsigniertes HTTPS-Zertifikat erzeugen, falls nicht vorhanden' \
    'mkdir -p /etc/apache2/ssl' \
    'if [ ! -f /etc/apache2/ssl/server.crt ]; then' \
    '    openssl req -x509 -nodes -days 3650 -newkey rsa:4096 \' \
    '        -keyout /etc/apache2/ssl/server.key \' \
    '        -out /etc/apache2/ssl/server.crt \' \
    '        -subj "/C=AT/O=LeTTo/CN=${SSL_HOSTNAME:-localhost}"' \
    'fi' \
    '' \
    'chmod 600 /etc/apache2/ssl/server.key' \
    '' \
    '# SSH starten' \
    '/usr/sbin/sshd' \
    '' \
    '# Apache im Vordergrund starten' \
    'exec apachectl -D FOREGROUND' \
    > /usr/local/bin/start-container.sh && \
    chmod +x /usr/local/bin/start-container.sh

EXPOSE 22 80 443

CMD ["/usr/local/bin/start-container.sh"]