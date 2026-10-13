# BasisKonfiguration mit ChatGPT
```
Erstelle mir ein Dockerfile für einen Container basierend auf Ubuntu:26.04 mit apache2 Webserver und Nano. Es soll weiter eine https -Zugriff mit selbssigniertem Zertifikat möglich sein. Ein Zertifikat welches ich am eigenen Browser installieren kann sollte ebenfalls vorbereitet werden. Auch eine ssh-Zugriff mit root als Benutzer sollte möglich sein. Gib in den Container noch nützliche tools wie nano, netzwerk-Konfigurationen, htop,top,zip,unzip,etc.
Erstelle weiters eine docker-compose.yml welche den Container startet und die Webseite in einem lokalen Volume hat. Passwörter sollen über eine getrennt .env einstellbar sein. Das Zertifikat für den Browser soll mit einer Anleitung ebenfalls in einem eigenen lokalen Volumen platziert werden. Standardmäßig ohne Angaben in der .env Datei sollen die Volume-Verzeichnisse als Verzeichnisse unterhalb der docker-compose.yml liegen.
Platziere alle Dateien die notwendig sind in einer Zip-Datei welche ich entpacken und sofort verwenden kann.
```

