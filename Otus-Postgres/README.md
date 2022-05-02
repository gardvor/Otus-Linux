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

### Проверка
* На ВМ1 добавим в таблицу test1 данные
```
otus=# INSERT INTO test1 (name, price) VALUES ('Hammer', 4.50), ('Chainsaw', 6.20), ('Plane', 3.80);
INSERT 0 3
otus=# select * from test1;
 id |   name   | price 
----+----------+-------
  1 | Hammer   |  4.50
  2 | Chainsaw |  6.20
  3 | Plane    |  3.80
(3 rows)
```
* Проверим на машине ВМ2
```
otus=# select * from test1;
 id |   name   | price 
----+----------+-------
  1 | Hammer   |  4.50
  2 | Chainsaw |  6.20
  3 | Plane    |  3.80
(3 rows)
```
* На ВМ2 добавим в таблицу test2 данные
```
otus=# INSERT INTO test2 (name, price) VALUES ('Mirror', 4.00), ('Flower pot', 2.57), ('Vase', 3.20);
INSERT 0 3
otus=# select * from test2;
 id |    name    | price 
----+------------+-------
  1 | Mirror     |  4.00
  2 | Flower pot |  2.57
  3 | Vase       |  3.20
(3 rows)
```
* Проверяем на ВМ1
```
otus=# select * from test2;
 id |    name    | price 
----+------------+-------
  1 | Mirror     |  4.00
  2 | Flower pot |  2.57
  3 | Vase       |  3.20
(3 rows)
```
### ВМ 3 использовать как реплику для чтения (подписаться на таблицы из ВМ №1 и №2 ).
* Действуем аналогично первым двум заданияи
* Заходим на машину postgres3
```
vagrant ssh postgres3
```
* Заходим в Posgresql
```
vagrant@postgres3:~$ sudo -u postgres psql
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
* Создаем подписки на test1_pub и test2_pub
```
otus=# CREATE SUBSCRIPTION test1_sub3 CONNECTION 'host=192.168.10.10 port=5432 password=12345678 user=postgres dbname=otus' PUBLICATION test1_pub;
NOTICE:  created replication slot "test1_sub3" on publisher
CREATE SUBSCRIPTION
otus=# CREATE SUBSCRIPTION test2_sub3 CONNECTION 'host=192.168.10.20 port=5432 password=12345678 user=postgres dbname=otus' PUBLICATION test2_pub;
NOTICE:  created replication slot "test2_sub3" on publisher
CREATE SUBSCRIPTION
```
* Нельзя использовать имя подписки с предыдущих машин test1_sub и test2_sub, выдает ошибку.
* Меняем пароль пользователя postgres нужно будет для следующего задания.
```
postgres=# \password
Enter new password for user "postgres":
Enter it again:
```

### Реализовать горячее реплицирование для высокой доступности на 4ВМ и бэкапов.
* На ВМ4
```
vagrant ssh postgres4
```
* Подключаем репликацию
```
vagrant@postgres4:~$ sudo -u postgres  pg_basebackup -h 192.168.10.30 -p 5432  -P -v -R -X stream -C -S pgstandby -D /var/lib/postgresql/12/main
Password:
pg_basebackup: initiating base backup, waiting for checkpoint to complete
pg_basebackup: checkpoint completed
pg_basebackup: write-ahead log start point: 0/E000028 on timeline 1
pg_basebackup: starting background WAL receiver
pg_basebackup: created replication slot "pgstandby"
32630/32630 kB (100%), 1/1 tablespace
pg_basebackup: write-ahead log end point: 0/E000100
pg_basebackup: waiting for background process to finish streaming ...
pg_basebackup: syncing data to disk ...
pg_basebackup: base backup completed
```
* Перезапускаем службу postgresql
```
vagrant@postgres4:~$ sudo systemctl restart postgresql
```

### Проверка
#### ВМ1
```
otus=# INSERT INTO test1 (name, price) VALUES ('Screwdriver', 13.50), ('Drill', 10.40),('Axe', 5.10), ('Wrench', 2.50);
otus=# select * from test1;
 id |    name     | price 
----+-------------+-------
  1 | Hammer      |  4.50
  2 | Chainsaw    |  6.20
  3 | Plane       |  3.80
  4 | Screwdriver | 13.50
  5 | Drill       | 10.40
  6 | Axe         |  5.10
  7 | Wrench      |  2.50
(7 rows)
```
#### ВМ2
```
otus=# INSERT INTO test2 (name, price) VALUES ('Watering can', 5.10), ('Garden hose', 7.40), ('Rake', 3.30);
otus=# select * from test2;
 id |     name     | price 
----+--------------+-------
  1 | Mirror       |  4.00
  2 | Flower pot   |  2.57
  3 | Vase         |  3.20
  4 | Watering can |  5.10
  5 | Garden hose  |  7.40
  6 | Rake         |  3.30
(6 rows)
otus=# select * from test1;
 id |    name     | price 
----+-------------+-------
  1 | Hammer      |  4.50
  2 | Chainsaw    |  6.20
  3 | Plane       |  3.80
  4 | Screwdriver | 13.50
  5 | Drill       | 10.40
  6 | Axe         |  5.10
  7 | Wrench      |  2.50
(7 rows)
```
#### ВМ1
```
otus=# select * from test2;
 id |     name     | price 
----+--------------+-------
  1 | Mirror       |  4.00
  2 | Flower pot   |  2.57
  3 | Vase         |  3.20
  4 | Watering can |  5.10
  5 | Garden hose  |  7.40
  6 | Rake         |  3.30
(6 rows)
```
#### ВМ3
```
otus=# select * from test1;
 id |    name     | price 
----+-------------+-------
  1 | Hammer      |  4.50
  2 | Chainsaw    |  6.20
  3 | Plane       |  3.80
  4 | Screwdriver | 13.50
  5 | Drill       | 10.40
  6 | Axe         |  5.10
  7 | Wrench      |  2.50
(7 rows)
otus=# select * from test2;
 id |     name     | price 
----+--------------+-------
  1 | Mirror       |  4.00
  2 | Flower pot   |  2.57
  3 | Vase         |  3.20
  4 | Watering can |  5.10
  5 | Garden hose  |  7.40
  6 | Rake         |  3.30
(6 rows)
```
#### ВМ4
```
otus=# select * from test1;
 id |    name     | price 
----+-------------+-------
  1 | Hammer      |  4.50
  2 | Chainsaw    |  6.20
  3 | Plane       |  3.80
  4 | Screwdriver | 13.50
  5 | Drill       | 10.40
  6 | Axe         |  5.10
  7 | Wrench      |  2.50
(7 rows)
otus=# select * from test2;
 id |     name     | price 
----+--------------+-------
  1 | Mirror       |  4.00
  2 | Flower pot   |  2.57
  3 | Vase         |  3.20
  4 | Watering can |  5.10
  5 | Garden hose  |  7.40
  6 | Rake         |  3.30
(6 rows)
```
