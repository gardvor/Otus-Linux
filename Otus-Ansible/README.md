# Otus-Ansible
Домашнее задание OTUS Linux Professional по теме "Автоматизация администрирования. Ansible-1"

## Что требуется
Требуется установленное програмное обеспечение

Hashicorp Vagrant, Oracle VirtualBox

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Как работает

* Vagrant создает две виртуальные машины a_host и a_server
* На виртульную машину a_server скриптом ansible_install.sh устанавливает Ansible
 
## Домашнее задание
* Копируем все файлы из репозитория в одну папку
* Запускаем проект командой vagrant up
* vagrant ssh a_server 
* cd /vagrant/
* ansible-playbook ./playbooks/nginx.yml  -i ./inventories/hosts
* curl 192.168.50.10:8080
