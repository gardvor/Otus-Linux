sudo -s
cp /vagrant/watchlog/watchlog /etc/sysconfig/ &&
cp /vagrant/watchlog/watchlog.sh /opt/ &&
cp /vagrant/watchlog/watchlog.service /etc/systemd/system/ &&
cp /vagrant/watchlog/watchlog.timer /etc/systemd/system/ &&
cp /vagrant/watchlog/watchlog.log /var/log/ &&
chmod +x /opt/watchlog.sh &&
yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd nano -y &&
cp /vagrant/spawn-fcgi/spawn-fcgi /etc/sysconfig/ &&
cp /vagrant/spawn-fcgi/spawn-fcgi.service /etc/systemd/system/ &&
cp /vagrant/httpd/httpd@.service /etc/systemd/system/ &&
cp /vagrant/httpd/httpd-first /etc/sysconfig/ &&
cp /vagrant/httpd/httpd-second /etc/sysconfig/ &&
cp /vagrant/httpd/first.conf /etc/httpd/conf/ &&
cp /vagrant/httpd/second.conf /etc/httpd/conf/ &&
systemctl daemon-reload &&
systemctl start watchlog.timer &&
systemctl start watchlog.service &&
systemctl start spawn-fcgi.service &&
systemctl start httpd@first &&
systemctl start httpd@second &&
