# Otus-Backup
Домашнее задание OTUS Linux Professional по теме "Резервное копировани"

## Что требуется
Работа выполнялась на стенде
Windows 10
Hashicorp Vagrant 2.2.19
Oracle VirtualBox 6.3

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Как работает

* Vagrant создает три виртуальные машины ansible, backup и client
* На виртуальную машину ansible скриптом ansible_install.sh устанавливается Ansible 
* 
 
## Домашнее задание
* Заходим на машину ansible
```
vagrant ssh ansible 
```
* Запустим playbook borg.yml 
```
[vagrant@ansible ~]$ sudo su
[root@ansible vagrant]# cd /vagrant/
[root@ansible vagrant]# ansible-playbook ./playbooks/borg.yml -i ./inventories/hosts 
```
* Он устaновил borgbackup на машины backup и client

*
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

