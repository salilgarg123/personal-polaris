# Main Infrastructure Module
# This module contains core infrastructure setup including:
# - Provider configuration
# - Google Cloud API enablement
# - Common locals and labels

# Resources are organized across multiple files:
# - networking.tf: VPC, subnets, and network configuration
# - storage.tf: Cloud Storage buckets and policies
# - service-accounts.tf: Service account definitions
# - cloud-run.tf: Cloud Run service configurations
# - cloud-sql.tf: Database resources and configuration
# - iam.tf: IAM role bindings and policies

# Provider configuration
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

# Local values for common configurations
locals {
  common_labels = {
    managed-by  = "terraform"
    project     = "polaris"
    environment = var.environment
  }

  # Required APIs for the infrastructure
  required_apis = [
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "cloudkms.googleapis.com",
    "run.googleapis.com",
    "iap.googleapis.com",
    "cloudscheduler.googleapis.com",
    "secretmanager.googleapis.com"
  ]
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset(local.required_apis)
  
  project = var.project_id
  service = each.value

  disable_dependent_services = true
}

# Data sources
data "google_project" "project" {
  project_id = var.project_id
}













