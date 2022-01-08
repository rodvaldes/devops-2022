#!/bin/bash
echo "Bootstrapping software layer....."
sudo yum update
sudo yum install -y git apache2
echo '<!doctype html><html><body><h1>Hello You Successfully was able to run a webserver on GCP with Terraform!</h1></body></html>' | sudo tee /var/www/html/index.html