terraform {
  cloud {
    organization = "bioborne"
     
    workspaces {
      name = "example-workspace"
    }
  }
}

provider "google" {
  credentials = file("terraform-gcp-auth.json")
  project     = "unique-grid-403916"
  region      = "europe-central2"
}

resource "google_dns_managed_zone" "my_zone" {
  name     = "ksolopa-zone"
  dns_name = "ksolopa.com."  // Pamiętaj o kropce na końcu
}

resource "google_compute_address" "default" {
  name   = "external-ip"
  region = "europe-central2"
}

resource "google_dns_record_set" "my_a_record" {
  name         = "ksolopa.com."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.my_zone.name
  rrdatas      = [google_compute_address.default.address]
}

# Przykład tworzenia instancji VM
resource "google_compute_instance" "default" {
  name         = "terraform-instance"
  machine_type = "f1-micro"
  zone         = "europe-central2-b"  # np. "us-central1-a"
  tags         = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20231101"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.default.address
    }
  }
}

resource "google_compute_firewall" "http_allow" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_firewall" "https_allow" {
  name    = "allow-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}