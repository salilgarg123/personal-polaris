resource "google_service_account" "bastion" {
  count        = var.bastion_enabled ? 1 : 0
  account_id   = "sa-bastion-${var.environment}"
  display_name = "Bastion Host Service Account - ${var.environment}"
  project      = var.project_id
}

resource "google_compute_instance" "bastion" {
  count        = var.bastion_enabled ? 1 : 0
  name         = "gce-bastion-${var.environment}"
  machine_type = var.bastion_machine_type
  zone         = var.default_zone
  project      = var.project_id
  tags         = ["bastion-${var.environment}"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = var.bastion_disk_size
      type  = var.bastion_disk_type
    }
  }

  network_interface {
    subnetwork         = data.google_compute_subnetwork.shared_subnet.id
    subnetwork_project = var.shared_vpc_host_project
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  service_account {
    email  = google_service_account.bastion[0].email
    scopes = ["cloud-platform"]
  }

  metadata = { enable-oslogin = "TRUE" }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y postgresql-client curl wget
    curl -o /usr/local/bin/cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.1/cloud-sql-proxy.linux.amd64
    chmod +x /usr/local/bin/cloud-sql-proxy
  EOT

  resource_policies = var.bastion_schedule_enabled ? [google_compute_resource_policy.bastion_stop_schedule[0].id] : []

  labels = {
    environment = var.environment
    purpose     = "bastion"
    managed-by  = "terraform"
  }

  depends_on = [google_project_service.required_apis["compute.googleapis.com"]]
}

resource "google_project_iam_member" "bastion_os_login" {
  count   = var.bastion_enabled ? 1 : 0
  project = var.project_id
  role    = "roles/compute.osLogin"
  member  = "serviceAccount:${google_service_account.bastion[0].email}"
}

resource "google_project_iam_member" "bastion_sql_client" {
  count   = var.bastion_enabled ? 1 : 0
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.bastion[0].email}"
}

resource "google_compute_resource_policy" "bastion_stop_schedule" {
  count   = var.bastion_enabled && var.bastion_schedule_enabled ? 1 : 0
  name    = "polaris-${var.environment}-bastion-stop"
  region  = var.default_region
  project = var.project_id

  instance_schedule_policy {
    vm_stop_schedule {
      schedule = var.bastion_stop_schedule
    }
    time_zone = var.bastion_schedule_timezone
  }
}
