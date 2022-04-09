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


