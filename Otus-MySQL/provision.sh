# Установка и запуск Mysql
sudo yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm -y &&
sudo yum install Percona-Server-server-57 -y &&
sudo yum install nano -y &&
sudo cp /vagrant/conf/conf.d/* /etc/my.cnf.d/ &&
sudo systemctl start mysql
# Настройка автризации ssh по паролю
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config    
systemctl restart sshd.service
