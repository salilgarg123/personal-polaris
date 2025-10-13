# State Bucket Module
# This module creates the GCS bucket for storing Terraform state files

# Google Cloud Storage bucket for Terraform state
resource "google_storage_bucket" "terraform_state" {
  name          = "polaris-terraform-state-${random_id.bucket_suffix.hex}"
  location      = var.bucket_location
  storage_class = "STANDARD"

  # Prevent accidental deletion of this bucket
  lifecycle {
    prevent_destroy = true
  }

  # Enable versioning so we can recover from mistakes
  versioning {
    enabled = true
  }

  # Block public access
  public_access_prevention = "enforced"

  uniform_bucket_level_access = true

  labels = {
    purpose     = "terraform-state"
    project     = "polaris"
    environment = "shared"
    managed-by  = "terraform"
  }

  project = var.project_id
}

# Random suffix for bucket name to ensure uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}
