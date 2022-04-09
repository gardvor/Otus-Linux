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


