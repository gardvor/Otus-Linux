#!/bin/bash

echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
echo "GATEWAY=192.168.2.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth2
echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-eth2
echo "DEVICE=eth2" >> /etc/sysconfig/network-scripts/ifcfg-eth2
echo "NM_CONTROLLED=no" >> /etc/sysconfig/network-scripts/ifcfg-eth2
echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth2.2
echo "VLAN=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth2.2
echo "BOOTPROTO=static" >> /etc/sysconfig/network-scripts/ifcfg-eth2.2
echo "TYPE=Ethernet" >> /etc/sysconfig/network-scripts/ifcfg-eth2.2
echo "DEVICE=eth2.2" >> /etc/sysconfig/network-scripts/ifcfg-eth2.2
echo "NM_CONTROLLED=no" >> /etc/sysconfig/network-scripts/ifcfg-eth2.2
echo "IPADDR=10.10.10.254" >> /etc/sysconfig/network-scripts/ifcfg-eth2.2
echo "PREFIX=24" >> /etc/sysconfig/network-scripts/ifcfg-eth2.2   
systemctl restart network
