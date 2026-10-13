#!/usr/bin/env bash
set -Eeuo pipefail
cd /certificates
umask 077

# CA persists across container recreations; never publish ca.key.
if [[ ! -s ca.key || ! -s ca.crt ]]; then
  if [[ -e ca.key || -e ca.crt ]]; then
    echo >&2 'FEHLER: Unvollstaendige CA; ca.key und ca.crt gemeinsam sichern/wiederherstellen.'
    exit 1
  fi
  echo 'Erzeuge lokale Zertifizierungsstelle (CA) ...'
  openssl req -x509 -new -newkey rsa:4096 -sha256 -nodes -days 3650 \
    -keyout ca.key -out ca.crt -subj '/CN=Local Docker Demo Root CA' \
    -addext 'basicConstraints=critical,CA:TRUE,pathlen:0' \
    -addext 'keyUsage=critical,keyCertSign,cRLSign'
fi

if [[ ! -s server.key || ! -s server.crt ]]; then
  if [[ -e server.key || -e server.crt ]]; then
    echo >&2 'FEHLER: Unvollstaendiges Server-Zertifikat. server.key/server.crt gemeinsam entfernen.'
    exit 1
  fi
  san='DNS:localhost,IP:127.0.0.1'
  IFS=',' read -ra dns_values <<< "${SITE_DNS_NAMES:-localhost}"
  for value in "${dns_values[@]}"; do
    value="${value//[[:space:]]/}"
    [[ -z "$value" || "$value" == localhost ]] && continue
    if [[ ! "$value" =~ ^[A-Za-z0-9][A-Za-z0-9.-]*$ ]]; then
      echo >&2 "Ungueltiger DNS-Name: $value"; exit 1
    fi
    san+=",DNS:$value"
  done
  IFS=',' read -ra ip_values <<< "${SITE_IP_ADDRESSES:-127.0.0.1}"
  for value in "${ip_values[@]}"; do
    value="${value//[[:space:]]/}"
    [[ -z "$value" || "$value" == 127.0.0.1 ]] && continue
    # Validate IP with Python? Not installed; OpenSSL validates IP entries itself.
    if [[ ! "$value" =~ ^[0-9a-fA-F:.]+$ ]]; then
      echo >&2 "Ungueltige IP: $value"; exit 1
    fi
    san+=",IP:$value"
  done
  printf 'subjectAltName=%s\nbasicConstraints=critical,CA:FALSE\nkeyUsage=critical,digitalSignature,keyEncipherment\nextendedKeyUsage=serverAuth\n' "$san" > server.ext
  echo "Erzeuge Serverzertifikat fuer: $san"
  openssl req -new -newkey rsa:3072 -nodes -sha256 -keyout server.key \
    -out server.csr -subj '/CN=localhost'
  openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
    -out server.crt -days 365 -sha256 -extfile server.ext
  rm -f server.csr
fi
chmod 600 ca.key server.key
chmod 644 ca.crt server.crt
