# Включаем вход по ssh при помощи паролей
sudo bash -c "sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication yes/' /etc/ssh/sshd_config && systemctl restart sshd.service" 

sudo yum install nano -y
# Добавляем тестовые группы
groupadd megaadmins
groupadd myusers
groupadd admin
# Добавляем группу admin для пользователя vagrant иначе не будет работать vagrant ssh
usermod -a -G admin vagrant
# Создаем тестовых пользователей и добавляем их в тестовые группы
useradd -g myusers vasya
useradd -g megaadmins petya
useradd -g admin kolya
# устанавливаем для пользователей пароли
echo 123456 | passwd vasya --stdin
echo 123456 | passwd petya --stdin
echo 123456 | passwd kolya --stdin
# копируем скрипт для pam_exec
cp /vagrant/admin.sh /etc/admin.sh
chmod +x /etc/admin.sh
# включаем модуль pam_exec для входа по ssh
sed -i '6i account    required     pam_exec.so /etc/admin.sh' /etc/pam.d/sshd
systemctl restart sshd
