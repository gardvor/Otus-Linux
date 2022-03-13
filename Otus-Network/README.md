# Otus-Network
Домашнее задание OTUS Linux Professional по теме "Архитектура сетей"

## Что требуется
Работа выполнялась на стенде Windows 10, Hashicorp Vagrant 2.2.19, Oracle VirtualBox 6.3

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Задание

Дано https://github.com/erlong15/otus-linux/tree/network (ветка network)Vagrantfile с начальным построением сети

* inetRouter
* centralRouter
* centralServer тестировалось на virtualbox

Планируемая архитектура

* Сеть office1
  * 192.168.2.0/26 - dev
  * 192.168.2.64/26 - test servers
  * 192.168.2.128/26 - managers
  * 192.168.2.192/26 - office hardware 
* Сеть office2
  * 192.168.1.0/25 - dev
  * 192.168.1.128/26 - test servers
  * 192.168.1.192/26 - office hardware 
* Сеть central
  * 192.168.0.0/28 - directors
  * 192.168.0.32/28 - office hardware
  * 192.168.0.64/26 - wifi 

``` 
Office1 ---\
             ----> Central --IRouter --> internet 
Office2----/ 
``` 
Итого должны получится следующие сервера:
* inetRouter
* centralRouter
* office1Router
* office2Router
* centralServer
* office1Server
* office2Server


Теоретическая часть:
* Найти свободные подсети
* Посчитать сколько узлов в каждой подсети, включая свободные
* Указать broadcast адрес для каждой подсети
* проверить нет ли ошибок при разбиении

Практическая часть:
* Соединить офисы в сеть согласно схеме и настроить роутинг
* Все сервера и роутеры должны ходить в инет черз inetRouter
* Все сервера должны видеть друг друга
* У всех новых серверов отключить дефолт на нат (eth0), который вагрант поднимает для связи


## Теоретическая часть

### Найти свободные подсети, посчитать количество узлов и указать Broadcast адреса

Данные представлены в таблице

Подсеть | Наименование подсети | Количество свободных IP | Broadcast адрес
--- | --- | --- | ---
192.168.2.0/26 | office1 - dev | 62 | 192.168.2.63
192.168.2.64/26 | office1 - test servers | 62 | 192.168.2.127
192.168.2.128/26 | office1 - managers | 62 | 192.168.2.191 
192.168.2.192/26 | office1 - office hardware | 62 | 192.168.2.255
192.168.1.0/25 | office2 - dev | 126 | 192.168.1.127
192.168.1.128/26 | office2 - test servers | 62 | 192.168.1.191
192.168.1.192/26 | office2 - office hardware | 62 | 192.168.1.255 
192.168.0.0/28 | central - directors | 14 | 192.168.0.15 
192.168.0.16/28 | central - free | 14 | 192.168.0.31
192.168.0.32/28 | central - office hardware | 14 | 192.168.0.47
192.168.0.48/28 | central - free | 14 | 192.168.0.63
192.168.0.64/26 | central - wifi | 62 | 192.168.0.127
192.168.0.128/25 | central - free | 126 | 192.168.0.255

Свободные подсети

Подсеть | Наименование подсети | Количество свободных IP | Broadcast адрес
--- | --- | --- | ---
192.168.0.16/28 | central - free | 14 | 192.168.0.31
192.168.0.48/28 | central - free | 14 | 192.168.0.63
192.168.0.128/25 | central - free | 126 | 192.168.0.255


## Практическая часть
* Соединить офисы в сеть согласно схеме и настроить маршруты

