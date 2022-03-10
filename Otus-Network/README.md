# Otus-Network
Домашнее задание OTUS Linux Professional по теме "Архитектура сетей"

## Что требуется
Работа выполнялась на стенде Windows 10, Hashicorp Vagrant 2.2.19, Oracle VirtualBox 6.3

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Задание

Дано https://github.com/erlong15/otus-linux/tree/network (ветка network)Vagrantfile с начальным построением сети

* inetRouter
* centralRouter
* centralServer тестировалось на virtualbox

Планируемая архитектура

* Сеть office1
  * 192.168.2.0/26 - dev
  * 192.168.2.64/26 - test servers
  * 192.168.2.128/26 - managers
  * 192.168.2.192/26 - office hardware 
* Сеть office2
  * 192.168.1.0/25 - dev
  * 192.168.1.128/26 - test servers
  * 192.168.1.192/26 - office hardware 
* Сеть central
  * 192.168.0.0/28 - directors
  * 192.168.0.32/28 - office hardware
  * 192.168.0.64/26 - wifi 

``` 
Office1 ---\
             ----> Central --IRouter --> internet 
Office2----/ 
``` 
Итого должны получится следующие сервера:
* inetRouter
* centralRouter
* office1Router
* office2Router
* centralServer
* office1Server
* office2Server


Теоретическая часть:
* Найти свободные подсети
* Посчитать сколько узлов в каждой подсети, включая свободные
* Указать broadcast адрес для каждой подсети
* проверить нет ли ошибок при разбиении

Практическая часть:
* Соединить офисы в сеть согласно схеме и настроить роутинг
* Все сервера и роутеры должны ходить в инет черз inetRouter
* Все сервера должны видеть друг друга
* У всех новых серверов отключить дефолт на нат (eth0), который вагрант поднимает для связи


## Теоретическая часть

### Найти свободные подсети
Подсеть | Наименование подсети | Количество свободных IP | Broadcast адрес
--- | --- | --- | ---
192.168.2.0/26 | 192.168.2.0/26 | dev | 64 
192.168.2.64/26 | 192.168.2.64/26 | test servers | 64 
192.168.2.128/26| 192.168.2.128/26 | managers | 64 
Сеть office1 | 192.168.2.192/26 | office hardware | 64 
Сеть office2 | 192.168.1.0/25 | dev | 128 
Сеть office2 | 192.168.1.128/26 | test servers | 64 
Сеть office2 | 192.168.1.192/26 | office hardware | 64 
Сеть central | 192.168.0.16/28 | undefined | 16 
Сеть central | 192.168.0.128/25 | undefined | 128 
Сеть central | 192.168.0.48/28 | undefined | 16 
Сеть central | 192.168.0.0/28 | directors | 16 
Сеть central | 192.168.0.32/28 | office hardware | 16 
Сеть central | 192.168.0.64/26 | wifi | 64 



