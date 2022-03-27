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
● 192.168.10.0/24
● 192.168.20.0/24
● 192.168.30.0/24
● 10.0.10.0/30
● 10.0.11.0/30
```
vagrant ssh inetRouter
```
