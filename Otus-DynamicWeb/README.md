# OTUS - DYNAMICWEB
Домашнее задание OTUS Linux Professional по теме "Динамический веб"

## Что требуется
Работа выполнялась на стенде Windows 10, Hashicorp Vagrant 2.2.19, Oracle VirtualBox 6.3

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Задание
* развертывание веб приложения
* Варианты стенда:

* nginx + php-fpm (laravel/wordpress) + python (flask/django) + js(react/angular);
* nginx + java (tomcat/jetty/netty) + go + ruby;
* можно свои комбинации. Реализации на выбор:
* на хостовой системе через конфиги в /etc;
* деплой через docker-compose. Для усложнения можно попросить проекты у коллег с курсов по разработке К сдаче принимается:
* vagrant стэнд с проброшенными на локалхост портами
* каждый порт на свой сайт через нжинкс 
* Формат сдачи ДЗ - vagrant + ansible

## Выполнение домашнего задания
* Будем настраивать
* php-fpm + laravel + 8080 порт
* python + uwsgi + django + 8081 порт
* ReactJs + 8082 порт

* Команда vagrant up создает две виртуальные машины web и ansible
* Заходим на ВМ ansible и запускаем подготовленный плейбук
```
vagrant ssh ansible
[vagrant@ansible ~]$ cd /vagrant
[vagrant@ansible vagrant]$ ansible-playbook ./web.yml 
```
* После того как плейбук закончит работать можно проверять домашнюю работу
* 
 
