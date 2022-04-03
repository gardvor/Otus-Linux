#!/bin/bash

echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
echo "GATEWAY=192.168.2.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth2
echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-eth2
echo "DEVICE=eth2" >> /etc/sysconfig/network-scripts/ifcfg-eth2
echo "NM_CONTROLLED=no" >> /etc/sysconfig/network-scripts/ifcfg-eth2
echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth2.1
echo "VLAN=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth2.1
echo "BOOTPROTO=static" >> /etc/sysconfig/network-scripts/ifcfg-eth2.1
echo "TYPE=Ethernet" >> /etc/sysconfig/network-scripts/ifcfg-eth2.1
echo "DEVICE=eth2.1" >> /etc/sysconfig/network-scripts/ifcfg-eth2.1
echo "NM_CONTROLLED=no" >> /etc/sysconfig/network-scripts/ifcfg-eth2.1
echo "IPADDR=10.10.10.1" >> /etc/sysconfig/network-scripts/ifcfg-eth2.1
echo "PREFIX=24" >> /etc/sysconfig/network-scripts/ifcfg-eth2.1      
systemctl restart network
