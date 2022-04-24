sudo dnf module reset postgresql -y &&
sudo dnf install @postgresql:12 -y &&
postgresql-setup initdb &&
systemctl enable postgresql --now 