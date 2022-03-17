# Otus-PXE
Домашнее задание OTUS Linux Professional по теме "DHCP, PXE "

## Что требуется
Работа выполнялась на стенде Windows 10, Hashicorp Vagrant 2.2.19, Oracle VirtualBox 6.3

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Домашнее задание
* Vagrant создает три виртуальные машины pxeserver, pxeclient, ansible
* Заходим на виртуальную машину ansible и запускаем подготовленный playbook
```
vagrant ssh ansible
[root@ansible vagrant]# sudo su
[root@ansible vagrant]# cd /vagrant
[root@ansible vagrant]# ansible-playbook ./playbook/provision.yml -i ./inventory/hosts
```
* playbook будет выполняться долго так как в него входит задача скачивания 9Гб ISO файла
* После успешного выполнения плейбука можно загружатся с виртуальной машины pxeclient и устанавливать операционную систему по сети.

* С kiсkstart файлом пока не разобрался.
