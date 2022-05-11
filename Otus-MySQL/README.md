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
* Проверяем включен ли режим GTID
```
mysql> SHOW VARIABLES LIKE 'gtid_mode';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| gtid_mode     | ON    |
+---------------+-------+
```
* Создаем базу bet;
```
mysql> CREATE DATABASE bet;
```
* Загрузим в нее дамп из данного в задании файла bet.dmp
```
[root@master vagrant]# mysql -uroot -p -D bet < /vagrant/bet.dmp
```
* Проверим что загрузилось
```
mysql> USE bet;
mysql> SHOW TABLES;
+------------------+
| Tables_in_bet    |
+------------------+
| bookmaker        |
| competition      |
| events_on_demand |
| market           |
| odds             |
| outcome          |
| v_same_event     |
+------------------+
```
* Создаем пользователя с правами репликации
```
mysql> CREATE USER 'replication'@'%' IDENTIFIED BY '1q2w3e$R';
mysql> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'%' IDENTIFIED BY '1q2w3e$R';
```
* Дампим базы для залива на Slave
```
[root@master vagrant]# mysqldump --all-databases --triggers --routines --master-data --ignore-table=bet.events_on_demand --ignore-table=bet.v_same_event -uroot -p > master.sql
```
* Копируем файл дамп на машину slave
```
scp ./master.sql vagrant@192.168.10.20:/home/vagrant
```
### 2. Настройка Slave
* Заходим на машину Slave
```
vagrant ssh slave
```
* Меняем конфигурационные файлы
* В файле /etc/my.cnf.d/01-base.cnf меняем параметр 
```
server-id = 1
```
на 
```
server-id = 2
```
* В файле /etc/my.cnf.d/05-binlog.cnf раскомментируем строки
```
#replicate-ignore-table=bet.events_on_demand
#replicate-ignore-table=bet.v_same_event
```

