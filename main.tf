terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file("devops-2020-337523-46f61b034ef2.json")

  project = "devops-2020-337523"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_network" "vpc_network" {
  name = "devops-2022-network"
}

resource "google_compute_instance" "vm_instance" {
  name         = "devops-instance"
  machine_type = "e2-standard-4"
  allow_stopping_for_update = true
  tags         = ["docker", "dev"]
  metadata = {
    startup-script = file("init.sh")
  }

  boot_disk {
    initialize_params {
      image = "projects/centos-cloud/global/images/centos-8-v20211214"
      size = "100"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}

resource "google_compute_firewall" "default" {
  name    = "devops-2022-allow-max"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8085", "7990", "7999", "8081", "9002", "1000-2000"]
  }
  source_ranges = ["0.0.0.0/0"]
}
