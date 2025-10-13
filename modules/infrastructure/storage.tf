# Storage Configuration
# This file contains Cloud Storage resources

# Cloud Storage bucket for Knowledge Management service data storage
# Stores files and documents uploaded to the knowledge service
resource "google_storage_bucket" "knowledge_data" {
  name          = "bkt-${var.project_id}-knowledge-data-${var.environment}"
  location      = var.default_region
  force_destroy = var.environment != "prod" # Only allow force destroy in non-prod

  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }

  labels = local.common_labels
}

# Cloud Storage bucket for Keycloak themes and providers
# Stores keycloak-theme.jar and other provider customizations
resource "google_storage_bucket" "keycloak_providers" {
  name          = "bkt-${var.project_id}-keycloak-providers-${var.environment}"
  location      = var.default_region
  force_destroy = var.environment != "prod"

  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }

  labels = local.common_labels
}

# Cloud Storage bucket for OpenSearch vector database storage
# Stores vector embeddings and frequently accessed search data
resource "google_storage_bucket" "opensearch_data" {
  name          = "bkt-${var.project_id}-opensearch-data-${var.environment}"
  location      = var.default_region
  force_destroy = var.environment != "prod"

  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }

  labels = local.common_labels
}


