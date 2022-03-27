# Otus-Iptables
Домашнее задание OTUS Linux Professional по теме "Фильтрация трафика - firewalld, iptables"

## Что требуется
Работа выполнялась на стенде Windows 10, Hashicorp Vagrant 2.2.19, Oracle VirtualBox 6.3

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Задание
1. Реализовать knocking port
* centralRouter может попасть на ssh inetrRouter через knock скрипт пример в материалах.)
2. Добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост.
3. Запустить nginx на centralServer.
4. пробросить 80й порт на inetRouter2 8080.
5. дефолт в инет оставить через inetRouter. Формат сдачи ДЗ - vagrant + ansible
* реализовать проход на 80й порт без маскарадинга

## Выполнение домашнего задания
* Командой Vagrant up развернется стенда построеный по схеме
![Схема](https://github.com/gardvor/Otus-Linux/blob/main/Otus-Iptables/Scheme.svg)


* Заходим на виртуальную машину ansible запускаем playbook provision.yml
```
vagrant ssh ansible
[vagrant@ansible ~]$ sudo su
[root@ansible vagrant]# cd /vagrant/
[root@ansible vagrant]# ansible-playbook ./playbook/0-Provision.yml -i ./inventory/hosts
```
* он установит весь нужный софт и настроит маршрутизацию
* На виртуальной машине inetRouter
```
vagrant ssh inetRouter
```
* приводим файл /etc/sysconfig/iptables к виду
```
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
COMMIT
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE
COMMIT
```
* Запускаем iptables
```
[root@inetRouter vagrant]# systemctl enable --now  iptables
Created symlink from /etc/systemd/system/basic.target.wants/iptables.service to /usr/lib/systemd/system/iptables.service.
```
* Теперь все машины на стенде ходят в интернет через inetRouter
* Проверка трассировкой с centralServer и inetRouter2 на 8.8.8.8
```
[vagrant@centralServer ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=107 time=9.09 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=107 time=10.5 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=107 time=9.74 ms
--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2004ms
rtt min/avg/max/mdev = 9.091/9.811/10.596/0.616 ms
[vagrant@centralServer ~]$ traceroute 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  gateway (192.168.0.1)  1.088 ms  0.476 ms  0.310 ms
 2  192.168.255.1 (192.168.255.1)  1.597 ms  1.814 ms  1.500 ms
 3  * * *
 4  * * *
```
```
[vagrant@inetRouter2 ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=108 time=8.58 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=108 time=12.3 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=108 time=9.16 ms
^C
--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2005ms
rtt min/avg/max/mdev = 8.585/10.042/12.379/1.669 ms
[vagrant@inetRouter2 ~]$ traceroute 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  gateway (192.168.255.1)  0.655 ms  0.369 ms  0.604 ms
 2  * * *
 3  * * *
 ```
## Проброс inetRouter порт 8080 на centralServer порт 80
* Задание выполняется с помощью ansible
```
vagrant ssh ansible
[root@ansible vagrant]# sudo su
[root@ansible vagrant]# cd /vagrant
[root@ansible vagrant]# ansible-playbook ./playbook/3-nginx_forwarding.yml -i ./inventory/hosts
```
* Плейбук запустит nginx на centralServer на 80 порту 
```
[vagrant@centralServer ~]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2022-03-22 17:03:24 UTC; 50min ago
  Process: 5331 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 5328 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 5327 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 5333 (nginx)
   CGroup: /system.slice/nginx.service
           ├─5333 nginx: master process /usr/sbin/nginx
           └─5336 nginx: worker process
```
* Запустит iptables на inetRouter2 и добавит правила для проброса портов
* Вебсервер будет доступен на 8080 порту inetRouter2
* проверим с машины ansible
```
[root@ansible vagrant]# curl http://192.168.50.11:8080
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title>Welcome to CentOS</title>
  <style rel="stylesheet" type="text/css">

        html {
        background-image:url(img/html-background.png);
        background-color: white;
        font-family: "DejaVu Sans", "Liberation Sans", sans-serif;
        font-size: 0.85em;
        line-height: 1.25em;
        margin: 0 4% 0 4%;
        }
```
* Проверим с машины inetRouter
```
[root@inetRouter vagrant]# curl http://192.168.255.2:8080
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title>Welcome to CentOS</title>
  <style rel="stylesheet" type="text/css">

        html {
        background-image:url(img/html-background.png);
        background-color: white;
        font-family: "DejaVu Sans", "Liberation Sans", sans-serif;
        font-size: 0.85em;
        line-height: 1.25em;
        margin: 0 4% 0 4%;
        }
...
```
* Так же localhost:8080 на inetRouter2 проброшен на хостовую машину и доступен через браузер
![Screen](https://github.com/gardvor/Otus-Linux/blob/main/Otus-Iptables/Screen.jpg)

## Настраиваем Knocking port
* На машине inetRouter
```
vagrant ssh inetRouter
```
* Файл /etc/sysconfig/iptables приводим к виду
```
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:TRAFFIC - [0:0]
:SSH-INPUT - [0:0]
:SSH-INPUTTWO - [0:0]
-A INPUT -j TRAFFIC
-A TRAFFIC -p icmp --icmp-type any -j ACCEPT
-A TRAFFIC -m state --state ESTABLISHED,RELATED -j ACCEPT
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 22 -m recent --rcheck --seconds 30 --name SSH2 -j ACCEPT
-A TRAFFIC -m state --state NEW -m tcp -p tcp -m recent --name SSH2 --remove -j DROP
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 9991 -m recent --rcheck --name SSH1 -j SSH-INPUTTWO
-A TRAFFIC -m state --state NEW -m tcp -p tcp -m recent --name SSH1 --remove -j DROP
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 7777 -m recent --rcheck --name SSH0 -j SSH-INPUT
-A TRAFFIC -m state --state NEW -m tcp -p tcp -m recent --name SSH0 --remove -j DROP
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 8881 -m recent --name SSH0 --set -j DROP
-A SSH-INPUT -m recent --name SSH1 --set -j DROP
-A SSH-INPUTTWO -m recent --name SSH2 --set -j DROP
-A TRAFFIC -j DROP
COMMIT
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE
COMMIT
```
* Перезагружаем iptables
```
[root@inetRouter vagrant]# systemctl restart iptables
```
* Эти не дают подключиться inetRouter по ssh без запуска специального скрипта
* Пробуем подключиться к inetRouter по ssh с CentralRouter
```
[vagrant@centralServer ~]$ ssh 192.168.255.1
ssh: connect to host 192.168.255.1 port 22: Connection timed out
```
* Не дает подключиться, выкидывает по тайм ауту
* Запускаем подготовленый knock.sh с нужными параметрами
```
[vagrant@centralRouter ~]$ sudo su
[root@centralRouter vagrant]# cd /vagrant
[root@centralRouter vagrant]# ./knock.sh 192.168.255.1 8881 7777 9991

Starting Nmap 6.40 ( http://nmap.org ) at 2022-03-22 18:12 UTC
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.00055s latency).
PORT     STATE    SERVICE
8881/tcp filtered unknown
MAC Address: 08:00:27:0E:F5:C3 (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 0.34 seconds

Starting Nmap 6.40 ( http://nmap.org ) at 2022-03-22 18:12 UTC
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.0014s latency).
PORT     STATE    SERVICE
7777/tcp filtered cbt
MAC Address: 08:00:27:0E:F5:C3 (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 0.35 seconds

Starting Nmap 6.40 ( http://nmap.org ) at 2022-03-22 18:12 UTC
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.0012s latency).
PORT     STATE    SERVICE
9991/tcp filtered issa
MAC Address: 08:00:27:0E:F5:C3 (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 0.35 seconds
[root@centralRouter vagrant]# ssh 192.168.255.1
The authenticity of host '192.168.255.1 (192.168.255.1)' can't be established.
ECDSA key fingerprint is SHA256:O5aAbXmQfjyLo8TfkhPaES3hA2/uSYoq6rf52Xdffrk.
ECDSA key fingerprint is MD5:cc:84:57:61:0a:07:b0:be:17:48:c1:98:1d:08:8f:4e.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.255.1' (ECDSA) to the list of known hosts.
root@192.168.255.1's password: 
Last login: Tue Mar 22 16:50:51 2022
[root@inetRouter ~]# 
```
* Скрипт с помощью утилиты nmap последовательно бьется на указаные в аргументах порты, после чего на inetRouter открывается 30 секундное окно для входа по ssh
