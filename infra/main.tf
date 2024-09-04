resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.cidr
  network       = google_compute_network.vpc_network.self_link
  region        = var.region
}

resource "google_compute_instance" "vm_instance" {
  name         = var.instance_name
  machine_type = var.instance_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.boot_image
    }
  }

  scheduling {
    preemptible = true
    automatic_restart = false
    provisioning_model = "SPOT"
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link
  }
}