# README.md

Este proyecto tiene el código de ejercicios devops 2022. Los desafios tecnivos son.

1. Manejo GCP
2. Terraform para la creación de Infraestructura.
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