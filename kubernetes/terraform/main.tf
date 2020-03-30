terraform {
  required_version = ">= 0.12.8"
}

provider "google" {
  version = "3.0.0"
  project = var.project
  region  = var.region
}

resource "google_container_cluster" "reddit-cluster" {
  name     = "reddit-cluster"
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
  }

  network_policy {
    enabled  = true
    provider = "CALICO"
  }
}


resource "google_container_node_pool" "reddit-nodes" {
  name       = "reddit-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.reddit-cluster.name
  node_count = 2
  management {
    auto_repair  = true
    auto_upgrade = false
  }

  node_config {
    disk_size_gb = 20
    disk_type    = "pd-ssd"
    preemptible  = false
    machine_type = "n1-standard-1"
    tags         = var.nodes-tag
    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_compute_firewall" "firewall-reddit" {
  name    = "allow-reddit-nodeport"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = var.port-list
  }
  direction     = "INGRESS"
  priority      = "1000"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = var.nodes-tag
}
