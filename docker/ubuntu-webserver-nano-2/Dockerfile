FROM ubuntu:26.04
RUN apt-get update &&\
    apt-get install -y nano apache2
EXPOSE 80 443
CMD ["apache2ctl", "-D", "FOREGROUND"]
