#!/bin/bash

sysctl net.ipv4.conf.all.forwarding=1
iptables -t nat -A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE 
echo "192.168.0.0/22 via 192.168.255.2 dev eth1" >> /etc/sysconfig/network-scripts/route-eth1
echo "DEVICE=bond0" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "TYPE=Bond" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "BONDING_MASTER=yes" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "MTU=9000" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "IPADDR=192.168.255.1" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "PREFIX=30" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "BOOTPROTO=static" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "BONDING_OPTS="mode=0 miimon=100"" >> /etc/sysconfig/network-scripts/ifcfg-bond0
echo "DEVICE=eth1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth1
echo "SLAVE=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth1
echo "MASTER=bond0" >> /etc/sysconfig/network-scripts/ifcfg-eth1
echo "MTU=9000" >> /etc/sysconfig/network-scripts/ifcfg-eth1
echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-eth1
echo "DEVICE=eth2" >> /etc/sysconfig/network-scripts/ifcfg-eth2
echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth2
echo "SLAVE=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth2
echo "MASTER=bond0" >> /etc/sysconfig/network-scripts/ifcfg-eth2
echo "MTU=9000" >> /etc/sysconfig/network-scripts/ifcfg-eth2
echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-eth2
systemctl restart network
sysctl net.ipv4.conf.all.forwarding=1 