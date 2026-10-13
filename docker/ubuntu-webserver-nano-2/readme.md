# Ubuntu Webserver mit Nano

# Dockerfile erstellen

FROM ubuntu:20.04
RUN apt-get update && apt-get install -y nano apache2
EXPOSE 80 443
CMD ["apache2ctl", "-D", "FOREGROUND"]

# Docker Image bauen
>docker build -t ubapna2 .