sudo wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - &&
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list &&
sudo apt update &&
sudo apt -y install postgresql-12 postgresql-client-12
sudo systemctl stop ufw
sudo systemctl disable ufw
