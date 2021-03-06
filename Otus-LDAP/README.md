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
* По завершении настройки увидим такую картину
```
Setup complete

Next steps:
        1. You must make sure these network ports are open:
                TCP Ports:
                  * 80, 443: HTTP/HTTPS
                  * 389, 636: LDAP/LDAPS
                  * 88, 464: kerberos
                  * 53: bind
                UDP Ports:
                  * 88, 464: kerberos
                  * 53: bind
                  * 123: ntp

        2. You can now obtain a kerberos ticket using the command: 'kinit admin'
           This ticket will allow you to use the IPA tools (e.g., ipa user-add)
           and the web user interface.

Be sure to back up the CA certificates stored in /root/cacert.p12
These files are required to create replicas. The password for these
files is the Directory Manager password
The ipa-server-install command was successful
```
* Free-IPA сервер установлен

### Подключение клиенской машины к Free-IPA серверу
* Заходим на машину ansible
```
vagrant ssh ansible
[vagrant@ansible ~]$ sudo su
[root@ansible vagrant]# cd /vagrant_new
```
* Запускаем подготовленый плейбук он должен подключить машину ipaсlient к домену
```
[root@ansible vagrant_new]# ansible-playbook ./playbooks/provision.yml
```
* Для проверки заодим на машину ipaclient
```
vagrant ssh ipaclient
[vagrant@ipa-client ~]$ sudo su
```
* Проверяем получает ipaclient билет от домена
```
[root@ipa-client vagrant]# kinit admin
Password for admin@DEN.LOCAL: 
[root@ipa-client vagrant]# klist
Ticket cache: KCM:0
Default principal: admin@DEN.LOCAL

Valid starting       Expires              Service principal
04/10/2022 18:24:14  04/11/2022 18:24:10  krbtgt/DEN.LOCAL@DEN.LOCAL
```
* Связь с доменом есть



 
