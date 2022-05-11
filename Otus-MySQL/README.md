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
* Дампим базы для залива на Slave игнорируя ненужные таблицы
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
* В файле /etc/my.cnf.d/05-binlog.cnf раскомментируем строки, для игнорирования ненужных таблиц при репликации
```
#replicate-ignore-table=bet.events_on_demand
#replicate-ignore-table=bet.v_same_event
```
* Перезапускаем MySQL
```
root@slave vagrant]# systemctl restart mysql
```
* Входим в интерфейс mysql
```
[root@slave vagrant]# cat /var/log/mysqld.log | grep 'root@localhost:' | awk '{print $11}'
*pot3sBkLle*
[root@slave vagrant]# mysql -uroot -p'*pot3sBkLle*'
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
|           2 |
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
* Сбрасываем режим master что бы не было проблем с GTID при заливке дампа Мастера
```
mysql> reset master;
```
* Заливаем дамп
```
mysql> SOURCE /home/vagrant/master.sql
```
* Проверяем залитую базу
```
mysql> SHOW DATABASES LIKE 'bet';
+----------------+
| Database (bet) |
+----------------+
| bet            |
+----------------+
mysql> USE bet;
Database changed
mysql> SHOW TABLES;
+---------------+
| Tables_in_bet |
+---------------+
| bookmaker     |
| competition   |
| market        |
| odds          |
| outcome       |
+---------------+
```
* Видно что проигнорированных таблиц нет
* Подключаем и запускаем Slave режим
```
mysql> CHANGE MASTER TO MASTER_HOST = "192.168.10.10", MASTER_PORT = 3306, MASTER_USER = "replication", MASTER_PASSWORD = "1q2w3e$R", MASTER_AUTO_POSITION = 1;
mysql> START SLAVE;
mysql> SHOW SLAVE STATUS\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.10.10
                  Master_User: replication
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000002
          Read_Master_Log_Pos: 119830
               Relay_Log_File: slave-relay-bin.000002
                Relay_Log_Pos: 414
        Relay_Master_Log_File: mysql-bin.000002
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: bet
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table: bet.events_on_demand,bet.v_same_event
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 119830
              Relay_Log_Space: 621
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File:
           Master_SSL_CA_Path:
              Master_SSL_Cert:
            Master_SSL_Cipher:
               Master_SSL_Key:
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Master_Server_Id: 1
                  Master_UUID: ea5a1d83-d15c-11ec-ba93-5254004d77d3
             Master_Info_File: /var/lib/mysql/master.info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set:
            Executed_Gtid_Set: ea5a1d83-d15c-11ec-ba93-5254004d77d3:1-40
                Auto_Position: 1
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:
```
* Slave запущен, указаные таблицы игнорируются.
### 3. Проверка
* На машине Master
```
mysql> USE bet;
mysql> SELECT * FROM bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  3 | unibet         |
+----+----------------+
```
* Добавим строку
```
mysql> INSERT INTO bookmaker (id,bookmaker_name) VALUES(1,'1xbet');
mysql> SELECT * FROM bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
|  1 | 1xbet          |
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  3 | unibet         |
+----+----------------+
```
* На машине Slave
```
mysql> USE bet;
mysql> SELECT * FROM bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
|  1 | 1xbet          |
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  3 | unibet         |
+----+----------------+
```



