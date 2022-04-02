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
