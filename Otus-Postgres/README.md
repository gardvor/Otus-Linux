# OTUS - POSTGRES
Домашнее задание OTUS Linux Professional по теме "Мосты, туннели и VPN"

## Что требуется
Работа выполнялась на стенде Windows 10, Hashicorp Vagrant 2.2.19, Oracle VirtualBox 6.3

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Задание
1. На 1 ВМ создаем таблицы test1 для записи, test2 для запросов на чтение.
2. Создаем публикацию таблицы test1 и подписываемся на публикацию таблицы test2 с ВМ №2.
3. На 2 ВМ создаем таблицы test2 для записи, test1 для запросов на чтение.
4. Создаем публикацию таблицы test2 и подписываемся на публикацию таблицы test1 с ВМ №1.
5. ВМ 3 использовать как реплику для чтения (подписаться на таблицы из ВМ №1 и №2 ).
6. Реализовать горячее реплицирование для высокой доступности на 4ВМ и бэкапов.

## Выполнение домашнего задания
* Команда Vagrant up разворачивает стенд с нужными виртуальными машинами и прописаными на них конфигурационными файлами
### 1. На 1 ВМ создаем таблицы test1 для записи, test2 для запросов на чтение.
* Заходим на машину postgres1
```
vagrant ssh postgres1
```
* Заходим в Posgresql
```
vagrant@postgres1:~$ sudo -u postgres psql
psql (12.10 (Ubuntu 12.10-1.pgdg18.04+1))
Type "help" for help.
```
* Создаем базу данных otus
```
postgres=# CREATE DATABASE otus;
CREATE DATABASE
```
* Заходим в базу otus
```
postgres=# \c otus
You are now connected to database "otus" as user "postgres".
```
* Создаем таблицы test1
```
otus=# CREATE TABLE test1
(
id SERIAL,
name TEXT,
price DECIMAL
);
CREATE TABLE
```
* Создаем таблицу test2
```
otus=# CREATE TABLE test2
(
id SERIAL,
name TEXT,
price DECIMAL
);
CREATE TABLE
```
### На 2 ВМ создаем таблицы test2 для записи, test1 для запросов на чтение.
* Заходим на машину postgres2
```
vagrant ssh postgres2
```
* Заходиим в Posgresql
```
vagrant@postgres2:~$ sudo -u postgres psql
psql (12.10 (Ubuntu 12.10-1.pgdg18.04+1))
Type "help" for help.
```
* Создаем базу данных otus
```
postgres=# CREATE DATABASE otus;
CREATE DATABASE
```
* Заходим в базу otus
```
postgres=# \c otus
You are now connected to database "otus" as user "postgres".
```
* Создаем таблицы test1
```
otus=# CREATE TABLE test1
(
id SERIAL,
name TEXT,
price DECIMAL
);
CREATE TABLE
```
* Создаем таблицу test2
```
otus=# CREATE TABLE test2
(
id SERIAL,
name TEXT,
price DECIMAL
);
CREATE TABLE
```
### На ВМ1 создаем публикацию таблицы test1
* Заходим на машину postgres1
```
vagrant ssh postgres1
```
* Заходим в Posgresql
```
vagrant@postgres1:~$ sudo -u postgres psql
psql (12.10 (Ubuntu 12.10-1.pgdg18.04+1))
Type "help" for help.
```
* Создаем публикацию для таблицы test1
```
otus=# CREATE PUBLICATION test1_pub FOR TABLE test1;
CREATE PUBLICATION
```
* Поменяем пароль для пользователя postgres
```
postgres=# \password
Enter new password for user "postgres": 
Enter it again:
```
* Пароль: 12345678
### На ВМ2 создаем публикацию таблицы test2
* Заходим на машину postgres2
```
vagrant ssh postgres2
```
* Заходим в Posgresql
```
vagrant@postgres2:~$ sudo -u postgres psql
psql (12.10 (Ubuntu 12.10-1.pgdg18.04+1))
Type "help" for help.
```
* Создаем публикацию для таблицы test2
```
otus=# CREATE PUBLICATION test2_pub FOR TABLE test2;
CREATE PUBLICATION
```
* Поменяем пароль для пользователя postgres
```
postgres=# \password
Enter new password for user "postgres": 
Enter it again:
```
* Пароль: 12345678
### На ВМ2 в базе otus создаем подписку на публицкацию test1_pub
```
otus=# CREATE SUBSCRIPTION test1_sub CONNECTION 'host=192.168.10.10 port=5432 password=12345678 user=postgres dbname=otus' PUBLICATION test1_pub;
NOTICE:  created replication slot "test1_sub" on publisher
CREATE SUBSCRIPTION
```
### На ВМ1 в базе otus создаем подписку на публицкацию test2_pub
```
otus=# CREATE SUBSCRIPTION test2_sub CONNECTION 'host=192.168.10.20 port=5432 password=12345678 user=postgres dbname=otus' PUBLICATION test2_pub;
NOTICE:  created replication slot "test2_sub" on publisher
CREATE SUBSCRIPTION
```

