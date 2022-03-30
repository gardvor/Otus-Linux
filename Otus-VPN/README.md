# OTUS - VPN
Домашнее задание OTUS Linux Professional по теме "Мосты, туннели и VPN"

## Что требуется
Работа выполнялась на стенде Windows 10, Hashicorp Vagrant 2.2.19, Oracle VirtualBox 6.3

## Как запустить
Скачать все файлы в одну директорию, из директории с vagrantfile выполнить команду Vagrant up

## Задание
1.Между двумя виртуалками поднять vpn в режимах
* tun;
* tap; 
* Прочуствовать разницу.
2. Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку. 
3. Самостоятельно изучить, поднять ocserv и подключиться с хоста к виртуалке (*) 
4. Формат сдачи ДЗ - vagrant + ansible

## Выполнение домашнего задания
* Командой Vagrant up развернется стенд из трех виртуальных машин
* server
* client
* ansible
* Заходим на машину ansible и запускаем плейбук provision.yml он установить весь нужный софт и отключит selinux
```
vagrant ssh ansible
[vagrant@ansible ~]$ sudo su
[root@ansible vagrant]# cd /vagrant
[root@ansible vagrant]# ansible-playbook ./playbooks/provision.yml 
```
### Проверка  VPN в TAP режиме
* На виртуальной машине server
* создаем ключ
```
[root@server vagrant]# openvpn --genkey --secret /etc/openvpn/static.key
```
* Приводим файл конфигурации /etc/openvpn/server.conf к виду
```
dev tap
ifconfig 10.10.10.1 255.255.255.0
topology subnet
secret /etc/openvpn/static.key
comp-lzo
status /var/log/openvpn-status.log
log /var/log/openvpn.log
verb 3

```
* Запускаем OpenVPN сервер
```
[root@server vagrant]# systemctl enable --now openvpn@server
Created symlink from /etc/systemd/system/multi-user.target.wants/openvpn@server.service to /usr/lib/systemd/system/openvpn@.service.
[root@server vagrant]# systemctl status openvpn@server
● openvpn@server.service - OpenVPN Robust And Highly Flexible Tunneling Application On server
   Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2022-03-29 18:16:23 UTC; 24s ago
 Main PID: 948 (openvpn)
   Status: "Pre-connection initialization successful"
   CGroup: /system.slice/system-openvpn.slice/openvpn@server.service
           └─948 /usr/sbin/openvpn --cd /etc/openvpn/ --config server.conf

Mar 29 18:16:23 server.loc systemd[1]: Starting OpenVPN Robust And Highly Flexible Tunneling Application On server...
Mar 29 18:16:23 server.loc systemd[1]: Started OpenVPN Robust And Highly Flexible Tunneling Application On server.
```
* На виртульной машине client
* Копируем файл /etc/openvpn/static.key с машины сервер в аналогичную папку на машине client
* Приводим файл конфигурации /etc/openvpn/server.conf к виду
```
dev tap
remote 192.168.10.10
ifconfig 10.10.10.2 255.255.255.0
topology subnet
route 192.168.10.0 255.255.255.0
secret /etc/openvpn/static.key
comp-lzo
status /var/log/openvpn-status.log
log /var/log/openvpn.log
verb 3
```
* Запускаем OpenVPN сервер
```
[root@client vagrant]# systemctl enable --now openvpn@server
Created symlink from /etc/systemd/system/multi-user.target.wants/openvpn@server.service to /usr/lib/systemd/system/openvpn@.service.
[root@client vagrant]# systemctl status openvpn@server
● openvpn@server.service - OpenVPN Robust And Highly Flexible Tunneling Application On server
   Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2022-03-29 18:20:39 UTC; 9s ago
 Main PID: 952 (openvpn)
   Status: "Pre-connection initialization successful"
   CGroup: /system.slice/system-openvpn.slice/openvpn@server.service
           └─952 /usr/sbin/openvpn --cd /etc/openvpn/ --config server.conf

Mar 29 18:20:39 client.loc systemd[1]: Starting OpenVPN Robust And Highly Flexible Tunneling Application On server...
Mar 29 18:20:39 client.loc systemd[1]: Started OpenVPN Robust And Highly Flexible Tunneling Application On server.
```
* VPN успешно поднялся
```
[root@client vagrant]# ping 10.10.10.1
PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=2.84 ms
64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=1.11 ms
64 bytes from 10.10.10.1: icmp_seq=3 ttl=64 time=1.34 ms
```
* На машине server запустим iperf в режиме сервера
```
[root@server vagrant]# iperf3 -s &
[1] 980
[root@server vagrant]# -----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
```
* На машине client запустим iperf в режиме клиента
```
[root@client vagrant]# iperf3 -c 10.10.10.1 -t 40 -i 5
Connecting to host 10.10.10.1, port 5201
[  4] local 10.10.10.2 port 56154 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-5.00   sec  12.5 MBytes  20.9 Mbits/sec    1    449 KBytes
[  4]   5.00-10.01  sec  13.5 MBytes  22.6 Mbits/sec    0    951 KBytes       
[  4]  10.01-15.00  sec  13.4 MBytes  22.5 Mbits/sec   38    942 KBytes       
[  4]  15.00-20.01  sec  13.7 MBytes  23.0 Mbits/sec    0   1.25 MBytes       
[  4]  20.01-25.00  sec  15.0 MBytes  25.1 Mbits/sec   12   1.04 MBytes       
[  4]  25.00-30.01  sec  14.9 MBytes  25.0 Mbits/sec    0   1.07 MBytes       
[  4]  30.01-35.01  sec  14.9 MBytes  25.0 Mbits/sec    0   1.19 MBytes       
[  4]  35.01-40.00  sec  12.4 MBytes  20.8 Mbits/sec   27   1.11 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-40.00  sec   110 MBytes  23.1 Mbits/sec   78             sender
[  4]   0.00-40.00  sec   109 MBytes  22.9 Mbits/sec                  receiver

iperf Done.
```
* Результаты на машине server
```
Accepted connection from 10.10.10.2, port 56152
[  5] local 10.10.10.1 port 5201 connected to 10.10.10.2 port 56154
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-1.00   sec  1.72 MBytes  14.4 Mbits/sec
[  5]   1.00-2.00   sec  1.90 MBytes  15.9 Mbits/sec
[  5]   2.00-3.00   sec  2.24 MBytes  18.8 Mbits/sec
[  5]   3.00-4.00   sec  2.24 MBytes  18.8 Mbits/sec
[  5]   4.00-5.00   sec  2.81 MBytes  23.6 Mbits/sec
[  5]   5.00-6.00   sec  2.69 MBytes  22.5 Mbits/sec
[  5]   6.00-7.01   sec  2.05 MBytes  17.0 Mbits/sec
[  5]   7.01-8.00   sec  2.45 MBytes  20.7 Mbits/sec
[  5]   8.00-9.01   sec  2.40 MBytes  20.1 Mbits/sec
[  5]   9.01-10.01  sec  2.49 MBytes  20.9 Mbits/sec
[  5]  10.01-11.00  sec  2.41 MBytes  20.3 Mbits/sec
[  5]  11.00-12.01  sec  3.02 MBytes  25.1 Mbits/sec
[  5]  12.01-13.00  sec  2.66 MBytes  22.4 Mbits/sec
[  5]  13.00-14.01  sec  2.24 MBytes  18.7 Mbits/sec
[  5]  14.01-15.01  sec  2.20 MBytes  18.5 Mbits/sec
[  5]  15.01-16.00  sec  2.60 MBytes  22.0 Mbits/sec
[  5]  16.00-17.00  sec  2.89 MBytes  24.2 Mbits/sec
[  5]  17.00-18.00  sec  3.01 MBytes  25.3 Mbits/sec
[  5]  18.00-19.01  sec  3.13 MBytes  26.1 Mbits/sec
[  5]  19.01-20.00  sec  3.02 MBytes  25.5 Mbits/sec
[  5]  20.00-21.00  sec  1.75 MBytes  14.6 Mbits/sec
[  5]  21.00-22.00  sec  3.46 MBytes  29.1 Mbits/sec
[  5]  22.00-23.00  sec  3.06 MBytes  25.7 Mbits/sec
[  5]  23.00-24.01  sec  3.11 MBytes  25.8 Mbits/sec
[  5]  24.01-25.00  sec  3.00 MBytes  25.5 Mbits/sec
[  5]  25.00-26.00  sec  3.01 MBytes  25.3 Mbits/sec
[  5]  26.00-27.01  sec  3.11 MBytes  25.9 Mbits/sec
[  5]  27.01-28.01  sec  3.01 MBytes  25.2 Mbits/sec
[  5]  28.01-29.00  sec  3.15 MBytes  26.7 Mbits/sec
[  5]  29.00-30.00  sec  3.08 MBytes  25.8 Mbits/sec
[  5]  30.00-31.00  sec  2.77 MBytes  23.3 Mbits/sec
[  5]  31.00-32.00  sec  2.94 MBytes  24.6 Mbits/sec
[  5]  32.00-33.00  sec  2.54 MBytes  21.3 Mbits/sec
[  5]  33.00-34.01  sec  3.09 MBytes  25.7 Mbits/sec
[  5]  34.01-35.00  sec  2.74 MBytes  23.1 Mbits/sec
[  5]  35.00-36.00  sec  2.95 MBytes  24.8 Mbits/sec
[  5]  36.00-37.01  sec  1.73 MBytes  14.4 Mbits/sec
[  5]  37.01-38.01  sec  2.94 MBytes  24.7 Mbits/sec
[  5]  38.01-39.00  sec  2.84 MBytes  24.0 Mbits/sec
[  5]  39.00-40.00  sec  2.92 MBytes  24.4 Mbits/sec
[  5]  40.00-40.83  sec  1.60 MBytes  16.4 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-40.83  sec  0.00 Bytes  0.00 bits/sec                  sender
[  5]   0.00-40.83  sec   109 MBytes  22.4 Mbits/sec                  receiver
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
```
### Проверка  VPN в TUN режиме
* Поменяем на каждой машине в файле /etc/openvpn/server.conf строку dev tap на dev tun
* и проведем аналогичные измерения
* Client
```
[root@client vagrant]# iperf3 -c 10.10.10.1 -t 40 -i 5                                                                                                                           
Connecting to host 10.10.10.1, port 5201
[  4] local 10.10.10.2 port 56158 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-5.00   sec  16.9 MBytes  28.4 Mbits/sec    1    477 KBytes
[  4]   5.00-10.00  sec  15.7 MBytes  26.4 Mbits/sec   19    610 KBytes       
[  4]  10.00-15.00  sec  15.1 MBytes  25.4 Mbits/sec    2    544 KBytes       
[  4]  15.00-20.01  sec  16.5 MBytes  27.7 Mbits/sec    0    560 KBytes       
[  4]  20.01-25.00  sec  15.2 MBytes  25.6 Mbits/sec    1    554 KBytes       
[  4]  25.00-30.01  sec  15.6 MBytes  26.2 Mbits/sec    0    571 KBytes       
[  4]  30.01-35.00  sec  16.1 MBytes  27.1 Mbits/sec    7    523 KBytes       
[  4]  35.00-40.00  sec  16.4 MBytes  27.5 Mbits/sec    1    482 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-40.00  sec   128 MBytes  26.8 Mbits/sec   31             sender
[  4]   0.00-40.00  sec   126 MBytes  26.5 Mbits/sec                  receiver

iperf Done.
```
* Server
```
[root@server vagrant]# iperf3 -s &
[1] 946
[root@server vagrant]# -----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
Accepted connection from 10.10.10.2, port 56156
[  5] local 10.10.10.1 port 5201 connected to 10.10.10.2 port 56158
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-1.00   sec  2.49 MBytes  20.7 Mbits/sec
[  5]   1.00-2.01   sec  3.39 MBytes  28.2 Mbits/sec
[  5]   2.01-3.01   sec  3.32 MBytes  28.0 Mbits/sec
[  5]   3.01-4.00   sec  3.07 MBytes  25.9 Mbits/sec
[  5]   4.00-5.01   sec  3.01 MBytes  25.1 Mbits/sec
[  5]   5.01-6.01   sec  2.96 MBytes  24.9 Mbits/sec
[  5]   6.01-7.01   sec  2.87 MBytes  24.0 Mbits/sec
[  5]   7.01-8.00   sec  2.42 MBytes  20.4 Mbits/sec
[  5]   8.00-9.00   sec  3.21 MBytes  26.9 Mbits/sec
[  5]   9.00-10.01  sec  3.30 MBytes  27.6 Mbits/sec
[  5]  10.01-11.01  sec  2.79 MBytes  23.2 Mbits/sec
[  5]  11.01-12.01  sec  2.82 MBytes  23.8 Mbits/sec
[  5]  12.01-13.00  sec  3.23 MBytes  27.3 Mbits/sec
[  5]  13.00-14.00  sec  3.17 MBytes  26.6 Mbits/sec
[  5]  14.00-15.00  sec  3.16 MBytes  26.5 Mbits/sec
[  5]  15.00-16.00  sec  3.25 MBytes  27.3 Mbits/sec
[  5]  16.00-17.00  sec  3.24 MBytes  27.2 Mbits/sec
[  5]  17.00-18.01  sec  3.29 MBytes  27.4 Mbits/sec
[  5]  18.01-19.01  sec  3.27 MBytes  27.4 Mbits/sec
[  5]  19.01-20.00  sec  3.30 MBytes  27.9 Mbits/sec
[  5]  20.00-21.00  sec  2.98 MBytes  24.9 Mbits/sec
[  5]  21.00-22.00  sec  3.30 MBytes  27.7 Mbits/sec
[  5]  22.00-23.00  sec  3.13 MBytes  26.2 Mbits/sec
[  5]  23.00-24.00  sec  3.27 MBytes  27.5 Mbits/sec
[  5]  24.00-25.00  sec  2.85 MBytes  23.9 Mbits/sec
[  5]  25.00-26.00  sec  2.34 MBytes  19.7 Mbits/sec
[  5]  26.00-27.00  sec  3.29 MBytes  27.6 Mbits/sec
[  5]  27.00-28.00  sec  3.23 MBytes  27.2 Mbits/sec
[  5]  28.00-29.00  sec  3.20 MBytes  26.8 Mbits/sec
[  5]  29.00-30.00  sec  3.25 MBytes  27.3 Mbits/sec
[  5]  30.00-31.00  sec  3.23 MBytes  27.1 Mbits/sec
[  5]  31.00-32.01  sec  3.32 MBytes  27.5 Mbits/sec
[  5]  32.01-33.00  sec  3.34 MBytes  28.3 Mbits/sec
[  5]  33.00-34.00  sec  2.37 MBytes  19.9 Mbits/sec
[  5]  34.00-35.00  sec  3.71 MBytes  31.2 Mbits/sec
[  5]  35.00-36.01  sec  3.43 MBytes  28.6 Mbits/sec
[  5]  36.01-37.00  sec  3.35 MBytes  28.2 Mbits/sec
[  5]  37.00-38.00  sec  3.50 MBytes  29.4 Mbits/sec
[  5]  38.00-39.01  sec  3.39 MBytes  28.3 Mbits/sec
[  5]  39.01-40.00  sec  2.94 MBytes  24.9 Mbits/sec
[  5]  40.00-40.36  sec  1.25 MBytes  29.1 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-40.36  sec  0.00 Bytes  0.00 bits/sec                  sender
[  5]   0.00-40.36  sec   126 MBytes  26.2 Mbits/sec                  receiver
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
```
* Через TUN интерфейс скорость несколько больше, но не драматично. Я так понимаю через TAN интерфей получается L2 сеть, появляется много лишнего технического трафика.

