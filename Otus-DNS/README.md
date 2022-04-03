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
#### Client1
* Должен видеть адреса 
* web1.dns.lab
```
[vagrant@client1 ~]$ ping web1.dns.lab
PING web1.dns.lab (192.168.50.15) 56(84) bytes of data.
64 bytes from client1 (192.168.50.15): icmp_seq=1 ttl=64 time=0.006 ms
64 bytes from client1 (192.168.50.15): icmp_seq=2 ttl=64 time=0.048 ms
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
