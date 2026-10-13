#!/usr/bin/env bash
set -Eeuo pipefail

if [[ -z "${ROOT_PASSWORD:-}" || "$ROOT_PASSWORD" == 'CHANGE_ME' ]]; then
  echo >&2 'FEHLER: ROOT_PASSWORD muss in .env gesetzt sein.'
  exit 1
fi
if [[ "$ROOT_PASSWORD" == *$'\n'* || "$ROOT_PASSWORD" == *:* ]]; then
  echo >&2 'FEHLER: ROOT_PASSWORD darf weder Doppelpunkt noch Zeilenumbruch enthalten.'
  exit 1
fi

mkdir -p /run/sshd /var/www/html /certificates
chmod 700 /certificates
if [[ -z "$(ls -A /var/www/html)" ]]; then
    cp -a /usr/local/share/default-web/. /var/www/html/
fi
printf 'root:%s\n' "$ROOT_PASSWORD" | chpasswd
/usr/local/bin/create-certificates.sh
ssh-keygen -A
apache2ctl configtest
/usr/sbin/sshd -t
exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/container.conf
