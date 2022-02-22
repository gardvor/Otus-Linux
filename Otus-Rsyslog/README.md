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
* Дальнейшие дествия будем вести на машине client
```
vagrant ssh client
```
* Иницилизируем репозиторий на сервере backup с машины client (для защиты задаём пароль "borg")
```
[root@client vagrant]#  borg init --encryption=repokey borg@192.168.11.160:/var/backup/
Enter new passphrase: 
Enter same passphrase again:
Do you want your passphrase to be displayed for verification? [yN]: y
Your passphrase (between double-quotes): "borg"
Make sure the passphrase displayed above is exactly what you wanted.

By default repositories initialized with this version will produce security
errors if written to with an older version (up to and including Borg 1.0.8).

If you want to use these older versions, you can disable the check by running:
borg upgrade --disable-tam ssh://borg@192.168.11.160/var/backup

See https://borgbackup.readthedocs.io/en/stable/changes.html#pre-1-0-9-manifest-spoofing-vulnerability for details about the security implications.

IMPORTANT: you will need both KEY AND PASSPHRASE to access this repo!
If you used a repokey mode, the key is stored in the repo, but you should back it up separately.
Use "borg key export" to export the key, optionally in printable format.
Write down the passphrase. Store both at safe place(s).
```
* Запускаем создание бэкапа папки /etc
```
[root@client vagrant]# borg create --stats --list borg@192.168.11.160:/var/backup/::"etc-{now:%Y-%m-%d_%H:%M:%S}" /etc
```
* Проверяем что получилось
```
[root@client vagrant]# borg list borg@192.168.11.160:/var/backup/
Enter passphrase for key ssh://borg@192.168.11.160/var/backup: 
etc-2022-02-14_15:41:18              Mon, 2022-02-14 15:41:23 [edc5216c5e8696493950a1a25f6bd16505f3bdebf82c950f78aaccbd6fa9afc0]
```
* Смотрим список файлов в бэкапе
```
borg list borg@192.168.11.160:/var/backup/::etc-2022-02-14_15:41:18
```
* Пробуем достать файл из бэкапа
```
[root@client vagrant]# borg extract borg@192.168.11.160:/var/backup/::etc-2022-02-14_15:41:18 etc/hostname
Enter passphrase for key ssh://borg@192.168.11.160/var/backup: 
[root@client vagrant]# ll
total 0
drwx------. 2 root root 22 Feb 14 15:46 etc
[root@client vagrant]# ll ./etc/
total 4
-rw-r--r--. 1 root root 7 Feb 14 14:19 hostname
```
* Автоматизируем бэкапы, создаем borg-backup.service
```
nano /etc/systemd/system/borg-backup.service
```
```
[Unit]
Description=Borg Backup

[Service]
Type=oneshot

# Парольная фраза
Environment="BORG_PASSPHRASE=borg"
# Репозиторий
Environment=REPO=borg@192.168.11.160:/var/backup/
# Что бэкапим
Environment=BACKUP_TARGET=/etc
# Создание бэкапа
ExecStart=/bin/borg create ${REPO}::{hostname}-{user}-{now:%Y-%m-%d_%H:%M:%S} ${BACKUP_TARGET}
# Проверка бэкапа
ExecStart=/bin/borg check ${REPO}
# Очистка старых бэкапов             
 ExecStart=/bin/borg prune --keep-daily 90 --keep-monthly 12 --keep-yearly 1 ${REPO}
```
* Создаем borg-backup.timer
```
nano /etc/systemd/system/borg-backup.timer 
```
```
[Unit]
Description=Borg Backup
Requires=borg-backup.service

[Timer]
Unit=borg-backup.service
OnUnitActiveSec=5min


[Install]
WantedBy=timers.target
```
* Запускаем задачу
```
systemctl enable borg-backup.timer
systemctl start borg-backup.timer
```
* Проверяем репозиторий
```
[root@client vagrant]# borg list borg@192.168.11.160:/var/backup/
Enter passphrase for key ssh://borg@192.168.11.160/var/backup: 
etc-2022-0bb195bd9d7f96438b8141d11a49cc56-14_client:58:10 Mon, 2022-02-14 23:58:11 [e57008df8c96b1cdde38a6bf1f35789ee5b34d9e17e56d069635ff6925b2fbdc]
"etc-2022-0bb195bd9d7f96438b8141d11a49cc56-15_client:58:10" Tue, 2022-02-15 20:58:11 [5d586c5fd3101d2beb2fabf34c3c5c85b5782684b7671c1921111804a15d580b]
etc-2022-0bb195bd9d7f96438b8141d11a49cc56-16_client:54:38 Wed, 2022-02-16 15:54:39 [7d6d00b00493472ccfd1f50594295b1bfe457085dce71f812306ea6cc971f7d6]
```
* Есть проблема с распознаванием регулярного выражения {now:%Y-%m-%d_%H:%M:%S} в при запуске borg-backup.service, почему то в некорректно его отрабатывает. Из командной строки все нормально. Пока не разобрался.