### RAS на базе OpenVPN  с клиентскими сертификатами
* на машине server переходим в папку /etc/openvpn/
```
[root@server vagrant]# cd /etc/openvpn/
```
* Инициализируем pki
```
[root@server openvpn]# /usr/share/easy-rsa/3.0.8/easyrsa init-pki

init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /etc/openvpn/pki
```
* Генерируем необходимые сертификаты
```
[root@server openvpn]# /usr/share/easy-rsa/3.0.8/easyrsa build-ca nopass
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating RSA private key, 2048 bit long modulus
...............+++
..................+++
e is 65537 (0x10001)
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:rasvpn

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/etc/openvpn/pki/ca.crt
```
```
[root@server openvpn]# /usr/share/easy-rsa/3.0.8/easyrsa gen-req server nopass
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating a 2048 bit RSA private key
...................................................................................+++
...+++
writing new private key to '/etc/openvpn/pki/easy-rsa-1957.BWhKet/tmp.jtKoRh'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [server]:rasvpn

Keypair and certificate request completed. Your files are:
req: /etc/openvpn/pki/reqs/server.req
key: /etc/openvpn/pki/private/server.key
```
```
[root@server openvpn]# /usr/share/easy-rsa/3.0.8/easyrsa sign-req server server
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a server certificate for 825 days:

subject=
    commonName                = rasvpn


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
Using configuration from /etc/openvpn/pki/easy-rsa-1983.to9moS/tmp.wNnDMN
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'rasvpn'
Certificate is to be certified until Jul  2 08:26:08 2024 GMT (825 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /etc/openvpn/pki/issued/server.crt
```
```
[root@server openvpn]# /usr/share/easy-rsa/3.0.8/easyrsa gen-dh
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating DH parameters, 2048 bit long safe prime, generator 2
This is going to take a long time
...........................................................................................+...........+....................................................................................................+............................................................................................+..+...........................................................................................................................................+..................................................................................................................................................+........+......................................................................................................+........................................................................................................................................................+..................................................................................................................................................+........................................................+..........................+...........................................................................................................................................................................................................................................................................................................................................................+................................+......................................................................+.....................................................................................+..................................................................................................................................................+..............................................................................................+.........................................................................................................................................++*++*

DH parameters of size 2048 created at /etc/openvpn/pki/dh.pem
```

