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
yum install epel-release
yum install ansible