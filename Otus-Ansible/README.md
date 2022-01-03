# Otus-Ansible
Домашнее задание OTUS Linux Professional по теме "Автоматизация администрирования. Ansible-1"

## Что требуется
Требуется установленное програмное обеспечение

Hashicorp Vagrant, Oracle VirtualBox

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Как работает

* Vagrant создает две виртуальные машины a_host и a_server
* На виртуальную машину a_server скриптом ansible_install.sh устанавливает Ansible
* Устанавливать nginx будем на машину a_host с адресом 192.168.50.10
 
## Домашнее задание
* Копируем все файлы из репозитория в одну папку
* Запускаем проект командой 
```
vagrant up
```
* Подключаемся к a_server
```
vagrant ssh a_server 
```
* Переходим в папку проекта
```
cd /vagrant/
```
* Запускаем playbook
```
ansible-playbook ./playbooks/nginx.yml  -i ./inventories/hosts
```
* Проверка доступа к целевой машине
```
curl 192.168.50.10:8080
```
