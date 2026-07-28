data "google_compute_network" "shared_vpc" {
  name    = var.shared_vpc_network_name
  project = var.shared_vpc_host_project
}

data "google_compute_subnetwork" "shared_subnet" {
  name    = var.shared_vpc_subnet_name
  region  = var.default_region
  project = var.shared_vpc_host_project
}

resource "google_compute_global_address" "private_ip_allocation" {
  name          = "polaris-${var.environment}-private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.private_ip_prefix_length
  network       = data.google_compute_network.shared_vpc.id
  project       = var.shared_vpc_host_project
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = data.google_compute_network.shared_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_allocation.name]
  update_on_creation_fail = true

  depends_on = [
    google_compute_global_address.private_ip_allocation,
    google_project_service.required_apis["servicenetworking.googleapis.com"]
  ]
}

resource "google_compute_firewall" "bastion_iap_ssh" {
  count   = var.bastion_enabled ? 1 : 0
  name    = "fw-polaris-${var.environment}-bastion-iap-ssh"
  network = data.google_compute_network.shared_vpc.id
  project = var.shared_vpc_host_project

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["bastion-${var.environment}"]
}
