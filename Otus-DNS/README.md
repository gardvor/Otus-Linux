# Otus-DNS
Домашнее задание OTUS Linux Professional по теме "DNS- настройка и обслуживание "

## Что требуется
Работа выполнялась на стенде Windows 10, Hashicorp Vagrant 2.2.19, Oracle VirtualBox 6.3

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Задание
* взять стенд https://github.com/erlong15/vagrant-bind
* добавить еще один сервер client2
* завести в зоне dns.lab
* имена
* web1 - смотрит на клиент1
* web2 смотрит на клиент2
* завести еще одну зону newdns.lab
* завести в ней запись
* www - смотрит на обоих клиентов
* настроить split-dns
* клиент1 - видит обе зоны, но в зоне dns.lab только web1
* клиент2 видит только dns.lab
* настроить все без выключения selinux Формат сдачи ДЗ - vagrant + ansible

## Выполнение домашнего задания




### Настройка стенда
* Заходим на виртуальную машину ansible запускаем плейбук playbook.yml
```
vagrant ssh ansible
[vagrant@ansible ~]$ sudo su
[root@ansible vagrant]# cd /vagrant/
[root@ansible vagrant]# ansible-playbook ./provisioning/playbook.yml
```
* он установит весь нужный софт и настроит виртуальные машины для проверки домашнего задания. 
### Проверка домашнего задания
c
* Должен видеть адреса 
* web1.dns.lab
```
[vagrant@client1 ~]$ ping web1.dns.lab
PING web1.dns.lab (192.168.50.15) 56(84) bytes of data.
64 bytes from client1 (192.168.50.15): icmp_seq=1 ttl=64 time=0.006 ms
64 bytes from client1 (192.168.50.15): icmp_seq=2 ttl=64 time=0.048 ms
```
```
[vagrant@client1 ~]$ dig @192.168.50.10 web1.dns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.9 <<>> @192.168.50.10 web1.dns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 54050
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;web1.dns.lab.                  IN      A

;; ANSWER SECTION:
web1.dns.lab.           3600    IN      A       192.168.50.15

;; AUTHORITY SECTION:
dns.lab.                3600    IN      NS      ns02.dns.lab.
dns.lab.                3600    IN      NS      ns01.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.           3600    IN      A       192.168.50.10
ns02.dns.lab.           3600    IN      A       192.168.50.11

;; Query time: 0 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Sun Apr 03 11:48:07 UTC 2022
;; MSG SIZE  rcvd: 127
```
* www.newdns.lab
```
[vagrant@client1 ~]$ ping www.newdns.lab
PING www.newdns.lab (192.168.50.15) 56(84) bytes of data.
64 bytes from client1 (192.168.50.15): icmp_seq=1 ttl=64 time=0.025 ms
64 bytes from client1 (192.168.50.15): icmp_seq=2 ttl=64 time=0.046 ms
```
* Причем на адресе www.newdns.lab висят два ip адреса
```[vagrant@client1 ~]$ dig @192.168.50.10 www.newdns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.9 <<>> @192.168.50.10 www.newdns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 51644
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 2, ADDITIONAL: 3

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.newdns.lab.                        IN      A

;; ANSWER SECTION:
www.newdns.lab.         3600    IN      A       192.168.50.15
www.newdns.lab.         3600    IN      A       192.168.50.16

;; AUTHORITY SECTION:
newdns.lab.             3600    IN      NS      ns02.dns.lab.
newdns.lab.             3600    IN      NS      ns01.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.           3600    IN      A       192.168.50.10
ns02.dns.lab.           3600    IN      A       192.168.50.11

;; Query time: 0 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Sun Apr 03 11:40:11 UTC 2022
;; MSG SIZE  rcvd: 149
```
* И не должен видеть адрес web2.dns.lab
```
[vagrant@client1 ~]$ ping web2.dns.lab
ping: web2.dns.lab: Name or service not known
```
```
[vagrant@client1 ~]$ dig @192.168.50.10 web2.dns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.9 <<>> @192.168.50.10 web2.dns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 21976
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;web2.dns.lab.                  IN      A

;; AUTHORITY SECTION:
dns.lab.                600     IN      SOA     ns01.dns.lab. root.dns.lab. 2711201407 3600 600 86400 600

;; Query time: 0 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Sun Apr 03 11:48:47 UTC 2022
;; MSG SIZE  rcvd: 87
```
#### Client2
* Должен видеть адреса web1.dns.lab и web2.dns.lab
```
[vagrant@client2 ~]$ ping web1.dns.lab
PING web1.dns.lab (192.168.50.15) 56(84) bytes of data.
64 bytes from 192.168.50.15 (192.168.50.15): icmp_seq=1 ttl=64 time=0.311 ms
64 bytes from 192.168.50.15 (192.168.50.15): icmp_seq=2 ttl=64 time=0.244 ms
```
```
[vagrant@client2 ~]$ dig @192.168.50.10  web1.dns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.9 <<>> @192.168.50.10 web1.dns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 8618
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;web1.dns.lab.                  IN      A

;; ANSWER SECTION:
web1.dns.lab.           3600    IN      A       192.168.50.15

;; AUTHORITY SECTION:
dns.lab.                3600    IN      NS      ns02.dns.lab.
dns.lab.                3600    IN      NS      ns01.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.           3600    IN      A       192.168.50.10
ns02.dns.lab.           3600    IN      A       192.168.50.11

;; Query time: 0 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Sun Apr 03 11:50:19 UTC 2022
;; MSG SIZE  rcvd: 127
```
```
[vagrant@client2 ~]$ ping web2.dns.lab
PING web2.dns.lab (192.168.50.16) 56(84) bytes of data.
64 bytes from client2 (192.168.50.16): icmp_seq=1 ttl=64 time=0.008 ms
64 bytes from client2 (192.168.50.16): icmp_seq=2 ttl=64 time=0.019 ms
```
```
[vagrant@client2 ~]$ dig @192.168.50.10  web2.dns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.9 <<>> @192.168.50.10 web2.dns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 56560
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;web2.dns.lab.                  IN      A

;; ANSWER SECTION:
web2.dns.lab.           3600    IN      A       192.168.50.16

;; AUTHORITY SECTION:
dns.lab.                3600    IN      NS      ns02.dns.lab.
dns.lab.                3600    IN      NS      ns01.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.           3600    IN      A       192.168.50.10
ns02.dns.lab.           3600    IN      A       192.168.50.11

;; Query time: 0 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Sun Apr 03 11:51:07 UTC 2022
;; MSG SIZE  rcvd: 127
```
* Не должен видеть www.newdns.lab
```
[vagrant@client2 ~]$ ping www.newdns.lab
ping: www.newdns.lab: Name or service not known
```
```
[vagrant@client2 ~]$ dig @192.168.50.10  www.newdns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.9 <<>> @192.168.50.10 www.newdns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 43871
;; flags: qr rd ra ad; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.newdns.lab.                        IN      A

;; AUTHORITY SECTION:
.                       10490   IN      SOA     a.root-servers.net. nstld.verisign-grs.com. 2022040300 1800 900 604800 86400

;; Query time: 0 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Sun Apr 03 11:51:28 UTC 2022
;; MSG SIZE  rcvd: 118
```

