# OTUS - VPN
Домашнее задание OTUS Linux Professional по теме "Мосты, туннели и VPN"

## Что требуется
Работа выполнялась на стенде Windows 10, Hashicorp Vagrant 2.2.19, Oracle VirtualBox 6.3

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Задание
1.Между двумя виртуалками поднять vpn в режимах
* tun;
* tap; 
* Прочуствовать разницу.
2. Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку. 
3. Самостоятельно изучить, поднять ocserv и подключиться с хоста к виртуалке (*) 
4. Формат сдачи ДЗ - vagrant + ansible

## Выполнение домашнего задания
* Командой Vagrant up развернется стенд из трех виртуальных машин
* server
* client
* ansible
* Заходим на машину ansible и запускаем плейбук provision.yml он установить весь нужный софт и отключит selinux
```
vagrant ssh ansible
[vagrant@ansible ~]$ sudo su
[root@ansible vagrant]# cd /vagrant
[root@ansible vagrant]# ansible-playbook ./playbooks/provision.yml 
```
### Проверка  VPN в TUN\TAP режимах






