terraform {
  required_version = ">= 0.12.8"
}

provider "google" {
  version = "3.4.0"
  project = var.project
  region  = var.region
}

resource "google_compute_instance" "docker" {
  count        = var.instance_count
  name         = "docker-${count.index}"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["docker"]
  labels       = var.labels
  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

resource "google_compute_firewall" "firewall-puma" {
  name    = "allow-puma-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  direction     = "INGRESS"
  priority      = "1000"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["docker"]
}
