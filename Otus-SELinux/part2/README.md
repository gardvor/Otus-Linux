# SELinux: проблема с удаленным обновлением зоны DNS

## Что требуется
Требуется установленное програмное обеспечение

Hashicorp Vagrant, Oracle VirtualBox, Ansible

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Домашнее задание
Инженер настроил следующую схему:

- ns01 - DNS-сервер (192.168.50.10);
- client - клиентская рабочая станция (192.168.50.15).

При попытке удаленно (с рабочей станции) внести изменения в зону ddns.lab происходит следующее:
```bash
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
update failed: SERVFAIL
>
```
Инженер перепроверил содержимое конфигурационных файлов и, убедившись, что с ними всё в порядке, предположил, что данная ошибка связана с SELinux.

В данной работе предлагается разобраться с возникшей ситуацией.


#### Задание

- Выяснить причину неработоспособности механизма обновления зоны.
- Предложить решение (или решения) для данной проблемы.
- Выбрать одно из решений для реализации, предварительно обосновав выбор.
- Реализовать выбранное решение и продемонстрировать его работоспособность.


#### Решение
* Проверяем логи SELinux на vm client
```
[root@client ~]# cat /var/log/audit/audit.log  | audit2why
[root@client ~]# 
```
* ошибок нет
* подключимся на vm ns01
```
[root@localhost selinux_dns_problems]# vagrant ssh ns01
Last login: Mon Jan  3 21:01:43 2022 from 10.0.2.2
[vagrant@ns01 ~]$ sudo -i
[root@ns01 ~]#  
```
* Проверяем логи SELinux на vm ns01
```
[root@ns01 ~]# cat /var/log/audit/audit.log  | audit2why
type=AVC msg=audit(1641244203.787:1891): avc:  denied  { create } for  pid=5079 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0

	Was caused by:
		Missing type enforcement (TE) allow rule.

		You can use audit2allow to generate a loadable module to allow this access.

[root@ns01 ~]# 
```
* Ошибка контекста безопасности. Вместо типа named_t используется тип etc_t

* Проверяем проблему в каталоге /etc/named куда скопированы файлы конфигурации
```
[root@ns01 ~]# ls -laZ /etc/named
drw-rwx---. root named system_u:object_r:etc_t:s0       .
drwxr-xr-x. root root  system_u:object_r:etc_t:s0       ..
drw-rwx---. root named unconfined_u:object_r:etc_t:s0   dynamic
-rw-rw----. root named system_u:object_r:etc_t:s0       named.50.168.192.rev
-rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab
-rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab.view1
-rw-rw----. root named system_u:object_r:etc_t:s0       named.newdns.lab
[root@ns01 ~]# 
```
* Конфигурационные файлы лежат в неправильной папке. где к ним применяется не нужный в нашем случае контекст.
* Корректные папки для конфигурационных файлов можно посмотреть командой
```
[root@ns01 ~]# semanage fcontext -l | grep named        
/etc/rndc.*                                        regular file       system_u:object_r:named_conf_t:s0 
/var/named(/.*)?                                   all files          system_u:object_r:named_zone_t:s0 
/etc/unbound(/.*)?                                 all files          system_u:object_r:named_conf_t:s0 
```
* Изменим тип контекста безопасности папки /etc/named
```
[root@ns01 ~]# chcon -R -t named_zone_t /etc/named
[root@ns01 ~]# ls -laZ /etc/named/        
drw-rwx---. root named system_u:object_r:named_zone_t:s0 .
drwxr-xr-x. root root  system_u:object_r:etc_t:s0       ..
drw-rwx---. root named unconfined_u:object_r:named_zone_t:s0 dynamic
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.50.168.192.rev
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab.view1
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.newdns.lab
[root@ns01 ~]# 
```
* Попробуем опять внести измение с vm client
```
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key 
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
> quit

[vagrant@client ~]$ nslookup www.ddns.lab
Server:		192.168.50.10
Address:	192.168.50.10#53

Name:	www.ddns.lab
Address: 192.168.50.15

[vagrant@client ~]$ dig www.ddns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.8 <<>> www.ddns.lab
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 45694
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.ddns.lab.			IN	A

;; ANSWER SECTION:
www.ddns.lab.		60	IN	A	192.168.50.15

;; AUTHORITY SECTION:
ddns.lab.		3600	IN	NS	ns01.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.		3600	IN	A	192.168.50.10

;; Query time: 0 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Mon Jan 03 22:25:54 UTC 2022
;; MSG SIZE  rcvd: 96

```
* Как результат исправил файл /provisioning/playbook.yml теперь стенд работает корректно при развертывании.
