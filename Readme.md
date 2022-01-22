# README.md

Este proyecto tiene el código de ejercicios devops 2022. Los desafios tecnivos son.

1. Manejo GCP
2. Terraform para la creación de Infraestructura.
    * Creación y configuración de red VCN para devops.
    * 
3. Bootstrap de capa de software con bash.
    * Java, Maven, Git, Docker, Ansible, wget.
3. Ansible para la configuración de la máquina a nivel de Sistema Operativo.


[GCP Get Started](https://learn.hashicorp.com/tutorials/terraform/google-cloud-platform-build?in=terraform/gcp-get-started)


## Requerimientos

1. Tener un proyecto GCP creado

GCP Project info


|   Atributo |    Valor     |
|----------------|--------------------|
| Project name | devops-2020        |
| Project number | 17216318124        |
| Project ID:    | devops-2020-337523 |


2. Enable GCE Ver Foto

3. Habilitar cuenta de servicio.


|   Atributo |    Valor     |
|----------------|--------------------|
|Email | devops-2022@devops-2020-337523.iam.gserviceaccount.com |
|Unique ID|104786519566100088299|
|Project| devops-2020| 


```
gcloud compute instances create instance-1
--project=devops-2020-337523
--zone=us-central1-a
--machine-type=e2-medium
--network-interface=network-tier=PREMIUM,subnet=default
--maintenance-policy=MIGRATE
--service-account=17216318124-compute@developer.gserviceaccount.com
--scopes=<https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append>
--create-disk=auto-delete=yes,boot=yes,device-name=instance-1,image=projects/centos-cloud/global/images/centos-8-v20211214,mode=rw,size=50,type=projects/devops-2020-337523/zones/us-central1-a/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

gcloud beta compute ssh VM_NAME --troubleshoot
gcloud beta compute ssh --zone "us-central1-c" "devops-instance"  --project "devops-2020-337523"
gcloud beta compute ssh "devops-instance" --troubleshoot

gcloud beta compute ssh --zone "us-central1-c" "devops-instance"  --project "devops-2020-337523" --troubleshoot

gcloud compute --project=devops-2020-337523 firewall-rules create devops-2022-allow-icmp --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=icmp --source-ranges=0.0.0.0/0
```

Terraform 
---------
```
C:\Users\rvaldes\Desktop\Devops-2022>terraform -version
Terraform v1.1.2
on windows_amd64
+ provider registry.terraform.io/hashicorp/google v3.5.0

Your version of Terraform is out of date! The latest version
is 1.1.3. You can update by downloading from https://www.terraform.io/downloads.html
```

### Ejemplo creación de regla de firewall desde gcloud

```
gcloud compute --project=devops-2020-337523 firewall-rules create devops-2022-allow-out-http --direction=EGRESS --priority=1000 --network=devops-2022-network --action=ALLOW --rules=tcp:80 --destination-ranges=0.0.0.0/0
```


# Inicializacion de capa de software 

La inicialización de la capa de software se puede automatizar mediante bash scripting o mecanismos mas avanzados.

A modo de MVP se generará una automatización básica basada en bash. 

* Instalación de Java, Maven, Docker, Ansible.

## Instalación de Bamboo

1. Creación de Base de Datos en PostgreSQL 14

```
sudo -u postgres bash -c "psql -c \"CREATE ROLE bamboo_user WITH LOGIN PASSWORD 'bamboo_user_pass' VALID UNTIL 'infinity';\""
sudo -u postgres bash -c "psql -c \"CREATE DATABASE bamboo_db WITH ENCODING 'UNICODE' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;\""

#sudo -u postgres bash -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE bamboo_db to bamboouser;\""
```

## 2. Instalación Bamboo

La instalación de Bamboo requiere de los siguientes elementos:

* Instalador.
* Java 8 o Superior.
* usuario bamboo
* Base de datos postgres creada.

Descarga de Instalador Bamboo
----
El instalador estará almacenado en un bucket Google Cloud Storage devops-2022 

```
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
```

# Instalación de Bitbucket

### Referencia
[Install Bitbucket Server on Linux](https://confluence.atlassian.com/bitbucketserver/install-bitbucket-server-on-linux-868976991.html)

* Instalador de Bitbucket.
* Java 8 o Superior.
* Base de datos postgres creada.
* Agregar los puertos 990, 7992, and 7993

BAse de Datos
````
sudo -u postgres bash -c "psql -c \"CREATE ROLE bitbucket_user WITH LOGIN PASSWORD 'bitbucket_user_pass' VALID UNTIL 'infinity';\""
sudo -u postgres bash -c "psql -c \"CREATE DATABASE bitbucket_db WITH ENCODING='UTF8' OWNER=bitbucket_user CONNECTION LIMIT=-1;\""

```



Dejar el instalador publico en el bucket obtener url y descargar con wget

```
wget https://storage.googleapis.com/devops-2022/atlassian-bitbucket-7.19.2-x64.bin
chmod u+x atlassian-bitbucket-7.19.2-x64.bin
./an-bitbucket-7.19.2-x64.bin -q
```

Instalación de git desde la fuente

El git que esta disponible en las distribuciones es el estable y es anterior al que requiere bitbucket por lo que es necesario instalar una version 
compatible Git 2.30.0 or higher.



````
dnf install dh-autoreconf curl-devel expat-devel gettext-devel openssl-devel perl-devel zlib-devel



## Instalación de GCP SDK
```
sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el8-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM

gsutil cp gs://devops-2022/devops-2020-337523-46f61b034ef2.json
gsutil cp https://storage.cloud.google.com/devops-2022/devops-2020-337523-46f61b034ef2.json

gs://devops-2022/atlassian-bamboo-8.1.1.tar.gz

https://storage.googleapis.com/devops-2022/atlassian-bamboo-8.1.1.tar.gz
```


Inventario de Herramientas
-------------------------
java
docker 
maven
ansible
terraform
gccloud
wget
nano
dnf
yum
postgres
git
bash



TODO
------

* Creación de Storage bucket desde terraform
* Ansibilisar configuracion inicial.
* Arrancar bamboo desde el script de instalación.-> OK
* Usar nginx proxy.
* Fix timezone del OS




