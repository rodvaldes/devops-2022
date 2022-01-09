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
