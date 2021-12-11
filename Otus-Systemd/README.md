# Otus-systemd
Домашнее задание OTUS Linux Professional по теме "SYSTEMD"

## Что требуется
Требуется установленное програмное обеспечение

Hashicorp Vagrant, Oracle VirtualBox

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Как работает

* Vagrant создает виртуальную машину на CentOS7
* Vagrant запускает скрипт настройки provision.sh 
* Скрипт раскидывает уже созданые unit и конфигурационные файлы по нужным папкам
* Запускает нужные сервисы
* После окончания работы Vagrant Должна быть готова к проверке домашнего задания
 
## Домашнее задание
Домашнее задание проверяется коммандами
* tail -f /var/log/messages
* systemctl status spawn-fcgi.service
* systemctl status httpd@first
* systemctl status httpd@second
