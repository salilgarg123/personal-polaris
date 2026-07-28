provider "google" {
  project = var.project_id
  region  = var.default_region
  zone    = var.default_zone

  default_labels = {
    managed-by  = "terraform"
    project     = "polaris"
    environment = var.environment
  }
}

provider "google-beta" {
  project = var.project_id
  region  = var.default_region
  zone    = var.default_zone

  default_labels = {
    managed-by  = "terraform"
    project     = "polaris"
    environment = var.environment
  }
}

locals {
  common_labels = {
    managed-by  = "terraform"
    project     = "polaris"
    environment = var.environment
  }

  required_apis = [
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "cloudkms.googleapis.com",
    "run.googleapis.com",
    "iap.googleapis.com",
    "cloudscheduler.googleapis.com",
    "secretmanager.googleapis.com",
    "artifactregistry.googleapis.com"
  ]
}

resource "google_project_service" "required_apis" {
  for_each = toset(local.required_apis)
  project  = var.project_id
  service  = each.value
  disable_dependent_services = true
}

data "google_project" "project" {
  project_id = var.project_id
}
