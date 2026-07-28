resource "google_storage_bucket" "keycloak_providers" {
  name                        = "bkt-${var.project_id}-keycloak-providers-${var.environment}"
  location                    = var.default_region
  project                     = var.project_id
  force_destroy               = true
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"

  labels = {
    environment = var.environment
    managed-by  = "terraform"
    project     = "polaris"
  }
}

resource "google_storage_bucket" "knowledge_data" {
  name                        = "bkt-${var.project_id}-knowledge-data-${var.environment}"
  location                    = var.default_region
  project                     = var.project_id
  force_destroy               = true
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"

  labels = {
    environment = var.environment
    managed-by  = "terraform"
    project     = "polaris"
  }
}

resource "google_storage_bucket" "opensearch_data" {
  name                        = "bkt-${var.project_id}-opensearch-data-${var.environment}"
  location                    = var.default_region
  project                     = var.project_id
  force_destroy               = true
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"

  labels = {
    environment = var.environment
    managed-by  = "terraform"
    project     = "polaris"
  }
}
