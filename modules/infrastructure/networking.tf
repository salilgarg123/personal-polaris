# Networking Configuration
# This file contains VPC network resources and related configurations

# VPC Network for the environment
resource "google_compute_network" "vpc_network" {
  name                    = "polaris-${var.environment}-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460

  project = var.project_id

  depends_on = [
    google_project_service.required_apis["compute.googleapis.com"]
  ]
}

# Subnet for the VPC
resource "google_compute_subnetwork" "subnet" {
  name          = "polaris-${var.environment}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.default_region
  network       = google_compute_network.vpc_network.id

  # Enable Private Google Access for instances without external IPs
  private_ip_google_access = true

  project = var.project_id
}

# Private IP allocation for managed services (Cloud SQL, etc.)
resource "google_compute_global_address" "private_ip_allocation" {
  name          = "polaris-${var.environment}-private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.private_ip_prefix_length
  network       = google_compute_network.vpc_network.id

  project = var.project_id
}

# Service networking connection for Google managed services
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_allocation.name]

  depends_on = [
    google_compute_global_address.private_ip_allocation,
    google_project_service.required_apis["servicenetworking.googleapis.com"]
  ]
}

# Cloud Router for Cloud NAT
resource "google_compute_router" "nat_router" {
  name    = "polaris-${var.environment}-nat-router"
  region  = var.default_region
  network = google_compute_network.vpc_network.id
  project = var.project_id

  depends_on = [
    google_project_service.required_apis["compute.googleapis.com"]
  ]
}

# Cloud NAT for internet access from private instances
resource "google_compute_router_nat" "nat_gateway" {
  name                               = "polaris-${var.environment}-nat-gateway"
  router                            = google_compute_router.nat_router.name
  region                            = var.default_region
  project                           = var.project_id
  nat_ip_allocate_option            = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  depends_on = [
    google_compute_router.nat_router,
    google_project_service.required_apis["compute.googleapis.com"]
  ]
}

# Firewall Rules
# All firewall rules for the VPC are defined here

# Firewall rule to allow IAP tunnel SSH access to bastion host
resource "google_compute_firewall" "bastion_iap_ssh" {
  count = var.bastion_enabled ? 1 : 0
  
  name    = "fw-bastion-${var.environment}-iap-ssh"
  network = google_compute_network.vpc_network.id
  project = var.project_id

  description = "Allow SSH access to bastion host via IAP tunnel"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # IAP's IP range for tunnel access
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["bastion-${var.environment}"]

  depends_on = [
    google_project_service.required_apis["compute.googleapis.com"]
  ]
}