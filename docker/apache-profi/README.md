# Ubuntu 26.04 LTS – Apache2, HTTPS und SSH

Ein sofort verwendbares Docker-Compose-Projekt fuer Windows 11 mit Docker Desktop oder Linux mit Docker Engine + Compose v2.

## Schnellstart

1. ZIP vollstaendig in ein Verzeichnis entpacken (einschliesslich **`.env`**).
2. Terminal / PowerShell in diesem Verzeichnis oeffnen.
3. `docker compose up -d --build` ausfuehren.
4. Im Browser **https://localhost:8443** (zunaechst Zertifikatswarnung) oder **http://localhost:8080** oeffnen.
5. Root-Login per SSH: `ssh -p 2222 root@localhost` und Passwort aus `.env`.
6. Browser-CA importieren: `certificates/ANLEITUNG-ZERTIFIKAT.txt` lesen, dann `certificates/ca.crt` installieren.

Der erste Start erzeugt CA und Serverzertifikat automatisch und legt eine Musterwebseite unter `www/index.html` an, falls das Verzeichnis leer ist.

## Verzeichnisstruktur

```text
ubuntu2604-apache-ssh/
|-- Dockerfile
|-- docker-compose.yml
|-- .env                      # Enthalten: zufaelliges initiales Root-Passwort
|-- .dockerignore
|-- .gitignore
|-- README.md
|-- config/
|   |-- apache-site.conf
|   |-- sshd-local.conf
|   `-- supervisord.conf
|-- scripts/
|   |-- entrypoint.sh
|   `-- create-certificates.sh
|-- www/
|   `-- index.html           # Von Windows aus bearbeitbar
`-- certificates/
    `-- ANLEITUNG-ZERTIFIKAT.txt
```

**Webseite und Zertifikate sind standardmaessig lokale Bind-Mount-Verzeichnisse** relativ zum Speicherort der `docker-compose.yml`. Mit `WEB_DIR` und `CERT_DIR` lassen sich andere Pfade setzen. Das Verzeichnis `certificates` enthaelt nach dem ersten Start die erzeugten Zertifikate und Schluessel.

## Konfiguration (.env)

| Variable | Standard | Beschreibung |
|---|---|---|
| `ROOT_PASSWORD` | Zufaellig in mitgelieferter `.env` | Root-Passwort, erforderlich |
| `BIND_ADDRESS` | `127.0.0.1` | Host-Interface; `0.0.0.0` macht Ports fuer LAN erreichbar |
| `HTTP_PORT` | `8080` | HTTP-Host-Port |
| `HTTPS_PORT` | `8443` | HTTPS-Host-Port |
| `SSH_PORT` | `2222` | SSH-Host-Port |
| `WEB_DIR` | `./www` | Webseite |
| `CERT_DIR` | `./certificates` | Zertifikate und Anleitung |
| `SITE_DNS_NAMES` | `localhost` | Kommagetrennte zusaetzliche DNS-Namen im HTTPS-Zertifikat |
| `SITE_IP_ADDRESSES` | `127.0.0.1` | Kommagetrennte zusaetzliche IPs im HTTPS-Zertifikat |
| `TZ` | `Europe/Vienna` | Zeitzone |

Falls du die Webseite z.B. ueber `https://192.168.1.50:8443` aufrufen willst, **vor dem ersten Start** `BIND_ADDRESS=0.0.0.0` und `SITE_IP_ADDRESSES=127.0.0.1,192.168.1.50` einstellen. Firewall muss Host-Port 8443 erlauben. Das CA-Zertifikat muss am *jeweiligen Client* importiert werden. Bei Aenderung nach erstem Start siehe Zertifikatsanleitung.

> Wichtig: Fuer die Verbindung von einem anderen Rechner nur in einem vertrauenswuerdigen Testnetz verwenden. Root-SSH mit Passwort und eine lokale CA sind keine sicheren Produktionsstandards. Das Root-Passwort befindet sich in `.env` und wird als Container-Umgebungsvariable uebergeben (auf dem Docker-Host fuer privilegierte Nutzer einsehbar). Fuer Produktion SSH-Schluessel, kein Root-Login, eigene Secrets und ein oeffentlich vertrauenswuerdiges TLS-Zertifikat verwenden.

## Betrieb

```bash
docker compose up -d --build
docker compose ps
docker compose logs -f
docker compose exec web bash
docker compose restart
docker compose down
```

Die Daten in `www/` und `certificates/` bleiben bei `docker compose down` erhalten. Nicht `ca.key` oder `server.key` veroeffentlichen; `.gitignore` und `.dockerignore` vermeiden versehentliches Einchecken bzw. den Versand ins Docker-Build-Kontext.

**Passwort aendern:** `.env` editieren und `docker compose up -d --force-recreate` ausfuehren; bei einem blossen `restart` wird ein geaendertes `.env` nicht uebernommen.

**Zertifikate:** Eine private CA wird fuer 10 Jahre erstellt und signiert ein Serverzertifikat fuer 365 Tage. Fuer Erneuerung nur `server.crt` und `server.key` bei gestopptem Container entfernen; anschliessend neu starten. Das CA-Schluesselpaar bleibt erhalten. Eine Zertifikatswarnung kann ausserdem bei abweichendem Hostnamen oder falscher Systemzeit auftreten.

**Tools:** nano, vim-tiny, curl, wget, ping, iproute2 (`ip`, `ss`), net-tools (`ifconfig`, `netstat`), dnsutils (`dig`, `nslookup`), traceroute, tcpdump, procps (`top`, `ps`), htop, lsof, psmisc, zip/unzip, tar, gzip, bzip2, xz, jq, git, rsync, openssl, SSH-Client und Apache-Utilities. Netzwerk-Konfigurationswerkzeuge sind installiert, aber Container besitzen standardmaessig keine erweiterten Rechte fuer Netzwerk-Aenderungen.

## Hinweise

- Es gibt **keinen** systemd-Prozess im Container; Supervisor betreibt Apache und sshd.
- HTTP wird **nicht** automatisch auf HTTPS umgeleitet, weil die externen Host-Ports frei konfigurierbar sind. Fuer sichere Anwendungen direkt HTTPS verwenden.
- Das Image wird bei `docker compose up -d --build` aus `ubuntu:26.04` gebaut. Internetzugang fuer Image- und Paketdownload ist beim ersten Build noetig.
