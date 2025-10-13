# Bootstrap Configuration
# This creates the initial GCS bucket for storing Terraform state
# Run this ONCE to create the state bucket, then use environments/

terraform {
  required_version = ">= 1.9"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # No backend configuration - this uses local state to bootstrap the remote state bucket
}

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.default_region
}

# Create the state bucket using the module
module "state_bucket" {
  source = "../modules/state-bucket"
  
  project_id      = var.project_id
  bucket_location = var.state_bucket_location
}
