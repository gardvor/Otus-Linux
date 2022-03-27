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


```
```
```
```

