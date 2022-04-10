# OTUS - LDAP
Домашнее задание OTUS Linux Professional по теме "LDAP. Централизованная авторизация и аутентификация P"

## Что требуется
Работа выполнялась на стенде Windows 10, Hashicorp Vagrant 2.2.19, Oracle VirtualBox 6.1

## Разворачивание стенда
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Задание
1. Установить FreeIPA;
2. Написать Ansible playbook для конфигурации клиента; 
3. Настроить аутентификацию по SSH-ключам *
4. Firewall должен быть включен на сервере и на клиенте **
5. Формат сдачи ДЗ - vagrant + ansible

## Выполнение домашнего задания
### Установить FreeIPA server 
* Устанавливать сервер будем вручную
* На развернутом стенде заходиv на машину ipaserver
```
vagrant ssh ipaserver
[vagrant@ipa-server ~]$ sudo su
```
* Устанавливаем Stream репозиторий
```
[root@ipa-server vagrant]# dnf install @idm:DL1 -y
```
* Устанавливает FreeIPA-server
```
[root@ipa-server vagrant]# dnf install ipa-server  ipa-server-dns -y
```
* Начинаем настройку Free-IPA сервера
```
[root@ipa-server vagrant]# ipa-server-install

The log file for this installation can be found in /var/log/ipaserver-install.log
==============================================================================
This program will set up the IPA Server.
Version 4.9.6

This includes:
  * Configure a stand-alone CA (dogtag) for certificate management
  * Configure the NTP client (chronyd)
  * Create and configure an instance of Directory Server
  * Create and configure a Kerberos Key Distribution Center (KDC)
  * Configure Apache (httpd)
  * Configure SID generation
  * Configure the KDC to enable PKINIT

To accept the default shown in brackets, press the Enter key.

Do you want to configure integrated DNS (BIND)? [no]: yes
```
* Следующие параметры оставляем по умолчанию
```
Do you want to configure integrated DNS (BIND)? [no]: yes

Enter the fully qualified domain name of the computer
on which you're setting up server software. Using the form
<hostname>.<domainname>
Example: master.example.com.


Server host name [ipa-server.den.local]:
```
```
Warning: skipping DNS resolution of host ipa-server.den.local
The domain name has been determined based on the host name.

Please confirm the domain name [den.local]:
```
```
The kerberos protocol requires a Realm name to be defined.
This is typically the domain name converted to uppercase.

Please provide a realm name [DEN.LOCAL]:
```
* Назначаем мастер пароль
```
Directory Manager password:
Password (confirm)::
```
* Назначаем пароль учетной записи admin
```
IPA admin password:
Password (confirm):
```
* Назначаем IP адрес IPA сервера в нашем случае совпадает IP адресом данного хоста
```
Checking DNS domain den.local., please wait ...
Invalid IP address 127.0.1.1 for ipa-server.den.local: cannot use loopback IP address 127.0.1.1
Please provide the IP address to be used for this host name: 192.168.50.1
```
* Следующие параметры оставляем без настройки
```
Enter an additional IP address, or press Enter to skip:
Do you want to configure DNS forwarders? [yes]: no
Do you want to search for missing reverse zones? [yes]: no
NetBIOS domain name [DEN]:
Do you want to configure chrony with NTP server or pool address? [no]:
```
* Запускаем настройку с установленными параметрами
```
Continue to configure the system with these values? [no]: yes
```
