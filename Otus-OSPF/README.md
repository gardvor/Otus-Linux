# Otus-OSPF
Домашнее задание OTUS Linux Professional по теме "Статическая и динамическая маршрутизация, OSPF "

## Что требуется
Работа выполнялась на стенде Windows 10, Hashicorp Vagrant 2.2.19, Oracle VirtualBox 6.3

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Задание
1. Поднять три виртуалки
2. Объединить их разными lan
3. Поднять OSPF между машинами на базе FRR;
4. Изобразить ассиметричный роутинг;
5. Сделать один из линков "дорогим", но что бы при этом роутинг был симметричным. 
Формат сдачи: Vagrantfile + ansible

## Выполнение домашнего задания
* Командой Vagrant up развернется стенда построеный по схеме
![Схема](https://github.com/gardvor/Otus-Linux/blob/main/Otus-OSPF/Scheme.png)



### Настройка OSPF
* Заходим на виртуальную машину ansible запускаем playbook provision.yml
```
vagrant ssh ansible
[vagrant@ansible ~]$ sudo su
[root@ansible vagrant]# cd /vagrant/
[root@ansible vagrant]# ansible-playbook ./playbooks/provision.yml
```
* он установит весь нужный софт и настроит FRR для проверки маршрутизации OSPF
* В этой конфигурации у всех маршрутизаторов должен быть доступ к подсетям
    * 192.168.10.0/24
    * 192.168.20.0/24
    * 192.168.30.0/24
    * 10.0.10.0/30
    * 10.0.11.0/30
    * 10.0.12.0/30

#### Проверим доступность с router1
```
root@router1:/home/vagrant# ping 192.168.10.1
PING 192.168.10.1 (192.168.10.1) 56(84) bytes of data.
64 bytes from 192.168.10.1: icmp_seq=1 ttl=64 time=0.011 ms
64 bytes from 192.168.10.1: icmp_seq=2 ttl=64 time=0.020 ms
```

```
root@router1:/home/vagrant# ping 192.168.20.1
PING 192.168.20.1 (192.168.20.1) 56(84) bytes of data.
64 bytes from 192.168.20.1: icmp_seq=1 ttl=64 time=0.344 ms
64 bytes from 192.168.20.1: icmp_seq=2 ttl=64 time=0.653 ms
```
```
root@router1:/home/vagrant# ping 192.168.30.1
PING 192.168.30.1 (192.168.30.1) 56(84) bytes of data.
64 bytes from 192.168.30.1: icmp_seq=1 ttl=64 time=0.324 ms
64 bytes from 192.168.30.1: icmp_seq=2 ttl=64 time=0.352 ms
64 bytes from 192.168.30.1: icmp_seq=3 ttl=64 time=1.01 ms
```
```
root@router1:/home/vagrant# ping 10.0.10.1
PING 10.0.10.1 (10.0.10.1) 56(84) bytes of data.
64 bytes from 10.0.10.1: icmp_seq=1 ttl=64 time=0.013 ms
64 bytes from 10.0.10.1: icmp_seq=2 ttl=64 time=0.026 ms
```
```
root@router1:/home/vagrant# ping 10.0.11.1
PING 10.0.11.1 (10.0.11.1) 56(84) bytes of data.
64 bytes from 10.0.11.1: icmp_seq=1 ttl=63 time=0.391 ms
64 bytes from 10.0.11.1: icmp_seq=2 ttl=63 time=1.85 ms

```
```
root@router1:/home/vagrant# ping 10.0.12.1
PING 10.0.12.1 (10.0.12.1) 56(84) bytes of data.
64 bytes from 10.0.12.1: icmp_seq=1 ttl=64 time=0.025 ms
64 bytes from 10.0.12.1: icmp_seq=2 ttl=64 time=0.174 ms
```
#### Проверим трассировки с router2
```
root@router2:/home/vagrant# traceroute  10.0.10.1
traceroute to 10.0.10.1 (10.0.10.1), 30 hops max, 60 byte packets
 1  10.0.10.1 (10.0.10.1)  0.372 ms  0.344 ms  0.329 ms
```
```
traceroute to 10.0.11.1 (10.0.11.1), 30 hops max, 60 byte packets
 1  10.0.11.1 (10.0.11.1)  0.258 ms  0.231 ms  0.185 ms
```
```
traceroute to 10.0.12.1 (10.0.12.1), 30 hops max, 60 byte packets
 1  10.0.12.2 (10.0.12.2)  0.611 ms  0.583 ms  0.567 ms
 2  10.0.12.1 (10.0.12.1)  0.553 ms  0.429 ms  0.407 ms
```
```
root@router2:/home/vagrant# traceroute  192.168.10.1
traceroute to 192.168.10.1 (192.168.10.1), 30 hops max, 60 byte packets
 1  192.168.10.1 (192.168.10.1)  0.269 ms  0.235 ms  0.219 ms
```
```
root@router2:/home/vagrant# traceroute  192.168.20.1
traceroute to 192.168.20.1 (192.168.20.1), 30 hops max, 60 byte packets
 1  router2 (192.168.20.1)  0.012 ms  0.003 ms  0.002 ms
 ```
 ```
 root@router2:/home/vagrant# traceroute  192.168.30.1
traceroute to 192.168.30.1 (192.168.30.1), 30 hops max, 60 byte packets
 1  192.168.30.1 (192.168.30.1)  0.554 ms  0.528 ms  0.517 ms
```
#### Проверим изменние маршрутов при отключении одного из интерфейсов на router3

* Посмотри трассировку до интерфейса enp0s10 router2
```
root@router3:/home/vagrant# traceroute 192.168.20.1
traceroute to 192.168.20.1 (192.168.20.1), 30 hops max, 60 byte packets
 1  192.168.20.1 (192.168.20.1)  0.322 ms  0.291 ms  0.276 ms
```
* Отключим интерфейс enp0s8 на router3
```
root@router3:/home/vagrant# ifconfig enp0s8 down
```
* Проверим как изменился маршрут
```
traceroute to 192.168.20.1 (192.168.20.1), 30 hops max, 60 byte packets
 1  10.0.12.1 (10.0.12.1)  0.457 ms  0.416 ms  0.401 ms
 2  192.168.20.1 (192.168.20.1)  0.761 ms  0.746 ms  0.731 ms
```
* Траффик пошел в ообход, через router1

### Настройка ассиметричного и симметричного роутинга
* Настройка роутинга на портах router1 enp0s8 и router2 enp0s8 проводится с помощью ansible playbook 
```
[root@ansible vagrant]# ansible-playbook ./playbooks/assymetricRouting.yml 
```
* И изменения переменной symmetric_routing:  в файле ../defaults/main.yml
   * symmetric_routing: false - стоимость трафика на порт router1 enp0s8 выше чем на порт router2 enp0s8
   * symmetric_routing: true - стомость трафика на эти порты одинаковая.
#### Проверим ассимметричный роутинг - symmetric_routing: false
* На router1 запускаем пинг от 192.168.10.1 до 192.168.20.1: 
```
PING 192.168.20.1 (192.168.20.1) from 192.168.10.1 : 56(84) bytes of data.
64 bytes from 192.168.20.1: icmp_seq=1 ttl=251 time=2.43 ms
64 bytes from 192.168.20.1: icmp_seq=2 ttl=251 time=2.45 ms
64 bytes from 192.168.20.1: icmp_seq=3 ttl=251 time=2.80 ms
```
* На router2 запускае просмотр icmp пакето в на порту enp0s9 и enp0s8
```
root@router2:/home/vagrant# tcpdump -i enp0s9
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on enp0s9, link-type EN10MB (Ethernet), capture size 262144 bytes
15:06:34.304588 IP 192.168.10.1 > router2: ICMP echo request, id 10, seq 38, length 64
15:06:35.306104 IP 192.168.10.1 > router2: ICMP echo request, id 10, seq 39, length 64
15:06:36.307530 IP 192.168.10.1 > router2: ICMP echo request, id 10, seq 40, length 64
15:06:37.308923 IP 192.168.10.1 > router2: ICMP echo request, id 10, seq 41, length 64
15:06:38.345924 IP 192.168.10.1 > router2: ICMP echo request, id 10, seq 42, length 64
15:06:39.347486 IP 192.168.10.1 > router2: ICMP echo request, id 10, seq 43, length 64
15:06:40.349723 IP 192.168.10.1 > router2: ICMP echo request, id 10, seq 44, length 64
```
```
root@router2:/home/vagrant# tcpdump -i enp0s8
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on enp0s8, link-type EN10MB (Ethernet), capture size 262144 bytes
15:08:31.394121 IP 10.0.10.1 > ospf-all.mcast.net: OSPFv2, Hello, length 48
15:08:31.459616 IP router2 > ospf-all.mcast.net: OSPFv2, Hello, length 48
15:08:31.858665 IP router2 > 192.168.10.1: ICMP echo reply, id 10, seq 153, length 64
15:08:32.860426 IP router2 > 192.168.10.1: ICMP echo reply, id 10, seq 154, length 64
15:08:33.862032 IP router2 > 192.168.10.1: ICMP echo reply, id 10, seq 155, length 64
15:08:34.863892 IP router2 > 192.168.10.1: ICMP echo reply, id 10, seq 156, length 64
15:08:35.865403 IP router2 > 192.168.10.1: ICMP echo reply, id 10, seq 157, length 64
15:08:36.868353 IP router2 > 192.168.10.1: ICMP echo reply, id 10, seq 158, length 64
15:08:37.870214 IP router2 > 192.168.10.1: ICMP echo reply, id 10, seq 159, length 64
```
* Входящие и исходящие icmp пакеты ходят разными маршрутами потому что стоимость исходящего порта на router1 чем стоимость искходящего порта на router2
#### Проверим симметричный роутинг - symmetric_routing: true
Смотрим пакеты на тех же портах
```
root@router2:/home/vagrant# tcpdump -i enp0s9
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on enp0s9, link-type EN10MB (Ethernet), capture size 262144 bytes
15:13:37.105286 ARP, Request who-has 10.0.11.1 tell router2, length 28
15:13:37.105618 ARP, Reply 10.0.11.1 is-at 08:00:27:0d:a2:18 (oui Unknown), length 46
15:13:37.199652 IP 192.168.10.1 > router2: ICMP echo request, id 10, seq 452, length 64
15:13:37.199682 IP router2 > 192.168.10.1: ICMP echo reply, id 10, seq 452, length 64
15:13:38.201934 IP 192.168.10.1 > router2: ICMP echo request, id 10, seq 453, length 64
15:13:38.201958 IP router2 > 192.168.10.1: ICMP echo reply, id 10, seq 453, length 64
15:13:39.211528 IP 192.168.10.1 > router2: ICMP echo request, id 10, seq 454, length 64
15:13:39.211545 IP router2 > 192.168.10.1: ICMP echo reply, id 10, seq 454, length 64
15:13:40.238917 IP 192.168.10.1 > router2: ICMP echo request, id 10, seq 455, length 64
15:13:40.238945 IP router2 > 192.168.10.1: ICMP echo reply, id 10, seq 455, length 64
```
* На enp0s9 ходят пакеты в обе стороны, хотя это не самы короткий маршрут.
```
root@router2:/home/vagrant# tcpdump -i enp0s8
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on enp0s8, link-type EN10MB (Ethernet), capture size 262144 bytes
15:15:14.314588 IP 10.0.10.1 > ospf-all.mcast.net: OSPFv2, Hello, length 48
15:15:14.334303 IP router2 > ospf-all.mcast.net: OSPFv2, Hello, length 48
15:15:24.310084 IP 10.0.10.1 > ospf-all.mcast.net: OSPFv2, Hello, length 48
15:15:24.334362 IP router2 > ospf-all.mcast.net: OSPFv2, Hello, length 48
15:15:34.305923 IP 10.0.10.1 > ospf-all.mcast.net: OSPFv2, Hello, length 48
15:15:34.334341 IP router2 > ospf-all.mcast.net: OSPFv2, Hello, length 48
15:15:44.334432 IP router2 > ospf-all.mcast.net: OSPFv2, Hello, length 48
15:15:44.336079 IP 10.0.10.1 > ospf-all.mcast.net: OSPFv2, Hello, length 48
```
* На enp0s8 icmp пакеты ходить перестали так как на обоих роутерах на этих портах повышеная стоимость маршрута.
