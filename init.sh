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
firewall-cmd --zone=public --permanent --add-port 8085/tcp
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
dnf install -y postgresql14-server wget
/usr/pgsql-14/bin/postgresql-14-setup initdb
systemctl enable postgresql-14
systemctl start postgresql-14
sudo -u postgres bash -c "psql -c \"CREATE USER bamboo_user WITH PASSWORD 'bamboouser_pass';\""
sudo -u postgres bash -c "psql -c \"CREATE DATABASE bamboo_db WITH ENCODING 'UNICODE' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;\""
sudo -u postgres bash -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE bamboo_db to bamboouser;\""
wget https://storage.googleapis.com/devops-2022/atlassian-bamboo-8.1.1.tar.gz
adduser bamboo
usermod -aG wheel bamboo
mkdir -p /opt/atlassian/bamboo
tar -xvzf atlassian-bamboo-8.1.1.tar.gz -C /opt/atlassian/bamboo
chown -R bamboo: /opt/atlassian/bamboo
mkdir -p /var/atlassian/bamboo/atlassian-bamboo-8.1.1
chown -R bamboo: /var/atlassian/bamboo
/bin/cp -f /home/robot/devops-2022/config/bamboo/bamboo-init.properties /opt/atlassian/bamboo/atlassian-bamboo-8.1.1/atlassian-bamboo/WEB-INF/classes
chown bamboo: /opt/atlassian/bamboo/atlassian-bamboo-8.1.1/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties
sudo -u bamboo bash -c "sh /var/atlassian/bamboo/atlassian-bamboo-8.1.1/bin/start-bamboo.sh"
