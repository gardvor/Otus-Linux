# Запустить nginx на нестандартном порту 3-мя разными способами

## Что требуется
Требуется установленное програмное обеспечение

Hashicorp Vagrant, Oracle VirtualBox

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Домашнее задание
* Копируем все файлы из репозитория в одну папку
* Запускаем проект командой 
```
vagrant up
```
* Vagrant выдает ошибку при запуске nginx
```
    selinux: Jan 03 17:19:12 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
    selinux: Jan 03 17:19:12 selinux nginx[25747]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    selinux: Jan 03 17:19:12 selinux nginx[25747]: nginx: [emerg] bind() to 0.0.0.0:4881 failed (13: Permission denied)
    selinux: Jan 03 17:19:12 selinux nginx[25747]: nginx: configuration file /etc/nginx/nginx.conf test failed
    selinux: Jan 03 17:19:12 selinux systemd[1]: nginx.service: Control process exited, code=exited status=1
    selinux: Jan 03 17:19:12 selinux systemd[1]: nginx.service: Failed with result 'exit-code'.
    selinux: Jan 03 17:19:12 selinux systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
```
* Подключаемся к виртуальной машине
```
vagrant ssh
```
* Проверяем работает ли Firewall
```
[root@selinux ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: inactive (dead)
     Docs: man:firewalld(1)
```
* Проверяем корректность конфигурации nginx
```
[root@selinux ~]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```
* Проверка доступа к целевой машине
```
curl 192.168.50.10:8080
```
