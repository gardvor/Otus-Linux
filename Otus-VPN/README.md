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
* На виртуальной машине server
* создаем ключ
```
[root@server vagrant]# openvpn --genkey --secret /etc/openvpn/static.key
```
* Приводим файл конфигурации /etc/openvpn/server.conf к виду
```
dev tap
ifconfig 10.10.10.1 255.255.255.0
topology subnet
secret /etc/openvpn/static.key
comp-lzo
status /var/log/openvpn-status.log
log /var/log/openvpn.log
verb 3

```
* Запускаем OpenVPN сервер
```
[root@server vagrant]# systemctl enable --now openvpn@server
Created symlink from /etc/systemd/system/multi-user.target.wants/openvpn@server.service to /usr/lib/systemd/system/openvpn@.service.
[root@server vagrant]# systemctl status openvpn@server
● openvpn@server.service - OpenVPN Robust And Highly Flexible Tunneling Application On server
   Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2022-03-29 18:16:23 UTC; 24s ago
 Main PID: 948 (openvpn)
   Status: "Pre-connection initialization successful"
   CGroup: /system.slice/system-openvpn.slice/openvpn@server.service
           └─948 /usr/sbin/openvpn --cd /etc/openvpn/ --config server.conf

Mar 29 18:16:23 server.loc systemd[1]: Starting OpenVPN Robust And Highly Flexible Tunneling Application On server...
Mar 29 18:16:23 server.loc systemd[1]: Started OpenVPN Robust And Highly Flexible Tunneling Application On server.
```
* На виртульной машине client
* Копируем файл /etc/openvpn/static.key с машины сервер в аналогичную папку на машине client
* Приводим файл конфигурации /etc/openvpn/server.conf к виду
```
dev tap
remote 192.168.10.10
ifconfig 10.10.10.2 255.255.255.0
topology subnet
route 192.168.10.0 255.255.255.0
secret /etc/openvpn/static.key
comp-lzo
status /var/log/openvpn-status.log
log /var/log/openvpn.log
verb 3
```
* Запускаем OpenVPN сервер
```
[root@client vagrant]# systemctl enable --now openvpn@server
Created symlink from /etc/systemd/system/multi-user.target.wants/openvpn@server.service to /usr/lib/systemd/system/openvpn@.service.
[root@client vagrant]# systemctl status openvpn@server
● openvpn@server.service - OpenVPN Robust And Highly Flexible Tunneling Application On server
   Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2022-03-29 18:20:39 UTC; 9s ago
 Main PID: 952 (openvpn)
   Status: "Pre-connection initialization successful"
   CGroup: /system.slice/system-openvpn.slice/openvpn@server.service
           └─952 /usr/sbin/openvpn --cd /etc/openvpn/ --config server.conf

Mar 29 18:20:39 client.loc systemd[1]: Starting OpenVPN Robust And Highly Flexible Tunneling Application On server...
Mar 29 18:20:39 client.loc systemd[1]: Started OpenVPN Robust And Highly Flexible Tunneling Application On server.
```






