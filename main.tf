terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.27.0"
    }
  }
}


provider "google" {
  # Configuration options
  project = "training-416401"
  region = "us-central1"
  zone = "us-central1-a"
  credentials = "training-416401-151621fcb8a1.json"
}


# main vpc
resource "google_compute_network" "vpc_network" {
  name                    = "terraform-vpc"
  auto_create_subnetworks = false
}

# private subnet
resource "google_compute_subnetwork" "private_subnet" {
  name          = "terraform-private-subnet"
  ip_cidr_range = "10.187.0.0/24"
  region = "us-central1"
  network      = google_compute_network.vpc_network.id
}

# vm instance
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-vm"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id

    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOF
  #!/bin/bash
  apt-get update
  apt-get install -y apache2
  echo '<html><body><h1>Hello, World from GCP VM!</h1></body></html>' > /var/www/html/index.html
  EOF
}

output "website_url" {
  value = google_compute_instance.vm_instance.network_interface.0.access_config.0.assigned_nat_ip
}

output "vpc_network" {
  value = google_compute_network.vpc_network.id
}

output "private_subnet" {
  value = google_compute_subnetwork.private_subnet.id
}

output "internal_ip" {
  value = google_compute_instance.vm_instance.network_interface.0.network_ip
}