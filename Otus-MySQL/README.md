# OTUS - MYSQL
Домашнее задание OTUS Linux Professional по теме "MySQL: Backup + Репликация"

## Что требуется
Работа выполнялась на стенде Windows 10, Hashicorp Vagrant 2.2.19, Oracle VirtualBox 6.3

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Задание
* В материалах приложены ссылки на вагрант для репликации и дамп базы bet.dmp
* Базу развернуть на мастере и настроить так, чтобы реплицировались таблицы:
* | bookmaker |
* | competition |
* | market |
* | odds |
* | outcome

* Настроить GTID репликацию x варианты которые принимаются к сдаче
* рабочий вагрантафайл
* скрины или логи SHOW TABLES
* конфиги
* пример в логе изменения строки и появления строки на реплике

## Выполнение домашнего задания
* Команда Vagrant up разворачивает стенд с нужными виртуальными машинами, и установленным и запущеным mysql
### 1. Настройка Master
* Заходим на машину master
```
vagrant ssh master
```
* Входим в интерфей mysql
```
[vagrant@master ~]$ sudo su
[root@master vagrant]# cat /var/log/mysqld.log | grep 'root@localhost:' | awk '{print $11}'
tYo,ruos!5Ge
[root@master vagrant]# mysql -u root -p'tYo,ruos!5Ge'
```
* Меняем пароль на пользователя root в mysql
```
mysql> ALTER USER USER() IDENTIFIED BY '1q2w3e$R';
```
* Проверяем параметр SERVER_ID
```
mysql> SELECT @@server_id;
+-------------+
| @@server_id |
+-------------+
|           1 |
+-------------+
```
