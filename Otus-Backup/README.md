# Otus-Backup
Домашнее задание OTUS Linux Professional по теме "Резервное копировани"

## Что требуется
Работа выполнялась на стенде Windows 10, Hashicorp Vagrant 2.2.19, Oracle VirtualBox 6.3

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Как работает

* Vagrant создает три виртуальные машины ansible, backup и client
* На виртуальную машину ansible скриптом ansible_install.sh устанавливается Ansible 

 
## Домашнее задание
* Заходим на машину ansible
```
vagrant ssh ansible 
```
* Запустим playbook borg.yml он устaновит borgbackup на машины backup и client
```
[vagrant@ansible ~]$ sudo su
[root@ansible vagrant]# cd /vagrant/
[root@ansible vagrant]# ansible-playbook ./playbooks/borg.yml -i ./inventories/hosts 
```
* Запустим playbook backup.yml он подготвит машину backup для выполнения домашнего задания. 
```
[root@ansible vagrant]# ansible-playbook ./playbooks/backup.yml -i ./inventories/hosts
```
* Заходим на машину client
```
vagrant ssh client
```
* Создаем генерируем ssh ключи 
```
[vagrant@client ~]$ sudo su
[root@client vagrant]# ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Created directory '/root/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:V/QyqIuzeM3rpHqGQhOb1DdvWgROX0KBWLqH5W/IAtQ root@client
The key's randomart image is:
+---[RSA 2048]----+
|     o.oo.  .    |
|   ...+ . .o .   |
|  ..Eo.o o. + .  |
| .o .=+ o. . o   |
| ..+o.o+S .      |
|  =. o ++o       |
| . ...=*=        |
|  . .o=*o        |
|   .o=o.o.       |
+----[SHA256]-----+
```
* Передаем ключи на машину backup
```
[root@client vagrant]# ssh-copy-id borg@192.168.11.160
/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
The authenticity of host '192.168.11.160 (192.168.11.160)' can't be established.
ECDSA key fingerprint is SHA256:W11SHxWzVTmRHrsR/NIBwouU6yo3CiI4MTzVcJgUJyc.
ECDSA key fingerprint is MD5:ee:54:77:66:35:04:22:df:34:34:20:6c:a4:2a:b6:2c.
Are you sure you want to continue connecting (yes/no)? yes
/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
borg@192.168.11.160's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'borg@192.168.11.160'"
and check to make sure that only the key(s) you wanted were added.
``` 
* 
```
ssh-copy-id username@remote_host
```

