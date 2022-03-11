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

### Найти свободные подсети, посчитать количество узлов и указать Broadcast адреса

Данные представлены в таблице

Подсеть | Наименование подсети | Количество свободных IP | Broadcast адрес
--- | --- | --- | ---
192.168.2.0/26 | office1 - dev | 62 | 192.168.2.63
192.168.2.64/26 | office1 - test servers | 62 | 192.168.2.127
192.168.2.128/26 | office1 - managers | 62 | 192.168.2.191 
192.168.2.192/26 | office1 - office hardware | 62 | 192.168.2.255
192.168.1.0/25 | office2 - dev | 126 | 192.168.1.127
192.168.1.128/26 | office2 - test servers | 62 | 192.168.1.191
192.168.1.192/26 | office2 - office hardware | 62 | 192.168.1.255 
192.168.0.0/28 | central - directors | 14 | 192.168.0.15 
192.168.0.16/28 | central - free | 14 | 192.168.0.31
192.168.0.32/28 | central - office hardware | 14 | 192.168.0.47
192.168.0.48/28 | central - free | 14 | 192.168.0.63
192.168.0.64/26 | central - wifi | 62 | 192.168.0.127
192.168.0.128/25 | central - free | 126 | 192.168.0.255

Свободные подсети

Подсеть | Наименование подсети | Количество свободных IP | Broadcast адрес
--- | --- | --- | ---
192.168.0.16/28 | central - free | 14 | 192.168.0.31
192.168.0.48/28 | central - free | 14 | 192.168.0.63
192.168.0.128/25 | central - free | 126 | 192.168.0.255


## Практическая часть

![Схема] (https://github.com/gardvor/Otus-Linux/blob/main/Otus-Network/Theory/Scheme.png)




