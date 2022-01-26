# zabbix-lab

```bash
sudo apt-get install sshpass -y
git clone https://github.com/do-community/ansible-playbooks.git
cd ansible-playbooks/wordpress-lamp_ubuntu1804/
export ANSIBLE_HOST_KEY_CHECKING=False

# install wordpress
ansible-playbook -l web -i /otus/otus.inv playbook.yml

sudo pip3 install PyMySQL
sudo pip3 install zabbix-api

ansible-galaxy collection install community.zabbix
ansible-galaxy install geerlingguy.mysql
ansible-galaxy install geerlingguy.apache

# install zabbix-server, zabbix-agent
ansible-playbook -l zabbix -i /otus/otus.inv /otus/zabbix.yml
```

