resource "google_artifact_registry_repository" "quay_remote" {
  location      = var.default_region
  repository_id = "quay-remote"
  description   = "Remote repository proxying quay.io for Keycloak"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"
  project       = var.project_id

  remote_repository_config {
    description = "Quay.io"
    docker_repository {
      custom_repository {
        uri = "https://quay.io"
      }
    }
  }

  depends_on = [google_project_service.required_apis["artifactregistry.googleapis.com"]]
}

resource "google_artifact_registry_repository_iam_member" "cloudrun_quay_reader" {
  location   = google_artifact_registry_repository.quay_remote.location
  repository = google_artifact_registry_repository.quay_remote.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
  project    = var.project_id
}

# GHCR Remote Repository (for Polaris Portal & Knowledge API images)
resource "google_secret_manager_secret" "ghcr_pull_token" {
  secret_id = "ghcr-pull-token"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_artifact_registry_repository" "ghcr_remote" {
  location      = var.default_region
  repository_id = "ghcr-remote"
  description   = "Remote repository proxying ghcr.io for Polaris images"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"
  project       = var.project_id

  remote_repository_config {
    description = "GitHub Container Registry"
    docker_repository {
      custom_repository {
        uri = "https://ghcr.io"
      }
    }
    upstream_credentials {
      username_password_credentials {
        username                = "polaris-gcp"
        password_secret_version = "${google_secret_manager_secret.ghcr_pull_token.id}/versions/latest"
      }
    }
  }

  depends_on = [
    google_project_service.required_apis["artifactregistry.googleapis.com"],
    google_secret_manager_secret.ghcr_pull_token
  ]
}

resource "google_artifact_registry_repository_iam_member" "cloudrun_ghcr_reader" {
  location   = google_artifact_registry_repository.ghcr_remote.location
  repository = google_artifact_registry_repository.ghcr_remote.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
  project    = var.project_id
}
