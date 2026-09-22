# sj26k5a
* Git: https://github.com/damboeck/sj26k5a.git
* Info: Docker Linux 5AHET 2026/27

# Linux
* Linux ist toll

# Docker

## wichtige Commandos
* Liste aller Container: 
  >docker ps -a
* Liste aller laufenden Container: 
  >docker ps

## Dockerfile
>docker build -t zielcontainername .

#### Container starten
>docker run -itd --name containername -p 2022:22 zielcontainername


## Im Unterricht verwendete Kommandos
<pre>
docker build -t ubuntu-ssh .
docker run -itd --name u5bssh -p 2022:22 ubuntu-ssh
docker kill u5bssh
docker rm u5bssh
docker run -itd --name u5bssh -p 2022:22 -v C:\github\Unterricht-HTL-DAMB\s25k5b\docker\ubuntu-ssh\data:/data ubuntu-ssh
</pre>

<pre>
apt-get install iputils-ping openssh-client
docker compose up -d
docker compose up -d --build
</pre>
