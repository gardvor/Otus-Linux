echo "homework"|sudo passwd --stdin homework
sudo bash -c "sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication yes/' /etc/ssh/sshd_config && systemctl restart sshd.service"
#dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo &&
#dnf install docker-ce -y &&
sudo yum install nano -y
groupadd myusers
groupadd admin
useradd -g myusers vasya
useradd -g myusers petya
useradd -g admin kolya
echo 123456 | passwd vasya --stdin
echo 123456 | passwd petya --stdin
echo 123456 | passwd kolya --stdin
cp /vagrant/admin.sh /etc/admin.sh
chmod +x /etc/admin.sh
systemctl restart sshd