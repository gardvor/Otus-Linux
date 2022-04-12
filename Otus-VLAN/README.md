# OTUS - VPN,LACP
Домашнее задание OTUS Linux Professional по теме "Сетевые пакеты. VLAN'ы. LACP"

## Что требуется
Работа выполнялась на стенде Windows 10, Hashicorp Vagrant 2.2.19, Oracle VirtualBox 6.3

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Задание
Реализовать схему
![Схема](https://github.com/gardvor/Otus-Linux/blob/main/Otus-VLAN/network23-1801-024140.png)
* testClient1 - 10.10.10.254
* testClient2 - 10.10.10.254
* testServer1- 10.10.10.1
* testServer2- 10.10.10.1
* testClient1 и testServer1 во vlan100
* testClient2 и testServer2 во vlan101
* Завести эти сервера на CentralRouter интерфейс eth3
* Настроить teaming между InetRouter и CentralRouter на двух интерфейсах с каждой стороны

## Выполнение домашнего задания
* Команда Vagrant up разворачивает стенд с нужными виртуальными машинами
* Заходим на виртуальную машину ansible и запускаем плейбук который настроит стенд для проверки домашнего задания

```
vagrant ssh ansible
[vagrant@ansible ~]$ sudo su
[root@ansible vagrant]# cd /vagrant/
[root@ansible vagrant]# ansible-playbook ./playbooks/provision.yml 
```
### Проверим teaming
* Пингуем с inetRouter машину CentralRouter
```
[root@inetRouter vagrant]# ping 192.168.255.2
PING 192.168.255.2 (192.168.255.2) 56(84) bytes of data.    
64 bytes from 192.168.255.2: icmp_seq=1 ttl=64 time=0.832 ms
64 bytes from 192.168.255.2: icmp_seq=2 ttl=64 time=1.27 ms
```
* На интерфейсе team0 указан MAC адрес интерфейса eth1 08:00:27:a5:3a:3b
```
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master team0 state UP group default qlen 1000
    link/ether 08:00:27:a5:3a:3b brd ff:ff:ff:ff:ff:ff
    inet6 fe80::a00:27ff:fea5:3a3b/64 scope link
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master team0 state UP group default qlen 1000
    link/ether 08:00:27:39:84:dc brd ff:ff:ff:ff:ff:ff
    inet6 fe80::a00:27ff:fe39:84dc/64 scope link
       valid_lft forever preferred_lft forever
7: team0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:a5:3a:3b brd ff:ff:ff:ff:ff:ff
    inet 192.168.255.1/30 brd 192.168.255.3 scope global team0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fea5:3a3b/64 scope link
       valid_lft forever preferred_lft forever
 ```
 * Отключим интерфейс eth1
 ```
 [root@inetRouter vagrant]# ifconfig  eth1 down
 ```
* MAC адрес на интерфейсе team0 меняется на MAC адрес интерфейса eth2 08:00:27:39:84:dc
```
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast master team0 state DOWN group default qlen 1000
    link/ether 08:00:27:a5:3a:3b brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master team0 state UP group default qlen 1000
    link/ether 08:00:27:39:84:dc brd ff:ff:ff:ff:ff:ff
    inet6 fe80::a00:27ff:fe39:84dc/64 scope link
       valid_lft forever preferred_lft forever
7: team0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:39:84:dc brd ff:ff:ff:ff:ff:ff
    inet 192.168.255.1/30 brd 192.168.255.3 scope global team0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fea5:3a3b/64 scope link
       valid_lft forever preferred_lft forever
 ```
 * Пинги нормально доходят
```
[root@inetRouter vagrant]# ping 192.168.255.2
PING 192.168.255.2 (192.168.255.2) 56(84) bytes of data.
64 bytes from 192.168.255.2: icmp_seq=1 ttl=64 time=1.12 ms
64 bytes from 192.168.255.2: icmp_seq=2 ttl=64 time=1.62 ms
```
* Вывод: teaming на интерфейсах eth1 и eth2 работает.

### VLAN
* Тут возникли вопросы. 
* Настроил vlan100 на testClient1 и testServer1
* Настроил vlan101 на testClient1 и testServer1
* Настроил на centralRouter vlan100 и vlan101 на интерфейсе eth3
* Но пингуется почему то только из какого-нибудь одного влана, скорей всего потому что одинаковые подсети. С разными подсетями все работает нормально.
* Не очень понимаю как эту ситуацию разрулить 

