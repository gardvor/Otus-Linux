# Otus-Iptables
Домашнее задание OTUS Linux Professional по теме "Фильтрация трафика - firewalld, iptables"

## Что требуется
Работа выполнялась на стенде Windows 10, Hashicorp Vagrant 2.2.19, Oracle VirtualBox 6.3

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Задание
1. Реализовать knocking port
* centralRouter может попасть на ssh inetrRouter через knock скрипт пример в материалах.)
2. Добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост.
3. Запустить nginx на centralServer.
4. пробросить 80й порт на inetRouter2 8080.
5. дефолт в инет оставить через inetRouter. Формат сдачи ДЗ - vagrant + ansible
* реализовать проход на 80й порт без маскарадинга