![Схема](https://github.com/gardvor/Otus-Linux/blob/main/Otus-Network/Theory/Scheme.jpg)

* На основании схемы подготовим таблицу серверов с интерфейсами которые нужно на них настроить

Сервер | Подсети | OS
--- | --- | ---
inetRouter | Default-NAT address Virtual Box | CentOS 7
inetRouter | 192.168.255.1/30 | CentOS 7
centralRouter | 192.168.255.2/30 | CentOS 7
centralRouter | 192.168.0.1/28 | CentOS 7
centralRouter | 192.168.0.33/28| CentOS 7
centralRouter | 192.168.0.65/26 | CentOS 7
centralRouter | 192.168.255.9/30 | CentOS 7
centralRouter | 192.168.255.5/30 | CentOS 7
office1Router | 192.168.255.10/30 | Ubuntu 20
office1Router | 192.168.2.1/26 | Ubuntu 20
office1Router | 192.168.2.65/26 | Ubuntu 20
office1Router | 192.168.2.129/26 | Ubuntu 20
office1Router | 192.168.2.193/26 | Ubuntu 20
office1Server | 192.168.2.130/26 | Ubuntu 20
office2Router| 192.168.255.6/30 | Debian 11
office2Router| 192.168.1.1/26 | Debian 11
office2Router| 192.168.1.129/26 | Debian 11
office2Router| 192.168.1.193/26 | Debian 11
office2Server| 192.168.1.2/26 | Debian 11

* В репозитории представлен [Vagrantfile](https://github.com/gardvor/Otus-Linux/blob/main/Otus-Network/Vagrantfile) с добавленными по таблице интерфейсами.
* Дальнейшая работа будет проводится со стендом собраным по этому [Vagrantfile](https://github.com/gardvor/Otus-Linux/blob/main/Otus-Network/Vagrantfile)

* Для корректной работы Ansible надо на двух серверах office2Router и office2Server вручную поставить пароль "vagrant" для пользователя vagrant

### Установка Traceroute на все сервера
* Будем проводить с помощью Ansible
```
vagrant ssh ansible
```
* Запустим подготовленный playbook
```
[vagrant@ansible ~]$ cd /vagrant
[vagrant@ansible vagrant]$ ansible-playbook ./playbooks/0-NanoTraceroute.yml -i ./inventories/hosts 
```


### Настройка NAT
* Заходим на сервер inetRouter
```
vagrant ssh inetRouter
```
* Устанавливае iptables
```
[root@inetRouter vagrant]# yum install iptables iptables-services -y
```
* Отключаем firewalld
```
[root@inetRouter vagrant]# systemctl stop firewalld
[root@inetRouter vagrant]# systemctl disable firewalld
```
* Добавляем iptables в автозагрузку
```
[root@inetRouter vagrant]# systemctl enable iptables
Created symlink from /etc/systemd/system/basic.target.wants/iptables.service to /usr/lib/systemd/system/iptables.service.
```
* Редактируем файл /etc/sysconfig/iptables приводим к следующему виду
```
# sample configuration for iptables service
# you can edit this manually or use system-config-firewall
# please do not ask us to add additional ports/services to this default configuration
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [37:2828]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
# Deny ping traffic
#-A INPUT -j REJECT --reject-with icmp-host-prohibited
#-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
*nat
:PREROUTING ACCEPT [1:161]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE
COMMIT
```
* Следующие строки запрещают ping между хостами через данный сервер их надо закомментировать
```
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
```
* Запускаем и смотрим статус iptables
```
[root@inetRouter vagrant]# systemctl start iptables
[root@inetRouter vagrant]# systemctl status iptables
● iptables.service - IPv4 firewall with iptables
   Loaded: loaded (/usr/lib/systemd/system/iptables.service; enabled; vendor preset: disabled)
   Active: active (exited) since Fri 2022-03-11 14:43:12 UTC; 8s ago
  Process: 23899 ExecStart=/usr/libexec/iptables/iptables.init start (code=exited, status=0/SUCCESS)
 Main PID: 23899 (code=exited, status=0/SUCCESS)

Mar 11 14:43:12 inetRouter systemd[1]: Starting IPv4 firewall with iptables...
Mar 11 14:43:12 inetRouter iptables.init[23899]: iptables: Applying firewall rules: [  OK  ]
Mar 11 14:43:12 inetRouter systemd[1]: Started IPv4 firewall with iptables.
```
* Пробовал сделать настройку через плейбук, почему то после копирования файла настроек не стартовал iptables. Буду разбираться.

### Маршрутизация транзитных пакетов (IP forward)
* Данную настройку будем проводить с помощью ansible, зайдем на vm ansible
```
vagrant ssh ansible
```
* Запустим подготовленный playbook
```
[vagrant@ansible ~]$ cd /vagrant
[vagrant@ansible vagrant]$ ansible-playbook ./playbooks/2-forwarding-on.yml -i ./inventories/hosts 
```
* Он установит на всех Router-серверах параметр net.ipv4.ip_forward в значение 1

### Отключение маршрута по умолчанию на интерфейсе eth0 на centralRouter и centralServer
* Данную настройку будем проводить с помощью ansible, зайдем на vm ansible
```
vagrant ssh ansible
```
* Запустим подготовленный playbook
```
[vagrant@ansible ~]$ cd /vagrant
[vagrant@ansible vagrant]$ ansible-playbook ./playbooks/3-def-routs.yml -i ./inventories/hosts
```
* Playbook отключит маршрут по умолчанию на интерфейсе vagrant eth0 и пропишет шлюз по умолчанию 192.168.0.1

### Настройка маршрутизации на CentOS серверах
#### centralServer
* Добавляем маршрут для интерфейса eth1
```
vagrant ssh centralServer
[vagrant@centralServer ~]$ sudo su
[root@centralServer vagrant]# nano /etc/sysconfig/network-scripts/route-eth1
0.0.0.0/0 via 192.168.0.1
```
* Создаем пустой файл /etc/sysconfig/network-scripts/route-eth0 что бы убрать маршрут по умолчанию через 10.0.2.2
```
[root@centralServer vagrant]# nano /etc/sysconfig/network-scripts/route-eth0
```
* Перезапустим сеть
```
[vagrant@centralServer ~]$ systemctl restart network
```
#### centralRouter
* Добавляем маршруты для eth1
```
vagrant ssh centralRouter
[root@centralRouter vagrant]# nano /etc/sysconfig/network-scripts/route-eth1
192.168.0.0/22 via 192.168.255.1
192.168.255.4/30 via 192.168.255.1
192.168.255.8./30 via 192.168.255.1
```
* Добавим обратные маршруты для интерфейсов eth5 и eth6 
```
[root@centralRouter vagrant]# nano /etc/sysconfig/network-scripts/route-eth5
192.168.1.0/24 via 192.168.255.6
192.168.255.4/30 via 192.168.255.6
[root@centralRouter vagrant]# nano /etc/sysconfig/network-scripts/route-eth6
192.168.2.0/24 via 192.168.255.10
192.168.255.8/30 via 192.168.255.10
```
* Перезапустим сеть
```
[root@centralRouter vagrant]# systemctl restart network
```
#### inetRouter
* Добавим обратный маршрут для интерфейса eth1
```
vagrant ssh inetRouter
[root@inetRouter vagrant]# nano /etc/sysconfig/network-scripts/route-eth1
192.168.0.0/22 via 192.168.255.2
192.168.255.8/30 via 192.168.255.2
192.168.255.4/30 via 192.168.255.2
```
* Перезапустим сеть
```
[root@inetRouter vagrant]# systemctl restart network
```

### Настройка маршрутизации на Ubuntu серверах
#### office1Server
* В Ubuntu все настраивается через конфигурационные файлы лежащие в каталоге /etc/netplan
```
vagrant ssh office1Server
vagrant@office1Server:~$ sudo su
root@office1Server:/home/vagrant# nano /etc/netplan/50-vagrant.yaml
```
* приводим файл к виду
```
---
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s8:
      addresses:
      - 192.168.2.130/26
      routes:
      - to: 0.0.0.0/0
        via: 192.168.2.129
    enp0s19:
      addresses:
      - 192.168.50.21/24
```
* Применим изменения
```
root@office1Server:/home/vagrant# netplan apply
root@office1Server:/home/vagrant# netplan try
```
#### office1Router
```
vagrant ssh office1Router
vagrant@office1Router:~$ sudo su
root@office1Router:/home/vagrant# nano /etc/netplan/50-vagrant.yaml 
```
* приводим файл к виду
```
---
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s8:
      addresses:
      - 192.168.255.10/30
      routes:
      - to: 0.0.0.0/0
        via: 192.168.255.9
    enp0s9:
      addresses:
      - 192.168.2.1/26
    enp0s10:
      addresses:
      - 192.168.2.65/26
    enp0s16:
      addresses:
      - 192.168.2.129/26
    enp0s17:
      addresses:
      - 192.168.2.193/26
    enp0s19:
      addresses:
      - 192.168.50.20/24
```      
* Применим изменения
```
root@office1Router:/home/vagrant# netplan apply
root@office1Router:/home/vagrant# netplan try
```

### Настройка маршрутизации на Debian серверах
