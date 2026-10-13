FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Vienna \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data

RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 apache2-utils openssh-server openssh-client openssl ca-certificates \
    supervisor nano vim-tiny less bash-completion \
    curl wget iproute2 iputils-ping net-tools dnsutils traceroute \
    tcpdump procps htop lsof psmisc \
    zip unzip tar gzip bzip2 xz-utils file jq git rsync \
    sudo tzdata && \
    a2enmod ssl headers rewrite && \
    a2dissite 000-default default-ssl 2>/dev/null || true
RUN rm -rf /var/lib/apt/lists/* && mkdir -p /run/sshd /var/www/html /certificates /var/log/supervisor

COPY config/apache-site.conf /etc/apache2/sites-available/local-https.conf
COPY config/sshd-local.conf /etc/ssh/sshd_config.d/90-local-container.conf
COPY config/supervisord.conf /etc/supervisor/conf.d/container.conf
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/create-certificates.sh /usr/local/bin/create-certificates.sh
COPY www/index.html /usr/local/share/default-web/index.html
RUN chmod 0755 /usr/local/bin/entrypoint.sh /usr/local/bin/create-certificates.sh && \
    a2ensite local-https && \
    chmod 700 /root

EXPOSE 80 443 22
VOLUME ["/var/www/html", "/certificates"]
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
