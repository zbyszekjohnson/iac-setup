provider "google" {
  credentials = file("terraform-gcp-auth.json")
  project     = "unique-grid-403916"
  region      = "europe-central2"
}

# Przykład tworzenia instancji VM
resource "google_compute_instance" "default" {
  name         = "terraform-instance"
  machine_type = "f1-micro"
  zone         = "europe-central2-b"  # np. "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20231101"
    }
  }

  network_interface {
    network = "default"
  }
}