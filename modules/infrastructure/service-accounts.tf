resource "google_service_account" "polaris_portal" {
  account_id   = "polaris-portal-${var.environment}"
  display_name = "Polaris Portal Service Account (${var.environment})"
  description  = "Service account for Polaris Portal Cloud Run service in ${var.environment} environment"
  project      = var.project_id
}

resource "google_service_account" "knowledge_management_api" {
  account_id   = "knowledge-mgmt-api-${var.environment}"
  display_name = "Knowledge Management API Service Account (${var.environment})"
  description  = "Service account for Knowledge Management API Cloud Run service in ${var.environment} environment"
  project      = var.project_id
}

resource "google_service_account" "opensearch_vector_db" {
  account_id   = "opensearch-vector-${var.environment}"
  display_name = "OpenSearch Vector DB Service Account (${var.environment})"
  description  = "Service account for OpenSearch Vector DB Cloud Run service in ${var.environment} environment"
  project      = var.project_id
}

resource "google_service_account" "keycloak" {
  account_id   = "keycloak-${var.environment}"
  display_name = "Keycloak Service Account (${var.environment})"
  description  = "Service account for Keycloak Cloud Run service in ${var.environment} environment"
  project      = var.project_id
}

resource "google_service_account" "connectivity_test" {
  account_id   = "connectivity-test-${var.environment}"
  display_name = "Connectivity Test Service Account (${var.environment})"
  description  = "Service account for Connectivity Test Cloud Run service in ${var.environment} environment"
  project      = var.project_id
}
