# Otus-Rsyslog
Домашнее задание OTUS Linux Professional по теме "Сбор и анализ логов "

## Что требуется
Работа выполнялась на стенде Windows 10, Hashicorp Vagrant 2.2.19, Oracle VirtualBox 6.3

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Как работает

* Vagrant создает три виртуальные машины ansible, log и web
* На виртуальную машину ansible скриптом ansible_install.sh устанавливается Ansible 

 
## Домашнее задание
* Заходим на машину ansible
```
vagrant ssh ansible 
```
* Запустим плейбуки log.yml и web.yml они они подготовят машины log и web к проверке домашней работы 
```
[vagrant@ansible ~]$ sudo su
[root@ansible vagrant]# ansible-playbook ./playbooks/log.yml -i ./inventories/hosts 
[root@ansible vagrant]# ansible-playbook ./playbooks/web.yml -i ./inventories/hosts  
```
* Попробуем зайти на вебсервер nginx запущеный на машине web
```
[root@ansible vagrant]# curl http://192.168.11.160/
```
* Попробуем зайти на некорректный адрес
```
[root@ansible vagrant]# curl http://192.168.11.160/ffsdfsdf
```
* Провверяем логи Access и Error логи на машине log
```
vagrant ssh log 
[root@log vagrant]# sudo su
[root@log vagrant]# cat /var/log/rsyslog/web/nginx_access.log 
Feb 22 17:39:23 web nginx_access: 192.168.11.170 - - [22/Feb/2022:17:39:23 +0300] "GET / HTTP/1.1" 200 4833 "-" "curl/7.29.0"
Feb 22 17:39:28 web nginx_access: 192.168.11.170 - - [22/Feb/2022:17:39:28 +0300] "GET /ffsdfsdf HTTP/1.1" 404 3650 "-" "curl/7.29.0"
[root@log vagrant]# cat /var/log/rsyslog/web/nginx_error.log 
Feb 22 17:39:28 web nginx_error: 2022/02/22 17:39:28 [error] 24442#24442: *9 open() "/usr/share/nginx/html/ffsdfsdf" failed (2: No such file or directory), client: 192.168.11.170, server: _, request: "GET /ffsdfsdf HTTP/1.1", host: "192.168.11.160"
[root@log vagrant]#
```
* Зайдем на машину web и попытаемся изменить конфигурацию nginx
```
vagrant ssh log 
[vagrant@web ~]$ sudo su
[root@web vagrant]# chmod +x /etc/nginx/nginx.conf
[root@web vagrant]# ll /etc/nginx/nginx.conf
-rwxr-xr-x. 1 root root 1773 Feb 22 16:56 /etc/nginx/nginx.conf
``` 
* Проверим наличие записи о этом действии в файле audit.log на машине log
```
[root@log vagrant]# grep web /var/log/audit/audit.log
```
