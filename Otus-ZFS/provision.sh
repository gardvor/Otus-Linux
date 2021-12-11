sudo -s
#install wget
yum install -y wget &&
#install zfs repo
wget http://download.zfsonlinux.org/epel/zfs-release.el7_8.noarch.rpm &&
yum install -y zfs-release.el7_8.noarch.rpm &&
#import gpg key
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux &&
#install DKMS style packages for correct work ZFS
yum install -y epel-release kernel-devel &&
#change ZFS repo 
yum-config-manager --disable zfs &&
yum-config-manager --enable zfs-kmod &&
yum install -y zfs &&
#Add kernel module zfs
modprobe zfs

