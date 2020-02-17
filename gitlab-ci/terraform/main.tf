terraform {
  required_version = ">= 0.12.8"
}

provider "google" {
  version = "3.4.0"
  project = var.project
  region  = var.region
}

resource "google_compute_instance" "runner" {
  count        = var.instance_count
  name         = "runner-${count.index}"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["runner"]
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
    ssh-keys = "runner:${file(var.public_key_path)}"
  }
}
