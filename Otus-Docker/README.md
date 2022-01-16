# Otus-Docker
Домашнее задание OTUS Linux Professional по теме "Docker"

## Что требуется
Домашнее задание выполнялось на CentOS 8 c установленым Docker version 20.10.12, build e91ed57


## Домашнее задание
* Образ выложен в репозиторий https://hub.docker.com/repository/docker/gardvor/otus_nginx
* [Dockerfile](https://github.com/gardvor/Otus-Linux/blob/main/Otus-Docker/Dockerfile) на основе которого создавался образ
* файлы для настройки nginx [nginx.conf](https://github.com/gardvor/Otus-Linux/blob/main/Otus-Docker/nginx.conf) [index.html] (https://github.com/gardvor/Otus-Linux/blob/main/Otus-Docker/index.html)
* Качаем образ из репозитория
```

[root@presentation docker]# docker pull gardvor/otus_nginx
Using default tag: latest
latest: Pulling from gardvor/otus_nginx
59bf1c3509f3: Pull complete
10dfd4edca90: Pull complete
4d7b2e825fc5: Pull complete
b398884bff97: Pull complete
7cd5fa7a71cf: Pull complete
73c522b3219c: Pull complete
44dd54c1aa1b: Pull complete
7bd38d0f6eb7: Pull complete
8d3a9d63a584: Pull complete
Digest: sha256:280e0a4d79bc532565d81bafb71cebb9d4087ef24638dfed077f182483a5b1a0
Status: Downloaded newer image for gardvor/otus_nginx:latest
docker.io/gardvor/otus_nginx:latest

```
* Проверяем наличие образа в локалдьном репозитории
```
[root@presentation docker]# docker images
REPOSITORY           TAG       IMAGE ID       CREATED          SIZE
gardvor/otus_nginx   latest    6d7ff349c6f1   52 minutes ago   9.33MB

```
* Запускаем docker контейнер
```
[root@presentation docker]# docker run -d --name Otus_nginx -p 8088:80 gardvor/otus_nginx
88e2222d8fc981fd5dbec149225fa97d46ed2b13e09c7d516dfaf8fea5376ad4
[root@presentation docker]# docker ps
CONTAINER ID   IMAGE                COMMAND                  CREATED          STATUS          PORTS                                   NAMES
88e2222d8fc9   gardvor/otus_nginx   "nginx -g 'daemon of…"   37 seconds ago   Up 36 seconds   0.0.0.0:8088->80/tcp, :::8088->80/tcp   Otus_nginx
```
* Впроверяем страницу которую выдает nginx на порту 8088
```
[root@presentation docker]# curl 127.0.0.1:8088
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>HTML5</title>
</head>
<body>
    Server is online
</body>
</html>

```


