#!/bin/bash
echo "Bootstrapping software layer....."
yum update
yum install -y git yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker
systemctl start docker
groupadd docker
adduser robot
usermod -aG wheel robot
usermod -aG docker robot
firewall-cmd --zone=public --add-service=http
firewall-cmd --reload
yum install -y httpd
systemctl enable httpd
systemctl start httpd
yum install -y epel-release
yum update
yum install -y ansible
yum install -y java-1.8.0-openjdk
yum install -y maven
git clone https://github.com/rodvaldes/devops-2022.git /home/robot/devops-2022
chown -R robot: /home/robot/devops-2022
dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
dnf -qy module disable postgresql
dnf install -y postgresql14-server
/usr/pgsql-14/bin/postgresql-14-setup initdb
systemctl enable postgresql-14
systemctl start postgresql-14
sudo -u postgres bash -c "psql -c \"CREATE USER bamboouser WITH PASSWORD 'bamboouserpass';\""
sudo -u postgres bash -c "psql -c \"CREATE DATABASE bamboo_db WITH ENCODING 'UNICODE' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;\""
sudo -u postgres bash -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE bamboo_db to bamboouser;\""

