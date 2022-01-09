#!/bin/bash
echo "Bootstrapping software layer....."
yum update
yum install -y yum-utils  # este git no sirve para bitbucket
dnf install dh-autoreconf curl-devel expat-devel gettext-devel openssl-devel perl-devel zlib-devel --skip-broken
dnf install asciidoc xmlto -y --skip-broken
dnf install getop -y --skip-broken
dnf group install "Development Tools" -y
wget https://storage.googleapis.com/devops-2022/git-2.34.0.tar.gz
tar -xzvf git-2.34.0.tar.gz
cd git-2.34.0
make configure
./configure --prefix=/usr
make all doc info
make install install-doc install-html install-info
cd ..
git clone https://github.com/rodvaldes/devops-2022.git /home/robot/devops-2022
chown -R robot: /home/robot/devops-2022
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
#yum install -y httpd
#systemctl enable httpd
#systemctl start httpd
yum install -y epel-release
yum update
yum install -y ansible
yum install -y java-1.8.0-openjdk
yum install -y maven
dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
dnf -qy module disable postgresql
dnf install -y postgresql14-server wget
/usr/pgsql-14/bin/postgresql-14-setup initdb
systemctl enable postgresql-14
systemctl start postgresql-14
sudo -u postgres bash -c "psql -c \"CREATE ROLE bamboo_user WITH LOGIN PASSWORD 'bamboo_user_pass' VALID UNTIL 'infinity';\""
sudo -u postgres bash -c "psql -c \"CREATE DATABASE bamboo_db WITH ENCODING 'UNICODE' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;\""
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
sudo -u bamboo bash -c "sh /opt/atlassian/bamboo/atlassian-bamboo-8.1.1/bin/start-bamboo.sh"
sudo -u postgres bash -c "psql -c \"CREATE ROLE bitbucket_user WITH LOGIN PASSWORD 'bitbucket_user_pass' VALID UNTIL 'infinity';\""
sudo -u postgres bash -c "psql -c \"CREATE DATABASE bitbucket_db WITH ENCODING='UTF8' OWNER=bitbucket_user CONNECTION LIMIT=-1;\""
wget https://storage.googleapis.com/devops-2022/atlassian-bitbucket-7.19.2-x64.bin
chmod u+x atlassian-bitbucket-7.19.2-x64.bin
./atlassian-bitbucket-7.19.2-x64.bin -q