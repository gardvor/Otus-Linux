# Запустить nginx на нестандартном порту 3-мя разными способами

## Что требуется
Требуется установленное програмное обеспечение

Hashicorp Vagrant, Oracle VirtualBox

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Домашнее задание
* Копируем все файлы из репозитория в одну папку
* Запускаем проект командой 
```
vagrant up
```
* Vagrant выдает ошибку при запуске nginx
```
    selinux: Jan 03 17:19:12 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
    selinux: Jan 03 17:19:12 selinux nginx[25747]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    selinux: Jan 03 17:19:12 selinux nginx[25747]: nginx: [emerg] bind() to 0.0.0.0:4881 failed (13: Permission denied)
    selinux: Jan 03 17:19:12 selinux nginx[25747]: nginx: configuration file /etc/nginx/nginx.conf test failed
    selinux: Jan 03 17:19:12 selinux systemd[1]: nginx.service: Control process exited, code=exited status=1
    selinux: Jan 03 17:19:12 selinux systemd[1]: nginx.service: Failed with result 'exit-code'.
    selinux: Jan 03 17:19:12 selinux systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
```
* Подключаемся к виртуальной машине
```
vagrant ssh
```
* Проверяем работает ли Firewall
```
[root@selinux ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: inactive (dead)
     Docs: man:firewalld(1)
```
* Проверяем корректность конфигурации nginx
```
[root@selinux ~]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```
* Проверяем режим работы SELinux
```
[root@selinux ~]# getenforce
Enforcing
```
### Разрешим в SELinux работу nginx на порту TCP 4881 c помощью переключателей setsebool
* Находим в логах информацию о блокировании порта
```
cat /var/log/audit/audit.log | grep 4881
type=SERVICE_START msg=audit(1641230351.711:904): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=run-r08a0b0081e364881b5a71cf58a652ee6 comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'UID="root" AUID="unset"
type=AVC msg=audit(1641230352.419:906): avc:  denied  { name_bind } for  pid=25747 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
type=SERVICE_STOP msg=audit(1641230353.142:925): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=run-r08a0b0081e364881b5a71cf58a652ee6 comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'UID="root" AUID="unset"
```
* Нужная строка
```
type=AVC msg=audit(1641230352.419:906): avc:  denied  { name_bind } for  pid=25747 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
```
* Смотрим информацию об ошибке с помощью утилиты Audit2why
```
[root@selinux ~]# grep 1641230352.419:906 /var/log/audit/audit.log | audit2why
type=AVC msg=audit(1641230352.419:906): avc:  denied  { name_bind } for  pid=25747 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

        Was caused by:
        The boolean nis_enabled was set incorrectly.
        Description:
        Allow system to run with NIS

        Allow access by executing:
        # setsebool -P nis_enabled 1
```
* Включим параметр nis_enabled и перезапустим nginx
```
[root@selinux ~]# setsebool -P nis_enabled 1
[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2022-01-03 17:43:32 UTC; 10s ago
  Process: 26197 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 26195 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 26194 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 26199 (nginx)
    Tasks: 2 (limit: 5972)
   Memory: 3.9M
   CGroup: /system.slice/nginx.service
           ├─26199 nginx: master process /usr/sbin/nginx
           └─26200 nginx: worker process

Jan 03 17:43:32 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jan 03 17:43:32 selinux nginx[26195]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jan 03 17:43:32 selinux nginx[26195]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Jan 03 17:43:32 selinux systemd[1]: nginx.service: Failed to parse PID from file /run/nginx.pid: Invalid argument
Jan 03 17:43:32 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
```
* Проверим работу nginx
```
[root@selinux ~]# curl 127.0.0.1:4881
```
* Проверим статус параметра nis_enabled
```
[root@selinux ~]# getsebool -a | grep nis_enabled
nis_enabled --> on
```
* Вернем запрет работы nginx
```
[root@selinux ~]# setsebool -P nis_enabled 0
```
### Разрешим в SELinux работу nginx на порту TCP 4881 c помощью добавления нестандартного порта в имеющийся тип

* Поиск имеющегося типа, для http трафика:
```
[root@selinux ~]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989
```
* Добавим порт в тип http_port_t:
```
[root@selinux ~]# semanage port -a -t http_port_t -p tcp 4881
[root@selinux ~]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      4881, 80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989
```
* Перезапускаем nginx
```
[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2022-01-03 17:55:51 UTC; 5s ago
  Process: 26248 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 26246 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 26245 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 26250 (nginx)
    Tasks: 2 (limit: 5972)
   Memory: 3.9M
   CGroup: /system.slice/nginx.service
           ├─26250 nginx: master process /usr/sbin/nginx
           └─26251 nginx: worker process

Jan 03 17:55:51 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jan 03 17:55:51 selinux nginx[26246]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jan 03 17:55:51 selinux nginx[26246]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Jan 03 17:55:51 selinux systemd[1]: nginx.service: Failed to parse PID from file /run/nginx.pid: Invalid argument
Jan 03 17:55:51 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
```
* Проверяем работу nginx
```
curl 127.0.0.1:4881
```
* Удаляем порт из типа http_port_t 
```
[root@selinux ~]# semanage port -d -t http_port_t -p tcp 4881
[root@selinux ~]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989
```
### Разрешим в SELinux работу nginx на порту TCP 4881 c помощью формирования и установки модуля SELinux:


* Вернем запрет работы nginx
```
[root@selinux ~]# setsebool -P nis_enabled 0
```* Вернем запрет работы nginx
```
[root@selinux ~]# setsebool -P nis_enabled 0
```* Вернем запрет работы nginx
```
[root@selinux ~]# setsebool -P nis_enabled 0
```
